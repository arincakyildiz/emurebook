import 'auth_service.dart';
import 'book_service.dart';
import 'message_service.dart';

class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._internal();

  factory ServiceProvider() {
    return _instance;
  }

  ServiceProvider._internal() {
    // Initialize services
    _authService = AuthService();
    _bookService = BookService();
    _messageService = MessageService();
  }

  late final AuthService _authService;
  late final BookService _bookService;
  late final MessageService _messageService;

  // Getters for services
  AuthService get authService => _authService;
  BookService get bookService => _bookService;
  MessageService get messageService => _messageService;

  // Initialize all services
  Future<void> initialize() async {
    await _authService.init();
  }

  // Dispose all services
  void dispose() {
    _authService.dispose();
  }
}
