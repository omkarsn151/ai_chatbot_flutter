import 'package:flutter/foundation.dart' show immutable;

@immutable
class Message {
  final String id;
  final String message;
  final String? imgUrl;
  final DateTime createdAt;
  final bool isMine;

  const Message(
      {required this.id,
      required this.message,
        this.imgUrl,
      required this.createdAt,
      required this.isMine});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'message': message,
      'imageUrl': imgUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isMine': isMine,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      message: map['message'] as String,
      imgUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isMine: map['isMine'] as bool,
    );
  }

  Message copyWith({
    String? imageUrl,
  }) {
    return Message(
      id: id,
      message: message,
      createdAt: createdAt,
      isMine: isMine,
      imgUrl: imageUrl,
    );
  }
}
