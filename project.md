# Booktopia — Kitap Okuma Asistanı

- Bu doküman, Flutter projesini geliştirecek Antigravity ajanı ve yazılım geliştiriciler için bağlayıcı proje kılavuzudur. Üretilen kodlar bu dokümandaki gereksinimlere ve proje kurallarına uymalıdır.

## 1. Proje özeti ve teknolojiler
- Uygulama adı: Booktopia
- Amaç: Kullanıcıların kitaplarını düzenlemesini, okuma alışkanlıklarını takip etmesini ve okuma istatistiklerini görmesini sağlayan kişisel kitap okuma asistanı.
- Hedef platformlar: Öncelikle Android ve iOS; web desteği proje yapılandırmasının elverdiği ölçüde korunacaktır.
- Teknolojiler: Flutter, Dart, Material Design 3 ve Supabase.
- Kimlik doğrulama: Supabase Auth ile e-posta ve şifre üzerinden kayıt ve giriş.
- Veri saklama: Supabase veritabanı. Kullanıcılar yalnızca kendi kayıtlarına erişebilmelidir.
- State yönetimi: Öncelikle Flutter ve Dart'ın yerel API'leri; gereksiz ağır state yönetimi paketleri kullanılmayacaktır.
- Grafikler: İhtiyaç duyulursa fl_chart kullanılabilir.
- Tasarım: Modern vintage, sade, kitap temalı ve göz yormayan arayüz.
- Dil: Türkçe ve İngilizce.
- Tema: Açık tema varsayılan, koyu tema seçeneği.
- Logo ve açılış ekranı: Booktopia'ya özgü gerçek logo görseli ve slogan içeren açılış ekranı oluşturulacaktır.

## 2. Uygulama özellikleri

### 2.1 Açılış ve kimlik doğrulama
- Uygulama açılışında Booktopia logosu ve kısa slogan gösterilir.
- İlk kullanımda giriş ve kayıt ekranı sunulur.
- E-posta ve şifre ile kayıt ve giriş yapılır.
- Şifre sıfırlama ve çıkış işlemleri bulunur.
- Kullanıcı oturumu uygun şekilde korunur.
- Giriş yapan kullanıcı kendi verilerine erişir.

### 2.2 Ana ekran
- Kullanıcının devam ettiği kitap ve okuma ilerlemesi gösterilir.
- Günlük okuma hedefi ve mevcut okuma serisi gösterilir.
- Okumaya başlama kısayolu bulunur.
- Son okuma oturumu ve kısa bir motivasyon sözü gösterilebilir.

### 2.3 Kitaplık
- Okunuyor, okundu ve okunacak kitaplar ayrı kategorilerde listelenir.
- Kitap ekleme, düzenleme, silme ve arama yapılabilir.
- Kitap adı, yazar, sayfa sayısı, kapak görseli ve mevcut sayfa tutulur.
- Kitabın okuma ilerlemesi hesaplanır.
- Kitap tamamlandı olarak işaretlenebilir.
- Kullanıcı kişisel puan, değerlendirme, not ve alıntı ekleyebilir.

### 2.4 Okuma oturumu
- Zamanlayıcı başlatılabilir, duraklatılabilir, devam ettirilebilir ve bitirilebilir.
- 15, 25 ve 45 dakikalık hedefler sunulabilir.
- Oturum sonunda okunan sayfa sayısı kaydedilebilir.
- Okuma süresi ve ilerleme ilgili kitapla ilişkilendirilir.

### 2.5 Günlük takip ve takvim
- Günlük okuma kayıtları takvim üzerinden görüntülenir.
- Günlük okuma süresi ve sayfa sayısı gösterilir.
- Okuma hedeflerinin tamamlanması takip edilir.
- Günlük kayıtlar geçmişe dönük görüntülenebilir.

### 2.6 İstatistikler
- Toplam kitap, sayfa ve okuma süresi gösterilir.
- Haftalık ve aylık okuma verileri görüntülenir.
- Hedef tamamlama oranı ve okuma serisi gösterilir.
- Grafikler gerçek kayıtlar üzerinden oluşturulur.

### 2.7 Reading Wrapped
- Aylık ve yıllık okuma özeti hazırlanır.
- Okunan kitaplar, sayfalar, süre ve okuma serisi gösterilir.
- En çok okunan veya kullanıcının favorisi olan kitap gösterilebilir.
- Özet kartı paylaşılabilir.
- Kayıt bulunmuyorsa uydurma istatistik gösterilmez.

### 2.8 Quote Studio
- Kullanıcı kitap alıntısı ekleyebilir.
- Alıntı; kitap, yazar ve sayfa bilgisiyle saklanabilir.
- Vintage tasarımlı alıntı kartları hazırlanabilir.
- Kart önizlenebilir, kaydedilebilir ve paylaşılabilir.

### 2.9 Dijital Reading Corner
- Tamamlanan kitapların kapakları sanal kitaplıkta gösterilir.
- Sade, iki boyutlu bir kitaplık tasarımı kullanılır.
- Karmaşık 3D sistemler kullanılmaz.

### 2.10 Profil ve ayarlar
- Profil adı ve isteğe bağlı profil görseli yönetilebilir.
- Kullanıcının okuma istatistikleri, favorileri, değerlendirmeleri ve alıntıları görüntülenebilir.
- Tema, dil ve günlük okuma hedefi değiştirilebilir.
- Güvenli çıkış işlemi bulunur.

## 3. Mimari yapı: Özellik bazlı
- Kodlar tek bir dosyada veya tek bir klasörde toplanmayacaktır. Her özellik kendi feature klasöründe geliştirilecektir.

- Her feature gerektiğinde controller/, models/, view/ ve widget/ alt klasörlerine ayrılır. Ortak tema, sabitler ve servisler core/ altında yönetilir.

## 4. Backend ve veri güvenliği
- Supabase bağlantısı ortak bir servis üzerinden yönetilir.
- Kullanıcı kimlik doğrulaması Supabase Auth ile yapılır.
- Profil, kitap, okuma oturumu, alıntı ve okuma hedefleri veritabanında saklanır.
- Kullanıcıya ait kayıtlar kullanıcı kimliğiyle ilişkilendirilir.
- Supabase Row Level Security (RLS) politikaları uygulanır.
- Kullanıcının başka bir kullanıcıya ait kayıtları okuması veya değiştirmesi engellenir.
- service_role anahtarı mobil uygulama koduna konulmaz.
- Gizli anahtarlar kaynak kodda tutulmaz.
- Veritabanı şeması ve gerekli yapılandırma tamamlanmadan veri işlemleri tamamlanmış sayılmaz.

## 5. Kırmızı çizgiler: Kod kalite standartları

### 5.1 State yönetimi
- Sayfa düzeyinde ağır setState kullanımı yapılmayacaktır.
- StatefulWidget yalnızca yerel arayüz durumları için kullanılacaktır.
- Gerektiğinde ChangeNotifier veya ValueNotifier gibi yerel API'ler kullanılabilir.
- Onay olmadan ağır state yönetimi paketleri eklenmeyecektir.

### 5.2 UI ve performans
- Statik widget'larda mümkün olan yerlerde const zorunludur.
- Renkler ve metin stilleri tema dosyalarında tanımlanır.
- 40 satırı aşan build metotları uygun özel widget'lara ayrılır.
- Ekranlar küçük mobil ekranlarda da düzgün görünmelidir.
- Yüklenme, boş veri ve hata durumları ele alınmalıdır.

### 5.3 Paket kullanımı
- Onay olmadan gereksiz veya ağır paket eklenmeyecektir.
- Supabase için gereken paketler ve ihtiyaç duyulan grafik paketi bu kuralın kapsamındaki gerekli istisnalardır.
- Paketler kullanılmadan önce proje ve SDK sürümüyle uyumlulukları kontrol edilir.

### 5.4 Kapsam sınırları
- Sosyal medya akışı, takip sistemi ve çevrim içi topluluk oluşturulmayacaktır.
- Yapay zekâ özellikleri eklenmeyecektir.
- İstenmeyen özellikler, sırf projeyi büyütmek için eklenmeyecektir.

## 6. Geliştirme, analiz ve test komutları
Kod değişikliklerinden sonra uygun kontroller çalıştırılmalıdır.

Statik analiz:
flutter analyze

Birim ve widget testleri:
flutter test

Uygulamayı çalıştırma:
flutter run

Ajan, çalıştıramadığı bir komutu başarılıymış gibi göstermemeli; hatayı ve sebebini açıkça bildirmelidir.


## 7. Ajanın çıktı ve yanıt standartları

- Açıklamalar Türkçe, net ve doğrudan olmalıdır.
- Büyük dosyalar gereksiz yere tekrar yazdırılmamalı; değişiklikler özetlenmelidir.
- Oluşturulan dosyaların göreli yolları belirtilmelidir.
- Gerçekten oluşturulmamış dosyalar oluşturulmuş gibi sunulmamalıdır.
- Her geliştirme aşamasından sonra analiz ve test sonucu bildirilmelidir.
- Eksik yapılandırma veya kullanıcıdan gereken bilgi varsa açıkça belirtilmelidir.