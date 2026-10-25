# Booktopia — Kişisel Kitap Okuma Asistanı

**Flutter** ve **Supabase** ile geliştirilmiş; modern, estetik ve çok platformlu (cross-platform) kişisel kitap okuma asistanı ve kütüphane takip uygulaması. Booktopia; odaklanmış okuma zamanlayıcıları, sakinleştirici ambiyans sesleri, estetik alıntı kartı paylaşımı ve okuma istatistikleriyle kitap okumayı keyifli bir alışkanlığa dönüştürür.

---

## 📖 Özellikler

- **Kişisel Kütüphane Yönetimi**:
  - Kitap ekleme, düzenleme ve okuma durumuna göre gruplandırma (*Şu An Okunanlar*, *Okunacaklar*, *Tamamlananlar*).
  - Sayfa takibi, okuma yüzdesi ve detaylı kitap bilgileri.
- **Odaklı Okuma Köşesi (Zamanlayıcı)**:
  - **Pomodoro ve Serbest Zamanlayıcı**: 25 dakikalık odaklanma seansları veya serbest okuma oturumları.
  - **Otomatik İlerleme Senkronizasyonu**: Oturum bittiğinde kitap sayfa sayısı ve oturum geçmişi Supabase'e anında kaydedilir.
- **Yüksek Kaliteli Ambiyans Sesleri**:
  - 4 farklı dinlendirici ses atmosferi: **Hafif Yağmur** (pencereye vuran damlalar), **Şömine Çıtırtısı** (sıcak meşe kütükleri), **Eski Kütüphane** (derin sessizlik ve sayfa hışırtıları), **Sessiz Kafe** (dingin kahve dükkanı akustiği).
  - Kesintisiz döngü (seamless loop), gerçek zamanlı ses seviyesi ayarı ve tekil ses yönetimi (yeni bir ses açıldığında önceki otomatik durur).
  - Çoklu platform motoru: Chrome web tarayıcısında Web Audio API sentezleyicisi, Android mobil cihazlarda `audioplayers` yerel oynatıcı.
- **Alıntı Stüdyosu (Quote Studio) ve Kart Paylaşımı**:
  - Kitaplardan ve yazarlardan ilham veren alıntıları kaydetme ve listeleme.
  - **Spotify Tarzı Alıntı Kartları**: Yazı tipi, arka plan rengi, kart şablonu ve metin hizalamasını kişiselleştirme.
  - Alıntı kartını görsel formatında dışa aktarıp sosyal medyada veya mesajlaşma uygulamalarında tek dokunuşla paylaşma (`share_plus`).
- **Okuma İstatistikleri ve Analizler**:
  - Günlük okuma hedefleri, okuma serisi (streak), toplam okunan dakika ve tamamlanan kitap grafikleri.
- **Profil ve Kişiselleştirme**:
  - Supabase Storage altyapısıyla güvenli profil fotoğrafı yükleme ve güncelleme.
  - **Material 3 Tasarım Dili**: Krem, Orman Yeşili, Bordo, Adaçayı ve Terracotta tonlarından oluşan özel renk paleti.
  - **Akıcı Açık ve Koyu Tema**: Yazı tipi uyumsuzluğu yaşanmayan pürüzsüz geçiş animasyonları.
  - **Çift Dil Desteği**: Türkçe ve İngilizce dilleri arasında anında geçiş.

---

## 🛠️ Kullanılan Teknolojiler ve Paketler

- **Çekirdek**: [Flutter](https://flutter.dev/) (Kanal: stable, Dart 3.x)
- **Arka Plan (Backend)**: [Supabase](https://supabase.com/)
  - Kimlik Doğrulama (E-posta / Parola, Güvenli Oturum Yönetimi)
  - PostgreSQL Veritabanı ve Satır Düzeyinde Güvenlik (Row-Level Security - RLS)
  - Supabase Storage (Profil avatarları)
- **Önemli Paketler**:
  - `supabase_flutter`: Supabase istemcisi, kimlik doğrulama ve veri yönetimi.
  - `audioplayers`: Android ve mobilde kesintisiz döngüsel ses oynatma.
  - `google_fonts`: Newsreader (edebi serif) ve Plus Jakarta Sans (arayüz tipografisi).
  - `shared_preferences`: Yerel tema ve dil tercihlerini kalıcı olarak saklama.
  - `image_picker`: Galeriden veya kameradan profil fotoğrafı seçimi.
  - `share_plus` & `path_provider`: Alıntı kartlarını görsel olarak cihazda işleme ve paylaşma.
  - `intl`: Çoklu dil ve tarih formatlama desteği.

---

## 📁 Proje Klasör Yapısı

```text
booktopia/
├── android/                   # Android yerel ayarları, izinler ve başlatıcı ikonlar
├── assets/
│   ├── audio/                 # Döngüsel ambiyans sesleri (rain, fireplace, library, cafe)
│   ├── icons/                 # Vektörel arayüz ikonları
│   └── images/                # Uygulama logosu, başlatıcı ikon ve illüstrasyonlar
├── lib/
│   ├── core/
│   │   ├── constants/         # AppColors ve tema sabitleri
│   │   ├── localization/      # Türkçe / İngilizce metin sözlükleri ve dil yöneticisi
│   │   ├── services/          # Supabase servisi, cross-platform ambiyans ses servisi
│   │   └── theme/             # Material 3 açık ve koyu tema tanımları, ThemeController
│   ├── features/
│   │   ├── authentication/    # SplashView, LoginView, RegisterView ve AuthController
│   │   ├── book_library/      # Kitaplık ekranı, kitap modelleri ve yönetim kontrolleri
│   │   ├── reading_corner/    # Zamanlayıcı, ambiyans ses kontrolleri ve oturum kaydı
│   │   ├── quote_studio/      # Alıntı stüdyosu, kart tasarımı ve görsel paylaşımı
│   │   ├── statistics/        # Okuma alışkanlıkları, streak ve grafik analizleri
│   │   └── profile/           # Profil ekranı, avatar yükleme ve uygulama ayarları
│   └── main.dart              # Uygulama başlangıcı, tema ve dil dinleyicileri
├── test/                      # Birim ve widget testleri (42 adet test)
├── tool/                      # Ambiyans seslerini üreten bağımsız Dart aracı
├── pubspec.yaml               # Bağımlılıklar, asset tanımları ve ikon yapılandırması
└── README.md
```

---

## 🚀 Kurulum

### Önkoşullar

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.13.5`)
- [Android Studio / Android SDK](https://developer.android.com/studio) (Android derlemesi için)
- Google Chrome (Web çalıştırması için)

### Adımlar

1. **Projeyi klonlayın**:
   ```bash
   git clone https://github.com/kullanici-adiniz/booktopia.git
   cd booktopia
   ```

2. **Bağımlılıkları yükleyin**:
   ```bash
   flutter pub get
   ```

3. **Geliştirme ortamını doğrulayın**:
   ```bash
   flutter doctor
   ```

---

## 🔐 Supabase Yapılandırması

Booktopia, Supabase bağlantısını güvenli istemci anahtarlarıyla sağlar. Kendi Supabase projenizi bağlamak için çalışma veya derleme esnasında bilgileri `--dart-define` ile sağlayabilirsiniz:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://projeniz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=anon-genel-anahtariniz
```

> **Önemli Güvenlik Notu:** `service_role` (yönetici) anahtarını asla istemci uygulamasına yazmayın veya kaynak koda eklemeyin. Mobil istemciler yalnızca Supabase Row-Level Security (RLS) politikalarıyla korunan genel `anon` anahtarını kullanmalıdır.

---

## 💻 Uygulamayı Çalıştırma

### Google Chrome (Web) üzerinde:
```bash
flutter run -d chrome
```

### Android Cihaz veya Emülatör üzerinde:
```bash
flutter run -d android
```

---

## 📦 Release APK Oluşturma

Android cihazlara doğrudan yüklenebilecek optimize edilmiş bağımsız bir release APK üretmek için:

```bash
flutter build apk --release
```

Derlenen APK dosyası şu konumda oluşturulur:
```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Test ve Kalite Kontrolü

- **Otomasyon testlerini çalıştırmak için**:
  ```bash
  flutter test
  ```
- **Statik kod analizini çalıştırmak için**:
  ```bash
  flutter analyze
  ```

---

## 🤝 Geliştirme ve Katkı

Projeye katkıda bulunmak isterseniz:
1. Projeyi çatallayın (Fork).
2. Yeni bir özellik dalı oluşturun (`git checkout -b feature/YeniOzellik`).
3. Değişikliklerinizi commit edin (`git commit -m 'Yeni özellik eklendi'`).
4. `flutter test` ve `flutter analyze` komutlarının hatasız geçtiğinden emin olun.
5. Dalınızı GitHub'a gönderin (`git push origin feature/YeniOzellik`).
6. Bir Çekme İsteği (Pull Request) açın.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) kapsamında lisanslanmıştır.
