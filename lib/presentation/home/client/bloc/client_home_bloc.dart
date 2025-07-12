import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/data/models/response/comments/comment_response_model.dart';
import 'package:foody/data/models/request/comments/comment_request_model.dart';
import 'package:foody/data/repository/comment_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';

part 'client_home_event.dart';
part 'client_home_state.dart';

class ClientHomeBloc extends Bloc<ClientHomeEvent, ClientHomeState> {
  final FeedRepository _feedRepository;
  final CommentRepository _commentRepository;

  ClientHomeBloc(this._feedRepository, this._commentRepository)
    : super(ClientHomeInitial()) {
    on<LoadFeeds>(_onLoadFeeds);
    on<RefreshFeeds>(_onRefreshFeeds);
    on<ShowComments>(_onShowComments);
    on<HideComments>(_onHideComments);
    on<PostComment>(_onPostComment);
  }

  Future<void> _onLoadFeeds(
    LoadFeeds event,
    Emitter<ClientHomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _feedRepository.getAllFeeds();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure)),
      (feeds) => emit(state.copyWith(isLoading: false, feeds: feeds)),
    );
  }

  Future<void> _onRefreshFeeds(
    RefreshFeeds event,
    Emitter<ClientHomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await _feedRepository.getAllFeeds();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure)),
      (feeds) => emit(state.copyWith(isLoading: false, feeds: feeds)),
    );
  }

  Future<void> _onShowComments(
    ShowComments event,
    Emitter<ClientHomeState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, selectedFeedIdForComments: event.feedId),
    );
    final result = await _commentRepository.getCommentsByFeedId(event.feedId);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure)),
      (comments) => emit(
        state.copyWith(isLoading: false, commentsForSelectedFeed: comments),
      ),
    );
  }

  void _onHideComments(HideComments event, Emitter<ClientHomeState> emit) {
    emit(
      state.copyWith(
        selectedFeedIdForComments: null,
        commentsForSelectedFeed: [],
        errorMessage: null,
      ),
    );
  }

  Future<void> _onPostComment(
    PostComment event,
    Emitter<ClientHomeState> emit,
  ) async {
    emit(state.copyWith(isCommenting: true));
    final commentRequest = CommentRequestModel(
      idFeeds: event.feedId,
      content: event.content,
      idParent: event.parentCommentId,
    );
    final result = await _commentRepository.postComment(commentRequest);
    result.fold(
      (failure) =>
          emit(state.copyWith(isCommenting: false, errorMessage: failure)),
      (newComment) {
        add(ShowComments(event.feedId, state.commentsForSelectedFeed));
        emit(state.copyWith(isCommenting: false));
      },
    );
  }
}
