import 'package:flutter/material.dart';
import 'package:foody/core/constants/colors.dart';
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
        // Tambah 1 untuk tombol "View My Profile"
        itemCount: feeds.length + 1,
        itemBuilder: (context, index) {
          // Item pertama adalah tombol
          if (index == 0) {
            return _buildViewProfileButton(context);
          }
          // Item lainnya adalah FeedCard
          final feed = feeds[index - 1];
          return FeedCard(feed: feed);
        },
      ),
    );
  }

  Widget _buildViewProfileButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          if (loggedInClientId != null) {
            Navigator.pushNamed(context, '/profile', arguments: loggedInClientId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Client ID not found. Please login again.")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'View My Profile',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
