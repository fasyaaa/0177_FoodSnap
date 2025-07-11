import 'dart:convert';

class FeedsRequestModel {
    final String? title;
    final String? description;
    final String? locationName;
    final double? latitude;
    final double? longitude;
    final String? imgFeeds;

    FeedsRequestModel({
        this.title,
        this.description,
        this.locationName,
        this.latitude,
        this.longitude,
        this.imgFeeds,
    });

    factory FeedsRequestModel.fromJson(String str) => FeedsRequestModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory FeedsRequestModel.fromMap(Map<String, dynamic> json) => FeedsRequestModel(
        title: json["title"],
        description: json["description"],
        locationName: json["location_name"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        imgFeeds: json["img_feeds"],
    );

    Map<String, dynamic> toMap() => {
        "title": title,
        "description": description,
        "location_name": locationName,
        "latitude": latitude,
        "longitude": longitude,
        "img_feeds": imgFeeds,
    };
}
