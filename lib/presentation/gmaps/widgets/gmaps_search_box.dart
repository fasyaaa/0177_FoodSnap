import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/constants/colors.dart';

class GmapsSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode; // <-- Parameter ditambahkan di sini
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;

  const GmapsSearchBox({
    super.key,
    required this.controller,
    this.focusNode, // <-- Parameter ditambahkan di sini
    required this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode, // <-- Parameter digunakan di sini
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search here',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/icons/map_gmaps.svg',
              height: 24,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
