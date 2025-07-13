import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl; 
  const ProfilePicture({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 45,
      backgroundColor: Colors.grey[800],
      child: ClipOval(
        child:
            hasImage
                ? Image.memory(
                  base64Decode(
                    imageUrl!,
                  ),
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                  gaplessPlayback:
                      true, 
                  errorBuilder: (context, error, stackTrace) {
                    print("Error displaying base64 image: $error");
                    return _defaultIcon();
                  },
                )
                : _defaultIcon(),
      ),
    );
  }

  Widget _defaultIcon() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SvgPicture.asset(
        'assets/icons/profile_fill.svg',
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
