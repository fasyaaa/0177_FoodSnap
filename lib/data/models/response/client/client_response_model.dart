import 'dart:convert';

class ClientResponseModel {
    final int? idClient;
    final String? name;
    final String? username;
    final String? email;
    final String? gender;
    final String? role;
    final String? imgProfile;
    final DateTime? createdAtClient;
    final DateTime? updateAtClient;

    ClientResponseModel({
        this.idClient,
        this.name,
        this.username,
        this.email,
        this.gender,
        this.imgProfile,
        this.role,
        this.createdAtClient,
        this.updateAtClient,
    });

    factory ClientResponseModel.fromJson(String str) => ClientResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ClientResponseModel.fromMap(Map<String, dynamic> json) => ClientResponseModel(
        idClient: json["id_client"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        gender: json["gender"],
        imgProfile: json["img_profile"],
        role: json["role"],
        createdAtClient: json["created_at_client"] == null ? null : DateTime.parse(json["created_at_client"]),
        updateAtClient: json["update_at_client"] == null ? null : DateTime.parse(json["update_at_client"]),
    );

    Map<String, dynamic> toMap() => {
        "id_client": idClient,
        "name": name,
        "username": username,
        "email": email,
        "gender": gender,
        "img_profile": imgProfile,
        "role": role,
        "created_at_client": createdAtClient?.toIso8601String(),
        "update_at_client": updateAtClient?.toIso8601String(),
    };
}
