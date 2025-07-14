import 'package:equatable/equatable.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';

abstract class GmapsEvent extends Equatable {
  const GmapsEvent();

  @override
  List<Object?> get props => [];
}

// Event untuk menginisialisasi peta dan memuat marker awal
class InitializeMap extends GmapsEvent {}

// Event saat pengguna mengetik di search bar
class QueryChanged extends GmapsEvent {
  final String query;
  const QueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// Event saat pengguna memilih salah satu saran lokasi
class SuggestionSelected extends GmapsEvent {
  final Suggestion suggestion;
  const SuggestionSelected(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

// Event untuk membersihkan hasil pencarian dan saran
class ClearSearch extends GmapsEvent {}
