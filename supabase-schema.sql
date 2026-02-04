-- TylkoMatmaOnline Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- EDUCATION HIERARCHY TABLES
-- ============================================

-- Education Levels (e.g., Liceum, Technikum)
CREATE TABLE education_levels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories (e.g., Analiza, Geometria)
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  education_level_id UUID NOT NULL REFERENCES education_levels(id) ON DELETE CASCADE,
  parent_category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(education_level_id, slug)
);

-- Topics (e.g., Pochodne funkcji)
CREATE TABLE topics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  learning_objectives JSONB DEFAULT '[]',
  estimated_time INTEGER, -- in minutes
  difficulty_level TEXT CHECK (difficulty_level IN ('basic', 'intermediate', 'advanced')),
  display_order INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  seo_title TEXT,
  seo_description TEXT,
  seo_keywords TEXT,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(category_id, slug)
);

-- Materials (content blocks for topics)
CREATE TABLE materials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('theory', 'example', 'exercise', 'summary')),
  title TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  content JSONB DEFAULT '[]', -- Array of content blocks
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TEST SYSTEM TABLES
-- ============================================

-- Tests
CREATE TABLE tests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES topics(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  time_limit INTEGER, -- in minutes
  passing_score INTEGER DEFAULT 60, -- percentage
  is_published BOOLEAN DEFAULT false,
  show_correct_answers BOOLEAN DEFAULT true,
  randomize_questions BOOLEAN DEFAULT false,
  randomize_answers BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (topic_id IS NOT NULL OR category_id IS NOT NULL)
);

-- Questions (reusable question bank)
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content TEXT NOT NULL,
  explanation TEXT, -- shown after answer
  difficulty_level TEXT CHECK (difficulty_level IN ('basic', 'intermediate', 'advanced')),
  tags JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Test-Question junction table
CREATE TABLE test_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  test_id UUID NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  display_order INTEGER NOT NULL DEFAULT 0,
  points INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(test_id, question_id)
);

-- Answers (ABCD options)
CREATE TABLE answers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  label TEXT NOT NULL CHECK (label IN ('A', 'B', 'C', 'D')),
  is_correct BOOLEAN DEFAULT false,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(question_id, label)
);

-- ============================================
-- USER & PROGRESS TABLES (Future expansion)
-- ============================================

-- User profiles
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  avatar_url TEXT,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Test attempts
CREATE TABLE test_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  test_id UUID NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  score INTEGER, -- percentage
  answers JSONB DEFAULT '{}', -- user's answers
  time_spent INTEGER, -- in seconds
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User progress tracking
CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  topic_id UUID NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('not_started', 'in_progress', 'completed')),
  completion_percentage INTEGER DEFAULT 0,
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, topic_id)
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_categories_education_level ON categories(education_level_id);
CREATE INDEX idx_categories_parent ON categories(parent_category_id);
CREATE INDEX idx_topics_category ON topics(category_id);
CREATE INDEX idx_materials_topic ON materials(topic_id);
CREATE INDEX idx_tests_topic ON tests(topic_id);
CREATE INDEX idx_tests_category ON tests(category_id);
CREATE INDEX idx_test_questions_test ON test_questions(test_id);
CREATE INDEX idx_test_questions_question ON test_questions(question_id);
CREATE INDEX idx_answers_question ON answers(question_id);
CREATE INDEX idx_test_attempts_user ON test_attempts(user_id);
CREATE INDEX idx_test_attempts_test ON test_attempts(test_id);
CREATE INDEX idx_user_progress_user ON user_progress(user_id);
CREATE INDEX idx_user_progress_topic ON user_progress(topic_id);

-- Published content indexes
CREATE INDEX idx_education_levels_published ON education_levels(is_published);
CREATE INDEX idx_categories_published ON categories(is_published);
CREATE INDEX idx_topics_published ON topics(is_published);
CREATE INDEX idx_tests_published ON tests(is_published);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE education_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- POLICIES: Education Levels
-- ============================================

-- Public can read published
CREATE POLICY "Public can view published education levels"
  ON education_levels FOR SELECT
  USING (is_published = true);

-- Admins have full access
CREATE POLICY "Admins have full access to education levels"
  ON education_levels FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: Categories
-- ============================================

CREATE POLICY "Public can view published categories"
  ON categories FOR SELECT
  USING (is_published = true);

CREATE POLICY "Admins have full access to categories"
  ON categories FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: Topics
-- ============================================

CREATE POLICY "Public can view published topics"
  ON topics FOR SELECT
  USING (is_published = true);

CREATE POLICY "Admins have full access to topics"
  ON topics FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: Materials
-- ============================================

CREATE POLICY "Public can view published materials"
  ON materials FOR SELECT
  USING (
    is_published = true AND
    EXISTS (
      SELECT 1 FROM topics
      WHERE topics.id = materials.topic_id AND topics.is_published = true
    )
  );

CREATE POLICY "Admins have full access to materials"
  ON materials FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: Tests
-- ============================================

CREATE POLICY "Public can view published tests"
  ON tests FOR SELECT
  USING (is_published = true);

CREATE POLICY "Admins have full access to tests"
  ON tests FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: Questions
-- ============================================

CREATE POLICY "Authenticated users can view questions"
  ON questions FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins have full access to questions"
  ON questions FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: Test Questions
-- ============================================

CREATE POLICY "Authenticated users can view test questions"
  ON test_questions FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins have full access to test questions"
  ON test_questions FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: Answers
-- ============================================

CREATE POLICY "Authenticated users can view answers"
  ON answers FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins have full access to answers"
  ON answers FOR ALL
  USING (is_admin());

-- ============================================
-- POLICIES: User Profiles
-- ============================================

CREATE POLICY "Users can view their own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON user_profiles FOR SELECT
  USING (is_admin());

-- ============================================
-- POLICIES: Test Attempts
-- ============================================

CREATE POLICY "Users can view their own test attempts"
  ON test_attempts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own test attempts"
  ON test_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own test attempts"
  ON test_attempts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all test attempts"
  ON test_attempts FOR SELECT
  USING (is_admin());

-- ============================================
-- POLICIES: User Progress
-- ============================================

CREATE POLICY "Users can view their own progress"
  ON user_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own progress"
  ON user_progress FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all progress"
  ON user_progress FOR SELECT
  USING (is_admin());

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_education_levels_updated_at BEFORE UPDATE ON education_levels
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_topics_updated_at BEFORE UPDATE ON topics
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_materials_updated_at BEFORE UPDATE ON materials
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tests_updated_at BEFORE UPDATE ON tests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SEED DATA (Sample content for testing)
-- ============================================

-- Insert sample education level
INSERT INTO education_levels (name, slug, description, display_order, is_published)
VALUES ('Liceum', 'liceum', 'Zakres liceum ogólnokształcącego', 1, true);

-- You can add more seed data as needed

