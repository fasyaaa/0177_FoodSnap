part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();
  @override
  List<Object?> get props => [];
}

class InitializeFeed extends FeedEvent {
  final FeedsResponseModel? feed;
  final BookmarkPlace? location;
  const InitializeFeed({this.feed, this.location});

  @override
  List<Object?> get props => [feed, location];
}

class ImageSelected extends FeedEvent {
  final File image;
  const ImageSelected(this.image);
  @override
  List<Object> get props => [image];
}

class LocationSelected extends FeedEvent {
  final BookmarkPlace location;
  const LocationSelected(this.location);
  @override
  List<Object> get props => [location];
}

class PostSubmitted extends FeedEvent {
  final String title;
  final String description;
  const PostSubmitted({required this.title, required this.description});
}
