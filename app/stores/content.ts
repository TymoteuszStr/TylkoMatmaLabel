import { defineStore } from 'pinia'
import type {
  EducationLevel,
  Category,
  Topic,
  Material,
  CategoryWithLevel,
  TopicWithRelations,
} from '~/types/database'

export const useContentStore = defineStore('content', () => {
  const supabase = useSupabaseClient()

  // State
  const educationLevels = ref<EducationLevel[]>([])
  const categories = ref<Category[]>([])
  const topics = ref<Topic[]>([])
  const currentTopic = ref<TopicWithRelations | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Actions
  async function fetchEducationLevels(includeUnpublished = false) {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('education_levels')
        .select('*')
        .order('display_order')

      if (!includeUnpublished) {
        query = query.eq('is_published', true)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      educationLevels.value = data || []
    } catch (err: any) {
      error.value = err.message
      console.error('Failed to fetch education levels:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchCategories(levelId?: string, includeUnpublished = false) {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('categories')
        .select('*, education_level:education_levels(*)')
        .order('display_order')

      if (levelId) {
        query = query.eq('education_level_id', levelId)
      }

      if (!includeUnpublished) {
        query = query.eq('is_published', true)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      categories.value = data || []
    } catch (err: any) {
      error.value = err.message
      console.error('Failed to fetch categories:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchTopics(categoryId?: string, includeUnpublished = false) {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('topics')
        .select(`
          *,
          category:categories(
            *,
            education_level:education_levels(*)
          )
        `)
        .order('display_order')

      if (categoryId) {
        query = query.eq('category_id', categoryId)
      }

      if (!includeUnpublished) {
        query = query.eq('is_published', true)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      topics.value = data || []
    } catch (err: any) {
      error.value = err.message
      console.error('Failed to fetch topics:', err)
    } finally {
      loading.value = false
    }
  }

  function clearCurrentTopic() {
    currentTopic.value = null
  }

  return {
    // State
    educationLevels,
    categories,
    topics,
    currentTopic,
    loading,
    error,

    // Actions
    fetchEducationLevels,
    fetchCategories,
    fetchTopics,
    clearCurrentTopic,
  }
})

