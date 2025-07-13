import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/presentation/profile/client/bloc/profile_bloc.dart';
import 'package:foody/presentation/profile/client/edit_profile/edit_profile_page.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onLogout;
  const ActionButtons({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final state = context.read<ProfileBloc>().state;
              if (state is ProfileLoaded) {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProfilePage(clientId: state.clientId),
                  ),
                );

                if (result == true && context.mounted) {
                  context.read<ProfileBloc>().add(LoadProfile(state.clientId));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile data is not loaded yet.'),
                  ),
                );
              }
            },
            style: _buttonStyle(),
            child: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: onLogout,
            style: _buttonStyle(),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppColors.background,
      side: const BorderSide(color: AppColors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
