part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final String? username;
  final String? name;
  final String? imgProfile;
  final List<FeedsResponseModel> feeds;

  const ProfileLoaded({
    required this.username,
    required this.name,
    required this.imgProfile,
    required this.feeds,
  });

  @override
  List<Object?> get props => [username, name, imgProfile, feeds];
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
