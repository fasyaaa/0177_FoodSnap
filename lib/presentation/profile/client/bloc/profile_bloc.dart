import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ClientRepository clientRepository;
  final FeedRepository feedRepository;

  ProfileBloc({
    required this.clientRepository,
    required this.feedRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      final clientResult = await clientRepository.getClientById(event.clientId);
      final feedResult = await feedRepository.getAllFeeds();

      return clientResult.fold(
        (error) => emit(ProfileError(error)),
        (client) {
          // Filter feeds by current client ID
          final userFeeds = feedResult.fold(
            (error) => <FeedsResponseModel>[],
            (feeds) => feeds.where((f) => f.idClient == client.idClient).toList(),
          );

          emit(ProfileLoaded(
            clientId: event.clientId,
            username: client.username,
            name: client.name,
            imgProfile: client.imgProfile,
            feeds: userFeeds,
          ));
        },
      );
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }
}
