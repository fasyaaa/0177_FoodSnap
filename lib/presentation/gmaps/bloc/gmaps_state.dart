part of 'gmaps_bloc.dart';

sealed class GmapsState extends Equatable {
  const GmapsState();
  
  @override
  List<Object> get props => [];
}

final class GmapsInitial extends GmapsState {}
