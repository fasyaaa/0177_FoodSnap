import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiceHttpClient {
  final String baseUrl = 'http://10.0.2.2:3000/api';
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'authToken');
  }

  Future<void> _saveToken(String token) async {
    await storage.write(key: 'authToken', value: token);
  }

  Future<void> _deleteToken() async {
    await storage.delete(key: 'authToken');
  }

  // General POST method
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    return await http.post(
      url,
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  // General GET method
  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    return await http.get(
      url,
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
    );
  }

  // Multipart POST (for image upload etc.)
  Future<http.Response> postMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    String? fileField,
    String? filePath,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = token != null ? 'Bearer $token' : ''
      ..fields.addAll(
        fields.map((key, value) => MapEntry(key, value.toString())),
      );

    if (fileField != null && filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // Optional: PUT method
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    return await http.put(
      url,
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  // Optional: DELETE method
  Future<http.Response> delete(String endpoint) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    return await http.delete(
      url,
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
    );
  }
}
