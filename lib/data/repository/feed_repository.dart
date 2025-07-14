import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:foody/core/constants/api_path.dart';
import 'package:foody/data/models/request/feeds/feed_request_model.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/service/service_http_client.dart';

class FeedRepository {
  final ServiceHttpClient _httpClient;

  FeedRepository(this._httpClient);

  /// Create a feed (with optional image)
  Future<Either<String, FeedsResponseModel>> createFeed(
    FeedsRequestModel model, {
    String? imagePath,
  }) async {
    try {
      final response = await _httpClient.postMultipart(
        ApiPath.feeds,
        model.toMap(),
        fileField: imagePath != null ? 'img_feeds' : null,
        filePath: imagePath,
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        final createdFeed = FeedsResponseModel(
          idFeeds: jsonResponse['feedId'],
          title: model.title,
          description: model.description,
          locationName: model.locationName,
          latitude: model.latitude,
          longitude: model.longitude,
        );
        return Right(createdFeed);
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to create feed');
      }
    } catch (e) {
      return Left('An error occurred while creating feed: $e');
    }
  }

  /// Fetch all feeds
  Future<Either<String, List<FeedsResponseModel>>> getAllFeeds() async {
    try {
      final response = await _httpClient.get(ApiPath.feeds);
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final feeds =
            (jsonResponse['data'] as List)
                .map((e) => FeedsResponseModel.fromMap(e))
                .toList();
        return Right(feeds);
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to fetch feeds');
      }
    } catch (e) {
      return Left('An error occurred while fetching feeds: $e');
    }
  }

  /// Get feed by ID (GET /feeds/{id})
  Future<Either<String, FeedsResponseModel>> getFeedById(int id) async {
    try {
      final response = await _httpClient.get('${ApiPath.feeds}/$id');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final feed = FeedsResponseModel.fromMap(jsonResponse['data']);
        return Right(feed);
      } else {
        return Left(jsonResponse['message'] ?? 'Feed not found');
      }
    } catch (e) {
      return Left('An error occurred while fetching feed: $e');
    }
  }

  Future<Either<String, String>> updateFeed(
    int id,
    FeedsRequestModel model, {
    String? imagePath,
  }) async {
    try {
      final response =
          await (imagePath != null
              ? _httpClient.postMultipart(
                '${ApiPath.feeds}/$id?_method=PUT',
                model.toMap(),
                fileField: 'img_feeds',
                filePath: imagePath,
              )
              : _httpClient.put('${ApiPath.feeds}/$id', model.toMap()));

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse['message'] ?? 'Feed updated successfully');
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to update feed');
      }
    } catch (e) {
      return Left('An error occurred while updating feed: $e');
    }
  }

  /// Delete feed by ID (DELETE /feeds/{id})
  Future<Either<String, String>> deleteFeed(int id) async {
    try {
      final response = await _httpClient.delete('${ApiPath.feeds}/$id');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse['message'] ?? 'Feed deleted successfully');
      } else {
        return Left(jsonResponse['message'] ?? 'Failed to delete feed');
      }
    } catch (e) {
      return Left('An error occurred while deleting feed: $e');
    }
  }
}
