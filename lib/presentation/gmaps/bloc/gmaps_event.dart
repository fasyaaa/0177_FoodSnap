// presentation/gmaps/bloc/gmaps_event.dart

import 'package:equatable/equatable.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';

abstract class GmapsEvent extends Equatable {
  const GmapsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMap extends GmapsEvent {}

class SearchSubmitted extends GmapsEvent {
  final String query;
  const SearchSubmitted(this.query);

  @override
  List<Object?> get props => [query];
}

class PlaceSelected extends GmapsEvent {
  final Suggestion suggestion;
  const PlaceSelected(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class MarkerTapped extends GmapsEvent {
  final Suggestion suggestion;
  const MarkerTapped(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

/// Event baru saat pengguna mengetuk langsung di peta
class MapTapped extends GmapsEvent {
  final LatLng location;
  const MapTapped(this.location);

  @override
  List<Object?> get props => [location];
}

class ClearSelectedSuggestion extends GmapsEvent {}

class ClearSearch extends GmapsEvent {}

// Class menampilkan tempat yang disimpan
class ShowSavedPlace extends GmapsEvent {
  final BookmarkPlace place;
  const ShowSavedPlace(this.place);

  @override
  List<Object?> get props => [place];
}
