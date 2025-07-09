import 'package:meta/meta.dart';
import 'dart:convert';

class RegisterRequestModel {
    final String name;
    final String username;
    final String email;
    final String password;

    RegisterRequestModel({
        required this.name,
        required this.username,
        required this.email,
        required this.password,
    });

    factory RegisterRequestModel.fromRawJson(String str) => RegisterRequestModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory RegisterRequestModel.fromJson(Map<String, dynamic> json) => RegisterRequestModel(
        name: json["name"],
        username: json["username"],
        email: json["email"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "username": username,
        "email": email,
        "password": password,
    };
}
