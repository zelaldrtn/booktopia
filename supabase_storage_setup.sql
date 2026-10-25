-- ==============================================================================
-- BOOKTOPIA: Supabase Storage 'avatars' Bucket & Row Level Security (RLS) Politikaları
-- ==============================================================================
-- Bu SQL scripti, profil fotoğrafı yükleme ve güncelleme işlemlerinde alınan
-- "StorageException: new row violates row-level security policy (403)" hatasını
-- kökten ve kalıcı biçimde çözer.
--
-- Gerçek Hata Nedenleri ve Çözümleri:
-- 1. EKSİK / UYUMSUZ UPDATE POLİTİKASI:
--    Supabase Storage istemcisinde 'upsert: true' kullanıldığında PostgreSQL arka planda
--    "INSERT ... ON CONFLICT (bucket_id, name) DO UPDATE" sorgusu çalıştırır.
--    PostgreSQL RLS kuralları gereği ON CONFLICT DO UPDATE durumunda hem INSERT (WITH CHECK)
--    hem de UPDATE (hem USING hem WITH CHECK) politikaları aranır.
--    UPDATE politikası veya onun WITH CHECK kuralı eksik olduğunda PostgreSQL doğrudan
--    "403 new row violates row-level security policy" hatası fırlatır.
-- 2. SELECT POLİTİKASI & RETURNING * KISITI:
--    Storage API yükleme sonrasında eklenen satırı "RETURNING *" ile geri okur.
--    SELECT politikası authenticated rolü için geçerli değilse işlem 403 ile reddedilir.
-- 3. storage.foldername vs split_part FONKSİYON GÜVENİLİRLİĞİ:
--    storage.foldername(name) fonksiyonunun bazı Supabase sürümlerinde null dönmesi veya
--    erişim kısıtına takılması riskine karşı, yerel PostgreSQL fonksiyonu olan
--    split_part(name, '/', 1) ve LIKE operatörü ile auth.uid() doğrulaması garantiye alınır.
-- 4. ÇAKIŞMA & İSTEMCİ İYİLEŞTİRMESİ:
--    İstemci artık zaman damgalı tekil dosya adları ({userId}/avatar_{timestamp}.{ext})
--    ve upsert: false kullanarak salt INSERT yapmaktadır; böylece UPDATE çakışmaları
--    ve tarayıcı önbellek sorunları tamamen önlenmiştir.
-- ==============================================================================

-- 1. 'avatars' depolama alanını (bucket) oluştur ve public olarak ayarla
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880, -- Maksimum 5 MB dosya boyutu
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- 2. Storage tablosu ve şeması için gerekli SQL izinlerini garanti et
GRANT USAGE ON SCHEMA storage TO authenticated, anon;
GRANT SELECT ON TABLE storage.buckets TO authenticated, anon;
GRANT SELECT ON TABLE storage.objects TO authenticated, anon;
GRANT INSERT, UPDATE, DELETE ON TABLE storage.objects TO authenticated;

-- 3. Mevcut çakışan ve eski avatar politikalarını güvenli biçimde temizle
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'storage' AND tablename = 'objects'
          AND (
            policyname ILIKE '%avatar%'
            OR policyname ILIKE '%booktopia%'
            OR policyname ILIKE '%upload%'
            OR policyname ILIKE '%own folder%'
          )
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
    END LOOP;
END $$;

-- Bilinen statik politika isimlerini de temizle
DROP POLICY IF EXISTS "Booktopia Public Avatars Read" ON storage.objects;
DROP POLICY IF EXISTS "Booktopia User Avatar Insert" ON storage.objects;
DROP POLICY IF EXISTS "Booktopia User Avatar Update" ON storage.objects;
DROP POLICY IF EXISTS "Booktopia User Avatar Delete" ON storage.objects;
DROP POLICY IF EXISTS "Booktopia Avatars Select" ON storage.objects;
DROP POLICY IF EXISTS "Booktopia Avatars Insert" ON storage.objects;
DROP POLICY IF EXISTS "Booktopia Avatars Update" ON storage.objects;
DROP POLICY IF EXISTS "Booktopia Avatars Delete" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1mp1a_0" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1mp1a_1" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1mp1a_2" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1mp1a_3" ON storage.objects;

-- 4. SELECT POLİTİKASI (Public Read & Authenticated Check)
-- Hem herkese açık URL ile profil fotoğraflarının görüntülenmesini
-- hem de yükleme sonrasındaki "RETURNING *" sorgusunun başarıyla tamamlanmasını sağlar.
CREATE POLICY "Booktopia Avatars Select"
ON storage.objects FOR SELECT
TO public, authenticated
USING ( bucket_id = 'avatars' );

-- 5. INSERT POLİTİKASI (Kullanıcının Sadece Kendi Klasörüne Dosya Yüklemesi)
-- Dosya yolu kuralı: {auth.uid()}/avatar_{timestamp}.{ext}
-- split_part(name, '/', 1) birinci yol segmentini alır ve auth.uid() ile eşleştirir.
CREATE POLICY "Booktopia Avatars Insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (
    split_part(name, '/', 1) = (SELECT auth.uid()::text)
    OR (storage.foldername(name))[1] = (SELECT auth.uid()::text)
    OR name LIKE ((SELECT auth.uid()::text) || '/%')
  )
);

-- 6. UPDATE POLİTİKASI (Kullanıcının Kendi Dosyasını Güncellemesi / Upsert)
-- ÖNEMLİ: upsert: true işlemi için PostgreSQL hem USING hem de WITH CHECK bloklarını zorunlu tutar.
CREATE POLICY "Booktopia Avatars Update"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (
    split_part(name, '/', 1) = (SELECT auth.uid()::text)
    OR (storage.foldername(name))[1] = (SELECT auth.uid()::text)
    OR name LIKE ((SELECT auth.uid()::text) || '/%')
  )
)
WITH CHECK (
  bucket_id = 'avatars'
  AND (
    split_part(name, '/', 1) = (SELECT auth.uid()::text)
    OR (storage.foldername(name))[1] = (SELECT auth.uid()::text)
    OR name LIKE ((SELECT auth.uid()::text) || '/%')
  )
);

-- 7. DELETE POLİTİKASI (Kullanıcının Yalnızca Kendi Eski Fotoğraflarını Silmesi)
CREATE POLICY "Booktopia Avatars Delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (
    split_part(name, '/', 1) = (SELECT auth.uid()::text)
    OR (storage.foldername(name))[1] = (SELECT auth.uid()::text)
    OR name LIKE ((SELECT auth.uid()::text) || '/%')
  )
);

-- 8. DOĞRULAMA SORGUSU:
-- Bu betik Supabase SQL Editöründe çalıştırıldığında oluşturulan politikaları listeler:
SELECT
    policyname AS "Politika Adı",
    cmd AS "Komut",
    roles::text AS "Roller",
    qual AS "USING Koşulu",
    with_check AS "WITH CHECK Koşulu"
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname ILIKE '%avatar%';
