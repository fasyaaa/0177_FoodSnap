import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';

class FeedCardHeader extends StatelessWidget {
  final String username;
  const FeedCardHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/profile_empty.svg',
            width: 36,
            height: 36,
            colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(username, style: const TextStyle(color: AppColors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
class FeedCardImage extends StatelessWidget {
  final List<int>? imageBytes;
  const FeedCardImage({super.key, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null && imageBytes!.isNotEmpty;
    return AspectRatio(
      aspectRatio: 1,
      child: hasImage
          ? Image.memory(Uint8List.fromList(imageBytes!), fit: BoxFit.cover)
          : Container(
              color: AppColors.grey,
              child: const Center(
                child: Text('Image not available', style: TextStyle(color: Colors.white)),
              ),
            ),
    );
  }
}

class CommentBottomSheet extends StatelessWidget {
  final int feedId;
  const CommentBottomSheet({super.key, required this.feedId});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Comments untuk Feed ID: $feedId", style: const TextStyle(color: AppColors.white)));
  }
}


class FeedCardFooter extends StatelessWidget {
  final FeedsResponseModel feed;
  const FeedCardFooter({super.key, required this.feed});

  String _formatTime(DateTime uploadTime) {
    final duration = DateTime.now().difference(uploadTime);
    if (duration.inMinutes < 60) return '${duration.inMinutes}m';
    if (duration.inHours < 24) return '${duration.inHours}h';
    return '${duration.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final username = feed.clientName ?? 'Unknown';
    final caption = feed.description ?? '';
    final uploadDate = feed.createdAtFeeds ?? DateTime.now();
    const commentCount = 0; // Data dummy

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showCommentBottomSheet(context, feed.idFeeds!),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/comment_empty.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                ),
                const SizedBox(width: 4),
                Text('$commentCount', style: const TextStyle(color: AppColors.white, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              children: [
                TextSpan(text: username, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: '  '),
                TextSpan(text: caption),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(_formatTime(uploadDate), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showCommentBottomSheet(BuildContext context, int feedId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6,
        child: CommentBottomSheet(feedId: feedId),
      ),
    );
  }
}
