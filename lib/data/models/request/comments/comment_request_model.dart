import 'dart:convert';

class CommentRequestModel {
    final int? idFeeds;
    final String? content;
    final int? idParent;

    CommentRequestModel({
        this.idFeeds,
        this.content,
        this.idParent,
    });

    factory CommentRequestModel.fromJson(String str) => CommentRequestModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory CommentRequestModel.fromMap(Map<String, dynamic> json) => CommentRequestModel(
        idFeeds: json["id_feeds"],
        content: json["content"],
        idParent: json["id_parent"],
    );

    Map<String, dynamic> toMap() => {
        "id_feeds": idFeeds,
        "content": content,
        "id_parent": idParent,
    };
}
