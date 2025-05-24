import '../models/book_model.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'dart:math';

class BookService {
  final AuthService _authService = AuthService();

  // Mock kitap verileri
  final List<Book> _mockBooks = [
    Book(
      id: '1',
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      description:
          'A comprehensive introduction to the modern study of computer algorithms.',
      imageUrl: 'assets/images/algorithms.jpg',
      condition: 'Good',
      price: 250,
      category: 'Computer Science',
      exchangeType: 'Sell',
      owner: {
        '_id': '100',
        'name': 'Admin User',
        'email': AuthService.ADMIN_EMAIL
      },
      language: 'English',
      availability: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Book(
      id: '2',
      title: 'Calculus: Early Transcendentals',
      author: 'James Stewart',
      description:
          'This book is for students taking calculus courses who want to learn the basic concepts of calculus and develop problem solving skills.',
      imageUrl: 'assets/images/calculus.jpg',
      condition: 'Like New',
      price: 300,
      category: 'Mathematics',
      exchangeType: 'Exchange',
      owner: {
        '_id': '100',
        'name': 'Admin User',
        'email': AuthService.ADMIN_EMAIL
      },
      language: 'English',
      availability: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Book(
      id: '3',
      title: 'Operating System Concepts',
      author: 'Abraham Silberschatz',
      description:
          'The tenth edition provides up-to-date materials and explanations of modern operating systems.',
      imageUrl: 'assets/images/os.jpg',
      condition: 'Good',
      price: 200,
      category: 'Computer Science',
      exchangeType: 'Sell',
      owner: {
        '_id': '100',
        'name': 'Admin User',
        'email': AuthService.ADMIN_EMAIL
      },
      language: 'English',
      availability: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Book(
      id: '4',
      title: 'Computer Networks',
      author: 'Andrew S. Tanenbaum',
      description:
          'This book is ideal for students of computer science and electrical engineering.',
      imageUrl: 'assets/images/networking.jpg',
      condition: 'Fair',
      price: 150,
      category: 'Computer Science',
      exchangeType: 'Rent',
      owner: {
        '_id': '100',
        'name': 'Admin User',
        'email': AuthService.ADMIN_EMAIL
      },
      language: 'English',
      availability: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Book(
      id: '5',
      title: 'Engineering Mechanics: Statics',
      author: 'Russell C. Hibbeler',
      description:
          'Engineering Mechanics: Statics excels in providing a clear and thorough presentation of the theory and application of engineering mechanics.',
      imageUrl: 'assets/images/mechanics.jpg',
      condition: 'Good',
      price: 180,
      category: 'Engineering',
      exchangeType: 'Sell',
      owner: {
        '_id': '100',
        'name': 'Admin User',
        'email': AuthService.ADMIN_EMAIL
      },
      language: 'English',
      availability: true,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  // Kullanıcıların favori kitapları (userId -> bookIds)
  final Map<String, List<String>> _userFavorites = {};

  // Get all books
  Future<List<Book>> getAllBooks({
    int page = 1,
    int limit = 10,
    String? sort,
    Map<String, dynamic>? filters,
  }) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      // Filtreleme işlemleri (gerçekte API'de yapılacak)
      List<Book> filteredBooks = List.from(_mockBooks);

      if (filters != null) {
        if (filters['category'] != null) {
          filteredBooks = filteredBooks
              .where((book) => book.category == filters['category'])
              .toList();
        }

        if (filters['exchangeType'] != null) {
          filteredBooks = filteredBooks
              .where((book) => book.exchangeType == filters['exchangeType'])
              .toList();
        }

        if (filters['minPrice'] != null) {
          filteredBooks = filteredBooks
              .where((book) => book.price >= filters['minPrice'])
              .toList();
        }

        if (filters['maxPrice'] != null) {
          filteredBooks = filteredBooks
              .where((book) => book.price <= filters['maxPrice'])
              .toList();
        }

        // Kullanıcıya göre filtreleme
        if (filters['userId'] != null) {
          filteredBooks = filteredBooks
              .where((book) => book.owner['_id'] == filters['userId'])
              .toList();
        }
      }

      // Sıralama (gerçekte API'de yapılacak)
      if (sort != null) {
        if (sort == 'price') {
          filteredBooks.sort((a, b) => a.price.compareTo(b.price));
        } else if (sort == '-price') {
          filteredBooks.sort((a, b) => b.price.compareTo(a.price));
        } else if (sort == 'createdAt') {
          filteredBooks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        } else if (sort == '-createdAt') {
          filteredBooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }

      // Sayfalama (gerçekte API'de yapılacak)
      int startIndex = (page - 1) * limit;
      int endIndex = min(startIndex + limit, filteredBooks.length);

      if (startIndex >= filteredBooks.length) {
        return [];
      }

      return filteredBooks.sublist(startIndex, endIndex);
    } catch (e) {
      rethrow;
    }
  }

  // Get book details
  Future<Book> getBookDetails(String bookId) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final book = _mockBooks.firstWhere(
        (book) => book.id == bookId,
        orElse: () => throw Exception('Kitap bulunamadı'),
      );

      return book;
    } catch (e) {
      rethrow;
    }
  }

  // Create new book
  Future<Book> createBook(Map<String, dynamic> bookData) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Kitap eklemek için giriş yapmalısınız');
      }

      final newBook = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: bookData['title'],
        author: bookData['author'],
        description: bookData['description'],
        imageUrl: bookData['imageUrl'],
        condition: bookData['condition'],
        price: bookData['price'] != null
            ? double.parse(bookData['price'].toString())
            : 0.0,
        category: bookData['category'],
        exchangeType: bookData['exchangeType'],
        department: bookData['department'],
        courseCode: bookData['courseCode'],
        owner: {
          '_id': currentUser.id,
          'name': currentUser.name,
          'email': currentUser.email
        },
        isbn: bookData['isbn'],
        language: bookData['language'] ?? 'English',
        publisher: bookData['publisher'],
        publishedYear: bookData['publishedYear'],
        availability: true,
        createdAt: DateTime.now(),
      );

      _mockBooks.add(newBook);

      return newBook;
    } catch (e) {
      rethrow;
    }
  }

  // Update book
  Future<Book> updateBook(String bookId, Map<String, dynamic> bookData) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      int index = _mockBooks.indexWhere((book) => book.id == bookId);

      if (index == -1) {
        throw Exception('Kitap bulunamadı');
      }

      Book oldBook = _mockBooks[index];
      final currentUser = _authService.currentUser;

      // Kitabın sahibi şu anki kullanıcı mı kontrolü (admin hariç)
      if (currentUser != null &&
          currentUser.role != 'admin' &&
          oldBook.owner['_id'] != currentUser.id) {
        throw Exception('Sadece kendi kitaplarınızı düzenleyebilirsiniz');
      }

      Book updatedBook = Book(
        id: oldBook.id,
        title: bookData['title'] ?? oldBook.title,
        author: bookData['author'] ?? oldBook.author,
        description: bookData['description'] ?? oldBook.description,
        imageUrl: bookData['imageUrl'] ?? oldBook.imageUrl,
        condition: bookData['condition'] ?? oldBook.condition,
        price: bookData['price'] != null
            ? double.parse(bookData['price'].toString())
            : oldBook.price,
        category: bookData['category'] ?? oldBook.category,
        exchangeType: bookData['exchangeType'] ?? oldBook.exchangeType,
        department: bookData['department'] ?? oldBook.department,
        courseCode: bookData['courseCode'] ?? oldBook.courseCode,
        owner: oldBook.owner,
        isbn: bookData['isbn'] ?? oldBook.isbn,
        language: bookData['language'] ?? oldBook.language,
        publisher: bookData['publisher'] ?? oldBook.publisher,
        publishedYear: bookData['publishedYear'] ?? oldBook.publishedYear,
        availability: bookData['availability'] ?? oldBook.availability,
        createdAt: oldBook.createdAt,
      );

      _mockBooks[index] = updatedBook;

      return updatedBook;
    } catch (e) {
      rethrow;
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      int index = _mockBooks.indexWhere((book) => book.id == bookId);

      if (index == -1) {
        throw Exception('Kitap bulunamadı');
      }

      final currentUser = _authService.currentUser;
      final book = _mockBooks[index];

      // Kitabın sahibi şu anki kullanıcı mı kontrolü (admin hariç)
      if (currentUser != null &&
          currentUser.role != 'admin' &&
          book.owner['_id'] != currentUser.id) {
        throw Exception('Sadece kendi kitaplarınızı silebilirsiniz');
      }

      _mockBooks.removeAt(index);
    } catch (e) {
      rethrow;
    }
  }

  // Search books
  Future<List<Book>> searchBooks(String query) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      if (query.isEmpty) {
        return _mockBooks;
      }

      query = query.toLowerCase();

      return _mockBooks.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.category.toLowerCase().contains(query) ||
            (book.description != null &&
                book.description!.toLowerCase().contains(query));
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get book categories
  Future<List<String>> getBookCategories() async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      return [
        'Computer Science',
        'Mathematics',
        'Engineering',
        'Physics',
        'Chemistry',
        'Biology',
        'Economics',
        'Business Administration',
        'Psychology',
        'Literature',
        'History',
        'Arts',
        'Other'
      ];
    } catch (e) {
      rethrow;
    }
  }

  // Rate book
  Future<Book> rateBook(String bookId, int rating, String? review) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      int index = _mockBooks.indexWhere((book) => book.id == bookId);

      if (index == -1) {
        throw Exception('Kitap bulunamadı');
      }

      // Gerçek uygulamada API'ye gönderilecek ve güncellenmiş kitap dönecek
      return _mockBooks[index];
    } catch (e) {
      rethrow;
    }
  }

  // Get favorite books
  Future<List<Book>> getFavoriteBooks() async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Favori kitaplarınızı görmek için giriş yapmalısınız');
      }

      final userFavoriteIds = _userFavorites[currentUser.id] ?? [];
      return _mockBooks
          .where((book) => userFavoriteIds.contains(book.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Toggle favorite book
  Future<List<String>> toggleFavoriteBook(String bookId) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Kitabı favorilere eklemek için giriş yapmalısınız');
      }

      // Kullanıcının favorileri yoksa oluştur
      if (!_userFavorites.containsKey(currentUser.id)) {
        _userFavorites[currentUser.id] = [];
      }

      // Favorilere ekle veya çıkar
      if (_userFavorites[currentUser.id]!.contains(bookId)) {
        _userFavorites[currentUser.id]!.remove(bookId);
      } else {
        _userFavorites[currentUser.id]!.add(bookId);
      }

      return _userFavorites[currentUser.id]!;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's books
  Future<List<Book>> getUserBooks() async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Kitaplarınızı görmek için giriş yapmalısınız');
      }

      return _mockBooks
          .where((book) => book.owner['_id'] == currentUser.id)
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
