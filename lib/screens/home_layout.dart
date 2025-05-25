import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'listings_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;
  String _selectedLanguage = 'English';
  List<String> _notifications = [];
  VoidCallback? _refreshHomeScreen;

  void _updateLanguage(String newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  Map<String, Map<String, String>> localized = {
    'English': {
      'popular': 'Popular Books',
      'newlyAdded': 'Newly Added',
      'seeAll': 'See All',
      'searchHint': 'Search books, authors...',
      'filterBooks': 'Filter Books',
      'priceRange': 'Price Range',
      'condition': 'Condition',
      'reset': 'Reset',
      'applyFilters': 'Apply Filters',
      'contactSeller': 'Contact Seller',
      'buy': 'Buy',
      'messageSeller': 'Message Seller',
      'messageSent': 'Message sent!',
      'notifications': 'Notifications',
      'noNotifications': 'No notifications yet.',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'turkish': 'Türkçe',
      'close': 'Close',
      'purchaseSuccess': 'Purchase completed successfully!',
      'bookDetail': 'Book Detail',
      'allBooks': 'All Books',
      'listings': 'Listings',
      'details': 'Details',
      'description': 'Description',
      'price': 'Price',
      'edition': 'Edition',
      'language': 'Language',
      'reviews': 'reviews',
      'send': 'Send',
      'seller': 'Seller',
      'author': 'Author',
      'title': 'Title',
      'messages': 'Messages',
      'noMessages': 'No messages.',
      'profile': 'Profile',
      'profileInfo': 'Profile info here.',
      'thank_you_title': 'Thank You!',
      'thank_you_message': 'Your feedback has been submitted.',
      'rate_the_book': 'Rate the Book',
      'how_was_your_experience': 'How was your experience?',
      'leave_a_comment': 'Leave a comment (optional):',
      'write_your_feedback_here': 'Write your feedback here...',
      'submit': 'Submit',
      'account_settings': 'Account Settings',
      'edit_profile': 'Edit Profile',
      'manage_listings': 'Manage My Listings',
      'privacy_security': 'Privacy & Security',
      'language_settings': 'Language Settings',
      'help_support': 'Help & Support',
      'faq': 'FAQ',
      'terms_of_service': 'Terms of Service',
      'contact_support': 'Contact Support',
      'logout': 'Log Out',
      'all': 'All',
      'like_new': 'Like New',
      'good': 'Good',
      'fair': 'Fair',
      'favorites': 'Favorites',
      'my_favorites': 'My Favorites',
      'no_favorites': 'No favorites yet.',
      'name': 'Name',
      'email': 'Email',
      'save': 'Save',
      'new_password': 'New Password',
      'change_password': 'Change Password',
      'password_changed': 'Password changed!',
    },
    'Türkçe': {
      'popular': 'Popüler Kitaplar',
      'newlyAdded': 'Yeni Eklenenler',
      'seeAll': 'Tümünü Gör',
      'searchHint': 'Kitap, yazar ara...',
      'filterBooks': 'Kitapları Filtrele',
      'priceRange': 'Fiyat Aralığı',
      'condition': 'Durum',
      'reset': 'Sıfırla',
      'applyFilters': 'Filtrele',
      'contactSeller': 'Satıcıyla İletişim',
      'buy': 'Satın Al',
      'messageSeller': 'Satıcıya Mesaj Gönder',
      'messageSent': 'Mesaj gönderildi!',
      'notifications': 'Bildirimler',
      'noNotifications': 'Henüz bildirim yok.',
      'selectLanguage': 'Dil Seç',
      'english': 'English',
      'turkish': 'Türkçe',
      'close': 'Kapat',
      'purchaseSuccess': 'Satın alma işlemi başarıyla tamamlandı!',
      'bookDetail': 'Kitap Detayı',
      'allBooks': 'Tüm Kitaplar',
      'listings': 'İlanlar',
      'details': 'Detaylar',
      'description': 'Açıklama',
      'price': 'Fiyat',
      'edition': 'Baskı',
      'language': 'Dil',
      'reviews': 'yorum',
      'send': 'Gönder',
      'seller': 'Satıcı',
      'author': 'Yazar',
      'title': 'Başlık',
      'messages': 'Mesajlar',
      'noMessages': 'Henüz mesaj yok.',
      'profile': 'Profil',
      'profileInfo': 'Profil bilgileri burada.',
      'thank_you_title': 'Teşekkürler!',
      'thank_you_message': 'Geri bildiriminiz alındı.',
      'rate_the_book': 'Kitabı Değerlendir',
      'how_was_your_experience': 'Deneyiminiz nasıldı?',
      'leave_a_comment': 'Yorum bırak (isteğe bağlı):',
      'write_your_feedback_here': 'Görüşünüzü buraya yazın...',
      'submit': 'Gönder',
      'account_settings': 'Hesap Ayarları',
      'edit_profile': 'Profili Düzenle',
      'manage_listings': 'İlanlarım',
      'privacy_security': 'Gizlilik ve Güvenlik',
      'language_settings': 'Dil Ayarları',
      'help_support': 'Yardım & Destek',
      'faq': 'SSS',
      'terms_of_service': 'Kullanım Şartları',
      'contact_support': 'Destek ile İletişim',
      'logout': 'Çıkış Yap',
      'all': 'Tümü',
      'like_new': 'Yeni Gibi',
      'good': 'İyi',
      'fair': 'Orta',
      'favorites': 'Favoriler',
      'my_favorites': 'Favorilerim',
      'no_favorites': 'Henüz favori yok.',
      'name': 'Ad',
      'email': 'E-posta',
      'save': 'Kaydet',
      'new_password': 'Yeni Şifre',
      'change_password': 'Şifre Değiştir',
      'password_changed': 'Şifre değiştirildi!',
    }
  };

  void addNotification(String msg) {
    setState(() {
      _notifications.insert(0, msg);
    });
  }

  void _onBookAdded() {
    // Refresh the home screen when a book is added
    _refreshHomeScreen?.call();
  }

  @override
  Widget build(BuildContext context) {
    final lang = localized[_selectedLanguage]!;
    final List<Widget> _pages = [
      HomeScreen(
        lang: lang,
        selectedLanguage: _selectedLanguage,
        onMessageSent: addNotification,
        onLanguageChanged: _updateLanguage,
        notifications: _notifications,
        onRefreshCallback: (callback) => _refreshHomeScreen = callback,
      ),
      ListingsScreen(
        lang: lang,
        onMessageSent: addNotification,
        showOnlyMine: true,
        onBookAdded: _onBookAdded,
      ),
      FavoritesScreen(lang: lang),
      MessagesScreen(lang: lang),
      ProfileScreen(lang: lang, onLanguageChanged: _updateLanguage),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2D66F4),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
