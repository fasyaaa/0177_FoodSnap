import 'package:bloc/bloc.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GmapsBloc extends Bloc<GmapsEvent, GmapsState> {
  GmapsBloc() : super(const GmapsState()) {
    on<InitializeMap>(_onInitialize);
    on<LocationPicked>(_onLocationPicked);
    on<ClearPickedLocation>(_onClearPicked);
  }

  Future<void> _onInitialize(
      InitializeMap event, Emitter<GmapsState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final pos = await _getPermission();
      final latLng = LatLng(pos.latitude, pos.longitude);

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = placemarks.first;
      final address = '${p.name}, ${p.locality}, ${p.country}';

      emit(state.copyWith(
        currentLocation: latLng,
        currentAddress: address,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(currentLocation: const LatLng(0, 0), isLoading: false));
    }
  }

  Future<void> _onLocationPicked(
      LocationPicked event, Emitter<GmapsState> emit) async {
    final placemarks = await placemarkFromCoordinates(
        event.latLng.latitude, event.latLng.longitude);
    final p = placemarks.first;

    final marker = Marker(
      markerId: const MarkerId('picked'),
      position: event.latLng,
      infoWindow: InfoWindow(
        title: p.name?.isNotEmpty == true ? p.name : 'Lokasi Dipilih',
        snippet: '${p.street}, ${p.locality}',
      ),
    );

    final address =
        '${p.name}, ${p.street}, ${p.locality}, ${p.country}, ${p.postalCode}';

    emit(state.copyWith(pickedMarker: marker, pickedAddress: address));
  }

  void _onClearPicked(ClearPickedLocation event, Emitter<GmapsState> emit) {
    emit(state.copyWith(pickedMarker: null, pickedAddress: null));
  }

  Future<Position> _getPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location service belum aktif';
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw 'Izin lokasi ditolak';
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw 'Izin Lokasi ditolak permanen';
    }

    return Geolocator.getCurrentPosition();
  }
}