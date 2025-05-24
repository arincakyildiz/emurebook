import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Admin kullanıcısı
  static const String ADMIN_EMAIL = "admin@emu.edu.tr";
  static const String ADMIN_PASSWORD = "admin123";

  // Kayıtlı kullanıcılar listesi (mock)
  final List<Map<String, dynamic>> _registeredUsers = [
    {
      'id': '100',
      'name': 'Admin User',
      'email': ADMIN_EMAIL,
      'password': ADMIN_PASSWORD,
      'department': 'Computer Engineering',
      'studentId': 'ADMIN001',
      'phone': '555-123-4567',
      'role': 'admin',
      'favoriteBooks': [],
      'createdAt':
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    },
  ];

  // Current authenticated user
  User? _currentUser;

  // Stream controller for authentication state
  final _authStateController = StreamController<bool>.broadcast();

  // Auth state stream
  Stream<bool> get authStateStream => _authStateController.stream;

  // Getter for current user
  User? get currentUser => _currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Initialize auth state
  Future<void> init() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final savedUserId = prefs.getString('user_id');

      if (token != null && savedUserId != null) {
        // Kayıtlı kullanıcıyı bul
        final savedUserData = _registeredUsers.firstWhere(
          (userData) => userData['id'] == savedUserId,
          orElse: () => throw Exception('Kullanıcı bulunamadı'),
        );

        _currentUser = _createUserFromData(savedUserData);
        _authStateController.add(true);
      } else {
        _currentUser = null;
        _authStateController.add(false);
      }
    } catch (e) {
      _currentUser = null;
      _authStateController.add(false);
    }
  }

  // Register new user
  Future<User> register(Map<String, dynamic> userData) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      // Email daha önce kayıtlı mı kontrol et
      final existingUser = _registeredUsers
          .where((user) => user['email'] == userData['email'])
          .toList();
      if (existingUser.isNotEmpty) {
        throw Exception('Bu email adresi zaten kullanılmaktadır');
      }

      // Yeni kullanıcı oluştur
      final newUserId =
          (DateTime.now().millisecondsSinceEpoch % 10000).toString();
      final newUserData = {
        'id': newUserId,
        'name': userData['name'],
        'email': userData['email'],
        'password': userData['password'] ?? 'password123', // Varsayılan şifre
        'department': userData['department'],
        'studentId': userData['studentId'],
        'phone': userData['phone'],
        'role': 'user', // Yeni kayıt olan herkes normal kullanıcı olacak
        'favoriteBooks': [],
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Kullanıcıyı kaydet
      _registeredUsers.add(newUserData);
      _currentUser = _createUserFromData(newUserData);

      // Token kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = 'dummy-token-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', newUserId);

      _authStateController.add(true);
      return _currentUser!;
    } catch (e) {
      _authStateController.add(false);
      rethrow;
    }
  }

  // Login user
  Future<User> login(String email, String password) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email ve şifre boş olamaz');
      }

      // Kullanıcıyı e-posta adresine göre bul
      final userData = _registeredUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () =>
            throw Exception('Kullanıcı bulunamadı, lütfen önce kayıt olunuz'),
      );

      // Şifre kontrolü
      if (userData['password'] != password) {
        throw Exception('Geçersiz kullanıcı adı veya şifre');
      }

      _currentUser = _createUserFromData(userData);

      // Token kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token =
          '${userData["role"]}-token-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', userData['id']);

      _authStateController.add(true);
      return _currentUser!;
    } catch (e) {
      _authStateController.add(false);
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Token temizle
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');

      _currentUser = null;
      _authStateController.add(false);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<User> updateProfile(Map<String, dynamic> userData) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      if (_currentUser == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Kayıtlı kullanıcılar listesinde güncelle
      int userIndex =
          _registeredUsers.indexWhere((user) => user['id'] == _currentUser!.id);
      if (userIndex != -1) {
        // Mevcut kullanıcı verilerini al
        Map<String, dynamic> updatedUserData =
            Map.from(_registeredUsers[userIndex]);

        // Güncellenen alanları ekle
        if (userData['name'] != null)
          updatedUserData['name'] = userData['name'];
        if (userData['email'] != null)
          updatedUserData['email'] = userData['email'];
        if (userData['department'] != null)
          updatedUserData['department'] = userData['department'];
        if (userData['studentId'] != null)
          updatedUserData['studentId'] = userData['studentId'];
        if (userData['phone'] != null)
          updatedUserData['phone'] = userData['phone'];

        // Kullanıcıyı güncelle
        _registeredUsers[userIndex] = updatedUserData;

        // Güncel kullanıcı nesnesini oluştur
        _currentUser = _createUserFromData(updatedUserData);
      }

      _authStateController.add(true);
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // API isteği simülasyonu

      if (_currentUser == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Kayıtlı kullanıcı verilerini bul
      int userIndex =
          _registeredUsers.indexWhere((user) => user['id'] == _currentUser!.id);
      if (userIndex == -1) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Mevcut şifre kontrolü
      if (_registeredUsers[userIndex]['password'] != currentPassword) {
        throw Exception('Mevcut şifre yanlış');
      }

      // Şifreyi güncelle
      _registeredUsers[userIndex]['password'] = newPassword;
    } catch (e) {
      rethrow;
    }
  }

  // Kullanıcı verilerinden User nesnesi oluşturma yardımcı metodu
  User _createUserFromData(Map<String, dynamic> userData) {
    List<String> favorites = [];
    if (userData['favoriteBooks'] != null) {
      if (userData['favoriteBooks'] is List) {
        favorites = (userData['favoriteBooks'] as List)
            .map((item) => item is String ? item : item.toString())
            .toList()
            .cast<String>();
      }
    }

    return User(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      department: userData['department'],
      studentId: userData['studentId'],
      phone: userData['phone'],
      role: userData['role'] ?? 'user',
      favoriteBooks: favorites,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'])
          : DateTime.now(),
    );
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}
