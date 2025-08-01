import 'dart:convert';

class FeedsResponseModel {
  final int? idFeeds;
  final int? idClient;
  final String? title;
  final String? description;
  final List<int>? imgFeeds;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAtFeeds;
  final DateTime? updatedAtFeeds;
  final String? clientName;
  final String? username;
  final String? imgProfile;
  final int? totalComment;

  FeedsResponseModel({
    this.idFeeds,
    this.idClient,
    this.title,
    this.description,
    this.imgFeeds,
    this.locationName,
    this.latitude,
    this.longitude,
    this.createdAtFeeds,
    this.updatedAtFeeds,
    this.clientName,
    this.username,
    this.imgProfile,
    this.totalComment,
  });

  factory FeedsResponseModel.fromJson(String str) =>
      FeedsResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FeedsResponseModel.fromMap(Map<String, dynamic> json) =>
      FeedsResponseModel(
        idFeeds: json["id_feeds"],
        idClient: json["id_client"],
        title: json["title"],
        description: json["description"],
        imgFeeds: json["img_feeds"] == null ? null : base64Decode(json["img_feeds"]),
        locationName: json["location_name"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        createdAtFeeds:
            json["created_at_feeds"] == null
                ? null
                : DateTime.parse(json["created_at_feeds"]),
        updatedAtFeeds:
            json["updated_at_feeds"] == null
                ? null
                : DateTime.parse(json["updated_at_feeds"]),
        clientName: json["client_name"],
        username: json["username"],
        imgProfile: json["img_profile"],
        totalComment: json["total_comment"],
      );

  Map<String, dynamic> toMap() => {
    "id_feeds": idFeeds,
    "id_client": idClient,
    "title": title,
    "description": description,
    "img_feeds": imgFeeds,
    "location_name": locationName,
    "latitude": latitude,
    "longitude": longitude,
    "created_at_feeds": createdAtFeeds?.toIso8601String(),
    "updated_at_feeds": updatedAtFeeds?.toIso8601String(),
    "client_name": clientName,
    "username": username,
    "img_profile": imgProfile,
    "total_comment": totalComment,
  };
}
