import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/components/custom_bottom_bar.dart';
import 'package:foody/core/components/head_bar.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/presentation/profile/client/bloc/profile_bloc.dart';
import 'package:foody/presentation/profile/client/home_profile/widgets/loaded_profile_body.dart';

class ProfileView extends StatelessWidget {
  final void Function(String) onTabSelected;
  final VoidCallback onLogout;

  const ProfileView({
    super.key,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProfileActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final String title =
              state is ProfileLoaded
                  ? state.client.username ?? 'Profile'
                  : 'Profile';

          Uint8List? profileImageBytes;
          if (state is ProfileLoaded &&
              state.client.imgProfile != null &&
              state.client.imgProfile!.isNotEmpty) {
            try {
              profileImageBytes = base64Decode(state.client.imgProfile!);
            } catch (e) {
              print("Error decoding base64 in ProfileView: $e");
              profileImageBytes = null;
            }
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: HeadBar(
              titleText: title,
              currentRoute: '/profile',
              onTabSelected: onTabSelected,
            ),
            body: _buildBody(context, state),
            bottomNavigationBar: CustomBottomBar(
              currentRoute: '/profile',
              onTabSelected: onTabSelected,
              profileImageBytes: profileImageBytes,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is ProfileLoaded) {
      return LoadedProfileBody(state: state, onLogout: onLogout);
    }
    if (state is ProfileFailure) {
      return Center(
        child: Text(state.error, style: const TextStyle(color: Colors.red)),
      );
    }

    if (state is ProfileActionFailure) {
      final lastState = context.read<ProfileBloc>().state;
      if (lastState is ProfileLoaded) {
        return LoadedProfileBody(state: lastState, onLogout: onLogout);
      }
    }
    return const SizedBox.shrink();
  }
}
