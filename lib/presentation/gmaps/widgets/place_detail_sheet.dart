import 'package:flutter/material.dart';
import 'package:foody/core/constants/constants.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';

class PlaceDetailSheet extends StatelessWidget {
  final BookmarkPlace place;

  const PlaceDetailSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            place.address,
            style: const TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
        
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(context, Icons.directions, 'Directions'),
              _buildActionButton(context, Icons.bookmark_border, 'Save'),
              _buildActionButton(context, Icons.share, 'Share'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.primary)),
      ],
    );
  }
}
