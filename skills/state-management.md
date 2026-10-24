# State Management Skill — Booktopia

## Amaç

Uygulama durumlarını basit, anlaşılır ve tutarlı şekilde yönet.

## Kurallar

- Öncelikle Flutter ve Dart'ın yerel API'lerini kullan.
- Gerektiğinde ChangeNotifier ve ValueNotifier kullan.
- Sayfa düzeyinde karmaşık setState kullanımından kaçın.
- Sadece yerel ve kısa süreli arayüz durumlarında StatefulWidget kullan.
- Veritabanındaki kayıtları kalıcı veri kaynağı olarak ele al.
- Ekrandaki geçici durumu kalıcı veriyle karıştırma.
- Tema ve dil tercihlerinin yeniden açılışta korunmasını sağla.
- Kitap ilerlemesi değiştiğinde ilgili ekranların doğru güncellenmesini sağla.
- Okuma oturumu bittiğinde süre ve sayfa bilgisini doğrula ve kaydet.
- Aynı verinin gereksiz kopyalarını tutma.
- Onay almadan ağır bir state yönetimi paketi ekleme.
- Durum güncellemelerinde yüklenme, başarı ve hata durumlarını ele al.