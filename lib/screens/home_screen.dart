import 'package:flutter/material.dart';
import 'book_detail_screen.dart';
import 'all_books_screen.dart';
import '../services/service_provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final Map<String, String> lang;
  final String selectedLanguage;
  final void Function(String) onMessageSent;
  final void Function(String) onLanguageChanged;
  final List<String> notifications;
  final void Function(VoidCallback)? onRefreshCallback;
  const HomeScreen(
      {super.key,
      required this.lang,
      required this.selectedLanguage,
      required this.onMessageSent,
      required this.onLanguageChanged,
      required this.notifications,
      this.onRefreshCallback});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedCondition = 'All';
  String _selectedExchangeType = 'All'; // All, Sell, Exchange
  String _searchQuery = '';
  final _bookService = ServiceProvider().bookService;
  List<Map<String, dynamic>> _userAddedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadUserBooks();
    widget.onRefreshCallback?.call(refreshBooks);
  }

  Future<void> _loadUserBooks() async {
    try {
      final userBooks = await _bookService.getRecentlyAddedBooks();
      if (mounted) {
        setState(() {
          _userAddedBooks = userBooks;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  // Public method to refresh books from outside
  void refreshBooks() {
    _loadUserBooks();
  }

  void addNotification(String msg) {
    setState(() {
      widget.notifications.insert(0, msg);
    });
  }

  Widget _buildBookImage(String imagePath, {double? width, double? height}) {
    // Check if it's a file path (starts with '/' or contains ':' for Windows)
    if (imagePath.startsWith('/') || imagePath.contains(':')) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

    // Check if it's an asset or fallback to asset
    return Image.asset(
      imagePath.startsWith('assets/')
          ? imagePath
          : 'assets/images/emu_logo.png',
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width ?? double.infinity,
          color: Colors.grey[300],
          child: const Icon(
            Icons.book,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final popularBooks = [
      {
        'title': 'Introduction to Algorithms',
        'author': 'Cormen et al',
        'price': 150,
        'image': 'assets/images/algorithms.jpg',
        'label': 'EXCHANGE',
        'labelColor': Colors.green,
        'description': 'Comprehensive textbook on algorithms.',
        'rating': 4.5,
        'reviews': 128,
        'condition': 'Like New',
        'exchangeType': 'Exchange',
      },
      {
        'title': 'Calculus',
        'author': 'Early Transcendentals',
        'price': 200,
        'image': 'assets/images/calculus.jpg',
        'label': 'SELL',
        'labelColor': Colors.blue,
        'description':
            'Textbook on calculus with early transcendental approach.',
        'rating': 4.2,
        'reviews': 95,
        'condition': 'Good',
        'exchangeType': 'Sell',
      },
      {
        'title': 'Operating System Concepts',
        'author': 'Silberschatz et al',
        'price': 180,
        'image': 'assets/images/os.jpg',
        'label': 'EXCHANGE',
        'labelColor': Colors.green,
        'description': 'Core concepts of modern operating systems.',
        'rating': 4.7,
        'reviews': 156,
        'condition': 'Like New',
        'exchangeType': 'Exchange',
      },
    ];

    final staticNewlyAdded = [
      {
        'title': 'Computer Networking',
        'author': 'Kurose & Ross',
        'price': 140,
        'image': 'assets/images/networking.jpg',
        'label': 'SELL',
        'labelColor': Colors.blue,
        'description': 'Book covering computer network principles.',
        'rating': 4.3,
        'reviews': 87,
        'condition': 'Good',
        'exchangeType': 'Sell',
      },
      {
        'title': 'Engineering Mechanics',
        'author': 'Hibbeler',
        'price': 100,
        'image': 'assets/images/mechanics.jpg',
        'label': 'EXCHANGE',
        'labelColor': Colors.green,
        'description': 'Engineering statics and dynamics reference.',
        'rating': 4.1,
        'reviews': 72,
        'condition': 'Like New',
        'exchangeType': 'Exchange',
      },
    ];

    // Combine static books with user-added books
    final newlyAdded = [..._userAddedBooks, ...staticNewlyAdded];

    // Search filter
    final lowerQuery = _searchQuery.toLowerCase();
    final filteredPopularBooks = popularBooks.where((book) {
      final price = book['price'] as int;
      final condition = book['condition'] as String;
      final exchangeType = book['exchangeType'] as String;
      final matchesSearch = ((book['title'] as String?)?.toLowerCase() ?? '')
              .contains(lowerQuery) ||
          ((book['author'] as String?)?.toLowerCase() ?? '')
              .contains(lowerQuery);
      return price >= _priceRange.start &&
          price <= _priceRange.end &&
          (_selectedCondition == 'All' || _selectedCondition == condition) &&
          (_selectedExchangeType == 'All' ||
              exchangeType.contains(_selectedExchangeType)) &&
          (lowerQuery.isEmpty || matchesSearch);
    }).toList();

    final filteredNewlyAdded = newlyAdded.where((book) {
      final price = book['price'] as int;
      final condition = book['condition'] as String;
      final exchangeType = book['exchangeType'] as String? ?? 'Sell';
      final matchesSearch = ((book['title'] as String?)?.toLowerCase() ?? '')
              .contains(lowerQuery) ||
          ((book['author'] as String?)?.toLowerCase() ?? '')
              .contains(lowerQuery);
      return price >= _priceRange.start &&
          price <= _priceRange.end &&
          (_selectedCondition == 'All' || _selectedCondition == condition) &&
          (_selectedExchangeType == 'All' ||
              exchangeType.contains(_selectedExchangeType)) &&
          (lowerQuery.isEmpty || matchesSearch);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/emu_logo.png', height: 32),
            const SizedBox(width: 8),
            Text(
              'EmuReBook',
              style: const TextStyle(
                color: Color(0xFF2D66F4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.lang['selectLanguage']!),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: Text(widget.lang['english']!),
                        value: 'English',
                        groupValue: widget.selectedLanguage,
                        onChanged: (val) {
                          widget.onLanguageChanged('English');
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(widget.lang['turkish']!),
                        value: 'Türkçe',
                        groupValue: widget.selectedLanguage,
                        onChanged: (val) {
                          widget.onLanguageChanged('Türkçe');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.lang['notifications']!),
                  content: SizedBox(
                    width: 300,
                    child: widget.notifications.isEmpty
                        ? Text(widget.lang['noNotifications']!)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.notifications
                                .map((n) => ListTile(
                                      leading: const Icon(Icons.message,
                                          color: Color(0xFF2D66F4)),
                                      title: Text(n),
                                    ))
                                .toList(),
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(widget.lang['close']!),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserBooks,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: widget.lang['searchHint'],
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.grey),
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Popular Books
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.lang['popular']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D66F4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllBooksScreen(
                            books: filteredPopularBooks,
                            title: widget.lang['popular']!,
                            lang: widget.lang,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.lang['seeAll']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D66F4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredPopularBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) => SizedBox(
                    width: 180,
                    child: _buildBookCard(context, filteredPopularBooks[index]),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Newly Added
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.lang['newlyAdded']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D66F4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllBooksScreen(
                            books: filteredNewlyAdded,
                            title: widget.lang['newlyAdded']!,
                            lang: widget.lang,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.lang['seeAll']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D66F4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...filteredNewlyAdded.map(
                (book) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildBookCard(context, book, isVertical: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    Map<String, dynamic> book, {
    bool isVertical = false,
  }) {
    final lang = widget.lang;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(
              book: book,
              lang: lang,
              onMessageSent: widget.onMessageSent,
            ),
          ),
        );
      },
      child: Container(
        width: isVertical ? double.infinity : null,
        height: isVertical ? 320 : 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildBookImage(
                    book['image'],
                    height: isVertical ? 180 : 120,
                  ),
                ),
                if (book['label'] != null && book['label'].isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: book['labelColor'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book['label'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        height: 1.3,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['author'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺${book['price']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2D66F4),
                            letterSpacing: 0.2,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book['rating'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Books',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D66F4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _priceRange = const RangeValues(0, 1000);
                        _selectedCondition = 'All';
                        _selectedExchangeType = 'All';
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D66F4),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 10,
                labels: RangeLabels(
                  '₺${_priceRange.start.round()}',
                  '₺${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Exchange Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildExchangeTypeChip('All'),
                  _buildExchangeTypeChip('Sell'),
                  _buildExchangeTypeChip('Exchange'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Condition',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildConditionChip('All'),
                  _buildConditionChip('Like New'),
                  _buildConditionChip('Good'),
                  _buildConditionChip('Fair'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    this.setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D66F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
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
      ),
    );
  }

  Widget _buildExchangeTypeChip(String exchangeType) {
    final isSelected = _selectedExchangeType == exchangeType;
    Color chipColor;
    IconData chipIcon;

    switch (exchangeType) {
      case 'Sell':
        chipColor = Colors.green;
        chipIcon = Icons.sell;
        break;
      case 'Exchange':
        chipColor = Colors.blue;
        chipIcon = Icons.swap_horiz;
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.all_inclusive;
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chipIcon,
            size: 16,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 4),
          Text(exchangeType),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedExchangeType = exchangeType;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    final isSelected = _selectedCondition == condition;
    Color chipColor;
    IconData chipIcon;

    switch (condition) {
      case 'Like New':
        chipColor = Colors.green;
        chipIcon = Icons.star;
        break;
      case 'Good':
        chipColor = Colors.blue;
        chipIcon = Icons.thumb_up;
        break;
      case 'Fair':
        chipColor = Colors.orange;
        chipIcon = Icons.info;
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.all_inclusive;
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chipIcon,
            size: 16,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 4),
          Text(condition),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedCondition = condition;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14,
        letterSpacing: 0.2,
      ),
    );
  }
}
