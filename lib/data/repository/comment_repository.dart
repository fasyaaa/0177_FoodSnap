import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:foody/core/constants/api_path.dart';
import 'package:foody/data/models/request/comments/comment_request_model.dart';
import 'package:foody/data/models/response/comments/comment_response_model.dart';
import 'package:foody/service/service_http_client.dart';

class CommentRepository {
  final ServiceHttpClient _httpClient;

  CommentRepository(this._httpClient);

  /// Post a new comment (POST /comments)
  Future<Either<String, CommentResponseModel>> createComment(CommentRequestModel model) async {
    try {
      final response = await _httpClient.post(ApiPath.comments, model.toMap());
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        final comment = CommentResponseModel.fromMap(jsonResponse['data']);
        return Right(comment);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to create comment");
      }
    } catch (e) {
      return Left("An error occurred while creating comment: $e");
    }
  }

  /// Get all comments for a feed (GET /comments?feedId={id})
  Future<Either<String, List<CommentResponseModel>>> getCommentsByFeedId(int feedId) async {
    try {
      final response = await _httpClient.get('${ApiPath.comments}?feedId=$feedId');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<CommentResponseModel> comments = (jsonResponse['data'] as List)
            .map((item) => CommentResponseModel.fromMap(item))
            .toList();
        return Right(comments);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to fetch comments");
      }
    } catch (e) {
      return Left("An error occurred while fetching comments: $e");
    }
  }

  /// Get a single comment by ID (GET /comments/{id})
  Future<Either<String, CommentResponseModel>> getCommentById(int id) async {
    try {
      final response = await _httpClient.get('${ApiPath.comments}/$id');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final comment = CommentResponseModel.fromMap(jsonResponse['data']);
        return Right(comment);
      } else {
        return Left(jsonResponse['message'] ?? "Comment not found");
      }
    } catch (e) {
      return Left("An error occurred while fetching comment: $e");
    }
  }

  /// Delete comment (DELETE /comments/{id})
  Future<Either<String, String>> deleteComment(int id) async {
    try {
      final response = await _httpClient.delete('${ApiPath.comments}/$id');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse['message'] ?? "Comment deleted successfully");
      } else {
        return Left(jsonResponse['message'] ?? "Failed to delete comment");
      }
    } catch (e) {
      return Left("An error occurred while deleting comment: $e");
    }
  }
}
