part of 'client_home_bloc.dart';

sealed class ClientHomeState extends Equatable {
  const ClientHomeState();
  
  @override
  List<Object> get props => [];
}

final class ClientHomeInitial extends ClientHomeState {}
