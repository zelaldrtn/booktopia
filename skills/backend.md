# Backend Skill — Booktopia

## Amaç

Supabase ile güvenli ve tutarlı veri erişimi sağla.

## Kurallar

- Supabase bağlantısını ortak servis üzerinden yönet.
- Kullanılan paket ve SDK sürümlerinin uyumluluğunu kontrol et.
- Veritabanı işlemlerini mümkün olduğunca arayüz kodundan ayır.
- Kitap, okuma oturumu, alıntı, profil ve hedef kayıtlarını doğru kullanıcıyla ilişkilendir.
- Oturum açan kullanıcının kimliğini Supabase Auth üzerinden al.
- Veri kaydetme, güncelleme ve silme hatalarını ele al.
- İşlem başarısız olduğunda kullanıcıya yanlış başarı mesajı gösterme.
- Hassas anahtarları kaynak koduna yazma.
- service_role anahtarını Flutter uygulamasına hiçbir zaman ekleme.
- İstemci tarafındaki kontrolleri tek başına güvenlik önlemi kabul etme.
- Veritabanı erişiminde RLS politikalarının etkin ve doğru olduğunu doğrula.
- Backend yapılandırması tamamlanmadıysa çalışıyormuş gibi raporlama.
- Gerekli Supabase URL ve public/publishable anahtar yapılandırmasını güvenli şekilde sağla.