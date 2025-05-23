import 'package:flutter/material.dart';

class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exchangeBooks = List.generate(
      5,
      (index) => {
        'title': 'Exchange Book ${index + 1}',
        'owner': 'User ${index + 1}',
        'image': 'https://via.placeholder.com/100x140',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Books'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D66F4),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exchangeBooks.length,
        itemBuilder: (context, index) {
          final book = exchangeBooks[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/book-detail');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: Image.network(
                      book['image']!,
                      width: 110,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A1034),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Owner: ${book['owner']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/book-detail');
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2D66F4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Exchange',
                                style: TextStyle(color: Color(0xFF2D66F4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
