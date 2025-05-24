# EmuReBook Backend API

Bu repo, EmuReBook kitap değişim platformunun backend API'sini içerir.

## Teknolojiler

- Node.js
- Express.js
- MongoDB
- JWT Authentication

## Kurulum

1. Gerekli paketleri yükleyin:

```bash
npm install
```

2. `.env` dosyası oluşturun:

```
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/emurebook
JWT_SECRET=your-secret-key-should-be-at-least-32-characters
JWT_EXPIRES_IN=90d
JWT_COOKIE_EXPIRES_IN=90
```

3. MongoDB veritabanınızı çalıştırın.

4. Uygulamayı başlatın:

```bash
npm run dev
```

## API Endpointleri

### Kullanıcı Kimlik Doğrulama

- `POST /api/auth/register` - Yeni kullanıcı kaydı
- `POST /api/auth/login` - Kullanıcı girişi
- `POST /api/auth/logout` - Kullanıcı çıkışı
- `GET /api/auth/me` - Mevcut kullanıcı bilgilerini getir
- `PATCH /api/auth/update-password` - Şifre güncelleme
- `PATCH /api/auth/update-me` - Kullanıcı bilgilerini güncelleme
- `POST /api/auth/forgot-password` - Şifremi unuttum
- `POST /api/auth/reset-password/:token` - Şifre sıfırlama

### Kitaplar

- `GET /api/books` - Tüm kitapları listele
- `GET /api/books/:id` - Belirli bir kitabı getir
- `POST /api/books` - Yeni kitap ekle
- `PATCH /api/books/:id` - Kitap bilgilerini güncelle
- `DELETE /api/books/:id` - Kitap sil
- `GET /api/books/search` - Kitap ara
- `GET /api/books/categories` - Kitap kategorilerini getir
- `GET /api/books/user/:userId` - Kullanıcının kitaplarını getir
- `POST /api/books/:id/rating` - Kitaba puan ver
- `POST /api/books/:id/favorite` - Kitabı favorilere ekle/çıkar

### Mesajlar

- `GET /api/messages` - Kullanıcının tüm mesajlarını getir
- `GET /api/messages/conversations` - Kullanıcının tüm konuşmalarını getir
- `GET /api/messages/conversation/:userId` - Belirli bir kullanıcıyla olan konuşmayı getir
- `POST /api/messages` - Yeni mesaj gönder
- `PATCH /api/messages/:id/read` - Mesajı okundu olarak işaretle
- `DELETE /api/messages/:id` - Mesaj sil

### Kullanıcılar

- `GET /api/users/:id` - Kullanıcı profilini getir
- `GET /api/users/favorites/books` - Kullanıcının favori kitaplarını getir
- `POST /api/users/upload-avatar` - Kullanıcı profil resmi yükle
- `GET /api/users` - Tüm kullanıcıları listele (sadece admin)
- `DELETE /api/users/:id` - Kullanıcı sil (sadece admin)

## Veri Modelleri

### Kullanıcı

```javascript
{
  name: String,
  email: String,
  password: String,
  avatar: String,
  department: String,
  studentId: String,
  phone: String,
  role: String,
  favoriteBooks: [BookId],
  createdAt: Date
}
```

### Kitap

```javascript
{
  title: String,
  author: String,
  description: String,
  imageUrl: String,
  condition: String,
  price: Number,
  category: String,
  exchangeType: String,
  department: String,
  courseCode: String,
  owner: UserId,
  isbn: String,
  language: String,
  publisher: String,
  publishedYear: Number,
  availability: Boolean,
  createdAt: Date,
  ratings: [
    {
      user: UserId,
      rating: Number,
      review: String,
      createdAt: Date
    }
  ]
}
```

### Mesaj

```javascript
{
  sender: UserId,
  receiver: UserId,
  content: String,
  relatedBook: BookId,
  isRead: Boolean,
  createdAt: Date
}
```
