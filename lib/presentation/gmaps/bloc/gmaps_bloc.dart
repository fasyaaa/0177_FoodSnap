import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GmapsBloc extends Bloc<GmapsEvent, GmapsState> {
  GmapsBloc() : super(const GmapsState()) {
    on<InitializeMap>(_onInitialize);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<PlaceSelected>(_onPlaceSelected);
    on<MarkerTapped>(_onMarkerTapped);
    on<MapTapped>(_onMapTapped);
    on<ShowSavedPlace>(_onShowSavedPlace);
    on<ClearSearch>(_onClearSearch);
    on<ClearSelectedSuggestion>(_onClearSelectedSuggestion);
  }

  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<GmapsState> emit,
  ) async {
    if (event.query.isEmpty) return;

    emit(
      state.copyWith(
        status: GmapsStatus.loading,
        clearError: true,
        clearSearchResult: true,
      ),
    );
    try {
      final locations = await locationFromAddress(event.query);

      if (locations.isEmpty) {
        throw 'Lokasi tidak ditemukan';
      }

      // ✅ LOGIKA BARU UNTUK MENANGANI HASIL PENCARIAN
      if (locations.length == 1) {
        // Jika hasil hanya 1, langsung tampilkan di peta
        final placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );
        final suggestion = _formatPlacemark(
          placemarks.firstOrNull,
          event.query,
          locations.first,
        );
        add(PlaceSelected(suggestion));
      } else {
        // Jika hasil lebih dari 1, tampilkan sebagai daftar pilihan
        List<Suggestion> results = [];
        for (var location in locations) {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          results.add(
            _formatPlacemark(placemarks.firstOrNull, event.query, location),
          );
        }
        emit(
          state.copyWith(status: GmapsStatus.success, searchResults: results),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: GmapsStatus.failure,
          errorMessage: 'Gagal mencari lokasi: $e',
        ),
      );
    }
  }

  // Helper untuk memformat alamat agar konsisten
  Suggestion _formatPlacemark(Placemark? p, String query, Location location) {
    if (p == null) {
      return Suggestion(
        description: query,
        position: LatLng(location.latitude, location.longitude),
      );
    }
    String placeName = p.name ?? '';
    String street = p.street ?? '';
    if (placeName.startsWith(street) && street.isNotEmpty) {
      placeName = street;
    } else if (placeName.isEmpty) {
      placeName = street.isNotEmpty ? street : (p.subLocality ?? '');
    }
    final fullAddress = [
      placeName,
      p.subLocality,
      p.locality,
      p.country,
    ].where((s) => s != null && s.isNotEmpty).join(', ');
    return Suggestion(
      description: fullAddress,
      position: LatLng(location.latitude, location.longitude),
    );
  }

  /// Menginisialisasi peta dengan lokasi pengguna saat ini.
  Future<void> _onInitialize(
    InitializeMap event,
    Emitter<GmapsState> emit,
  ) async {
    emit(state.copyWith(status: GmapsStatus.loading));
    try {
      final position = await _getCurrentLocationWithPermission();
      final latLng = LatLng(position.latitude, position.longitude);

      final mockDataPosition = LatLng(
        latLng.latitude + 0.01,
        latLng.longitude + 0.01,
      );
      final mockDataDescription = 'Nasi Goreng Enak, Dekat Sini';

      final mockMarkers = {
        Marker(
          markerId: const MarkerId('post_1'),
          position: mockDataPosition,
          infoWindow: const InfoWindow(title: 'Nasi Goreng Enak'),
          onTap: () {
            final suggestion = Suggestion(
              description: mockDataDescription,
              position: mockDataPosition,
            );
            add(MarkerTapped(suggestion));
          },
        ),
      };

      emit(
        state.copyWith(
          status: GmapsStatus.success,
          initialPosition: latLng,
          postMarkers: mockMarkers,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: GmapsStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  /// Menangani event saat marker yang ada di peta di-klik untuk menampilkan pop-up.
  void _onMarkerTapped(MarkerTapped event, Emitter<GmapsState> emit) {
    emit(state.copyWith(selectedSuggestion: event.suggestion));
  }

  /// Menangani event dari halaman bookmark untuk menampilkan lokasi yang sudah disimpan.
  void _onShowSavedPlace(ShowSavedPlace event, Emitter<GmapsState> emit) {
    final suggestion = Suggestion(
      description: event.place.address,
      position: LatLng(event.place.latitude, event.place.longitude),
    );
    // Menjalankan alur yang sama seperti memilih tempat untuk efisiensi
    add(PlaceSelected(suggestion));
  }

  /// Menangani event saat pengguna mengetuk langsung di peta.
  Future<void> _onMapTapped(MapTapped event, Emitter<GmapsState> emit) async {
    emit(
      state.copyWith(
        status: GmapsStatus.loading,
        clearError: true,
        clearSearchResult: true,
      ),
    );
    try {
      final placemarks = await placemarkFromCoordinates(
        event.location.latitude,
        event.location.longitude,
      );
      final p = placemarks.isNotEmpty ? placemarks.first : null;

      String placeName = p?.thoroughfare ?? p?.subLocality ?? 'Lokasi Dipilih';
      final fullAddress = [
        placeName,
        p?.locality,
        p?.subAdministrativeArea,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      final suggestion = Suggestion(
        description: fullAddress,
        position: event.location,
      );
      add(PlaceSelected(suggestion));
    } catch (e) {
      emit(
        state.copyWith(
          status: GmapsStatus.failure,
          errorMessage: 'Gagal mendapatkan detail lokasi: $e',
        ),
      );
    }
  }

  /// Handler pusat untuk menampilkan lokasi yang dipilih di peta.
  void _onPlaceSelected(PlaceSelected event, Emitter<GmapsState> emit) {
    final newMarker = Marker(
      markerId: const MarkerId('search_result'),
      position: event.suggestion.position,
      infoWindow: InfoWindow(
        title: event.suggestion.description.split(',').first,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      onTap: () {
        add(MarkerTapped(event.suggestion));
      },
    );

    emit(
      state.copyWith(
        status: GmapsStatus.success,
        searchResultMarker: newMarker,
        cameraPosition: CameraPosition(
          target: event.suggestion.position,
          zoom: 16,
        ),
        selectedSuggestion: event.suggestion, // Ini akan memicu pop-up di UI
      ),
    );
  }

  /// Membersihkan hasil pencarian.
  void _onClearSearch(ClearSearch event, Emitter<GmapsState> emit) {
    emit(state.copyWith(suggestions: [], clearSearchResult: true));
  }

  /// Membersihkan suggestion pemicu pop-up setelah ditampilkan.
  void _onClearSelectedSuggestion(
    ClearSelectedSuggestion event,
    Emitter<GmapsState> emit,
  ) {
    emit(state.copyWith(clearSelectedSuggestion: true));
  }

  /// Helper untuk memeriksa dan meminta izin lokasi.
  Future<Position> _getCurrentLocationWithPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi belum aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Izin lokasi ditolak permanen, kami tidak dapat meminta izin.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
