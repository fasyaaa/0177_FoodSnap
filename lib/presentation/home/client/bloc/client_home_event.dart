part of 'client_home_bloc.dart';

sealed class ClientHomeEvent extends Equatable {
  const ClientHomeEvent();

  @override
  List<Object> get props => [];
}

class LoadFeeds extends ClientHomeEvent {}

class RefreshFeeds extends ClientHomeEvent {}

/// Event untuk menghapus sebuah feed berdasarkan ID-nya.
class DeleteFeed extends ClientHomeEvent {
  final int feedId;
  const DeleteFeed(this.feedId);

  @override
  List<Object> get props => [feedId];
}

class ShowComments extends ClientHomeEvent {
  final int feedId;
  final List<CommentResponseModel> comments;

  const ShowComments(this.feedId, this.comments);

  @override
  List<Object> get props => [feedId, comments];
}

class HideComments extends ClientHomeEvent {}

class PostComment extends ClientHomeEvent {
  final int feedId;
  final String content;
  final int? parentCommentId;

  const PostComment({
    required this.feedId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object> get props => [feedId, content, parentCommentId ?? 0];
}
