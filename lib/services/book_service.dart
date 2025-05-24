import '../models/book_model.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  // Simple static book list
  static final List<Book> _books = [];

  // Add a book
  Future<Book> addBook(String title, String author, double price) async {
    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: author,
      description: 'A book by $author',
      imageUrl: 'assets/images/emu_logo.png',
      condition: 'Good',
      price: price,
      category: 'General',
      exchangeType: 'Sell',
      owner: {'_id': 'user1', 'name': 'User', 'email': 'user@example.com'},
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

  // Get count
  int getBooksCount() {
    return _books.length;
  }
}
