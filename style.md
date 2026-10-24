# Booktopia — Design System

## 1. Tasarım amacı
Booktopia, kitap okuma ve kişisel gelişim hissi veren modern vintage bir uygulamadır. Görünüm sıcak, sade, düzenli ve göz yormayan olmalıdır.

## 2. Renk paleti
- Cream: #F5F0E6
- Burgundy: #6B3038
- Sage: #7C8062
- Sand Beige: #D9C7AE
- Dark Brown: #302C29
- Dark Background: #242321
- Açık tema varsayılandır. Koyu temada arka plan, metin, kart ve vurgu renkleri okunabilirliği koruyacak şekilde tanımlanmalıdır. Renkler ekranlara doğrudan rastgele yazılmamalı, merkezi tema yapılandırmasından kullanılmalıdır.

## 3. Tipografi
- Başlıklarda serif yazı tipi kullan.
- Gövde metinlerinde okunaklı sans-serif yazı tipi kullan.
- Başlık, alt başlık, gövde ve açıklama metinleri arasında belirgin hiyerarşi oluştur.
- Türkçe karakterleri destekleyen fontlar seç.
- Font dosyaları kullanılıyorsa assets/fonts/ altında düzenle ve Flutter yapılandırmasına ekle.

# 4. Ekran düzeni
- Mobil öncelikli tasarım yap.
- Tutarlı kenar boşlukları ve aralıklar kullan.
- İçeriği gereksiz kartlarla doldurma.
- Uzun metinleri ve kitap listelerini rahat okunabilir biçimde sun.
- Kitap kapaklarının oranlarını koru.
- Küçük ekranlarda taşma oluşmamasını sağla.

## 5. Bileşenler
- Butonlar, metin alanları, kartlar, diyaloglar ve sekmeler ortak görsel dile sahip olmalıdır.
- Birincil işlemlerde bordo vurgu rengi kullanılabilir.
- İkincil alanlarda krem, bej ve adaçayı tonları kullanılabilir.
- İlerleme çubukları ve grafikler anlaşılır olmalıdır.
- Hata, başarı ve boş veri durumları açıkça gösterilmelidir.
- Dokunma alanları mobil kullanım için yeterince büyük olmalıdır.

# 6. Navigasyon
- Ana navigasyonda beş bölüm bulunur: Home, My Library, Reading Corner, Statistics ve Profile.
- Okuma zamanlayıcısına Home ve kitap detay ekranlarından erişilir.
- Quote Studio ve Reading Wrapped ilgili kitap, istatistik veya profil ekranlarından açılabilir.
- Gereksiz navigasyon katmanları oluşturulmaz.

## 7. Logo ve splash screen
- Booktopia adına uygun özgün bir kitap temalı logo oluştur.
- Logo, uygulamanın vintage tasarımıyla uyumlu olmalıdır.
- Gerçek bir görsel varlık üret ve assets/images/ altında sakla.
- Logo görselini Flutter uygulamasına bağla.
- Açılış ekranında logo ve kısa bir slogan göster.
- Gerekli uygulama ikonunu ve splash screen yapılandırmasını tamamla.
- Yalnızca geçici metin veya emoji kullanarak tamamlanmış sayma.

## 8. Açık ve koyu tema
- Açık tema varsayılan olarak açılsın.
- Kullanıcı koyu temaya geçebilsin.
- Her iki temada da metin ve ikon kontrastı yeterli olsun.
- Tema renkleri core/theme/ ve core/constants/ üzerinden yönetilsin.

## 9. Tasarım sınırları
- Sosyal medya akışı veya takip sistemi tasarlama.
- Gereksiz animasyon ve karmaşık 3D efektler kullanma.
- Kullanıcıyı yoran kalabalık dashboard tasarımlarından kaçın.
- Tasarım, project.md içindeki işlevleri desteklemelidir.