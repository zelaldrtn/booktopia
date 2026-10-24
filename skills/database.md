# Database Skill — Booktopia

## Amaç

Booktopia verilerini Supabase veritabanında tutarlı ve kullanıcıya özel şekilde sakla.

## Temel tablolar

- profiles: Kullanıcı profili, görünen ad ve tercihler.
- books: Kitap bilgileri, okuma durumu, sayfa sayısı ve ilerleme.
- reading_sessions: Okuma oturumları, süre, okunan sayfa ve tarih.
- quotes: Kullanıcının kitap alıntıları, kitap ilişkisi ve sayfa bilgisi.
- reading_goals: Günlük okuma hedefleri.

### Kurallar

- Her kullanıcıya ait kayıtlarda uygun kullanıcı kimliği alanı bulunmalıdır.
- Kayıtlar gerektiğinde Supabase Auth kullanıcısıyla ilişkilendirilmelidir.
- Gerekli alanların veri türlerini ve zorunluluklarını açıkça tanımla.
- Kitapların sayfa sayısı ve mevcut sayfası gibi sayısal alanlarda geçerli değerleri kontrol et.
- Mevcut sayfanın kitap toplam sayfasını aşmasına izin verme.
- Okuma süresi ve sayfa sayısını tutarlı biçimde sakla.
- Kitap silme ve ilişkili kayıtların davranışını bilinçli şekilde belirle.
- Kullanıcıya ait tablolar için RLS etkinleştir ve uygun politikalar oluştur.
- Kullanıcı yalnızca kendi kayıtlarını okuyabilmeli, ekleyebilmeli, güncelleyebilmeli ve silebilmelidir.
- Gerekli veritabanı şeması veya politikalar oluşturulmadıysa bu eksikliği bildir.
- Gizli servis anahtarlarını istemci uygulamasında kullanma.
- Veritabanı işlemlerinin başarılı olduğunu gerçek sonuçtan doğrula.