import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_bloc.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';
import 'package:foody/presentation/gmaps/widgets/gmaps_search_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GmapsPage extends StatelessWidget {
  const GmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sediakan GmapsBloc di sini agar bisa diakses oleh GmapView
    return BlocProvider(
      create: (_) => GmapsBloc()..add(InitializeMap()),
      child: const GmapView(),
    );
  }
}

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
    // Listener untuk mengirim event saat pengguna mengetik di search box
    _searchController.addListener(() {
      context.read<GmapsBloc>().add(QueryChanged(_searchController.text));
      // setState diperlukan untuk memperbarui UI, seperti menampilkan tombol 'clear'
      setState(() {});
    });
    // Listener untuk membersihkan saran saat fokus pada search box hilang
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        context.read<GmapsBloc>().add(ClearSearch());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hapus AppBar untuk UI yang lebih fleksibel menggunakan Stack
      body: BlocConsumer<GmapsBloc, GmapsState>(
        listener: (context, state) async {
          // Tampilkan SnackBar jika ada error dari BLoC
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
          // Animasikan kamera ke posisi baru jika ada
          if (state.cameraPosition != null) {
            final controller = await _mapController.future;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(state.cameraPosition!),
            );
          }
        },
        builder: (context, state) {
          // Gabungkan semua marker (postingan dan hasil pencarian) menjadi satu Set
          final allMarkers = Set<Marker>.from(state.postMarkers);
          if (state.searchResultMarker != null) {
            allMarkers.add(state.searchResultMarker!);
          }

          // Tampilkan loader saat peta sedang inisialisasi
          if (state.status == GmapsStatus.initial ||
              (state.status == GmapsStatus.loading &&
                  state.initialPosition == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          // Gunakan Stack untuk menumpuk peta, search box, dan daftar saran
          return Stack(
            children: [
              // Widget Peta sebagai lapisan paling bawah
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      state.initialPosition ??
                      const LatLng(
                        -6.200000,
                        106.816666,
                      ), // Fallback ke Jakarta
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled:
                    false, // Tombol lokasi default disembunyikan
                zoomControlsEnabled: false, // Sembunyikan tombol zoom
                markers: allMarkers, // Tampilkan semua marker
                onTap:
                    (_) =>
                        _searchFocusNode
                            .unfocus(), // Sembunyikan keyboard saat peta diketuk
              ),
              // Kolom unnuk menampung search box dan daftar saran
              Column(
                children: [
                  GmapsSearchBox(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<GmapsBloc>().add(QueryChanged(value));
                      }
                    },
                    onClear: () {
                      _searchController.clear();
                      context.read<GmapsBloc>().add(ClearSearch());
                    },
                  ),
                  // Daftar Saran Lokasi
                  if (state.suggestions.isNotEmpty && _searchFocusNode.hasFocus)
                    Expanded(
                      child: Container(
                        color: AppColors.background.withOpacity(0.95),
                        child: ListView.builder(
                          itemCount: state.suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = state.suggestions[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              title: Text(
                                suggestion.description,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                _searchFocusNode.unfocus();
                                _searchController.text =
                                    suggestion.description.split(',').first;
                                context.read<GmapsBloc>().add(
                                  SuggestionSelected(suggestion),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
              // Overlay loading saat sedang mencari
              if (state.status == GmapsStatus.loading &&
                  state.suggestions.isEmpty)
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
          // TODO: Implementasi navigasi ke halaman "Add Post"
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
