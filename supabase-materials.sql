-- ============================================
-- MATERIAŁY - Tabela i polityki RLS dla Supabase
-- ============================================
-- Uruchom ten skrypt w SQL Editor w Supabase, jeśli tabela materials
-- nie istnieje jeszcze w Twojej bazie.
-- Jeśli masz już pełny schemat (supabase-schema.sql), ten plik nie jest potrzebny.
--
-- WYMAGANIA: Tabela topics i user_profiles muszą istnieć.
-- Funkcja is_admin() jest tworzona poniżej jeśli nie istnieje.
-- ============================================

-- Włącz rozszerzenie UUID (jeśli nie włączone)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Funkcja sprawdzająca czy użytkownik jest adminem (jeśli nie istnieje)
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Tabela materials (bloki treści dla tematów)
CREATE TABLE IF NOT EXISTS materials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('theory', 'example', 'exercise', 'summary')),
  title TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  content JSONB DEFAULT '[]',
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indeks dla wydajności
CREATE INDEX IF NOT EXISTS idx_materials_topic ON materials(topic_id);
CREATE INDEX IF NOT EXISTS idx_materials_published ON materials(is_published);

-- Włącz RLS
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;

-- Usuń stare polityki jeśli istnieją (dla idempotentności)
DROP POLICY IF EXISTS "Public can view published materials" ON materials;
DROP POLICY IF EXISTS "Admins have full access to materials" ON materials;

-- Polityka: publiczność widzi tylko opublikowane materiały z opublikowanych tematów
CREATE POLICY "Public can view published materials"
  ON materials FOR SELECT
  USING (
    is_published = true AND
    EXISTS (
      SELECT 1 FROM topics
      WHERE topics.id = materials.topic_id AND topics.is_published = true
    )
  );

-- Polityka: admini mają pełny dostęp
CREATE POLICY "Admins have full access to materials"
  ON materials FOR ALL
  USING (is_admin());

-- Trigger dla updated_at (jeśli funkcja już istnieje)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_materials_updated_at ON materials;
CREATE TRIGGER update_materials_updated_at BEFORE UPDATE ON materials
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
