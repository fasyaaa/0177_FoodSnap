import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'gmaps_event.dart';
import 'gmaps_state.dart';
class GmapsPage extends StatelessWidget {
  const GmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
  final Completer<GoogleMapController> _ctrl = Completer();

  void _confirmSelection(String pickedAddress) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Alamat'),
        content: Text(pickedAddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, pickedAddress);
            },
            child: const Text('pilih'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GmapsBloc, GmapsState>(
      builder: (context, state) {
        if (state.isLoading || state.currentLocation == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Pilih Alamat")),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: state.currentLocation!,
                  zoom: 10,
                ),
                onMapCreated: (controller) => _ctrl.complete(controller),
                myLocationEnabled: true,
                onTap: (latLng) =>
                    context.read<GmapsBloc>().add(LocationPicked(latLng)),
                markers: state.pickedMarker != null
                    ? {state.pickedMarker!}
                    : {},
              ),
              Positioned(
                top: 25,
                left: 50,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(state.currentAddress ?? 'Kosong'),
                ),
              ),
              if (state.pickedAddress != null)
                Positioned(
                  bottom: 120,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        state.pickedAddress!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.pickedAddress != null)
                FloatingActionButton.extended(
                  onPressed: () =>
                      _confirmSelection(state.pickedAddress!),
                  label: const Text('Pilih alamat'),
                ),
              const SizedBox(height: 8),
              if (state.pickedAddress != null)
                FloatingActionButton.extended(
                  onPressed: () => context.read<GmapsBloc>().add(ClearPickedLocation()),
                  label: const Text('Hapus alamat'),
                ),
            ],
          ),
        );
      },
    );
  }
}