# Testing Skill — Booktopia

## Amaç

Uygulamanın temel özelliklerinin doğru çalıştığını doğrula.

## Kontrol edilecek alanlar

- Kayıt, giriş, çıkış ve şifre sıfırlama.
- Kitap ekleme, düzenleme, silme ve arama.
- Okuma ilerlemesinin doğru hesaplanması.
- Zamanlayıcının başlatılması, duraklatılması ve bitirilmesi.
- Okuma oturumunun kaydedilmesi.
- Günlük hedef ve istatistiklerin doğru hesaplanması.
- Türkçe ve İngilizce dil değişimi.
- Açık ve koyu tema değişimi.
- Boş veri, yüklenme ve hata ekranları.
- Kullanıcının başka kullanıcıların verilerine erişememesi.

## Kurallar

- İş mantığı için uygun birim testleri yaz.
- Önemli arayüz davranışları için widget testleri yaz.
- Supabase bağlantısı veya yapılandırması bulunmadığında gerçek backend testlerinin başarılı olduğu iddia edilmemelidir.
- Test verilerinin gerçek kullanıcı kayıtlarını değiştirmemesine dikkat et.
- Kod değişikliklerinden sonra flutter analyze çalıştır.
- Uygun testleri flutter test ile çalıştır.
- Mümkün olduğunda uygulamayı flutter run ile açıp kontrol et.
- Hata varsa raporla, düzelt ve kontrolleri tekrar çalıştır.
- Çalıştırılmayan testleri geçmiş gibi gösterme.