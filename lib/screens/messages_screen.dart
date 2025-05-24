import 'package:flutter/material.dart';
import '../services/service_provider.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final Map<String, String> lang;
  const MessagesScreen({super.key, required this.lang});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageService = ServiceProvider().messageService;
  final _authService = ServiceProvider().authService;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadConversations();
  }

  Future<void> _checkAuthAndLoadConversations() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check if user is logged in
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _isUserLoggedIn = false;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isUserLoggedIn = true;
      });

      await _loadConversations();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isUserLoggedIn = false;
      });
    }
  }

  Future<void> _loadConversations() async {
    if (!_isUserLoggedIn) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final conversations = await _messageService.getConversations();

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // If there's an error loading conversations, show default admin conversation
      setState(() {
        _conversations = [
          {
            'otherUser': {
              '_id': '100',
              'name': 'Admin User',
            },
            'lastMessage': 'Welcome to EmuReBook! How can I help you?',
            'timestamp': DateTime.now(),
            'unreadCount': 0,
          }
        ];
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Same day - show time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return widget.lang['yesterday'] ?? 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${widget.lang['days_ago'] ?? 'days ago'}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.lang['login_required'] ?? 'Login Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.lang['login_to_messages'] ??
                  'Please log in to view your messages',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(widget.lang['login'] ?? 'Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lang['messages'] ?? 'Messages'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: !_isUserLoggedIn
          ? _buildLoginPrompt()
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.lang['no_conversations'] ??
                                'No conversations yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.lang['start_messaging'] ??
                                'Start messaging with book owners!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _conversations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          final otherUser = conversation['otherUser'];
                          final lastMessage =
                              conversation['lastMessage'] as String;
                          final timestamp =
                              conversation['timestamp'] as DateTime;
                          final unreadCount =
                              conversation['unreadCount'] as int;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    otherUser['name'].isNotEmpty
                                        ? otherUser['name'][0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    otherUser['name'],
                                    style: TextStyle(
                                      fontWeight: unreadCount > 0
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatTime(timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: unreadCount > 0
                                        ? Colors.blue[700]
                                        : Colors.grey[600],
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                lastMessage,
                                style: TextStyle(
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: unreadCount > 0
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    recipientId: otherUser['_id'],
                                    recipientName: otherUser['name'],
                                    lang: widget.lang,
                                  ),
                                ),
                              );

                              // Refresh conversations when returning from chat
                              if (result != null || mounted) {
                                _loadConversations();
                              }
                            },
                          );
                        },
                      ),
                    ),
      floatingActionButton: _isUserLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                // Navigate to admin chat for demo purposes
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      recipientId: '100',
                      recipientName: 'Admin User',
                      lang: widget.lang,
                    ),
                  ),
                );

                // Refresh conversations when returning from chat
                if (result != null || mounted) {
                  _loadConversations();
                }
              },
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.add_comment, color: Colors.white),
            )
          : null,
    );
  }
}
