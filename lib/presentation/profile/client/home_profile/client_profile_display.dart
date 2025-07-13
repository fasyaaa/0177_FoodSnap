import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';
import 'package:foody/presentation/profile/client/bloc/profile_bloc.dart';
import 'package:foody/presentation/profile/client/home_profile/widgets/profile_view.dart';

class ProfilePage extends StatefulWidget {
  final int clientId;

  const ProfilePage({super.key, required this.clientId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();

  void _onTabSelected(String route) {
    if (route == '/profile' && ModalRoute.of(context)?.settings.name == '/profile') return;

    if (route == '/home') {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  // Logout.
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.button,
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await _storage.deleteAll();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        clientRepository: RepositoryProvider.of<ClientRepository>(context),
        feedRepository: RepositoryProvider.of<FeedRepository>(context),
      )..add(LoadProfile(widget.clientId)),
      child: ProfileView(
        onTabSelected: _onTabSelected,
        onLogout: _logout,
      ),
    );
  }
}
