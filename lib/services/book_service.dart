import '../models/book_model.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'service_provider.dart';
import 'auth_service.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  // Simple static book list
  static final List<Book> _books = [];

  // Get AuthService from ServiceProvider
  AuthService get _authService => ServiceProvider().authService;

  // Add a book
  Future<Book> addBook(
    String title,
    String author,
    double price, {
    String? description,
    File? imageFile,
    String exchangeType = 'Sell',
    String condition = 'Good',
  }) async {
    // For now, we'll just use a placeholder image path or the provided file path
    String imageUrl = 'assets/images/emu_logo.png';
    if (imageFile != null) {
      // In a real app, you would upload this to a server and get back a URL
      // For now, we'll just use the file path
      imageUrl = imageFile.path;
    }

    // Get current user information
    final currentUser = _authService.currentUser;
    Map<String, dynamic> owner;

    if (currentUser != null) {
      owner = {
        '_id': currentUser.id,
        'name': currentUser.name,
        'email': currentUser.email,
      };
    } else {
      // Create a default test user instead of guest
      owner = {
        '_id': 'test_user_1',
        'name': 'Test User',
        'email': 'test@emu.edu.tr'
      };
    }

    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: author,
      description: description ?? 'A book by $author',
      imageUrl: imageUrl,
      condition: condition,
      price: price,
      category: 'General',
      exchangeType: exchangeType,
      owner: owner,
      language: 'English',
      availability: true,
      createdAt: DateTime.now(),
    );

    _books.add(newBook);
    return newBook;
  }

  // Get all books
  Future<List<Book>> getAllBooks() async {
    return List.from(_books);
  }

  // Get books for current user only (for listings screen)
  Future<List<Book>> getUserBooks() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return [];
    }

    return _books.where((book) => book.owner['_id'] == currentUser.id).toList();
  }

  // Get books formatted for home screen display
  Future<List<Map<String, dynamic>>> getBooksForHomeScreen() async {
    return _books.map((book) {
      // Handle multiple exchange types
      final types = book.exchangeType
          .split(', ')
          .where((type) => type.isNotEmpty)
          .toList();
      String displayLabel = types.join(' & ').toUpperCase();
      Color labelColor = types.contains('Sell') && types.contains('Exchange')
          ? Colors.purple // Mixed color for both
          : types.contains('Sell')
              ? Colors.green
              : Colors.blue;

      return {
        'title': book.title,
        'author': book.author,
        'price': book.price.toInt(),
        'image': book.imageUrl ?? 'assets/images/emu_logo.png',
        'label': displayLabel,
        'labelColor': labelColor,
        'description': book.description ?? 'No description available.',
        'rating': book.averageRating,
        'reviews': book.ratings?.length ?? 0,
        'condition': book.condition,
        'owner': book.owner,
        'availability': book.availability,
        'createdAt': book.createdAt,
        'exchangeType': book.exchangeType,
      };
    }).toList();
  }

  // Get recently added books (last 10)
  Future<List<Map<String, dynamic>>> getRecentlyAddedBooks() async {
    final allBooks = await getBooksForHomeScreen();
    // Sort by creation date (newest first) and take last 10
    allBooks.sort((a, b) =>
        (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
    return allBooks.take(10).toList();
  }

  // Get count
  int getBooksCount() {
    return _books.length;
  }
}
