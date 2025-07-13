import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/components/custom_bottom_bar.dart';
import 'package:foody/core/components/head_bar.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/presentation/home/client/bloc/client_home_bloc.dart';
import 'package:foody/presentation/home/client/widgets/feed_list_view.dart';

class HomeView extends StatelessWidget {
  final void Function(String) onTabSelected;
  final Future<void> Function() onRefresh;
  final int? loggedInClientId;
  final Uint8List? profileImageBytes;

  const HomeView({
    super.key,
    required this.onTabSelected,
    required this.onRefresh,
    this.loggedInClientId,
    this.profileImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    // Rute saat ini diatur secara statis karena ini adalah halaman home.
    const currentRoute = '/home';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HeadBar(
        currentRoute: currentRoute,
        onTabSelected: onTabSelected,
      ),
      body: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) {
          if (state.isLoading && state.feeds.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.feeds.isEmpty) {
            return const Center(
              child: Text('No Posts Available', style: TextStyle(color: AppColors.white)),
            );
          }

          return FeedListView(
            feeds: state.feeds,
            onRefresh: onRefresh,
            loggedInClientId: loggedInClientId,
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: currentRoute,
        onTabSelected: onTabSelected,
        profileImageBytes: profileImageBytes,
      ),
    );
  }
}
