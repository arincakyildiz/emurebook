import 'package:flutter/material.dart';
import './book_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final Map<String, String> lang;
  const FavoritesScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final favBooks = BookDetailScreenFavorites.favoriteBooks;
    // Dummy book data for demo (gerçek uygulamada favori kitapların tüm verisi tutulmalı)
    // Şimdilik sadece başlık üzerinden arama yapıyoruz.
    final allBooks = [
      // Buraya örnek kitaplar eklenebilir veya global bir kitap listesi kullanılabilir
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(lang['my_favorites'] ?? 'My Favorites'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: favBooks.isEmpty
          ? Center(
              child: Text(
                lang['no_favorites'] ?? 'No favorites yet.',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView(
              children: favBooks.map((book) => ListTile(
                leading: book['image'] != null && book['image'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          book['image'],
                          width: 40,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.book, size: 40, color: Colors.grey),
                title: Text(book['title'] ?? ''),
                subtitle: Text(book['author'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(
                        book: book,
                        lang: lang,
                      ),
                    ),
                  );
                },
              )).toList(),
            ),
    );
  }
} 