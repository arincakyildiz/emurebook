class Message {
  final String id;
  final Map<String, dynamic> sender;
  final Map<String, dynamic> receiver;
  final String content;
  final Map<String, dynamic>? relatedBook;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    this.relatedBook,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      sender: json['sender'],
      receiver: json['receiver'],
      content: json['content'],
      relatedBook: json['relatedBook'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'receiver': receiver,
      'content': content,
      'relatedBook': relatedBook,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
