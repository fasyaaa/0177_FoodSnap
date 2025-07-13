import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/constants/colors.dart';

class CustomBottomBar extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onTabSelected;
  final Uint8List? profileImageBytes;

  const CustomBottomBar({
    super.key,
    required this.currentRoute,
    required this.onTabSelected,
    this.profileImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home
          _buildIconButton(
            isActive: currentRoute == '/home',
            activeAsset: 'assets/icons/home_fill.svg',
            inactiveAsset: 'assets/icons/home_empty.svg',
            onTap: () => onTabSelected('/home'),
          ),

          // Location
          _buildIconButton(
            isActive: currentRoute == '/location',
            activeAsset: 'assets/icons/location_fill.svg',
            inactiveAsset: 'assets/icons/location_empty.svg',
            onTap: () => onTabSelected('/location'),
          ),

          // Bookmark
          _buildIconButton(
            isActive: currentRoute == '/bookmark',
            activeAsset: 'assets/icons/bookmark_fill.svg',
            inactiveAsset: 'assets/icons/bookmark_empty.svg',
            onTap: () => onTabSelected('/bookmark'),
          ),

          // Profile with image
          GestureDetector(
            onTap: () => onTabSelected('/profile'),
            child:
                profileImageBytes != null
                    ? Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              currentRoute == '/profile'
                                  ? AppColors.white
                                  : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundImage: MemoryImage(profileImageBytes!),
                      ),
                    )
                    : SvgPicture.asset(
                      currentRoute == '/profile'
                          ? 'assets/icons/profile_fill.svg'
                          : 'assets/icons/profile_empty.svg',
                      width: 26,
                      height: 26,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required bool isActive,
    required String activeAsset,
    required String inactiveAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SvgPicture.asset(
        isActive ? activeAsset : inactiveAsset,
        width: 26,
        height: 26,
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
      ),
    );
  }
}
