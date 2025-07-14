import 'package:flutter/material.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/presentation/profile/client/bloc/profile_bloc.dart';
import 'package:foody/presentation/profile/client/home_profile/widgets/profile_picture.dart';
import 'package:foody/presentation/profile/client/home_profile/widgets/action_button.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileLoaded state;
  final VoidCallback onLogout;

  const ProfileHeader({super.key, required this.state, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfilePicture(imageUrl: state.client.imgProfile),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.client.name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${state.client.username ?? ''}',
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ActionButtons(onLogout: onLogout, clientId: state.client.idClient!),
        ],
      ),
    );
  }
}
