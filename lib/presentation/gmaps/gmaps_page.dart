import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/constants/constants.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_bloc.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';
import 'package:foody/presentation/gmaps/widgets/gmaps_search_box.dart';
import 'package:foody/presentation/gmaps/widgets/location_detail_popup.dart';
import 'package:foody/presentation/gmaps/widgets/search_result_list_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GmapsPage extends StatelessWidget {
  const GmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GmapView();
  }
}

/// Widget utama yang menampilkan peta dan semua elemen UI terkait.
class GmapView extends StatefulWidget {
  const GmapView({super.key});

  @override
  State<GmapView> createState() => _GmapViewState();
}

class _GmapViewState extends State<GmapView> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Menampilkan pop-up (bottom sheet) dengan detail lokasi.
  void _showLocationDetails(BuildContext context, Suggestion suggestion) {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background.withOpacity(0.95),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => LocationDetailPopup(
            place: BookmarkPlace(
              name: suggestion.description.split(',').first,
              address: suggestion.description,
              latitude: suggestion.position.latitude,
              longitude: suggestion.position.longitude,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GmapsBloc, GmapsState>(
        listener: (context, state) async {
          // Menampilkan pesan eror
          if (state.status == GmapsStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
          }

          // Menampilkan daftar hasil pencarian jika ada lebih dari satu
          if (state.searchResults != null && state.searchResults!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: BlocProvider.of<GmapsBloc>(context),
                      child: SearchResultListPage(
                        results: state.searchResults!,
                      ),
                    ),
              ),
            );
            // Bersihkan state agar tidak ter-trigger lagi saat kembali
            context.read<GmapsBloc>().add(ClearSearch());
          }

          // Animasikan kamera dan tampilkan pop-up untuk lokasi yang terpilih
          if (state.cameraPosition != null) {
            final controller = await _mapController.future;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(state.cameraPosition!),
            );
            if (state.selectedSuggestion != null) {
              _showLocationDetails(context, state.selectedSuggestion!);
              context.read<GmapsBloc>().add(ClearSelectedSuggestion());
            }
          }
        },
        builder: (context, state) {
          final allMarkers = Set<Marker>.from(state.postMarkers);
          if (state.searchResultMarker != null) {
            allMarkers.add(state.searchResultMarker!);
          }

          if (state.status == GmapsStatus.initial ||
              (state.status == GmapsStatus.loading &&
                  state.initialPosition == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      state.initialPosition ??
                      const LatLng(-6.200000, 106.816666),
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: allMarkers,
                onTap: (location) {
                  context.read<GmapsBloc>().add(MapTapped(location));
                },
              ),
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: GmapsSearchBox(
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.read<GmapsBloc>().add(SearchSubmitted(value));
                    }
                  },
                  onClear: () {
                    _searchController.clear();
                    context.read<GmapsBloc>().add(ClearSearch());
                  },
                ),
              ),
              Positioned(
                bottom: 100,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoomIn',
                      onPressed: () async {
                        final controller = await _mapController.future;
                        controller.animateCamera(CameraUpdate.zoomIn());
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoomOut',
                      onPressed: () async {
                        final controller = await _mapController.future;
                        controller.animateCamera(CameraUpdate.zoomOut());
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.remove, color: Colors.black),
                    ),
                  ],
                ),
              ),
              if (state.status == GmapsStatus.loading &&
                  state.initialPosition != null)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur Tambah Post belum diimplementasikan.'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
