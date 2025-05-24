import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Admin user
  static const String ADMIN_EMAIL = "admin@emu.edu.tr";
  static const String ADMIN_PASSWORD = "admin123";

  // Registered users list (mock)
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
        // Find registered user
        final savedUserData = _registeredUsers.firstWhere(
          (userData) => userData['id'] == savedUserId,
          orElse: () => throw Exception('User not found'),
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
          const Duration(seconds: 1)); // API request simulation

      // Check if email is already registered
      final existingUser = _registeredUsers
          .where((user) => user['email'] == userData['email'])
          .toList();
      if (existingUser.isNotEmpty) {
        throw Exception('This email address is already in use');
      }

      // Create new user
      final newUserId =
          (DateTime.now().millisecondsSinceEpoch % 10000).toString();
      final newUserData = {
        'id': newUserId,
        'name': userData['name'],
        'email': userData['email'],
        'password': userData['password'] ?? 'password123', // Default password
        'department': userData['department'],
        'studentId': userData['studentId'],
        'phone': userData['phone'],
        'role': 'user', // All new registrations will be normal users
        'favoriteBooks': [],
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save user
      _registeredUsers.add(newUserData);
      _currentUser = _createUserFromData(newUserData);

      // Save token
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
          const Duration(seconds: 1)); // API request simulation

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      // Find user by email address
      final userData = _registeredUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => throw Exception('User not found, please register first'),
      );

      // Password check
      if (userData['password'] != password) {
        throw Exception('Invalid username or password');
      }

      _currentUser = _createUserFromData(userData);

      // Save token
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
      // Clear token
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
          const Duration(seconds: 1)); // API request simulation

      if (_currentUser == null) {
        throw Exception('User is not logged in');
      }

      // Update in registered users list
      int userIndex =
          _registeredUsers.indexWhere((user) => user['id'] == _currentUser!.id);
      if (userIndex != -1) {
        // Get current user data
        Map<String, dynamic> updatedUserData =
            Map.from(_registeredUsers[userIndex]);

        // Add updated fields
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

        // Update user
        _registeredUsers[userIndex] = updatedUserData;

        // Create updated user object
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
          const Duration(seconds: 1)); // API request simulation

      if (_currentUser == null) {
        throw Exception('User is not logged in');
      }

      // Find registered user data
      int userIndex =
          _registeredUsers.indexWhere((user) => user['id'] == _currentUser!.id);
      if (userIndex == -1) {
        throw Exception('User not found');
      }

      // Current password check
      if (_registeredUsers[userIndex]['password'] != currentPassword) {
        throw Exception('Current password is incorrect');
      }

      // Update password
      _registeredUsers[userIndex]['password'] = newPassword;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to create User object from user data
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
