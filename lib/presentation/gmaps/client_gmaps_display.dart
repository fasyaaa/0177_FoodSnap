import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foody/core/components/custom_bottom_bar.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';
import 'package:foody/presentation/gmaps/gmaps_page.dart';
import 'package:foody/presentation/profile/client/bloc/profile_bloc.dart';

class ClientGmapsDisplay extends StatefulWidget {
  const ClientGmapsDisplay({super.key});

  @override
  State<ClientGmapsDisplay> createState() => _ClientGmapsDisplayState();
}

class _ClientGmapsDisplayState extends State<ClientGmapsDisplay> {
  int? _clientId;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadClientId();
  }

  /// Memuat ID klien dari penyimpanan aman untuk mengambil data profil.
  Future<void> _loadClientId() async {
    final id = await _storage.read(key: 'clientId');
    if (mounted && id != null) {
      setState(() {
        _clientId = int.tryParse(id);
      });
    } else {
      // TODO: Handle jika ID klien tidak ditemukan, mungkin navigasi ke halaman login.
      print("Client ID not found in storage.");
    }
  }

  /// Meng-handle navigasi saat tab di bottom bar ditekan.
  void _onTabSelected(String route) {
    // Mencegah navigasi ke halaman yang sama
    if (route == '/location' && ModalRoute.of(context)?.settings.name == '/location') return;

    // Logika navigasi sederhana
    if (route == '/home') {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (route == '/profile' && _clientId != null) {
      Navigator.pushNamed(context, '/profile', arguments: _clientId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_clientId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Sediakan ProfileBloc untuk mengambil data pengguna (foto profil)
    return BlocProvider(
      create: (context) => ProfileBloc(
        clientRepository: RepositoryProvider.of<ClientRepository>(context),
        feedRepository: RepositoryProvider.of<FeedRepository>(context),
      )..add(LoadProfile(_clientId!)),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          // Siapkan data gambar untuk CustomBottomBar
          Uint8List? profileImageBytes;
          if (profileState is ProfileLoaded &&
              profileState.imgProfile != null &&
              profileState.imgProfile!.isNotEmpty) {
            try {
              profileImageBytes = base64Decode(profileState.imgProfile!);
            } catch (e) {
              print("Error decoding base64 in ClientGmapsDisplay: $e");
              profileImageBytes = null;
            }
          }

          return Scaffold(
            body: const GmapsPage(),
            bottomNavigationBar: CustomBottomBar(
              currentRoute: '/location',
              onTabSelected: _onTabSelected,
              profileImageBytes: profileImageBytes,
            ),
          );
        },
      ),
    );
  }
}
