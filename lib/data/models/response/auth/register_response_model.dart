import 'dart:convert';

class RegisterResponseModel {
    final String? message;
    final String? token;

    RegisterResponseModel({
        this.message,
        this.token,
    });

    factory RegisterResponseModel.fromJson(String str) => RegisterResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory RegisterResponseModel.fromMap(Map<String, dynamic> json) => RegisterResponseModel(
        message: json["message"],
        token: json["token"],
    );

    Map<String, dynamic> toMap() => {
        "message": message,
        "token": token,
    };
}
