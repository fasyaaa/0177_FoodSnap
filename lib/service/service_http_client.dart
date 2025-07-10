import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiceHttpClient {
  final String baseUrl = 'https://your-api-url.com/api';
  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> _saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<void> _deleteToken() async {
    await storage.delete(key: 'token');
  }

  // ===== REGISTER =====
  Future<http.Response> register(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      body: jsonEncode(userData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      await _saveToken(body['token']);
    }

    return response;
  }

  // ===== LOGIN =====
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await _saveToken(body['data']['token']);
    }

    return response;
  }

  // ===== GET CLIENTS (Admin only) =====
  Future<http.Response> getClients() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/client');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // ===== CREATE FEED =====
  Future<http.Response> createFeed(Map<String, dynamic> feedData) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/feeds');

    final request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields.addAll(
            feedData.map((key, value) => MapEntry(key, value.toString())),
          );

    if (feedData['img_feeds'] != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'img_feeds',
          feedData['img_feeds'],
        ),
      );
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // ===== COMMENT on feed =====
  Future<http.Response> createComment(Map<String, dynamic> commentData) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/comments');

    return await http.post(
      url,
      body: jsonEncode(commentData),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // ===== GET comments on a feed =====
  Future<http.Response> getComments(String feedId) async {
    final url = Uri.parse('$baseUrl/comments/$feedId');
    return await http.get(url);
  }

  // ===== SET Rating =====
  Future<http.Response> setRating(String feedId, int rating) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/ratings');

    return await http.post(
      url,
      body: jsonEncode({'id_feeds': feedId, 'rating': rating}),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // ===== GET Feed Ratings =====
  Future<http.Response> getRating(String feedId) async {
    final url = Uri.parse('$baseUrl/ratings/$feedId');
    return await http.get(url);
  }

  // ===== GET Logged-in User Rating =====
  Future<http.Response> getUserRating(String feedId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/ratings/user/$feedId');

    return await http.get(url, headers: {'Authorization': 'Bearer $token'});
  }
}
