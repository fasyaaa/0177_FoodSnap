part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ClientResponseModel client;
  final List<FeedsResponseModel> feeds;

  const ProfileLoaded({required this.client, required this.feeds});

  @override
  List<Object?> get props => [client, feeds];
}

class ProfileFailure extends ProfileState {
  final String error;
  const ProfileFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class ProfileActionSuccess extends ProfileState {
  final String message;
  const ProfileActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileActionFailure extends ProfileState {
  final String error;
  const ProfileActionFailure(this.error);
  @override
  List<Object?> get props => [error];
}
