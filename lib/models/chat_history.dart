import 'package:hive/hive.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject {
  @HiveField(0)
  final String chatId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  String? lastMessage;

  @HiveField(4)
  DateTime? lastMessageTime;

  @HiveField(5)
  String modelType;

  ChatHistory({
    required this.chatId,
    required this.title,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.modelType = 'simulacion',
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'modelType': modelType,
    };
  }

  factory ChatHistory.fromMap(Map<String, dynamic> map) {
    return ChatHistory(
      chatId: map['chatId'],
      title: map['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : null,
      modelType: map['modelType'] ?? 'simulacion',
    );
  }
}