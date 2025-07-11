import 'dart:convert';

class CommentResponseModel {
    final int? idComments;
    final int? idClient;
    final int? idFeeds;
    final int? idParent;
    final String? content;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? clientName;
    final int? replyCount;
    final List<CommentResponseModel>? replies;

    CommentResponseModel({
        this.idComments,
        this.idClient,
        this.idFeeds,
        this.idParent,
        this.content,
        this.createdAt,
        this.updatedAt,
        this.clientName,
        this.replyCount,
        this.replies,
    });

    factory CommentResponseModel.fromJson(String str) => CommentResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory CommentResponseModel.fromMap(Map<String, dynamic> json) => CommentResponseModel(
        idComments: json["id_comments"],
        idClient: json["id_client"],
        idFeeds: json["id_feeds"],
        idParent: json["id_parent"],
        content: json["content"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        clientName: json["client_name"],
        replyCount: json["reply_count"],
        replies: json["replies"] == null ? [] : List<CommentResponseModel>.from(json["replies"]!.map((x) => CommentResponseModel.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id_comments": idComments,
        "id_client": idClient,
        "id_feeds": idFeeds,
        "id_parent": idParent,
        "content": content,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "client_name": clientName,
        "reply_count": replyCount,
        "replies": replies == null ? [] : List<dynamic>.from(replies!.map((x) => x.toMap())),
    };
}
