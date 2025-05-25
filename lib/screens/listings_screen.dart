import 'package:flutter/material.dart';
import 'package:emurebook/services/book_service.dart';
import 'package:emurebook/models/book_model.dart';
import 'add_listing_screen.dart';
import 'book_detail_screen.dart';
import 'dart:io';

class ListingsScreen extends StatefulWidget {
  final Map<String, String> lang;
  final void Function(String) onMessageSent;
  final VoidCallback? onBookAdded;

  const ListingsScreen({
    super.key,
    required this.lang,
    required this.onMessageSent,
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
      // Load only current user's books for listings screen
      final books = await _bookService.getUserBooks();
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
          .where((book) => book.exchangeType.contains(_selectedExchangeType))
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
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const SizedBox(
                  width: 60,
                  child: Text(
                    'Type:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildExchangeTypeChip('All', Icons.all_inclusive),
                      const SizedBox(width: 6),
                      _buildExchangeTypeChip('Sell', Icons.sell),
                      const SizedBox(width: 6),
                      _buildExchangeTypeChip('Exchange', Icons.swap_horiz),
                      const SizedBox(width: 16), // Extra padding at end
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Condition Filter
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const SizedBox(
                  width: 60,
                  child: Text(
                    'Condition:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildConditionChip('All', Icons.all_inclusive),
                      const SizedBox(width: 6),
                      _buildConditionChip('Like New', Icons.star),
                      const SizedBox(width: 6),
                      _buildConditionChip('Good', Icons.thumb_up),
                      const SizedBox(width: 6),
                      _buildConditionChip('Fair', Icons.info),
                      const SizedBox(width: 16), // Extra padding at end
                    ],
                  ),
                ),
              ],
            ),
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
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 3),
          Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 3),
          Text(
            condition,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        title: Text(widget.lang['manage_listings'] ?? 'My Books'),
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
                                  ? 'You haven\'t added any books yet. Add your first book!'
                                  : 'None of your books match the selected filters.',
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
                                        _buildExchangeTypeBadges(
                                            book.exchangeType),
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

  Widget _buildExchangeTypeBadges(String exchangeTypes) {
    final types =
        exchangeTypes.split(', ').where((type) => type.isNotEmpty).toList();

    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: types.map((type) {
        Color badgeColor;
        switch (type.trim()) {
          case 'Sell':
            badgeColor = Colors.green;
            break;
          case 'Exchange':
            badgeColor = Colors.blue;
            break;
          default:
            badgeColor = Colors.grey;
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            type.trim().toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
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
