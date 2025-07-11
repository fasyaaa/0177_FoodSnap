import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foody/core/constants/api_path.dart';
import 'package:foody/data/models/request/auth/login_request_model.dart';
import 'package:foody/data/models/request/auth/register_request_model.dart';
import 'package:foody/data/models/response/auth/login_response_model.dart';
import 'package:foody/service/service_http_client.dart';

class AuthRepository {
  final ServiceHttpClient _serviceHttpClient;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  AuthRepository(this._serviceHttpClient);

  Future<Either<String, LoginResponseModel>> login(LoginRequestModel requestModel) async {
    try {
      final response = await _serviceHttpClient.post(
        ApiPath.login,
        requestModel.toMap(),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final loginResponse = LoginResponseModel.fromMap(jsonResponse);
        await secureStorage.write(key: "authToken", value: loginResponse.data!.token);
        await secureStorage.write(key: "UserRole", value: loginResponse.data!.role);
        return Right(loginResponse);
      } else {
        return Left(jsonResponse['message'] ?? "Login failed");
      }
    } catch (e) {
      return Left("An error occurred while logging in: $e");
    }
  }

  Future<Either<String, String>> register(RegisterRequestModel requestModel) async {
    try {
      final response = await _serviceHttpClient.post(
        ApiPath.register,
        requestModel.toMap(),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 201) {
        return Right(jsonResponse['message']);
      } else {
        return Left(jsonResponse['message'] ?? "Registration failed");
      }
    } catch (e) {
      return Left("An error occurred while registering: $e");
    }
  }
}
