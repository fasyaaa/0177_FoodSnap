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
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final String title =
            state is ProfileLoaded ? state.username ?? 'Profile' : 'Profile';

        // DIUBAH: Siapkan data gambar untuk CustomBottomBar
        Uint8List? profileImageBytes;
        if (state is ProfileLoaded &&
            state.imgProfile != null &&
            state.imgProfile!.isNotEmpty) {
          try {
            // Decode string base64 menjadi data gambar
            profileImageBytes = base64Decode(state.imgProfile!);
          } catch (e) {
            print("Error decoding base64 in ProfileView: $e");
            profileImageBytes = null; // Gagal decode, jangan tampilkan gambar
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
            // Berikan data gambar yang sudah di-decode ke bottom bar
            profileImageBytes: profileImageBytes,
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is ProfileLoaded) {
      return LoadedProfileBody(state: state, onLogout: onLogout);
    }
    if (state is ProfileError) {
      return Center(
          child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }
    return const SizedBox.shrink();
  }
}
