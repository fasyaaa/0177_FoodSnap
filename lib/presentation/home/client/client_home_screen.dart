import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/presentation/home/client/bloc/client_home_bloc.dart';
import 'package:foody/presentation/home/client/widgets/home_view.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _storage = const FlutterSecureStorage();
  int? _loggedInClientId;
  Uint8List? _loggedInProfileImageBytes;

  @override
  void initState() {
    super.initState();
    context.read<ClientHomeBloc>().add(LoadFeeds());
    _loadLoggedInClientData();
  }

  Future<void> _loadLoggedInClientData() async {
    final clientIdStr = await _storage.read(key: 'clientId');
    if (clientIdStr == null) {
      print("No client ID found in storage after login.");
      return;
    }

    final id = int.tryParse(clientIdStr);
    if (id == null) return;

    setState(() {
      _loggedInClientId = id;
    });

    final clientRepo = RepositoryProvider.of<ClientRepository>(context);
    final result = await clientRepo.getClientById(id);

    result.fold(
      (error) => print("Error fetching client profile for bottom bar: $error"),
      (client) {
        if (client.imgProfile != null && client.imgProfile!.isNotEmpty) {
          try {
            setState(() {
              _loggedInProfileImageBytes = base64Decode(client.imgProfile!);
            });
          } catch (e) {
            print("Error decoding profile image base64 for bottom bar: $e");
          }
        }
      },
    );
  }

  void _onTabSelected(String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == route) return;

    if (route == '/profile') {
      if (_loggedInClientId != null) {
        Navigator.pushNamed(context, route, arguments: _loggedInClientId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client ID not available. Please login again.")),
        );
      }
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  Future<void> _onRefresh() async {
    context.read<ClientHomeBloc>().add(RefreshFeeds());
    await _loadLoggedInClientData();
  }

  @override
  Widget build(BuildContext context) {
    return HomeView(
      onTabSelected: _onTabSelected,
      onRefresh: _onRefresh,
      loggedInClientId: _loggedInClientId,
      profileImageBytes: _loggedInProfileImageBytes,
    );
  }
}
