import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final Map<String, String> lang;
  const MessagesScreen({super.key, required this.lang});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();
    messages = [
      {
        "sender": "Ali",
        "text": "Is this book still available?",
        "time": "10:30 AM",
        "unread": true,
      },
      {
        "sender": "Ahmet Arınç Akyıldız",
        "text": "I'm interested in your listing.",
        "time": "Yesterday",
        "unread": false,
      },
      {
        "sender": "Emre",
        "text": "Can we exchange next week?",
        "time": "2 days ago",
        "unread": true,
      },
    ];
  }

  void _markMessageAsRead(int index) {
    setState(() {
      messages[index]['unread'] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lang['messages'] ?? 'Messages'),
        backgroundColor: const Color(0xFF2D66F4),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final message = messages[index];
          final String sender = message['sender'] as String;
          final String text = message['text'] as String;
          final String time = message['time'] as String;
          final bool unread = message['unread'] as bool;

          return ListTile(
            leading: Stack(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                if (unread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sender,
                  style: TextStyle(
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            subtitle: Text(
              text,
              style: TextStyle(
                fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            onTap: () {
              _markMessageAsRead(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    recipientName: sender,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
