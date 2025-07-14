class BookmarkList {
  final int id;
  final String name;
  final String iconAsset;
  final bool isCustom;

  BookmarkList({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.isCustom,
  });

  factory BookmarkList.fromMap(Map<String, dynamic> map) {
    return BookmarkList(
      id: map['id'],
      name: map['name'],
      iconAsset: map['icon_asset'],
      isCustom: map['is_custom'] == 1,
    );
  }
}
