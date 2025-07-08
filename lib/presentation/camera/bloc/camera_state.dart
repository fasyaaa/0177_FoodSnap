part of 'camera_bloc.dart';

sealed class CameraState extends Equatable {
  const CameraState();
  
  @override
  List<Object> get props => [];
}

final class CameraInitial extends CameraState {}
