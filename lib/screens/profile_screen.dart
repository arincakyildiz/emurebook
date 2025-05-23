import 'package:flutter/material.dart';
import 'favorites_screen.dart';
import 'listings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, String> lang;
  final void Function(String) onLanguageChanged;
  const ProfileScreen({super.key, required this.lang, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang['profile'] ?? 'Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage('assets/images/profile.jpg'), // Kendi profil fotoğrafını ekle
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ahmet Arınç Akyıldız',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '22000257@emu.edu.tr',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Account Settings
              Text(
                lang['account_settings'] ?? 'Account Settings',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _profileTile(context, Icons.edit, lang['edit_profile'] ?? 'Edit Profile', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              }),
              _profileTile(context, Icons.library_books, lang['manage_listings'] ?? 'Manage My Listings', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ListingsScreen(lang: lang, onMessageSent: (_) {}, showOnlyMine: true)));
              }),
              _profileTile(context, Icons.favorite, lang['my_favorites'] ?? 'My Favorites', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen(lang: lang)));
              }),
              _profileTile(context, Icons.notifications, lang['notifications'] ?? 'Notifications', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: lang['notifications'] ?? 'Notifications')));
              }),
              _profileTile(context, Icons.lock, lang['privacy_security'] ?? 'Privacy & Security', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: lang['privacy_security'] ?? 'Privacy & Security')));
              }),
              _profileTile(context, Icons.language, lang['language_settings'] ?? 'Language Settings', () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(lang['selectLanguage'] ?? 'Select Language'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: Text(lang['english'] ?? 'English'),
                          value: 'English',
                          groupValue: lang['turkish'] == 'Türkçe' ? 'Türkçe' : 'English',
                          onChanged: (val) {
                            Navigator.pop(context);
                            onLanguageChanged('English');
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(lang['turkish'] ?? 'Türkçe'),
                          value: 'Türkçe',
                          groupValue: lang['turkish'] == 'Türkçe' ? 'Türkçe' : 'English',
                          onChanged: (val) {
                            Navigator.pop(context);
                            onLanguageChanged('Türkçe');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Help & Support
              Text(
                lang['help_support'] ?? 'Help & Support',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _profileTile(context, Icons.help_outline, lang['faq'] ?? 'FAQ', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: lang['faq'] ?? 'FAQ')));
              }),
              _profileTile(context, Icons.description, lang['terms_of_service'] ?? 'Terms of Service', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: lang['terms_of_service'] ?? 'Terms of Service')));
              }),
              _profileTile(context, Icons.support_agent, lang['contact_support'] ?? 'Contact Support', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: lang['contact_support'] ?? 'Contact Support')));
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
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: Text(
                      lang['logout'] ?? 'Log Out',
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

  Widget _profileTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
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
