import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';

class ProfileFeedGrid extends StatelessWidget {
  final List<FeedsResponseModel> feeds;
  const ProfileFeedGrid({super.key, required this.feeds});

  @override
  Widget build(BuildContext context) {
    if (feeds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 60, color: AppColors.grey),
            SizedBox(height: 16),
            Text('No Posts Yet', style: TextStyle(color: AppColors.grey, fontSize: 18)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 2.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: feeds.length,
      itemBuilder: (context, index) {
        final feed = feeds[index];
        final hasImage = feed.imgFeeds != null && feed.imgFeeds!.isNotEmpty;
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on feed: ${feed.description}')));
          },
          child: Container(
            color: AppColors.lightSheet,
            child: hasImage
                ? Image.memory( 
                    Uint8List.fromList(feed.imgFeeds!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: AppColors.grey),
                  )
                : const Icon(Icons.image_not_supported, color: AppColors.grey),
          ),
        );
      },
    );
  }
}
