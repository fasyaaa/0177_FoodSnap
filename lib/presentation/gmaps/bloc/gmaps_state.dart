import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final Set<Marker> postMarkers;
  final Marker? searchResultMarker;
  final List<Suggestion> suggestions;
  final String? errorMessage;
  final CameraPosition? cameraPosition;
  final Suggestion? selectedSuggestion;
  final List<Suggestion>? searchResults;

  const GmapsState({
    this.status = GmapsStatus.initial,
    this.initialPosition,
    this.postMarkers = const {},
    this.searchResultMarker,
    this.suggestions = const [],
    this.errorMessage,
    this.cameraPosition,
    this.selectedSuggestion,
    this.searchResults,
  });

  GmapsState copyWith({
    GmapsStatus? status,
    LatLng? initialPosition,
    Set<Marker>? postMarkers,
    Marker? searchResultMarker,
    List<Suggestion>? suggestions,
    String? errorMessage,
    CameraPosition? cameraPosition,
    Suggestion? selectedSuggestion,
    List<Suggestion>? searchResults,
    bool clearError = false,
    bool clearSearchResult = false,
    bool clearSelectedSuggestion = false,
    bool clearSearchResults = false,
  }) {
    return GmapsState(
      status: status ?? this.status,
      initialPosition: initialPosition ?? this.initialPosition,
      postMarkers: postMarkers ?? this.postMarkers,
      searchResultMarker:
          clearSearchResult
              ? null
              : searchResultMarker ?? this.searchResultMarker,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      cameraPosition: cameraPosition,
      selectedSuggestion:
          clearSelectedSuggestion
              ? null
              : selectedSuggestion ?? this.selectedSuggestion,
      searchResults:
          clearSearchResults ? null : searchResults ?? this.searchResults,
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
    selectedSuggestion,
    searchResults,
  ];
}
