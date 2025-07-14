import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class GmapsBloc extends Bloc<GmapsEvent, GmapsState> {
  GmapsBloc() : super(const GmapsState()) {
    on<InitializeMap>(_onInitialize);
    on<QueryChanged>(_onQueryChanged, transformer: (events, mapper) {
      return events.debounceTime(const Duration(milliseconds: 500)).asyncExpand(mapper);
    });
    on<SuggestionSelected>(_onSuggestionSelected);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onInitialize(
      InitializeMap event, Emitter<GmapsState> emit) async {
    emit(state.copyWith(status: GmapsStatus.loading));
    try {
      final position = await _getCurrentLocationWithPermission();
      final latLng = LatLng(position.latitude, position.longitude);

      final mockMarkers = {
        Marker(
          markerId: const MarkerId('post_1'),
          position: LatLng(latLng.latitude + 0.01, latLng.longitude + 0.01),
          infoWindow: const InfoWindow(title: 'Nasi Gorek Enak'),
        ),
      };

      emit(state.copyWith(
        status: GmapsStatus.success,
        initialPosition: latLng,
        postMarkers: mockMarkers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GmapsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onQueryChanged(
      QueryChanged event, Emitter<GmapsState> emit) async {
    if (event.query.length < 3) {
      emit(state.copyWith(suggestions: []));
      return;
    }

    emit(state.copyWith(status: GmapsStatus.loading, clearError: true));
    try {
      final locations = await locationFromAddress(event.query);
      final suggestions = <Suggestion>[];

      for (var location in locations) {
        // Ambil nama jalan untuk deskripsi yang lebih baik
        final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          suggestions.add(Suggestion(
            description: "${p.name}, ${p.street}, ${p.subLocality}, ${p.locality}",
            position: LatLng(location.latitude, location.longitude),
          ));
        }
      }
      
      emit(state.copyWith(
        status: GmapsStatus.success,
        suggestions: suggestions,
      ));

    } catch (e) {
      emit(state.copyWith(
        status: GmapsStatus.failure,
        errorMessage: 'Gagal mencari lokasi: $e',
        suggestions: [],
      ));
    }
  }
  
  void _onSuggestionSelected(SuggestionSelected event, Emitter<GmapsState> emit) {
    final newMarker = Marker(
      markerId: const MarkerId('search_result'),
      position: event.suggestion.position,
      infoWindow: InfoWindow(title: event.suggestion.description.split(',').first),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    
    emit(state.copyWith(
      status: GmapsStatus.success,
      suggestions: [], // Kosongkan saran setelah dipilih
      searchResultMarker: newMarker,
      cameraPosition: CameraPosition(target: event.suggestion.position, zoom: 16),
    ));
  }

  void _onClearSearch(ClearSearch event, Emitter<GmapsState> emit) {
    emit(state.copyWith(
      suggestions: [],
      clearSearchResult: true,
    ));
  }

  Future<Position> _getCurrentLocationWithPermission() async {
    // ... (kode izin lokasi tidak berubah)
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Layanan lokasi belum aktif.';
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw 'Izin lokasi ditolak.';
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen.';
    }
    return Geolocator.getCurrentPosition();
  }
}
