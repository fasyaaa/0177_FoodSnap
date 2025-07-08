import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GmapsState extends Equatable {
  final LatLng? currentLocation;
  final String? currentAddress;
  final Marker? pickedMarker;
  final String? pickedAddress;
  final bool isLoading;

  const GmapsState({
    this.currentLocation,
    this.currentAddress,
    this.pickedMarker,
    this.pickedAddress,
    this.isLoading = true,
  });
  GmapsState copyWith({
    LatLng? currentLocation,
    String? currentAddress,
    Marker? pickedMarker,
    String? pickedAddress,
    bool? isLoading,
  }) {
    return GmapsState(
      currentLocation: currentLocation ?? this.currentLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      pickedMarker: pickedMarker,
      pickedAddress: pickedAddress,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    currentLocation,
    currentAddress,
    pickedMarker,
    pickedAddress,
    isLoading,
  ];
}
