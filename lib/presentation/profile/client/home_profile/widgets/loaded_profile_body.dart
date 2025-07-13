import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/components/sliver_tab_bar_delegate.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/presentation/profile/client/bloc/profile_bloc.dart';
import 'package:foody/presentation/profile/client/home_profile/widgets/profile_feed_grid.dart';
import 'package:foody/presentation/profile/client/home_profile/widgets/profile_header.dart';

class LoadedProfileBody extends StatelessWidget {
  final ProfileLoaded state;
  final VoidCallback onLogout;

  const LoadedProfileBody({
    super.key,
    required this.state,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: ProfileHeader(state: state, onLogout: onLogout),
          ),
          SliverPersistentHeader(
            delegate: SliverTabBarDelegate(
              TabBar(
                indicatorColor: AppColors.white,
                indicatorWeight: 1.5,
                tabs: [
                  Tab(
                    icon: SvgPicture.asset(
                      'assets/icons/grid_fill.svg', 
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pinned: true,
          ),
        ],
        body: TabBarView(
          children: [ProfileFeedGrid(feeds: state.feeds)],
        ),
      ),
    );
  }
}
