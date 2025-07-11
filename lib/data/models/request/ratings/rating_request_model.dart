import 'dart:convert';

class RatingRequestModel {
    final int? idFeeds;
    final double? rating;

    RatingRequestModel({
        this.idFeeds,
        this.rating,
    });

    factory RatingRequestModel.fromJson(String str) => RatingRequestModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory RatingRequestModel.fromMap(Map<String, dynamic> json) => RatingRequestModel(
        idFeeds: json["id_feeds"],
        rating: json["rating"]?.toDouble(),
    );

    Map<String, dynamic> toMap() => {
        "id_feeds": idFeeds,
        "rating": rating,
    };
}
