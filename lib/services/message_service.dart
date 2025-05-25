import '../models/message_model.dart';
import '../models/conversation_model.dart';
import 'api_service.dart';
import 'service_provider.dart';
import 'auth_service.dart';

class MessageService {
  // Get AuthService from ServiceProvider
  AuthService get _authService => ServiceProvider().authService;

  // Mock conversations and messages
  static final Map<String, List<Map<String, dynamic>>> _mockConversations = {
    // Admin user conversations
    '100': [
      {
        'id': '1',
        'sender': {'_id': '100', 'name': 'Admin User'},
        'receiver': {'_id': '101', 'name': 'Student User'},
        'message': 'Hello, is the book still available?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'read': true,
      },
      {
        'id': '2',
        'sender': {'_id': '101', 'name': 'Student User'},
        'receiver': {'_id': '100', 'name': 'Admin User'},
        'message': 'Yes, it is! Are you interested?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'read': false,
      },
    ],
  };

  // Messages list by user ID
  static final Map<String, List<Message>> _mockMessages = {};

  // Messages with admin user
  static List<Message> _adminMessages = [
    Message(
      id: '1',
      sender: {'_id': '100', 'name': 'Admin User'},
      receiver: {'_id': '101', 'name': 'Student User'},
      content: 'Hello, how can I help you?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: true,
    ),
    Message(
      id: '2',
      sender: {'_id': '101', 'name': 'Student User'},
      receiver: {'_id': '100', 'name': 'Admin User'},
      content: 'I have a question about the app.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      isRead: false,
    ),
    Message(
      id: '3',
      sender: {'_id': '100', 'name': 'Admin User'},
      receiver: {'_id': '101', 'name': 'Student User'},
      content: 'Sure, what would you like to know?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      isRead: false,
    ),
  ];

  // Get user conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to view your conversations');
      }

      // Filter user conversations
      List<Map<String, dynamic>> userConversations = [];
      Map<String, Map<String, dynamic>> conversationMap = {};

      _mockConversations.forEach((conversationKey, messages) {
        for (var message in messages) {
          if (message['sender']['_id'] == currentUser.id ||
              message['receiver']['_id'] == currentUser.id) {
            // Determine the other party in conversation
            Map<String, dynamic> otherUser =
                message['sender']['_id'] == currentUser.id
                    ? message['receiver']
                    : message['sender'];

            String otherUserId = otherUser['_id'];

            // Update conversation with latest message
            if (!conversationMap.containsKey(otherUserId) ||
                (message['timestamp'] as DateTime).isAfter(
                    conversationMap[otherUserId]!['timestamp'] as DateTime)) {
              conversationMap[otherUserId] = {
                'otherUser': otherUser,
                'lastMessage': message['message'],
                'timestamp': message['timestamp'],
                'unreadCount': message['receiver']['_id'] == currentUser.id &&
                        !message['read']
                    ? 1
                    : 0,
              };
            }
          }
        }
      });

      // Convert map to list and sort by timestamp
      userConversations = conversationMap.values.toList();
      userConversations.sort((a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

      return userConversations;
    } catch (e) {
      rethrow;
    }
  }

  // Get messages with specific user
  Future<List<Message>> getMessagesWithUser(String otherUserId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = _authService.currentUser;

      // If no user is logged in, provide demo messages
      if (currentUser == null) {
        // For demo purposes, return admin messages when no user is logged in
        if (otherUserId == '100') {
          return List.from(_adminMessages);
        }
        return [];
      }

      // Find all messages between current user and other user
      List<Message> conversationMessages = [];

      // Check all conversations for messages between these two users
      _mockConversations.forEach((conversationKey, messages) {
        for (var messageData in messages) {
          if ((messageData['sender']['_id'] == currentUser.id &&
                  messageData['receiver']['_id'] == otherUserId) ||
              (messageData['sender']['_id'] == otherUserId &&
                  messageData['receiver']['_id'] == currentUser.id)) {
            // Convert message data to Message object
            final message = Message(
              id: messageData['id'],
              sender: messageData['sender'],
              receiver: messageData['receiver'],
              content: messageData['message'],
              createdAt: messageData['timestamp'],
              isRead: messageData['read'],
            );

            conversationMessages.add(message);
          }
        }
      });

      // Also check individual message lists for backward compatibility
      [currentUser.id, otherUserId].forEach((userId) {
        if (_mockMessages.containsKey(userId)) {
          for (var message in _mockMessages[userId]!) {
            if ((message.sender['_id'] == currentUser.id &&
                    message.receiver['_id'] == otherUserId) ||
                (message.sender['_id'] == otherUserId &&
                    message.receiver['_id'] == currentUser.id)) {
              // Check if message is not already added
              bool alreadyExists =
                  conversationMessages.any((m) => m.id == message.id);
              if (!alreadyExists) {
                conversationMessages.add(message);
              }
            }
          }
        }
      });

      // Sort messages by date
      conversationMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // If no messages found and talking to admin, return admin messages for demo
      if (conversationMessages.isEmpty && otherUserId == '100') {
        return List.from(_adminMessages);
      }

      return conversationMessages;
    } catch (e) {
      rethrow;
    }
  }

  // Send message
  Future<Message> sendMessage(String receiverId, String content,
      {String? receiverName}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = _authService.currentUser;

      // Create message sender info - use guest info if no user is logged in
      Map<String, dynamic> senderInfo;
      if (currentUser == null) {
        senderInfo = {
          '_id': 'guest_user',
          'name': 'Guest User',
          'email': 'guest@example.com'
        };
      } else {
        senderInfo = {
          '_id': currentUser.id,
          'name': currentUser.name,
          'email': currentUser.email
        };
      }

      // Get receiver info (use provided name or default)
      Map<String, dynamic> receiverInfo = {
        '_id': receiverId,
        'name': receiverName ?? 'Seller User',
        'email': 'seller@emu.edu.tr'
      };

      // Create new message
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: senderInfo,
        receiver: receiverInfo,
        content: content,
        createdAt: DateTime.now(),
        isRead: false,
      );

      // Add message to sender's messages
      String senderId = senderInfo['_id'];
      if (!_mockMessages.containsKey(senderId)) {
        _mockMessages[senderId] = [];
      }
      _mockMessages[senderId]!.add(newMessage);

      // Create or update conversation in mock conversations
      String conversationKey = '${senderId}_$receiverId';
      if (!_mockConversations.containsKey(conversationKey)) {
        _mockConversations[conversationKey] = [];
      }

      // Add message to conversation
      _mockConversations[conversationKey]!.add({
        'id': newMessage.id,
        'sender': senderInfo,
        'receiver': receiverInfo,
        'message': content,
        'timestamp': DateTime.now(),
        'read': false,
      });

      // For demo purposes, add a mock response after a delay
      Future.delayed(const Duration(seconds: 3), () {
        final responseMessage = Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          sender: receiverInfo,
          receiver: senderInfo,
          content:
              'Thank you for your interest! The book is still available. When would you like to meet?',
          createdAt: DateTime.now(),
          isRead: false,
        );

        // Add response to receiver's messages
        if (!_mockMessages.containsKey(receiverId)) {
          _mockMessages[receiverId] = [];
        }
        _mockMessages[receiverId]!.add(responseMessage);

        // Add response to conversation
        _mockConversations[conversationKey]!.add({
          'id': responseMessage.id,
          'sender': receiverInfo,
          'receiver': senderInfo,
          'message': responseMessage.content,
          'timestamp': responseMessage.createdAt,
          'read': false,
        });
      });

      return newMessage;
    } catch (e) {
      rethrow;
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return 0;
      }

      int unreadCount = 0;

      // Count unread messages in all conversations
      _mockConversations.forEach((userId, messages) {
        for (var message in messages) {
          if (message['receiver']['_id'] == currentUser.id &&
              !message['read']) {
            unreadCount++;
          }
        }
      });

      return unreadCount;
    } catch (e) {
      return 0;
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return;
      }

      // Find and mark message as read in admin messages
      for (var message in _adminMessages) {
        if (message.id == messageId &&
            message.receiver['_id'] == currentUser.id) {
          // Note: In a real app, you'd update the message in the database
          // For now, we can't modify the isRead property as it's final
          break;
        }
      }
    } catch (e) {
      // Handle error silently for read status
    }
  }
}
