import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:foody/core/constants/api_path.dart';
import 'package:foody/data/models/request/comments/comment_request_model.dart';
import 'package:foody/data/models/response/comments/comment_response_model.dart';
import 'package:foody/service/service_http_client.dart';

class CommentRepository {
  final ServiceHttpClient _httpClient;

  CommentRepository(this._httpClient);

  /// Create a new comment (POST /comments)
  Future<Either<String, CommentResponseModel>> postComment(CommentRequestModel model) async {
    try {
      final response = await _httpClient.post(ApiPath.comments, model.toMap());
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        final comment = CommentResponseModel.fromMap(jsonResponse['data']);
        return Right(comment);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to post comment");
      }
    } catch (e) {
      return Left("An error occurred while posting comment: $e");
    }
  }

  /// Get all comments (GET /comments)
  Future<Either<String, List<CommentResponseModel>>> getAllComments() async {
    try {
      final response = await _httpClient.get(ApiPath.comments);
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<CommentResponseModel> comments = (jsonResponse['data'] as List)
            .map((e) => CommentResponseModel.fromMap(e))
            .toList();
        return Right(comments);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to fetch comments");
      }
    } catch (e) {
      return Left("An error occurred while fetching comments: $e");
    }
  }

  /// Get comments for a specific feed (GET /comments/feeds/{feedId})
  Future<Either<String, List<CommentResponseModel>>> getCommentsByFeedId(int feedId) async {
    try {
      final response = await _httpClient.get('${ApiPath.comments}/feeds/$feedId');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<CommentResponseModel> comments = (jsonResponse['data'] as List)
            .map((e) => CommentResponseModel.fromMap(e))
            .toList();
        return Right(comments);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to fetch comments for feed");
      }
    } catch (e) {
      return Left("An error occurred while fetching comments for feed: $e");
    }
  }

  /// Delete a comment by ID (DELETE /comments/{id})
  Future<Either<String, String>> deleteComment(int commentId) async {
    try {
      final response = await _httpClient.delete('${ApiPath.comments}/$commentId');
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
