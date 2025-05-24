import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // API base URL from config
  static const String baseUrl = ApiConfig.baseUrl;

  // Store token
  static String? _token;

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    // Add token if exists
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    } else {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        _token = token;
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Save token
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // User Registration
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Save token if registration successful
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return responseData['data']['user'];
      } else {
        throw responseData['message'] ?? 'Registration failed';
      }
    } catch (e) {
      rethrow;
    }
  }

  // User Login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token if login successful
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return responseData['data']['user'];
      } else {
        throw responseData['message'] ?? 'Login failed';
      }
    } catch (e) {
      rethrow;
    }
  }

  // User Logout
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/logout'),
        headers: await _getHeaders(),
      );

      await clearToken();
    } catch (e) {
      // Even if logout request fails, clear local token
      await clearToken();
    }
  }

  // Get Current User Information
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/me'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['user'];
      } else {
        throw responseData['message'] ?? 'Could not get user information';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get All Books
  static Future<List<dynamic>> getAllBooks({
    int page = 1,
    int limit = 10,
    String? sort,
    Map<String, dynamic>? filters,
  }) async {
    try {
      String url = '$baseUrl${ApiConfig.booksEndpoint}?page=$page&limit=$limit';

      if (sort != null) {
        url += '&sort=$sort';
      }

      if (filters != null) {
        filters.forEach((key, value) {
          url += '&$key=$value';
        });
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['books'];
      } else {
        throw responseData['message'] ?? 'Could not get books';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Book Details
  static Future<Map<String, dynamic>> getBookDetails(String bookId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/$bookId'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['book'];
      } else {
        throw responseData['message'] ?? 'Could not get book details';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add New Book
  static Future<Map<String, dynamic>> createBook(
      Map<String, dynamic> bookData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}'),
        headers: await _getHeaders(),
        body: json.encode(bookData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return responseData['data']['book'];
      } else {
        throw responseData['message'] ?? 'Could not add book';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update Book
  static Future<Map<String, dynamic>> updateBook(
      String bookId, Map<String, dynamic> bookData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/$bookId'),
        headers: await _getHeaders(),
        body: json.encode(bookData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['book'];
      } else {
        throw responseData['message'] ?? 'Could not update book';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete Book
  static Future<void> deleteBook(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/$bookId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204) {
        final responseData = json.decode(response.body);
        throw responseData['message'] ?? 'Could not delete book';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Search Books
  static Future<List<dynamic>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/search?q=$query'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['books'];
      } else {
        throw responseData['message'] ?? 'Book search failed';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Book Categories
  static Future<List<dynamic>> getBookCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/categories'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['categories'];
      } else {
        throw responseData['message'] ?? 'Could not get categories';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Rate Book
  static Future<Map<String, dynamic>> rateBook(
      String bookId, int rating, String? review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/$bookId/rate'),
        headers: await _getHeaders(),
        body: json.encode({
          'rating': rating,
          'review': review,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['book'];
      } else {
        throw responseData['message'] ?? 'Rating failed';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Favorite Books
  static Future<List<dynamic>> getFavoriteBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.usersEndpoint}/favorites/books'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['favoriteBooks'];
      } else {
        throw responseData['message'] ?? 'Could not get favorite books';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add/Remove Book to/from Favorites
  static Future<List<dynamic>> toggleFavoriteBook(String bookId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/$bookId/favorite'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['favoriteBooks'];
      } else {
        throw responseData['message'] ?? 'Favorite operation failed';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Send Message
  static Future<Map<String, dynamic>> sendMessage(
      String receiverId, String content,
      {String? relatedBookId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.messagesEndpoint}'),
        headers: await _getHeaders(),
        body: json.encode({
          'receiver': receiverId,
          'content': content,
          'relatedBook': relatedBookId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return responseData['data']['message'];
      } else {
        throw responseData['message'] ?? 'Could not send message';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Conversations
  static Future<List<dynamic>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.messagesEndpoint}/conversations'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['conversations'];
      } else {
        throw responseData['message'] ?? 'Could not get conversations';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Conversation with Specific User
  static Future<Map<String, dynamic>> getConversationWithUser(
      String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl${ApiConfig.messagesEndpoint}/conversations/$userId'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data'];
      } else {
        throw responseData['message'] ?? 'Could not get conversation';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update Profile Information
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiConfig.usersEndpoint}/profile'),
        headers: await _getHeaders(),
        body: json.encode(profileData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['user'];
      } else {
        throw responseData['message'] ?? 'Could not update profile';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update Password
  static Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiConfig.usersEndpoint}/password'),
        headers: await _getHeaders(),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw responseData['message'] ?? 'Could not update password';
      }
    } catch (e) {
      rethrow;
    }
  }
}
