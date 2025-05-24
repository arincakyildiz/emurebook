import 'message_model.dart';

class Conversation {
  final Map<String, dynamic> user;
  final Message lastMessage;
  final int unreadCount;

  Conversation({
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      user: json['user'],
      lastMessage: Message.fromJson(json['lastMessage']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'lastMessage': lastMessage.toJson(),
      'unreadCount': unreadCount,
    };
  }
}
