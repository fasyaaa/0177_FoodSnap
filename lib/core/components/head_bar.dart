import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/constants/colors.dart';

class HeadBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final void Function(String) onTabSelected;
  final String titleText;

  final Widget? leading;

  const HeadBar({
    super.key,
    required this.currentRoute,
    required this.onTabSelected,
    this.titleText = 'Food Snap',
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      shape: const Border(
        bottom: BorderSide(color: Colors.white12, width: 1.0),
      ),
      leading: leading,
      titleSpacing: leading == null ? 16 : 0,
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
            isActive: currentRoute == '/addFeed',
            activeAsset: 'assets/icons/plus_fill.svg',
            inactiveAsset: 'assets/icons/plus_empty.svg',
            onTap: () => onTabSelected('/addFeed'),
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
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
