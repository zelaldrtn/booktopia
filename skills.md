# Booktopia — Development Skills

- Bu dosya, Booktopia Flutter projesinde geliştirme yapan Antigravity ajanının genel çalışma standartlarını tanımlar. project.md ve style.md ile birlikte uygulanmalıdır.

## 1. Önce analiz et
- Kod yazmadan önce project.md, style.md ve ilgili skill dosyasını oku.
- Mevcut proje dosyalarını ve pubspec.yaml dosyasını incele.
- Var olan kodu anlamadan gereksiz dosya oluşturma veya dosyaları silme.
- Eksik gereksinimleri varsayımla doldurmak yerine açıkça belirt.

## 2. Mimari kurallar
- Özellik bazlı mimariyi kullan.
- Her özelliğin kodunu kendi lib/features/ klasöründe tut.
- İlgili kodları controller/, models/, view/ ve widget/ klasörlerine ayır.
- Ortak tema, sabitler ve servisleri lib/core/ altında tut.
- main.dart dosyasını gereksiz kodlarla büyütme.
3. Kodlama standartları
- Okunabilir ve küçük sorumluluklara ayrılmış kod yaz.
- Statik widget'larda mümkün olan yerlerde const kullan.
- 40 satırı aşan build metotlarını uygun widget'lara ayır.
- Renk ve metin stillerini merkezi tema dosyalarından yönet.
- Aynı kodu gereksiz yere tekrarlama.
- Sayfa düzeyinde ağır setState kullanımından kaçın.
- Gereksiz paket ekleme.

## 4. UI ve etkileşim
- Material Design 3 kullan.
- Görsel kurallar için style.md ve skills/design.md dosyalarını uygula.
- Butonlar, formlar, diyaloglar ve navigasyon gerçekten çalışmalıdır.
- Yüklenme, hata ve boş veri durumlarını tasarla.
- Türkçe ve İngilizce metinlerin taşmamasını kontrol et.
- Gerçek logo ve açılış ekranı varlıklarını oluştur ve yapılandır.

## 5. Backend ve güvenlik
- Supabase işlemlerini ortak servisler üzerinden yürüt.
- Kimlik doğrulama ile veritabanı erişimini birbirinden ayır.
- Kullanıcıya özel verileri oturum açan kullanıcının kimliğiyle ilişkilendir.
- RLS politikalarını dikkate al.
- service_role anahtarını istemci koduna koyma.
- Başarılı olmayan veri işlemlerini başarılı gibi gösterme.

## 6. Dil ve tema
- Türkçe ve İngilizce desteğini koru.
- Kullanıcının dil seçimini kalıcı olarak sakla.
- Açık ve koyu temayı ortak tema yapılandırmasından yönet.
- Tema ve dil değişikliğinde ekranların güncellenmesini sağla.

## 7. Test ve doğrulama
- Kod değişikliklerinden sonra flutter analyze çalıştır.
- Uygun birim ve widget testlerini flutter test ile çalıştır.
- Projeyi mümkün olduğunda flutter run ile başlat.
- Hata varsa önce düzelt, sonra ilgili kontrolleri tekrarla.
- Çalıştırılamayan testleri başarılı olarak raporlama.

## 8. Çalışma ve raporlama
- Önce mevcut yapıyı incele, sonra küçük ve kontrollü değişiklikler yap.
- Bir görev için ilgisiz dosyaları değiştirme.
- Yapılan değişiklikleri ve dosya yollarını belirt.
- Gerçekten oluşturulmamış dosyaları veya görselleri oluşturulmuş gibi sunma.
- Projede bulunmayan özellikleri kendiliğinden ekleme.
- Gereksinimler çelişiyorsa ilgili belgeleri karşılaştır ve çelişkiyi bildir.

## 9. İlgili kılavuzlar
- project.md: Proje kapsamı, özellikler ve teknik gereksinimler.
- style.md: Görsel tasarım ve bileşen kuralları.
- skills/design.md: Tasarım uygulama kuralları.
- skills/architecture.md: Dosya ve mimari düzeni.
- skills/frontend.md: Flutter ekranları ve etkileşimler.
- skills/backend.md: Supabase servisleri.
- skills/authentication.md: Kayıt ve oturum işlemleri.
- skills/database.md: Veri modeli ve güvenlik.
- skills/state-management.md: Arayüz durumu.
- skills/localization.md: Dil desteği.
- skills/testing.md: Analiz ve test yaklaşımı.