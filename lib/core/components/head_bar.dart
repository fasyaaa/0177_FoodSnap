import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/constants/colors.dart';

class HeadBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final void Function(String) onTabSelected;

  /// Teks yang akan ditampilkan sebagai judul. Default: 'Food Snap'
  final String titleText;

  const HeadBar({
    super.key,
    required this.currentRoute,
    required this.onTabSelected,
    this.titleText = 'Food Snap',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontFamily: 'Billabong',
              fontWeight: FontWeight.w400,
            ),
          ),
          _buildIconButton(
            isActive: currentRoute == '/addPost',
            activeAsset: 'assets/icons/plus_fill.svg',
            inactiveAsset: 'assets/icons/plus_empty.svg',
            onTap: () => onTabSelected('/addPost'),
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
      child: SvgPicture.asset(
        isActive ? activeAsset : inactiveAsset,
        height: 24,
        width: 24,
        color: AppColors.white,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
