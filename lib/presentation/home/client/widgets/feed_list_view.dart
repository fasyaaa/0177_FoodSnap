import 'package:flutter/material.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/presentation/home/client/widgets/feed_card.dart';

class FeedListView extends StatelessWidget {
  final List<FeedsResponseModel> feeds;
  final Future<void> Function() onRefresh;
  final int? loggedInClientId;

  const FeedListView({
    super.key,
    required this.feeds,
    required this.onRefresh,
    this.loggedInClientId,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: feeds.length,
        itemBuilder: (context, index) {
          final feed = feeds[index];
          return FeedCard(feed: feed, loggedInClientId: loggedInClientId);
        },
      ),
    );
  }
}
