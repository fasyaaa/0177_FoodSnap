import 'dart:convert';

class LoginRequestModel {
    final String? identity;
    final String? password;

    LoginRequestModel({
        this.identity,
        this.password,
    });

    factory LoginRequestModel.fromJson(String str) => LoginRequestModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory LoginRequestModel.fromMap(Map<String, dynamic> json) => LoginRequestModel(
        identity: json["identity"],
        password: json["password"],
    );

    Map<String, dynamic> toMap() => {
        "identity": identity,
        "password": password,
    };
}
