import 'dart:convert';

class ClientRequestModel {
  final String? name;
  final String? username;
  final String? email;
  final String? password;
  final String? gender;
  final String? imgProfile; // base64 image string

  ClientRequestModel({
    this.name,
    this.username,
    this.email,
    this.password,
    this.gender,
    this.imgProfile,
  });

  factory ClientRequestModel.fromJson(String str) =>
      ClientRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ClientRequestModel.fromMap(Map<String, dynamic> json) =>
      ClientRequestModel(
        name: json["name"],
        username: json["username"],
        email: json["email"],
        password: json["password"],
        gender: json["gender"],
        imgProfile: json["img_profile"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "username": username,
        "email": email,
        "password": password,
        "gender": gender,
        "img_profile": imgProfile,
      };
}
