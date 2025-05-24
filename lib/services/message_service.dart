import '../models/message_model.dart';
import '../models/conversation_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class MessageService {
  final AuthService _authService = AuthService();

  // Mock konuşmalar ve mesajlar
  final List<Map<String, dynamic>> _conversations = [
    {
      'user': {
        '_id': '100',
        'name': 'Admin User',
        'email': AuthService.ADMIN_EMAIL
      },
      'lastMessage': {
        '_id': '1',
        'sender': {'_id': '100', 'name': 'Admin User'},
        'receiver': {'_id': '1001', 'name': 'Test User'},
        'content': 'Merhaba, sisteme hoş geldiniz!',
        'isRead': false,
        'createdAt':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      'unreadCount': 1,
    }
  ];

  // Kullanıcı ID'ye göre mesajlar listesi
  final Map<String, List<Map<String, dynamic>>> _messages = {
    '100': [
      // Admin kullanıcısı ile olan mesajlar
      {
        '_id': '1',
        'sender': {'_id': '100', 'name': 'Admin User'},
        'receiver': {'_id': '1001', 'name': 'Test User'},
        'content': 'Merhaba, sisteme hoş geldiniz!',
        'isRead': false,
        'createdAt':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      }
    ]
  };

  // Get all conversations
  Future<List<Conversation>> getConversations() async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Konuşmalarınızı görmek için giriş yapmalısınız');
      }

      // Kullanıcının konuşmalarını filtrele
      final userConversations = _conversations.where((conversation) {
        final lastMessage = conversation['lastMessage'];
        return lastMessage['sender']['_id'] == currentUser.id ||
            lastMessage['receiver']['_id'] == currentUser.id;
      }).toList();

      // Konuşmaların karşı tarafını belirle (eğer gönderen kullanıcı ise alıcıyı, alıcı kullanıcı ise göndereni göster)
      for (var conversation in userConversations) {
        final lastMessage = conversation['lastMessage'];
        if (lastMessage['sender']['_id'] == currentUser.id) {
          conversation['user'] = lastMessage['receiver'];
        } else {
          conversation['user'] = lastMessage['sender'];
        }
      }

      return userConversations
          .map((conversation) => Conversation.fromJson(conversation))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get conversation with user
  Future<Map<String, dynamic>> getConversationWithUser(String userId) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Mesajlarınızı görmek için giriş yapmalısınız');
      }

      // Kullanıcı bilgilerini bul
      Map<String, dynamic>? user;
      for (var conversation in _conversations) {
        final lastMessage = conversation['lastMessage'];
        if ((lastMessage['sender']['_id'] == userId &&
                lastMessage['receiver']['_id'] == currentUser.id) ||
            (lastMessage['receiver']['_id'] == userId &&
                lastMessage['sender']['_id'] == currentUser.id)) {
          if (lastMessage['sender']['_id'] == userId) {
            user = lastMessage['sender'];
          } else {
            user = lastMessage['receiver'];
          }
          break;
        }
      }

      // Yeni bir kullanıcı ile konuşma başlatıldığında
      if (user == null) {
        // Yeni bir kullanıcı oluştur (gerçekte API'den gelecek)
        user = {
          '_id': userId,
          'name': 'Yeni Kullanıcı',
          'email': 'user@example.com'
        };
      }

      // İki kullanıcı arasındaki tüm mesajları bul
      List<Map<String, dynamic>> allUserMessages = [];

      // Her kullanıcının mesajlarını kontrol et
      _messages.forEach((key, messagesList) {
        for (var message in messagesList) {
          if ((message['sender']['_id'] == currentUser.id &&
                  message['receiver']['_id'] == userId) ||
              (message['receiver']['_id'] == currentUser.id &&
                  message['sender']['_id'] == userId)) {
            allUserMessages.add(message);
          }
        }
      });

      // Mesajları tarih sırasına göre sırala
      allUserMessages.sort((a, b) {
        DateTime aDate = DateTime.parse(a['createdAt']);
        DateTime bDate = DateTime.parse(b['createdAt']);
        return aDate.compareTo(bDate);
      });

      // Mesajları okundu olarak işaretle (sadece alınan mesajlar)
      for (var message in allUserMessages) {
        if (message['receiver']['_id'] == currentUser.id) {
          message['isRead'] = true;
        }
      }

      // Okunmamış mesaj sayısını güncelle
      for (var conversation in _conversations) {
        final lastMessage = conversation['lastMessage'];
        if ((lastMessage['sender']['_id'] == userId &&
                lastMessage['receiver']['_id'] == currentUser.id) ||
            (lastMessage['receiver']['_id'] == userId &&
                lastMessage['sender']['_id'] == currentUser.id)) {
          conversation['unreadCount'] = 0;
          break;
        }
      }

      final messages = allUserMessages
          .map<Message>((message) => Message.fromJson(message))
          .toList();

      return {
        'user': user,
        'messages': messages,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Send message
  Future<Message> sendMessage(String receiverId, String content,
      {String? relatedBookId}) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Mesaj göndermek için giriş yapmalısınız');
      }

      // Yeni mesaj oluştur
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final messageData = {
        '_id': messageId,
        'sender': {
          '_id': currentUser.id,
          'name': currentUser.name,
          'email': currentUser.email
        },
        'receiver': {'_id': receiverId, 'name': 'Alıcı Kullanıcı'},
        'content': content,
        'relatedBook': relatedBookId != null ? {'_id': relatedBookId} : null,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Mesajı ekle - gönderenin ID'si ile
      if (!_messages.containsKey(currentUser.id)) {
        _messages[currentUser.id] = [];
      }
      _messages[currentUser.id]!.add(messageData);

      // Konuşmayı güncelle veya ekle
      bool conversationExists = false;
      for (var conversation in _conversations) {
        final lastMessage = conversation['lastMessage'];
        if ((lastMessage['sender']['_id'] == receiverId &&
                lastMessage['receiver']['_id'] == currentUser.id) ||
            (lastMessage['receiver']['_id'] == receiverId &&
                lastMessage['sender']['_id'] == currentUser.id)) {
          conversation['lastMessage'] = messageData;
          // Alıcı tarafındaki okunmamış mesaj sayısını artır
          if (lastMessage['receiver']['_id'] == receiverId) {
            conversation['unreadCount'] =
                (conversation['unreadCount'] ?? 0) + 1;
          }
          conversationExists = true;
          break;
        }
      }

      // Yeni konuşma oluştur
      if (!conversationExists) {
        _conversations.add({
          'user': {'_id': receiverId, 'name': 'Alıcı Kullanıcı'},
          'lastMessage': messageData,
          'unreadCount': 1,
        });
      }

      return Message.fromJson(messageData);
    } catch (e) {
      rethrow;
    }
  }
}
