import '../models/message_model.dart';
import '../models/conversation_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class MessageService {
  final AuthService _authService = AuthService();

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

      _mockConversations.forEach((userId, messages) {
        for (var message in messages) {
          if (message['sender']['_id'] == currentUser.id ||
              message['receiver']['_id'] == currentUser.id) {
            // Determine the other party in conversation (if sender is user then show receiver, if receiver is user then show sender)
            Map<String, dynamic> otherUser =
                message['sender']['_id'] == currentUser.id
                    ? message['receiver']
                    : message['sender'];

            // Check if conversation already exists
            bool conversationExists = userConversations
                .any((conv) => conv['otherUser']['_id'] == otherUser['_id']);

            if (!conversationExists) {
              userConversations.add({
                'otherUser': otherUser,
                'lastMessage': message['message'],
                'timestamp': message['timestamp'],
                'unreadCount': 1, // Calculate actual unread count in production
              });
            }
          }
        }
      });

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

        // For other users, return empty list
        return [];
      }

      // Find user info
      Map<String, dynamic> otherUser = {
        '_id': otherUserId,
        'name': 'Other User',
        'email': 'other@example.com'
      };

      // If new conversation is started with a user
      if (otherUserId == 'new_user') {
        // Create a new user (in production this will come from API)
        otherUser = {
          '_id': 'new_user_id',
          'name': 'New User',
          'email': 'newuser@example.com'
        };
      }

      // Find all messages between two users
      List<Message> conversationMessages = [];

      // Check messages of each user
      [currentUser.id, otherUserId].forEach((userId) {
        if (_mockMessages.containsKey(userId)) {
          for (var message in _mockMessages[userId]!) {
            if ((message.sender['_id'] == currentUser.id &&
                    message.receiver['_id'] == otherUserId) ||
                (message.sender['_id'] == otherUserId &&
                    message.receiver['_id'] == currentUser.id)) {
              conversationMessages.add(message);
            }
          }
        }
      });

      // Sort messages by date
      conversationMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // If no messages found, return admin messages for demo
      if (conversationMessages.isEmpty && otherUserId == '100') {
        // Mark messages as read (only received messages)
        for (var message in _adminMessages) {
          if (message.receiver['_id'] == currentUser.id) {
            // Note: In a real app, you'd create a new Message with isRead: true
            // For now, we'll just return the messages as they are
          }
        }

        // Update unread message count
        return List.from(_adminMessages);
      }

      return conversationMessages;
    } catch (e) {
      rethrow;
    }
  }

  // Send message
  Future<Message> sendMessage(String receiverId, String content) async {
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

      // Create new message
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: senderInfo,
        receiver: {'_id': receiverId, 'name': 'Receiver User'},
        content: content,
        createdAt: DateTime.now(),
        isRead: false,
      );

      // For demo purposes, we'll add a mock response
      final responseMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: {'_id': receiverId, 'name': 'Receiver User'},
        receiver: senderInfo,
        content: 'Thank you for your message! I will get back to you soon.',
        createdAt: DateTime.now().add(const Duration(seconds: 5)),
        isRead: false,
      );

      // Add message - with sender's ID
      String senderId = senderInfo['_id'];
      if (!_mockMessages.containsKey(senderId)) {
        _mockMessages[senderId] = [];
      }
      _mockMessages[senderId]!.add(newMessage);

      // Add response message
      if (!_mockMessages.containsKey(receiverId)) {
        _mockMessages[receiverId] = [];
      }
      _mockMessages[receiverId]!.add(responseMessage);

      // If sending to admin (id: '100'), also add to admin messages for immediate visibility
      if (receiverId == '100') {
        _adminMessages.add(newMessage);

        // Add a delayed response to admin messages
        Future.delayed(const Duration(seconds: 2), () {
          _adminMessages.add(responseMessage);
        });
      }

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
