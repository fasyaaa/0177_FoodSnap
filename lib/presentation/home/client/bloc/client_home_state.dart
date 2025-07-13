part of 'client_home_bloc.dart';

class ClientHomeState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<FeedsResponseModel> feeds;
  final int? selectedFeedIdForComments;
  final List<CommentResponseModel> commentsForSelectedFeed;
  final bool isCommenting;
  final int? clientId;

  const ClientHomeState({
    this.isLoading = false,
    this.errorMessage,
    this.feeds = const [],
    this.selectedFeedIdForComments,
    this.commentsForSelectedFeed = const [],
    this.isCommenting = false,
    this.clientId,
  });

  ClientHomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<FeedsResponseModel>? feeds,
    int? selectedFeedIdForComments,
    List<CommentResponseModel>? commentsForSelectedFeed,
    bool? isCommenting,
    int? clientId,
  }) {
    return ClientHomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      feeds: feeds ?? this.feeds,
      selectedFeedIdForComments: selectedFeedIdForComments,
      commentsForSelectedFeed: commentsForSelectedFeed ?? this.commentsForSelectedFeed,
      isCommenting: isCommenting ?? this.isCommenting,
      clientId: clientId ?? this.clientId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        feeds,
        selectedFeedIdForComments,
        commentsForSelectedFeed,
        isCommenting,
        clientId,
      ];
}

final class ClientHomeInitial extends ClientHomeState {}
