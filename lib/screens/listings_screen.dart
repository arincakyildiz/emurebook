import 'package:flutter/material.dart';
import 'package:emurebook/services/book_service.dart';
import 'package:emurebook/models/book_model.dart';
import 'add_listing_screen.dart';

class ListingsScreen extends StatefulWidget {
  final Map<String, String> lang;
  final void Function(String) onMessageSent;
  final bool showOnlyMine;

  const ListingsScreen({
    super.key,
    required this.lang,
    required this.onMessageSent,
    this.showOnlyMine = false,
  });

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _bookService.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showOnlyMine ? 'My Books' : 'All Books'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? const Center(
                  child: Text(
                    'No books found. Add a new one!',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: const Icon(Icons.book, size: 40),
                        title: Text(
                          book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('by ${book.author}'),
                        trailing: Text(
                          '₺${book.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D66F4),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddListingScreen()),
          );
          if (result == true) {
            _loadBooks(); // Reload books after adding a new one
          }
        },
        backgroundColor: const Color(0xFF2D66F4),
        child: const Icon(Icons.add),
      ),
    );
  }
}
