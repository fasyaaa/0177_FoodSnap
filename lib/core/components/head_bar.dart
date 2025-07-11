import 'package:flutter/material.dart';
import 'package:foody/core/constants/colors.dart';

class HeadBar extends StatelessWidget implements PreferredSizeWidget {
  const HeadBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 16,
      title: const Text(
        'Food Snap',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 26,
          fontFamily: 'Billabong',
          fontWeight: FontWeight.w400,
        ),
      ),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
