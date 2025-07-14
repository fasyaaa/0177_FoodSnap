part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

/// Event untuk memuat data profil dan feed milik klien
class LoadProfile extends ProfileEvent {
  final int clientId;
  const LoadProfile(this.clientId);

  @override
  List<Object> get props => [clientId];
}

class DeleteFeed extends ProfileEvent {
  final int feedId;
  const DeleteFeed(this.feedId);

  @override
  List<Object> get props => [feedId];
}

class UpdateFeed extends ProfileEvent {
  final int feedId;
  final FeedsRequestModel updatedData;
  const UpdateFeed(this.feedId, this.updatedData);

  @override
  List<Object> get props => [feedId, updatedData];
}
