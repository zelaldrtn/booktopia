-- ==============================================================================
-- Booktopia — Supabase Veritabanı Şeması ve RLS Güvenlik Politikaları
-- ==============================================================================
-- Bu dosya, Booktopia mobil uygulaması için gerekli tabloları, ilişkileri,
-- kısıtlamaları ve Row Level Security (RLS) politikalarını içerir.
--
-- Güvenlik Kuralı:
-- Her kullanıcı yalnızca kendi verilerini görebilir, ekleyebilir, güncelleyebilir ve silebilir.
-- service_role anahtarı istemcide asla kullanılmaz.
-- ==============================================================================

-- 1. PROFİLLER TABLOSU (auth.users tablosu ile birebir ilişkili)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    daily_goal_minutes INTEGER NOT NULL DEFAULT 20 CHECK (daily_goal_minutes > 0),
    language TEXT NOT NULL DEFAULT 'tr' CHECK (language IN ('tr', 'en')),
    theme_mode TEXT NOT NULL DEFAULT 'light' CHECK (theme_mode IN ('light', 'dark', 'system')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. KİTAPLAR TABLOSU
CREATE TABLE IF NOT EXISTS public.books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    total_pages INTEGER NOT NULL CHECK (total_pages > 0),
    current_page INTEGER NOT NULL DEFAULT 0 CHECK (current_page >= 0 AND current_page <= total_pages),
    status TEXT NOT NULL DEFAULT 'reading' CHECK (status IN ('reading', 'completed', 'to_read')),
    cover_url TEXT,
    rating NUMERIC(2,1) CHECK (rating >= 0 AND rating <= 5),
    category TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. OKUMA OTURUMLARI TABLOSU
CREATE TABLE IF NOT EXISTS public.reading_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    book_id UUID REFERENCES public.books(id) ON DELETE CASCADE,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes >= 0),
    pages_read INTEGER NOT NULL DEFAULT 0 CHECK (pages_read >= 0),
    session_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. ALINTILAR TABLOSU (Quote Studio & Notlar)
CREATE TABLE IF NOT EXISTS public.quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    book_id UUID REFERENCES public.books(id) ON DELETE SET NULL,
    quote_text TEXT NOT NULL,
    author TEXT,
    book_title TEXT,
    page_number INTEGER CHECK (page_number >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. YILLIK OKUMA HEDEFLERİ TABLOSU
CREATE TABLE IF NOT EXISTS public.reading_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    target_books INTEGER NOT NULL CHECK (target_books > 0),
    completed_books INTEGER NOT NULL DEFAULT 0 CHECK (completed_books >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_user_year UNIQUE (user_id, year)
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLİTİKALARI
-- ==============================================================================

-- 1. profiles RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar sadece kendi profillerini görebilir"
ON public.profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Kullanıcılar kendi profillerini güncelleyebilir"
ON public.profiles FOR UPDATE
USING (auth.uid() = id);

CREATE POLICY "Kullanıcılar kendi profilini ekleyebilir"
ON public.profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- 2. books RLS
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar sadece kendi kitaplarını görebilir"
ON public.books FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi kitaplarını ekleyebilir"
ON public.books FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi kitaplarını güncelleyebilir"
ON public.books FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi kitaplarını silebilir"
ON public.books FOR DELETE
USING (auth.uid() = user_id);

-- 3. reading_sessions RLS
ALTER TABLE public.reading_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar sadece kendi okuma oturumlarını görebilir"
ON public.reading_sessions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi okuma oturumlarını ekleyebilir"
ON public.reading_sessions FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi okuma oturumlarını güncelleyebilir"
ON public.reading_sessions FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi okuma oturumlarını silebilir"
ON public.reading_sessions FOR DELETE
USING (auth.uid() = user_id);

-- 4. quotes RLS
ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar sadece kendi alıntılarını görebilir"
ON public.quotes FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi alıntılarını ekleyebilir"
ON public.quotes FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi alıntılarını güncelleyebilir"
ON public.quotes FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi alıntılarını silebilir"
ON public.quotes FOR DELETE
USING (auth.uid() = user_id);

-- 5. reading_goals RLS
ALTER TABLE public.reading_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar sadece kendi hedeflerini görebilir"
ON public.reading_goals FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi hedeflerini ekleyebilir"
ON public.reading_goals FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi hedeflerini güncelleyebilir"
ON public.reading_goals FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar sadece kendi hedeflerini silebilir"
ON public.reading_goals FOR DELETE
USING (auth.uid() = user_id);

-- ==============================================================================
-- OTOMATİK PROFİL OLUŞTURMA TETİKLEYİCİSİ (TRIGGER)
-- ==============================================================================
-- Bir kullanıcı Supabase Auth üzerinden kayıt olduğunda, public.profiles tablosuna
-- otomatik olarak eşleşen bir profil satırı ekler.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, username)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        split_part(NEW.email, '@', 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
