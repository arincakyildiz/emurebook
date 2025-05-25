import 'package:flutter/material.dart';
import 'package:emurebook/services/book_service.dart';
import 'package:emurebook/models/book_model.dart';
import 'add_listing_screen.dart';
import 'book_detail_screen.dart';
import 'dart:io';

class ListingsScreen extends StatefulWidget {
  final Map<String, String> lang;
  final void Function(String) onMessageSent;
  final bool showOnlyMine;
  final VoidCallback? onBookAdded;

  const ListingsScreen({
    super.key,
    required this.lang,
    required this.onMessageSent,
    this.showOnlyMine = false,
    this.onBookAdded,
  });

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = true;
  String _selectedExchangeType = 'All'; // All, Sell, Exchange
  String _selectedCondition = 'All'; // All, Like New, Good, Fair

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

  List<Book> get _filteredBooks {
    List<Book> filtered = _books;

    // Filter by exchange type
    if (_selectedExchangeType != 'All') {
      filtered = filtered
          .where((book) => book.exchangeType == _selectedExchangeType)
          .toList();
    }

    // Filter by condition
    if (_selectedCondition != 'All') {
      filtered = filtered
          .where((book) => book.condition == _selectedCondition)
          .toList();
    }

    return filtered;
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exchange Type Filter
          Row(
            children: [
              const Text(
                'Type: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildExchangeTypeChip('All', Icons.all_inclusive),
                      const SizedBox(width: 8),
                      _buildExchangeTypeChip('Sell', Icons.sell),
                      const SizedBox(width: 8),
                      _buildExchangeTypeChip('Exchange', Icons.swap_horiz),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Condition Filter
          Row(
            children: [
              const Text(
                'Condition: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildConditionChip('All', Icons.all_inclusive),
                      const SizedBox(width: 8),
                      _buildConditionChip('Like New', Icons.star),
                      const SizedBox(width: 8),
                      _buildConditionChip('Good', Icons.thumb_up),
                      const SizedBox(width: 8),
                      _buildConditionChip('Fair', Icons.info),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeTypeChip(String type, IconData icon) {
    final isSelected = _selectedExchangeType == type;
    Color chipColor;

    switch (type) {
      case 'Sell':
        chipColor = Colors.green;
        break;
      case 'Exchange':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedExchangeType = type;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget _buildConditionChip(String condition, IconData icon) {
    final isSelected = _selectedCondition == condition;
    Color chipColor;

    switch (condition) {
      case 'Like New':
        chipColor = Colors.green;
        break;
      case 'Good':
        chipColor = Colors.blue;
        break;
      case 'Fair':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            condition,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedCondition = condition;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget _buildBookImage(String? imageUrl) {
    if (imageUrl == null) {
      return const Icon(Icons.book, size: 40);
    }

    // Check if it's a file path (starts with '/' or contains ':' for Windows)
    if (imageUrl.startsWith('/') || imageUrl.contains(':')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    // Check if it's an asset
    if (imageUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.book, size: 40);
          },
        ),
      );
    }

    // Default fallback
    return const Icon(Icons.book, size: 40);
  }

  void _openBookDetail(Book book) {
    // Convert Book model to the format expected by BookDetailScreen
    final bookData = {
      'title': book.title,
      'author': book.author,
      'image': book.imageUrl ?? 'assets/images/emu_logo.png',
      'rating': book.averageRating,
      'price': '₺${book.price.toStringAsFixed(0)}',
      'description': book.description ?? 'No description available.',
      'condition': book.condition,
      'category': book.category,
      'exchangeType': book.exchangeType,
      'owner': book.owner,
      'language': book.language,
      'publisher': book.publisher,
      'publishedYear': book.publishedYear,
      'availability': book.availability,
      'label': book.exchangeType,
      'labelColor': book.exchangeType == 'Sell' ? Colors.green : Colors.blue,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(
          book: bookData,
          lang: widget.lang,
          onMessageSent: widget.onMessageSent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _filteredBooks;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showOnlyMine ? 'My Books' : 'All Books'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBooks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedExchangeType == 'All' &&
                                      _selectedCondition == 'All'
                                  ? Icons.book_outlined
                                  : Icons.filter_list_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedExchangeType == 'All' &&
                                      _selectedCondition == 'All'
                                  ? 'No books found. Add a new one!'
                                  : 'No books match your filters.',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            if (_selectedExchangeType != 'All' ||
                                _selectedCondition != 'All') ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedExchangeType = 'All';
                                    _selectedCondition = 'All';
                                  });
                                },
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            child: InkWell(
                              onTap: () => _openBookDetail(book),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    _buildBookImage(book.imageUrl),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'by ${book.author}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (book.description != null &&
                                              book.description!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              book.description!,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                'Seller: ${book.owner['name']}',
                                                style: TextStyle(
                                                  color: Colors.blue[600],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getConditionColor(
                                                      book.condition),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  book.condition.toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₺${book.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D66F4),
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: book.exchangeType == 'Sell'
                                                ? Colors.green
                                                : Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            book.exchangeType.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddListingScreen()),
          );
          if (result == true) {
            _loadBooks(); // Reload books after adding a new one
            widget.onBookAdded?.call(); // Notify parent that a book was added
          }
        },
        backgroundColor: const Color(0xFF2D66F4),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Like New':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
