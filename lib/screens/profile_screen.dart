import 'package:flutter/material.dart';
import 'package:emurebook/services/service_provider.dart';
import 'package:emurebook/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_screen.dart';
import 'listings_screen.dart';
import 'edit_profile_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final Map<String, String> lang;
  final void Function(String) onLanguageChanged;
  const ProfileScreen(
      {super.key, required this.lang, required this.onLanguageChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = ServiceProvider().authService;
  User? _currentUser;
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _currentUser = _authService.currentUser;
    });
    await _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (_currentUser != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_${_currentUser!.id}');
      if (imagePath != null && File(imagePath).existsSync()) {
        setState(() {
          _profileImagePath = imagePath;
        });
      }
    }
  }

  Future<String?> _getUserProfileImage(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_$userId');
    if (imagePath != null && File(imagePath).existsSync()) {
      return imagePath;
    }
    return null;
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && _currentUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${_currentUser!.id}', image.path);

        setState(() {
          _profileImagePath = image.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && _currentUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${_currentUser!.id}', image.path);

        setState(() {
          _profileImagePath = image.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    if (_currentUser != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_${_currentUser!.id}');

      setState(() {
        _profileImagePath = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Change Profile Picture',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.green),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takeProfilePhoto();
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Picture'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showUserSwitcher(BuildContext context) {
    final users = _authService.registeredUsers;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch User (Testing)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...users
                .map((user) => FutureBuilder<String?>(
                      future: _getUserProfileImage(user['id']),
                      builder: (context, snapshot) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user['id'] == _currentUser?.id
                                ? Colors.blue
                                : Colors.grey,
                            backgroundImage:
                                snapshot.hasData && snapshot.data != null
                                    ? FileImage(File(snapshot.data!))
                                    : null,
                            child: snapshot.hasData && snapshot.data != null
                                ? null
                                : Text(
                                    user['name'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                          title: Text(user['name']),
                          subtitle: Text(user['email']),
                          trailing: user['id'] == _currentUser?.id
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () async {
                            if (user['id'] != _currentUser?.id) {
                              try {
                                await _authService.switchUser(user['id']);
                                _loadUserData();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Switched to ${user['name']}'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to switch user: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.lang['profile'] ?? 'Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        body: const Center(
          child: Text('Please log in to view your profile'),
        ),
      );
    }

    final isAdmin = _currentUser!.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lang['profile'] ?? 'Profile'),
        backgroundColor: isAdmin ? Colors.blue[800] : Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isAdmin ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: TextStyle(
          color: isAdmin ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAdmin ? Colors.blue[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showProfileImageOptions,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                isAdmin ? Colors.blue[700] : Colors.grey[400],
                            backgroundImage: _profileImagePath != null
                                ? FileImage(File(_profileImagePath!))
                                : null,
                            child: _profileImagePath == null
                                ? Icon(
                                    isAdmin
                                        ? Icons.admin_panel_settings
                                        : Icons.person,
                                    size: 36,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser!.email,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isAdmin)
                            const Text(
                              "Administrator",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          if (_currentUser!.department != null)
                            Text(
                              _currentUser!.department!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Account Settings
              Text(
                widget.lang['account_settings'] ?? 'Account Settings',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _profileTile(context, Icons.edit,
                  widget.lang['edit_profile'] ?? 'Edit Profile', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      onProfileUpdated: _loadUserData,
                    ),
                  ),
                );
              }),
              _profileTile(context, Icons.library_books,
                  widget.lang['manage_listings'] ?? 'Manage My Listings', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListingsScreen(
                      lang: widget.lang,
                      onMessageSent: (_) {},
                    ),
                  ),
                );
              }),
              _profileTile(context, Icons.favorite,
                  widget.lang['my_favorites'] ?? 'My Favorites', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritesScreen(lang: widget.lang),
                  ),
                );
              }),

              // Admin specific options
              if (isAdmin) ...[
                _profileTile(context, Icons.people, 'Manage Users', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _PlaceholderScreen(title: 'Manage Users'),
                    ),
                  );
                }),
                _profileTile(
                    context, Icons.library_books_outlined, 'All Listings', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingsScreen(
                        lang: widget.lang,
                        onMessageSent: (_) {},
                      ),
                    ),
                  );
                }),
                _profileTile(context, Icons.category, 'Manage Categories', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _PlaceholderScreen(title: 'Manage Categories'),
                    ),
                  );
                }),
              ],

              _profileTile(context, Icons.notifications,
                  widget.lang['notifications'] ?? 'Notifications', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _PlaceholderScreen(
                            title: widget.lang['notifications'] ??
                                'Notifications')));
              }),
              _profileTile(context, Icons.lock,
                  widget.lang['privacy_security'] ?? 'Privacy & Security', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _PlaceholderScreen(
                            title: widget.lang['privacy_security'] ??
                                'Privacy & Security')));
              }),
              const SizedBox(height: 16),
              // Help & Support
              Text(
                widget.lang['help_support'] ?? 'Help & Support',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _profileTile(
                  context, Icons.help_outline, widget.lang['faq'] ?? 'FAQ', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _PlaceholderScreen(
                            title: widget.lang['faq'] ?? 'FAQ')));
              }),
              _profileTile(context, Icons.description,
                  widget.lang['terms_of_service'] ?? 'Terms of Service', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _PlaceholderScreen(
                            title: widget.lang['terms_of_service'] ??
                                'Terms of Service')));
              }),
              _profileTile(context, Icons.support_agent,
                  widget.lang['contact_support'] ?? 'Contact Support', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _PlaceholderScreen(
                            title: widget.lang['contact_support'] ??
                                'Contact Support')));
              }),
              const SizedBox(height: 16),
              // User Switcher (for testing)
              Text(
                'Switch User (Testing)',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _profileTile(context, Icons.switch_account, 'Switch User', () {
                _showUserSwitcher(context);
              }),
              const SizedBox(height: 24),
              // Log Out
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: Text(
                      widget.lang['logout'] ?? 'Log Out',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon,
            color: _currentUser?.role == 'admin'
                ? Colors.blue[700]
                : Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
        onTap: onTap,
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});
  @override
  Widget build(BuildContext context) {
    String info = '';
    if (title.contains('FAQ') || title.contains('SSS')) {
      info = 'Q: How do I use the app?\nA: Just browse, filter, and add books!';
    } else if (title.contains('Terms')) {
      info = 'Terms of Service: By using this app, you agree to our terms.';
    } else if (title.contains('Support') || title.contains('Destek')) {
      info = 'Contact us at support@emurebook.com for help.';
    } else if (title.contains('Notifications')) {
      info = 'No new notifications.';
    } else if (title.contains('Privacy')) {
      info = 'Your data is safe and never shared.';
    } else if (title.contains('Manage Users')) {
      info = 'Admin functionality: Manage all users.';
    } else if (title.contains('Manage Categories')) {
      info = 'Admin functionality: Manage book categories.';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            info.isNotEmpty ? info : title,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
