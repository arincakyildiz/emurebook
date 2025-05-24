# EmuReBook - Kitap Değişim Platformu

EmuReBook, üniversite öğrencileri arasında kitap değişimi, satışı ve kiralama işlemlerini kolaylaştırmak için geliştirilmiş bir mobil uygulamadır.

## Özellikler

- Kullanıcı hesabı oluşturma ve giriş yapma
- Kitap listeleme, arama ve filtreleme
- Kitap detaylarını görüntüleme
- Kitapları favorilere ekleme
- Kitap sahipleri ile mesajlaşma
- Kitapları puanlama ve değerlendirme
- Kullanıcı profilini düzenleme

## Proje Yapısı

Proje iki ana kısımdan oluşmaktadır:

1. **Frontend (Flutter)**: `lib/` klasöründe bulunur
2. **Backend (Node.js)**: `backend/` klasöründe bulunur

## Kurulum

### Frontend (Flutter)

1. Gerekli bağımlılıkları yükleyin:

```bash
flutter pub get
```

2. API servisinde baseURL'i kendi backend sunucunuza göre ayarlayın (`lib/services/api_service.dart`).

3. Uygulamayı çalıştırın:

```bash
flutter run
```

### Backend (Node.js)

1. `backend` klasörüne gidin:

```bash
cd backend
```

2. Gerekli paketleri yükleyin:

```bash
npm install
```

3. `.env` dosyası oluşturun:

```
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/emurebook
JWT_SECRET=your-secret-key-should-be-at-least-32-characters
JWT_EXPIRES_IN=90d
JWT_COOKIE_EXPIRES_IN=90
```

4. MongoDB veritabanınızı çalıştırın.

5. Backend sunucusunu başlatın:

```bash
npm run dev
```

## Backend API Dokümantasyonu

Detaylı API dokümantasyonu için `backend/README.md` dosyasını inceleyebilirsiniz.

## Katkıda Bulunma

1. Fork'layın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır.
