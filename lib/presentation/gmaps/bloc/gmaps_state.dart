import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Model sederhana untuk menampung data saran lokasi
class Suggestion extends Equatable {
  final String description;
  final LatLng position;

  const Suggestion({required this.description, required this.position});

  @override
  List<Object?> get props => [description, position];
}

enum GmapsStatus { initial, loading, success, failure }

class GmapsState extends Equatable {
  final GmapsStatus status;
  final LatLng? initialPosition;
  final Set<Marker> postMarkers; // Marker untuk postingan yang sudah ada
  final Marker? searchResultMarker; // Marker untuk hasil pencarian
  final List<Suggestion> suggestions;
  final String? errorMessage;
  final CameraPosition? cameraPosition;

  const GmapsState({
    this.status = GmapsStatus.initial,
    this.initialPosition,
    this.postMarkers = const {},
    this.searchResultMarker,
    this.suggestions = const [],
    this.errorMessage,
    this.cameraPosition,
  });

  GmapsState copyWith({
    GmapsStatus? status,
    LatLng? initialPosition,
    Set<Marker>? postMarkers,
    Marker? searchResultMarker,
    List<Suggestion>? suggestions,
    String? errorMessage,
    CameraPosition? cameraPosition,
    bool clearError = false,
    bool clearSearchResult = false,
  }) {
    return GmapsState(
      status: status ?? this.status,
      initialPosition: initialPosition ?? this.initialPosition,
      postMarkers: postMarkers ?? this.postMarkers,
      searchResultMarker: clearSearchResult ? null : searchResultMarker ?? this.searchResultMarker,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      cameraPosition: cameraPosition,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialPosition,
        postMarkers,
        searchResultMarker,
        suggestions,
        errorMessage,
        cameraPosition,
      ];
}
