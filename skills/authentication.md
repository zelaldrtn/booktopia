# Authentication Skill — Booktopia

## Amaç

Kullanıcı kayıt ve oturum işlemlerini Supabase Auth ile yönet.

## Özellikler

- E-posta ve şifreyle kayıt.
- E-posta ve şifreyle giriş.
- Şifre sıfırlama.
- Güvenli çıkış.
- Oturumun yeniden açılışta kontrol edilmesi.

## Kurallar

- Giriş ve kayıt formlarında zorunlu alanları doğrula.
- E-posta biçimini kontrol et.
- Şifre alanlarını uygun şekilde doğrula.
- Şifreyi düz metin olarak saklama veya loglara yazma.
- Supabase Auth tarafından döndürülen hataları anlaşılır kullanıcı mesajlarına dönüştür.
- Yüklenme sırasında tekrar tekrar form gönderilmesini engelle.
- Giriş yapılmadan kullanıcıya özel ekranlara erişimi engelle.
- Çıkışta kullanıcıya ait özel ekranları ve durumları doğru şekilde temizle.
- Kullanıcı oturumunu yalnızca yerel bir değişkenle kalıcıymış gibi gösterme.
- Şifre sıfırlama akışının gerçek Supabase yapılandırmasıyla çalıştığını kontrol et.
- Gerekli e-posta yönlendirme ve Supabase ayarları eksikse bunu belirt.
- Kullanıcıya ait verileri yalnızca ekranda gizlemekle yetinme; veritabanında RLS ile de koru.