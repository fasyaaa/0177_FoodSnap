import 'dart:convert';

class RegisterResponseModel {
  final String? message;
  final int? statusCode;
  final Data? data;

  RegisterResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory RegisterResponseModel.fromJson(String str) =>
      RegisterResponseModel.fromMap(json.decode(str));

  factory RegisterResponseModel.fromMap(Map<String, dynamic> json) =>
      RegisterResponseModel(
        message: json["message"],
        statusCode: json["status_code"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
      );
}

class Data {
  final int? id;
  final String? name;
  final String? username;
  final String? email;
  final String? role;
  final String? token;

  Data({
    this.id,
    this.name,
    this.username,
    this.email,
    this.role,
    this.token,
  });

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        role: json["role"],
        token: json["token"],
      );
}
