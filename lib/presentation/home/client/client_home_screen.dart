import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/components/custom_bottom_bar.dart';
import 'package:foody/core/components/head_bar.dart';
import 'package:foody/presentation/home/client/bloc/client_home_bloc.dart';
import 'package:intl/intl.dart';
import 'package:foody/core/constants/colors.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  String _formatTime(DateTime uploadTime) {
    final duration = DateTime.now().difference(uploadTime);

    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HeadBar(
        currentRoute: '/home',
        onTabSelected: (route) {
          if (route != '/home') {
            Navigator.pushNamed(context, route);
          }
        },
      ),

      body: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.feeds.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada postingan.',
                style: TextStyle(color: AppColors.white),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ClientHomeBloc>().add(RefreshFeeds());
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: state.feeds.length,
              itemBuilder: (context, index) {
                final feed = state.feeds[index];

                final username = feed.clientName ?? 'Unknown';
                final caption = feed.description ?? '';
                final commentCount = 0; // belum tersedia di response
                final uploadDate = feed.createdAtFeeds ?? DateTime.now();
                final imageBytes = feed.imgFeeds;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Profile & Name
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/profile_empty.svg',
                            width: 36,
                            height: 36,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            username,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Image
                    AspectRatio(
                      aspectRatio: 1,
                      child:
                          imageBytes != null
                              ? Image.memory(
                                Uint8List.fromList(imageBytes),
                                fit: BoxFit.cover,
                              )
                              : Container(
                                color: AppColors.grey,
                                child: const Center(
                                  child: Text(
                                    'image dari gallery',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                    ),

                    // Footer (comments, caption, time)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColors.lightSheet,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                builder: (context) {
                                  return FractionallySizedBox(
                                    heightFactor: 0.6,
                                    child: CommentBottomSheet(
                                      feedId: feed.idFeeds!,
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/comment_empty.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$commentCount',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: '  '),
                                TextSpan(text: caption),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(uploadDate),
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/home',
        onTabSelected: (route) {
          if (route != '/home') {
            Navigator.pushNamed(context, route);
          }
        },
        profileImageUrl: null,
      ),
    );
  }
}

// CommentBottomSheet sementara
class CommentBottomSheet extends StatelessWidget {
  final int feedId;

  const CommentBottomSheet({super.key, required this.feedId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Comments untuk Feed ID: $feedId",
        style: const TextStyle(color: AppColors.white),
      ),
    );
  }
}
