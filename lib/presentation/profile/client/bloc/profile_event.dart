part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final int clientId;

  const LoadProfile(this.clientId);

  @override
  List<Object?> get props => [clientId];
}
