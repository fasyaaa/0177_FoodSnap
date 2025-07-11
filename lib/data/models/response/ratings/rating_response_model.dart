import 'dart:convert';

class RatingResponseModel {
    final double? averageRating;
    final int? totalRatings;

    RatingResponseModel({
        this.averageRating,
        this.totalRatings,
    });

    factory RatingResponseModel.fromJson(String str) => RatingResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory RatingResponseModel.fromMap(Map<String, dynamic> json) => RatingResponseModel(
        averageRating: json["average_rating"]?.toDouble(),
        totalRatings: json["total_ratings"],
    );

    Map<String, dynamic> toMap() => {
        "average_rating": averageRating,
        "total_ratings": totalRatings,
    };
}
