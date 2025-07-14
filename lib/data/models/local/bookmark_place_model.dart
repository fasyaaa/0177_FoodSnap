class BookmarkPlace {
  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  BookmarkPlace({
    this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory BookmarkPlace.fromMap(Map<String, dynamic> map) {
    return BookmarkPlace(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
