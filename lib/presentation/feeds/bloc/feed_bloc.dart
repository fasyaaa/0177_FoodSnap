import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/data/models/request/feeds/feed_request_model.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/data/repository/feed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository feedRepository;

  FeedBloc(this.feedRepository) : super(const FeedState()) {
    on<InitializeFeed>(_onInitializeFeed);
    on<ImageSelected>(_onImageSelected);
    on<LocationSelected>(_onLocationSelected);
    on<PostSubmitted>(_onPostSubmitted);
  }

  void _onInitializeFeed(InitializeFeed event, Emitter<FeedState> emit) {
    if (event.feed != null) {
      final feed = event.feed!;
      BookmarkPlace? location;
      if (feed.locationName != null &&
          feed.latitude != null &&
          feed.longitude != null) {
        location = BookmarkPlace(
          name: feed.locationName!,
          address: feed.locationName!,
          latitude: feed.latitude!,
          longitude: feed.longitude!,
        );
      }
      emit(
        state.copyWith(
          feedToEdit: feed,
          existingImageBytes:
              feed.imgFeeds != null ? Uint8List.fromList(feed.imgFeeds!) : null,
          selectedLocation: location,
        ),
      );
    }
    else if (event.location != null) {
      emit(state.copyWith(selectedLocation: event.location));
    }
  }

  void _onImageSelected(ImageSelected event, Emitter<FeedState> emit) {
    emit(state.copyWith(selectedImage: event.image));
  }

  void _onLocationSelected(LocationSelected event, Emitter<FeedState> emit) {
    emit(state.copyWith(selectedLocation: event.location));
  }

  Future<void> _onPostSubmitted(
    PostSubmitted event,
    Emitter<FeedState> emit,
  ) async {
    // Cek apakah ini mode edit
    final bool isEditMode = state.feedToEdit != null;

    // Validasi: Gambar wajib ada saat membuat post baru
    if (!isEditMode && state.selectedImage == null) {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: 'Please select an image.',
        ),
      );
      emit(state.copyWith(status: FormStatus.initial)); // Reset status
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting));

    final requestModel = FeedsRequestModel(
      title: event.title,
      description: event.description,
      locationName: state.selectedLocation?.name,
      latitude: state.selectedLocation?.latitude,
      longitude: state.selectedLocation?.longitude,
    );

    if (isEditMode) {
      // LOGIKA UPDATE
      final result = await feedRepository.updateFeed(
        state.feedToEdit!.idFeeds!,
        requestModel,
        imagePath: state.selectedImage?.path,
      );
      result.fold(
        (error) => emit(
          state.copyWith(status: FormStatus.failure, errorMessage: error),
        ),
        (successMessage) => emit(state.copyWith(status: FormStatus.success)),
      );
    } else {
      // LOGIKA CREATE
      final result = await feedRepository.createFeed(
        requestModel,
        imagePath: state.selectedImage!.path,
      );
      result.fold(
        (error) => emit(
          state.copyWith(status: FormStatus.failure, errorMessage: error),
        ),
        (feed) => emit(state.copyWith(status: FormStatus.success)),
      );
    }
  }
}
