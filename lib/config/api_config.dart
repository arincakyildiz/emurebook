class ApiConfig {
  // API base URL for emulator
  static const String baseUrlEmulator = 'http://10.0.2.2:5000/api';

  // API base URL for physical device - replace with your actual backend IP
  static const String baseUrlDevice = 'http://192.168.1.X:5000/api';

  // Choose the appropriate URL based on your testing environment
  static const String baseUrl = baseUrlEmulator;

  // API endpoints
  static const String authEndpoint = '/auth';
  static const String booksEndpoint = '/books';
  static const String messagesEndpoint = '/messages';
  static const String usersEndpoint = '/users';

  // Token key for shared preferences
  static const String tokenKey = 'auth_token';
}
