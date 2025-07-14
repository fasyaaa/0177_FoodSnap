import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foody/data/models/request/feeds/feed_request_model.dart';
import 'package:foody/data/models/response/client/client_response_model.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ClientRepository clientRepository;
  final FeedRepository feedRepository;

  ProfileBloc({required this.clientRepository, required this.feedRepository})
    : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<DeleteFeed>(_onDeleteFeed);
    on<UpdateFeed>(_onUpdateFeed);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Mengambil data profil klien dan semua feed secara bersamaan
      final results = await Future.wait([
        clientRepository.getClientById(event.clientId),
        feedRepository.getAllFeeds(),
      ]);

      final clientResult = results[0] as Either<String, ClientResponseModel>;
      final feedsResult =
          results[1] as Either<String, List<FeedsResponseModel>>;

      // Memproses hasil dari kedua panggilan API
      clientResult.fold((error) => emit(ProfileFailure(error)), (client) {
        feedsResult.fold((error) => emit(ProfileFailure(error)), (allFeeds) {
          final clientFeeds =
              allFeeds
                  .where((feed) => feed.idClient == event.clientId)
                  .toList();

          emit(ProfileLoaded(client: client, feeds: clientFeeds));
        });
      });
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onDeleteFeed(
    DeleteFeed event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final result = await feedRepository.deleteFeed(event.feedId);
      result.fold((error) => emit(ProfileActionFailure(error)), (
        successMessage,
      ) {
        emit(ProfileActionSuccess(successMessage));
        add(LoadProfile(currentState.client.idClient!));
      });
    }
  }

  Future<void> _onUpdateFeed(
    UpdateFeed event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      final result = await feedRepository.updateFeed(
        event.feedId,
        event.updatedData,
      );
      result.fold((error) => emit(ProfileActionFailure(error)), (
        successMessage,
      ) {
        emit(ProfileActionSuccess(successMessage));
        add(LoadProfile(currentState.client.idClient!));
      });
    }
  }
}
