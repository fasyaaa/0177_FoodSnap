// data/local/database_helper.dart (LENGKAP dan BARU)
import 'package:foody/data/models/local/bookmark_list_model.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'foody_bookmarks_v2.db'); // v2 untuk skema baru
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmark_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_asset TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL UNIQUE,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE list_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        place_id INTEGER NOT NULL,
        FOREIGN KEY (list_id) REFERENCES bookmark_lists (id) ON DELETE CASCADE,
        FOREIGN KEY (place_id) REFERENCES places (id) ON DELETE CASCADE
      )
    ''');

    // Masukkan daftar default
    await _insertDefaultLists(db);
  }

  Future<void> _insertDefaultLists(Database db) async {
    await db.insert('bookmark_lists', {
      'name': 'Favorites',
      'icon_asset': 'assets/icons/like_empty.svg',
      'is_custom': 0,
    });
    await db.insert('bookmark_lists', {
      'name': 'Stared Place',
      'icon_asset': 'assets/icons/star.svg',
      'is_custom': 0,
    });
    await db.insert('bookmark_lists', {
      'name': 'Flag',
      'icon_asset': 'assets/icons/flag.svg',
      'is_custom': 0,
    });
  }

  Future<int> createCustomList(String name, String iconAsset) async {
    final db = await database;
    return await db.insert('bookmark_lists', {
      'name': name,
      'icon_asset': iconAsset,
      'is_custom': 1,
    });
  }

  Future<List<BookmarkList>> getLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmark_lists');
    return List.generate(maps.length, (i) => BookmarkList.fromMap(maps[i]));
  }

  Future<int> getPlaceCountInList(int listId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM list_items WHERE list_id = ?',
      [listId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<BookmarkPlace>> getPlacesInList(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT p.* FROM places p
      INNER JOIN list_items li ON p.id = li.place_id
      WHERE li.list_id = ?
    ''',
      [listId],
    );
    return List.generate(maps.length, (i) {
      return BookmarkPlace.fromMap(maps[i]);
    });
  }

  // Hapus tempat spesifik dari list spesifik
  Future<void> removePlaceFromList(int listId, int placeId) async {
    final db = await database;
    await db.delete(
      'list_items',
      where: 'list_id = ? AND place_id = ?',
      whereArgs: [listId, placeId],
    );
  }

  // Hapus list kustom
  Future<void> deleteCustomList(int listId) async {
    final db = await database;
    await db.delete(
      'bookmark_lists',
      where: 'id = ? AND is_custom = 1',
      whereArgs: [listId],
    );
  }

  Future<bool> isPlaceSaved(String address) async {
    final db = await database;
    // Cek dulu apakah tempat ini ada di tabel 'places'
    final existingPlaces = await db.query(
      'places',
      where: 'address = ?',
      whereArgs: [address],
      limit: 1,
    );

    if (existingPlaces.isEmpty) {
      return false; // Jika tidak ada di tabel places, pasti belum disimpan
    }

    final placeId = existingPlaces.first['id'] as int;

    // Cek apakah place_id ini ada di tabel penghubung 'list_items'
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) FROM list_items WHERE place_id = ?',
      [placeId],
    );

    final count = Sqflite.firstIntValue(countResult);
    return count != null && count > 0;
  }

  Future<void> addPlaceToLists(List<int> listIds, BookmarkPlace place) async {
    final db = await database;
    int placeId;

    // Cek apakah tempat sudah ada berdasarkan alamat
    final existingPlaces = await db.query(
      'places',
      where: 'address = ?',
      whereArgs: [place.address],
    );
    if (existingPlaces.isNotEmpty) {
      placeId = existingPlaces.first['id'] as int;
    } else {
      placeId = await db.insert(
        'places',
        place.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Tambahkan ke setiap list yang dipilih
    for (var listId in listIds) {
      // Hindari duplikasi dalam satu list
      final existingLink = await db.query(
        'list_items',
        where: 'list_id = ? AND place_id = ?',
        whereArgs: [listId, placeId],
      );
      if (existingLink.isEmpty) {
        await db.insert('list_items', {'list_id': listId, 'place_id': placeId});
      }
    }
  }
}
