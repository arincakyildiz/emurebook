import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emurebook/config/api_config.dart';

class ApiService {
  // API base URL from config
  static final String baseUrl = ApiConfig.baseUrl;

  // Token'ı saklamak için
  static String? _token;

  // Headers
  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (_token == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(ApiConfig.tokenKey);
    }

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Token'ı kaydet
  static Future<void> saveToken(String token) async {
    _token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
  }

  // Token'ı temizle
  static Future<void> clearToken() async {
    _token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
  }

  // Kullanıcı Kaydı
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/register'),
        headers: await _getHeaders(),
        body: json.encode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return responseData;
      } else {
        throw responseData['message'] ?? 'Kayıt başarısız oldu';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kullanıcı Girişi
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return responseData;
      } else {
        throw responseData['message'] ?? 'Giriş başarısız oldu';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kullanıcı Çıkışı
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/logout'),
        headers: await _getHeaders(),
      );
      await clearToken();
    } catch (e) {
      rethrow;
    }
  }

  // Mevcut Kullanıcı Bilgilerini Getir
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
        throw responseData['message'] ?? 'Kullanıcı bilgileri alınamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Tüm Kitapları Getir
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
        throw responseData['message'] ?? 'Kitaplar alınamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kitap Detayını Getir
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
        throw responseData['message'] ?? 'Kitap detayları alınamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Yeni Kitap Ekle
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
        throw responseData['message'] ?? 'Kitap eklenemedi';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kitap Güncelle
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
        throw responseData['message'] ?? 'Kitap güncellenemedi';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kitap Sil
  static Future<void> deleteBook(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/$bookId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204) {
        final responseData = json.decode(response.body);
        throw responseData['message'] ?? 'Kitap silinemedi';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kitap Ara
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
        throw responseData['message'] ?? 'Kitap araması başarısız oldu';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kitap Kategorilerini Getir
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
        throw responseData['message'] ?? 'Kategoriler alınamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kitaba Puan Ver
  static Future<Map<String, dynamic>> rateBook(
      String bookId, int rating, String? review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConfig.booksEndpoint}/$bookId/rating'),
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
        throw responseData['message'] ?? 'Puanlama başarısız oldu';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Favori Kitapları Getir
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
        throw responseData['message'] ?? 'Favori kitaplar alınamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Kitabı Favorilere Ekle/Çıkar
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
        throw responseData['message'] ?? 'Favori işlemi başarısız oldu';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Mesaj Gönder
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
        throw responseData['message'] ?? 'Mesaj gönderilemedi';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Konuşmaları Getir
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
        throw responseData['message'] ?? 'Konuşmalar alınamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Belirli Bir Kullanıcıyla Olan Konuşmayı Getir
  static Future<Map<String, dynamic>> getConversationWithUser(
      String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConfig.messagesEndpoint}/conversation/$userId'),
        headers: await _getHeaders(),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data'];
      } else {
        throw responseData['message'] ?? 'Konuşma alınamadı';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Profil Bilgilerini Güncelle
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/update-me'),
        headers: await _getHeaders(),
        body: json.encode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['user'];
      } else {
        throw responseData['message'] ?? 'Profil güncellenemedi';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Şifre Güncelle
  static Future<Map<String, dynamic>> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiConfig.authEndpoint}/update-password'),
        headers: await _getHeaders(),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return responseData['data']['user'];
      } else {
        throw responseData['message'] ?? 'Şifre güncellenemedi';
      }
    } catch (e) {
      rethrow;
    }
  }
}
