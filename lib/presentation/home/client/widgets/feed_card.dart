import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/presentation/feeds/feed_page.dart';
import 'package:foody/presentation/home/client/bloc/client_home_bloc.dart';
import 'package:foody/presentation/home/client/widgets/feed_card_header.dart';

class FeedCard extends StatelessWidget {
  final FeedsResponseModel feed;
  final int? loggedInClientId;

  const FeedCard({super.key, required this.feed, this.loggedInClientId});

  @override
  Widget build(BuildContext context) {
    final bool isOwner = feed.idClient == loggedInClientId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedCardHeader(
          username: feed.username ?? 'Unknown',
          profileImageBase64: feed.imgProfile,
          isOwner: isOwner,
          onDelete: () {
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    backgroundColor: const Color(0xff2d2d2d),
                    title: const Text(
                      'Delete Post',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this post?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (feed.idFeeds != null) {
                            context.read<ClientHomeBloc>().add(
                              DeleteFeed(feed.idFeeds!),
                            );
                          }
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            );
          },
          onEdit: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => FeedPage(feedToEdit: feed),
              ),
            );

            if (result == true && context.mounted) {
              context.read<ClientHomeBloc>().add(RefreshFeeds());
            }
          },
          onTap: () {
            if (feed.idClient != null) {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: feed.idClient,
              );
            }
          },
        ),
        FeedCardImage(imageBytes: feed.imgFeeds),
        FeedCardFooter(feed: feed),
        const SizedBox(height: 8),
      ],
    );
  }
}
