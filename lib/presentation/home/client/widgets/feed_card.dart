import 'package:flutter/material.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/presentation/home/client/widgets/feed_card_header.dart';

class FeedCard extends StatelessWidget {
  final FeedsResponseModel feed;

  const FeedCard({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedCardHeader(username: feed.clientName ?? 'Unknown'),
        FeedCardImage(imageBytes: feed.imgFeeds),
        FeedCardFooter(feed: feed),
        const SizedBox(height: 8),
      ],
    );
  }
}
