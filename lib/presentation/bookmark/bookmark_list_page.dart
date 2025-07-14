import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/local/bookmark_list_model.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/service/database_helper.dart';

class BookmarkListPage extends StatefulWidget {
  final BookmarkList list;
  const BookmarkListPage({super.key, required this.list});

  @override
  State<BookmarkListPage> createState() => _BookmarkListPageState();
}

class _BookmarkListPageState extends State<BookmarkListPage> {
  late Future<List<BookmarkPlace>> _placesFuture;
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  void _loadPlaces() {
    setState(() {
      _placesFuture = _dbHelper.getPlacesInList(widget.list.id);
    });
  }

  void _removePlace(BookmarkPlace place) async {
    // Konfirmasi sebelum menghapus
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Remove Place'),
            content: Text(
              'Are you sure you want to remove "${place.name}" from this list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await _dbHelper.removePlaceFromList(
                    widget.list.id,
                    place.id!,
                  );
                  Navigator.of(ctx).pop();
                  _loadPlaces(); // Muat ulang daftar setelah menghapus
                },
                child: const Text(
                  'Remove',
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
        // ... (AppBar tidak berubah)
      ),
      body: FutureBuilder<List<BookmarkPlace>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No places saved in this list yet.',
                style: TextStyle(color: AppColors.grey),
              ),
            );
          }

          final places = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: places.length,
            separatorBuilder:
                (context, index) => const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final place = places[index];
              return ListTile(
                title: Text(
                  place.name,
                  style: const TextStyle(color: AppColors.white),
                ),
                subtitle: Text(
                  place.address,
                  style: const TextStyle(color: AppColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  // Tombol Hapus
                  icon: const Icon(Icons.delete_outline, color: AppColors.grey),
                  onPressed: () => _removePlace(place),
                ),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/location',
                    (route) => false,
                    arguments: place,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
