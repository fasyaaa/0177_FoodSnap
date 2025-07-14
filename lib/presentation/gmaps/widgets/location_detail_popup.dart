import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/local/bookmark_list_model.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/service/database_helper.dart';

class LocationDetailPopup extends StatefulWidget {
  final BookmarkPlace place;
  const LocationDetailPopup({super.key, required this.place});

  @override
  State<LocationDetailPopup> createState() => _LocationDetailPopupState();
}

class _LocationDetailPopupState extends State<LocationDetailPopup> {
  bool _isSaved = false;
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _checkIfPlaceIsSaved();
  }

  /// Memeriksa ke database apakah lokasi ini sudah disimpan atau belum.
  Future<void> _checkIfPlaceIsSaved() async {
    final isSaved = await _dbHelper.isPlaceSaved(widget.place.address);
    if (mounted) {
      setState(() {
        _isSaved = isSaved;
      });
    }
  }

  /// Menampilkan dialog untuk memilih daftar bookmark.
  Future<void> _onSavePressed() async {
    // Menutup popup detail lokasi terlebih dahulu
    Navigator.pop(context);

    // Menampilkan dialog pilihan daftar
    await showDialog(
      context: context,
      builder: (_) => SelectBookmarkListDialog(place: widget.place),
    );

    // Setelah dialog ditutup, periksa kembali statusnya untuk memperbarui UI
    _checkIfPlaceIsSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.place.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.place.address,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    /* ... Logika Add Post ... */
                  },
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  label: const Text('Add Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ✅ Tombol yang berubah secara dinamis
              OutlinedButton.icon(
                onPressed: _onSavePressed,
                icon:
                    _isSaved
                        ? SvgPicture.asset(
                          // Ikon jika SUDAH tersimpan
                          'assets/icons/bookmark_fill.svg', // Pastikan path asset benar
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                          width: 18,
                        )
                        : const Icon(
                          Icons.bookmark_border,
                          size: 18,
                        ), // Ikon jika BELUM tersimpan
                label: Text(_isSaved ? 'Saved' : 'Save'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isSaved ? AppColors.primary : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  side: BorderSide(
                    color: _isSaved ? AppColors.primary : Colors.white54,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Dialog daftar
class SelectBookmarkListDialog extends StatefulWidget {
  final BookmarkPlace place;
  const SelectBookmarkListDialog({super.key, required this.place});

  @override
  State<SelectBookmarkListDialog> createState() =>
      _SelectBookmarkListDialogState();
}

class _SelectBookmarkListDialogState extends State<SelectBookmarkListDialog> {
  final dbHelper = DatabaseHelper();
  late Future<List<BookmarkList>> _listsFuture;
  final Set<int> _selectedListIds = {};

  @override
  void initState() {
    super.initState();
    _listsFuture = dbHelper.getLists();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff2d2d2d),
      title: const Text('Save to...', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<BookmarkList>>(
          future: _listsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final lists = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return CheckboxListTile(
                  activeColor: AppColors.primary,
                  title: Text(
                    list.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: _selectedListIds.contains(list.id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedListIds.add(list.id);
                      } else {
                        _selectedListIds.remove(list.id);
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
        ),
        TextButton(
          onPressed: () {
            if (_selectedListIds.isNotEmpty) {
              dbHelper.addPlaceToLists(_selectedListIds.toList(), widget.place);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved to lists!'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          child: const Text('Done', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }
}
