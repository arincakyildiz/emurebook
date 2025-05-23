import 'package:flutter/material.dart';
import 'add_listing_screen.dart';
import 'book_detail_screen.dart';

class ListingsScreen extends StatefulWidget {
  final Map<String, String> lang;
  final void Function(String) onMessageSent;
  final bool showOnlyMine;
  const ListingsScreen({super.key, required this.lang, required this.onMessageSent, this.showOnlyMine = false});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedCondition = 'All';
  String _selectedType = 'All'; // All, SELL, EXCHANGE
  List<Map<String, dynamic>> listings = [
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
      'owner': '',
    },
    {
      'title': 'Calculus',
      'author': 'Early Transcendentals',
      'price': 200,
      'image': 'assets/images/calculus.jpg',
      'label': 'SELL',
      'labelColor': Colors.blue,
      'description': 'Textbook on calculus with early transcendental approach.',
      'rating': 4.2,
      'reviews': 95,
      'condition': 'Good',
      'owner': '',
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
      'owner': '',
    },
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
      'owner': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final String currentUserEmail = '22000257@emu.edu.tr'; // Giriş yapan kullanıcı
    final isMyListings = widget.showOnlyMine;
    final filteredListings = (isMyListings
      ? listings.where((book) => book['owner'] == currentUserEmail && book['owner'].toString().isNotEmpty)
      : listings
    ).where((book) {
      final price = book['price'] as int;
      final condition = book['condition'] as String;
      final type = book['label'] as String;
      return price >= _priceRange.start && 
             price <= _priceRange.end && 
             (_selectedCondition == 'All' || _selectedCondition == condition) &&
             (_selectedType == 'All' || _selectedType == type);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.lang['listings'] ?? 'Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Type Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip('All'),
                  _buildTypeChip('SELL'),
                  _buildTypeChip('EXCHANGE'),
                ],
              ),
            ),
          ),
          // Listings
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredListings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildListingCard(context, filteredListings[index], canDelete: isMyListings),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBook = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddListingScreen()),
          );
          
          if (newBook != null) {
            setState(() {
              listings.insert(0, newBook);
            });
          }
        },
        backgroundColor: const Color(0xFF2D66F4),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, Map<String, dynamic> book, {bool canDelete = false}) {
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.asset(
                        book['image'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: book['labelColor'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
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
              ],
            ),
            if (canDelete)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(lang['delete'] ?? 'Delete'),
                        content: Text(lang['delete_confirm'] ?? 'Are you sure you want to delete this listing?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(lang['close'] ?? 'Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                listings.removeWhere((b) => b['title'] == book['title']);
                              });
                              Navigator.pop(ctx);
                            },
                            child: Text(lang['delete'] ?? 'Delete', style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(type),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedType = type;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF2D66F4).withAlpha(51),
        checkmarkColor: const Color(0xFF2D66F4),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2D66F4) : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String tempSelectedCondition = _selectedCondition;
    RangeValues tempPriceRange = _priceRange;
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
                  Text(
                    widget.lang['filterBooks'] ?? 'Filter Listings',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D66F4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        tempPriceRange = const RangeValues(0, 1000);
                        tempSelectedCondition = 'All';
                      });
                    },
                    child: Text(
                      widget.lang['reset'] ?? 'Reset',
                      style: const TextStyle(
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
              Text(
                widget.lang['priceRange'] ?? 'Price Range',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: tempPriceRange,
                min: 0,
                max: 1000,
                divisions: 10,
                labels: RangeLabels(
                  '₺${tempPriceRange.start.round()}',
                  '₺${tempPriceRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() {
                    tempPriceRange = values;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                widget.lang['condition'] ?? 'Condition',
                style: const TextStyle(
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
                  ...['All', 'Like New', 'Good', 'Fair'].map((c) {
                    String label = c;
                    if (c == 'All') label = widget.lang['all'] ?? 'All';
                    if (c == 'Like New') label = widget.lang['like_new'] ?? 'Like New';
                    if (c == 'Good') label = widget.lang['good'] ?? 'Good';
                    if (c == 'Fair') label = widget.lang['fair'] ?? 'Fair';
                    final selected = tempSelectedCondition == c;
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected) ...[
                            const Icon(Icons.check, size: 18, color: Colors.white),
                            SizedBox(width: 4),
                          ],
                          Text(label),
                        ],
                      ),
                      selected: selected,
                      onSelected: (selected) {
                        setState(() {
                          tempSelectedCondition = c;
                        });
                      },
                      backgroundColor: selected ? const Color(0xFF2D66F4) : Colors.grey[200],
                      selectedColor: const Color(0xFF2D66F4),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.grey[800],
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      shape: StadiumBorder(
                        side: selected
                            ? const BorderSide(color: Color(0xFF2D66F4), width: 2)
                            : BorderSide.none,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _priceRange = tempPriceRange;
                      _selectedCondition = tempSelectedCondition;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D66F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.lang['applyFilters'] ?? 'Apply Filters',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.white,
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
}
