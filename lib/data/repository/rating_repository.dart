import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:foody/core/constants/api_path.dart';
import 'package:foody/data/models/request/ratings/rating_request_model.dart';
import 'package:foody/data/models/response/ratings/rating_response_model.dart';
import 'package:foody/service/service_http_client.dart';

class RatingRepository {
  final ServiceHttpClient _httpClient;

  RatingRepository(this._httpClient);

  /// Submit rating for a feed
  Future<Either<String, String>> submitRating(RatingRequestModel model) async {
    try {
      final response = await _httpClient.post('${ApiPath.feeds}/rating', model.toMap());
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(jsonResponse['message'] ?? 'Rating submitted successfully');
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to submit rating');
      }
    } catch (e) {
      return Left('An error occurred while submitting rating: $e');
    }
  }

  /// Get average rating for a feed by ID
  Future<Either<String, RatingResponseModel>> getRatingByFeedId(int feedId) async {
    try {
      final response = await _httpClient.get('${ApiPath.feeds}/$feedId/rating');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final data = RatingResponseModel.fromMap(jsonResponse['data']);
        return Right(data);
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to fetch rating');
      }
    } catch (e) {
      return Left('An error occurred while fetching rating: $e');
    }
  }
}
