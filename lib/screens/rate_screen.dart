import 'package:flutter/material.dart';

class RateScreen extends StatefulWidget {
  final Map<String, String> lang;
  const RateScreen({super.key, required this.lang});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _selectedRating = 0;
  final TextEditingController _controller = TextEditingController();

  void _submitRating() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a rating.")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.lang['thank_you_title'] ?? "Thank You!"),
        content: Text(widget.lang['thank_you_message'] ??
            "Your feedback has been submitted."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(widget.lang['close'] ?? "Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: _selectedRating >= index ? Colors.orange : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _selectedRating = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lang['rate_the_book'] ?? 'Rate the Book'),
        backgroundColor: const Color(0xFF2D66F4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lang['how_was_your_experience'] ??
                  "How was your experience?",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            const SizedBox(height: 20),
            Text(
              widget.lang['leave_a_comment'] ?? "Leave a comment (optional):",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: widget.lang['write_your_feedback_here'] ??
                    "Write your feedback here...",
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D66F4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.lang['submit'] ?? "Submit",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
