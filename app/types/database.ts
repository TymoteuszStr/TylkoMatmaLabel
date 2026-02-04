// Database types generated from Supabase schema
// These types represent the database structure

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type DifficultyLevel = 'basic' | 'intermediate' | 'advanced'
export type MaterialType = 'theory' | 'example' | 'exercise' | 'summary'
export type UserRole = 'student' | 'admin'
export type ProgressStatus = 'not_started' | 'in_progress' | 'completed'

export interface Database {
  public: {
    Tables: {
      education_levels: {
        Row: EducationLevel
        Insert: EducationLevelInsert
        Update: EducationLevelUpdate
      }
      categories: {
        Row: Category
        Insert: CategoryInsert
        Update: CategoryUpdate
      }
      topics: {
        Row: Topic
        Insert: TopicInsert
        Update: TopicUpdate
      }
      materials: {
        Row: Material
        Insert: MaterialInsert
        Update: MaterialUpdate
      }
      tests: {
        Row: Test
        Insert: TestInsert
        Update: TestUpdate
      }
      questions: {
        Row: Question
        Insert: QuestionInsert
        Update: QuestionUpdate
      }
      test_questions: {
        Row: TestQuestion
        Insert: TestQuestionInsert
        Update: TestQuestionUpdate
      }
      answers: {
        Row: Answer
        Insert: AnswerInsert
        Update: AnswerUpdate
      }
      user_profiles: {
        Row: UserProfile
        Insert: UserProfileInsert
        Update: UserProfileUpdate
      }
      test_attempts: {
        Row: TestAttempt
        Insert: TestAttemptInsert
        Update: TestAttemptUpdate
      }
      user_progress: {
        Row: UserProgress
        Insert: UserProgressInsert
        Update: UserProgressUpdate
      }
    }
  }
}

// ============================================
// EDUCATION HIERARCHY TYPES
// ============================================

export interface EducationLevel {
  id: string
  name: string
  slug: string
  description: string | null
  display_order: number
  is_published: boolean
  created_at: string
  updated_at: string
}

export interface EducationLevelInsert {
  id?: string
  name: string
  slug: string
  description?: string | null
  display_order?: number
  is_published?: boolean
  created_at?: string
  updated_at?: string
}

export interface EducationLevelUpdate {
  name?: string
  slug?: string
  description?: string | null
  display_order?: number
  is_published?: boolean
  updated_at?: string
}

export interface Category {
  id: string
  education_level_id: string
  parent_category_id: string | null
  name: string
  slug: string
  description: string | null
  icon: string | null
  display_order: number
  is_published: boolean
  created_at: string
  updated_at: string
}

export interface CategoryInsert {
  id?: string
  education_level_id: string
  parent_category_id?: string | null
  name: string
  slug: string
  description?: string | null
  icon?: string | null
  display_order?: number
  is_published?: boolean
  created_at?: string
  updated_at?: string
}

export interface CategoryUpdate {
  education_level_id?: string
  parent_category_id?: string | null
  name?: string
  slug?: string
  description?: string | null
  icon?: string | null
  display_order?: number
  is_published?: boolean
  updated_at?: string
}

export interface Topic {
  id: string
  category_id: string
  name: string
  slug: string
  description: string | null
  learning_objectives: string[] | null
  estimated_time: number | null
  difficulty_level: DifficultyLevel | null
  display_order: number
  is_published: boolean
  seo_title: string | null
  seo_description: string | null
  seo_keywords: string | null
  published_at: string | null
  created_at: string
  updated_at: string
}

export interface TopicInsert {
  id?: string
  category_id: string
  name: string
  slug: string
  description?: string | null
  learning_objectives?: string[] | null
  estimated_time?: number | null
  difficulty_level?: DifficultyLevel | null
  display_order?: number
  is_published?: boolean
  seo_title?: string | null
  seo_description?: string | null
  seo_keywords?: string | null
  published_at?: string | null
  created_at?: string
  updated_at?: string
}

export interface TopicUpdate {
  category_id?: string
  name?: string
  slug?: string
  description?: string | null
  learning_objectives?: string[] | null
  estimated_time?: number | null
  difficulty_level?: DifficultyLevel | null
  display_order?: number
  is_published?: boolean
  seo_title?: string | null
  seo_description?: string | null
  seo_keywords?: string | null
  published_at?: string | null
  updated_at?: string
}

export interface ContentBlock {
  id: string
  type: 'text' | 'heading' | 'image' | 'formula' | 'code' | 'callout' | 'table' | 'divider'
  content: Json
  order: number
  settings?: Json
}

export interface Material {
  id: string
  topic_id: string
  type: MaterialType
  title: string
  display_order: number
  content: ContentBlock[]
  is_published: boolean
  created_at: string
  updated_at: string
}

export interface MaterialInsert {
  id?: string
  topic_id: string
  type: MaterialType
  title: string
  display_order?: number
  content?: ContentBlock[]
  is_published?: boolean
  created_at?: string
  updated_at?: string
}

export interface MaterialUpdate {
  topic_id?: string
  type?: MaterialType
  title?: string
  display_order?: number
  content?: ContentBlock[]
  is_published?: boolean
  updated_at?: string
}

// ============================================
// TEST SYSTEM TYPES
// ============================================

export interface Test {
  id: string
  topic_id: string | null
  category_id: string | null
  title: string
  description: string | null
  time_limit: number | null
  passing_score: number
  is_published: boolean
  show_correct_answers: boolean
  randomize_questions: boolean
  randomize_answers: boolean
  created_at: string
  updated_at: string
}

export interface TestInsert {
  id?: string
  topic_id?: string | null
  category_id?: string | null
  title: string
  description?: string | null
  time_limit?: number | null
  passing_score?: number
  is_published?: boolean
  show_correct_answers?: boolean
  randomize_questions?: boolean
  randomize_answers?: boolean
  created_at?: string
  updated_at?: string
}

export interface TestUpdate {
  topic_id?: string | null
  category_id?: string | null
  title?: string
  description?: string | null
  time_limit?: number | null
  passing_score?: number
  is_published?: boolean
  show_correct_answers?: boolean
  randomize_questions?: boolean
  randomize_answers?: boolean
  updated_at?: string
}

export interface Question {
  id: string
  content: string
  explanation: string | null
  difficulty_level: DifficultyLevel | null
  tags: string[]
  created_at: string
  updated_at: string
}

export interface QuestionInsert {
  id?: string
  content: string
  explanation?: string | null
  difficulty_level?: DifficultyLevel | null
  tags?: string[]
  created_at?: string
  updated_at?: string
}

export interface QuestionUpdate {
  content?: string
  explanation?: string | null
  difficulty_level?: DifficultyLevel | null
  tags?: string[]
  updated_at?: string
}

export interface TestQuestion {
  id: string
  test_id: string
  question_id: string
  display_order: number
  points: number
  created_at: string
}

export interface TestQuestionInsert {
  id?: string
  test_id: string
  question_id: string
  display_order?: number
  points?: number
  created_at?: string
}

export interface TestQuestionUpdate {
  test_id?: string
  question_id?: string
  display_order?: number
  points?: number
}

export interface Answer {
  id: string
  question_id: string
  content: string
  label: 'A' | 'B' | 'C' | 'D'
  is_correct: boolean
  display_order: number
  created_at: string
}

export interface AnswerInsert {
  id?: string
  question_id: string
  content: string
  label: 'A' | 'B' | 'C' | 'D'
  is_correct?: boolean
  display_order?: number
  created_at?: string
}

export interface AnswerUpdate {
  question_id?: string
  content?: string
  label?: 'A' | 'B' | 'C' | 'D'
  is_correct?: boolean
  display_order?: number
}

// ============================================
// USER & PROGRESS TYPES
// ============================================

export interface UserProfile {
  id: string
  display_name: string | null
  role: UserRole
  avatar_url: string | null
  preferences: Json
  created_at: string
  updated_at: string
}

export interface UserProfileInsert {
  id: string
  display_name?: string | null
  role?: UserRole
  avatar_url?: string | null
  preferences?: Json
  created_at?: string
  updated_at?: string
}

export interface UserProfileUpdate {
  display_name?: string | null
  role?: UserRole
  avatar_url?: string | null
  preferences?: Json
  updated_at?: string
}

export interface TestAttempt {
  id: string
  user_id: string
  test_id: string
  started_at: string
  completed_at: string | null
  score: number | null
  answers: Json
  time_spent: number | null
  created_at: string
}

export interface TestAttemptInsert {
  id?: string
  user_id: string
  test_id: string
  started_at?: string
  completed_at?: string | null
  score?: number | null
  answers?: Json
  time_spent?: number | null
  created_at?: string
}

export interface TestAttemptUpdate {
  completed_at?: string | null
  score?: number | null
  answers?: Json
  time_spent?: number | null
}

export interface UserProgress {
  id: string
  user_id: string
  topic_id: string
  status: ProgressStatus
  completion_percentage: number
  last_accessed_at: string
  created_at: string
  updated_at: string
}

export interface UserProgressInsert {
  id?: string
  user_id: string
  topic_id: string
  status: ProgressStatus
  completion_percentage?: number
  last_accessed_at?: string
  created_at?: string
  updated_at?: string
}

export interface UserProgressUpdate {
  status?: ProgressStatus
  completion_percentage?: number
  last_accessed_at?: string
  updated_at?: string
}

// ============================================
// EXTENDED TYPES (with relations)
// ============================================

export interface CategoryWithLevel extends Category {
  education_level?: EducationLevel
  subcategories?: Category[]
}

export interface TopicWithRelations extends Topic {
  category?: CategoryWithLevel
  materials?: Material[]
  tests?: Test[]
}

export interface TestWithQuestions extends Test {
  test_questions?: Array<TestQuestion & {
    question: Question & {
      answers: Answer[]
    }
  }>
}

export interface QuestionWithAnswers extends Question {
  answers: Answer[]
}

// ============================================
// UTILITY TYPES
// ============================================

// Type for error handling in stores and components
export interface AppError {
  message: string
  code?: string
  details?: unknown
}

// Type for topic with category relation (used in admin pages)
export interface TopicWithCategory extends Topic {
  categories?: {
    name: string
  }
}

// Type for material with topic relation (used in admin pages)
export interface MaterialWithTopic extends Material {
  topics?: {
    name: string
    slug: string
    categories?: {
      name: string
    }
  }
}

