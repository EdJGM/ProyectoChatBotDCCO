import 'package:hive/hive.dart';

class Message {
  final String messageId;
  final String chatId;
  final StringBuffer message;
  final DateTime timeSent;
  final bool isFromUser;

  Message({
    required this.messageId,
    required this.chatId,
    required this.message,
    required this.timeSent,
    this.isFromUser = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'message': message.toString(),
      'timeSent': timeSent.millisecondsSinceEpoch,
      'isFromUser': isFromUser,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'],
      chatId: map['chatId'],
      message: StringBuffer(map['message']),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      isFromUser: map['isFromUser'] ?? false,
    );
  }
}