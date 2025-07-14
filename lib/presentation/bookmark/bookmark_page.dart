import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/components/custom_bottom_bar.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/local/bookmark_list_model.dart';
import 'package:foody/data/repository/client_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';
import 'package:foody/presentation/bookmark/bookmark_list_page.dart';
import 'package:foody/presentation/profile/client/bloc/profile_bloc.dart';
import 'package:foody/service/database_helper.dart';

/// Wrapper untuk menyediakan ProfileBloc ke halaman BookmarkPage.
/// Pastikan Anda mendaftarkan widget ini di router (misal: di main.dart).
class BookmarkPageWrapper extends StatelessWidget {
  const BookmarkPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ProfileBloc(
            clientRepository: RepositoryProvider.of<ClientRepository>(context),
            feedRepository: RepositoryProvider.of<FeedRepository>(context),
          ),
      child: const BookmarkPage(),
    );
  }
}

/// Widget utama untuk halaman Bookmark.
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late Future<List<BookmarkList>> _listsFuture;
  final _dbHelper = DatabaseHelper();
  final _storage = const FlutterSecureStorage();
  int? _clientId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    _loadLists();

    final id = await _storage.read(key: 'clientId');
    if (mounted && id != null) {
      _clientId = int.tryParse(id);
      if (_clientId != null) {
        context.read<ProfileBloc>().add(LoadProfile(_clientId!));
      }
    }
  }

  void _loadLists() {
    setState(() {
      _listsFuture = _dbHelper.getLists();
    });
  }

  void _onTabSelected(String route) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (route == currentRouteName) return;

    if (route == '/home' || route == '/location') {
      Navigator.pushReplacementNamed(context, route);
    } else if (route == '/profile' && _clientId != null) {
      Navigator.pushNamed(context, '/profile', arguments: _clientId);
    }
  }

  Color _getIconColor(String listName) {
    switch (listName.toLowerCase()) {
      case 'favorites':
        return AppColors.pink;
      case 'stared place':
        return AppColors.yellow;
      case 'flag':
        return AppColors.green;
      default:
        return AppColors.green;
    }
  }

  void _showNewListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff2d2d2d),
          title: const Text(
            'New List',
            style: TextStyle(color: AppColors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: 'Enter list name',
              hintStyle: TextStyle(color: AppColors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _dbHelper.createCustomList(
                    controller.text,
                    'assets/icons/smile.svg',
                  );
                  Navigator.pop(context);
                  _loadLists(); 
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showDeleteListDialog(BookmarkList list) {
    if (!list.isCustom) return; 

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xff2d2d2d),
            title: const Text(
              'Delete List',
              style: TextStyle(color: AppColors.white),
            ),
            content: Text(
              'Are you sure you want to delete the "${list.name}" list? This action cannot be undone.',
              style: const TextStyle(color: AppColors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _dbHelper.deleteCustomList(list.id);
                  Navigator.of(ctx).pop();
                  _loadLists(); 
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return Text(
                state.username ?? 'Your Lists',
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }
            return const Text(
              'Your Lists',
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showNewListDialog,
                icon: const Icon(Icons.add, color: AppColors.white),
                label: const Text('New List'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<BookmarkList>>(
                future: _listsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: AppColors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No lists found.',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    );
                  }

                  final lists = snapshot.data!;
                  return ListView.separated(
                    itemCount: lists.length,
                    separatorBuilder:
                        (context, index) =>
                            const Divider(color: Colors.white24, height: 1),
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SvgPicture.asset(
                              list.iconAsset,
                              colorFilter: ColorFilter.mode(
                                _getIconColor(list.name),
                                BlendMode.srcIn,
                              ),
                              width: 26,
                              height: 26,
                            ),
                          ),
                        ),
                        title: Text(
                          list.name,
                          style: const TextStyle(color: AppColors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BookmarkListPage(list: list),
                            ),
                          ).then((_) => _loadLists());
                        },
                        onLongPress: () {
                          if (list.isCustom) {
                            _showDeleteListDialog(list);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          Uint8List? profileImageBytes;
          if (state is ProfileLoaded &&
              state.imgProfile != null &&
              state.imgProfile!.isNotEmpty) {
            try {
              profileImageBytes = base64Decode(state.imgProfile!);
            } catch (e) {
              profileImageBytes = null;
            }
          }
          return CustomBottomBar(
            currentRoute: '/bookmark',
            onTabSelected: _onTabSelected,
            profileImageBytes: profileImageBytes,
          );
        },
      ),
    );
  }
}
