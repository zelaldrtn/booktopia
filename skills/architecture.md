# Architecture Skill — Booktopia

## Amaç
Flutter projesini özellik bazlı, okunabilir ve sürdürülebilir şekilde düzenle.

## Klasör kuralları

- lib/main.dart: Uygulamayı başlatır.
- lib/core/constants/: Ortak sabitler ve renk tanımları.
- lib/core/theme/: Açık ve koyu tema.
- lib/core/localization/: Dil yapılandırması ve çeviri kaynakları.
- lib/core/services/: Ortak servisler ve Supabase bağlantısı.
- lib/features/: Her uygulama özelliğinin kodu.

### Feature düzeni

Her özellik gerektiğinde aşağıdaki yapıyı kullanır:

- controller/: İş mantığı ve durum yönetimi.
- models/: Veri modelleri.
- view/: Sayfa ve ekranlar.
- widget/: Özelliğe ait tekrar kullanılabilir arayüz bileşenleri.

### Kurallar

- Bir özelliğin tüm kodlarını main.dart içine yazma.
- Özellikler arası ortak kodları uygun ortak alanlarda tut.
- Dosyaları yalnızca gerçekten ihtiyaç varsa oluştur.
- Gereksiz soyutlama ve katman ekleme.
- Var olan dosyaları incelemeden silme veya yeniden oluşturma.
- Proje yapısını değiştireceksen önce mevcut bağımlılıkları kontrol et.
- project.md ile çelişen mimari kullanma.