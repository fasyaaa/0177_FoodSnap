import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foody/core/components/custom_bottom_bar.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_bloc.dart';
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

  Future<void> _loadClientId() async {
    final id = await _storage.read(key: 'clientId');
    if (mounted && id != null) {
      setState(() {
        _clientId = int.tryParse(id);
      });
    } else {
      print("Client ID not found in storage.");
    }
  }

  void _onTabSelected(String route) {
    if (route == ModalRoute.of(context)?.settings.name) return;

    if (route == '/home' || route == '/bookmark') {
      Navigator.pushReplacementNamed(context, route);
    } else if (route == '/profile' && _clientId != null) {
      Navigator.pushNamed(context, '/profile', arguments: _clientId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_clientId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final placeToShow =
        ModalRoute.of(context)?.settings.arguments as BookmarkPlace?;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ProfileBloc(
                clientRepository: RepositoryProvider.of<ClientRepository>(
                  context,
                ),
                feedRepository: RepositoryProvider.of<FeedRepository>(context),
              )..add(LoadProfile(_clientId!)),
        ),
        BlocProvider(
          create:
              (context) =>
                  GmapsBloc()..add(
                    placeToShow != null
                        ? ShowSavedPlace(placeToShow)
                        : InitializeMap(),
                  ),
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          Uint8List? profileImageBytes;
          if (profileState is ProfileLoaded &&
              profileState.client.imgProfile != null &&
              profileState.client.imgProfile!.isNotEmpty) {
            try {
              profileImageBytes = base64Decode(profileState.client.imgProfile!);
            } catch (e) {
              print("Error decoding base64 in ClientGmapsDisplay: $e");
              profileImageBytes = null;
            }
          }

          return Scaffold(
            body: const GmapView(),
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
