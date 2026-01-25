<template>
  <div class="bg-white dark:bg-gray-950">
    <!-- Breadcrumb -->
    <div class="border-b border-gray-200 bg-gray-50 dark:border-gray-800 dark:bg-gray-900">
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center gap-2 text-sm">
          <NuxtLink to="/" class="text-gray-600 hover:text-primary-600 dark:text-gray-400">
            Strona główna
          </NuxtLink>
          <UIcon name="i-heroicons-chevron-right" class="text-gray-400" />
          <NuxtLink 
            :to="`/${levelSlug}`" 
            class="text-gray-600 hover:text-primary-600 dark:text-gray-400"
          >
            {{ category?.education_level?.name }}
          </NuxtLink>
          <UIcon name="i-heroicons-chevron-right" class="text-gray-400" />
          <span class="font-medium text-gray-900 dark:text-white">
            {{ category?.name }}
          </span>
        </nav>
      </div>
    </div>

    <!-- Main Content -->
    <div class="container mx-auto px-4 py-12">
      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center py-12">
        <UIcon name="i-heroicons-arrow-path" class="animate-spin text-4xl text-primary-600" />
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="text-center">
        <UIcon name="i-heroicons-exclamation-triangle" class="mx-auto text-6xl text-red-500" />
        <h2 class="mt-4 text-2xl font-bold">Nie znaleziono kategorii</h2>
        <UButton :to="`/${levelSlug}`" class="mt-6" color="primary">
          Powrót do {{ levelSlug }}
        </UButton>
      </div>

      <!-- Content -->
      <div v-else>
        <!-- Header -->
        <div class="mb-12">
          <div class="flex items-center gap-4 mb-4">
            <div class="flex h-16 w-16 items-center justify-center rounded-xl bg-primary-100 dark:bg-primary-900">
              <UIcon 
                :name="category?.icon || 'i-heroicons-folder'" 
                class="text-3xl text-primary-600 dark:text-primary-400" 
              />
            </div>
            <div>
              <h1 class="text-4xl font-bold text-gray-900 dark:text-white">
                {{ category?.name }}
              </h1>
              <p class="text-gray-600 dark:text-gray-400">
                {{ category?.education_level?.name }}
              </p>
            </div>
          </div>
          <p v-if="category?.description" class="mt-4 text-lg text-gray-600 dark:text-gray-400">
            {{ category.description }}
          </p>
        </div>

        <!-- Topics List -->
        <div v-if="topics.length > 0" class="space-y-4">
          <UCard
            v-for="topic in topics"
            :key="topic.id"
            :ui="{ body: { padding: 'p-6' } }"
            class="hover:shadow-lg transition-shadow cursor-pointer"
            @click="navigateTo(`/${levelSlug}/${categorySlug}/${topic.slug}`)"
          >
            <div class="flex items-start justify-between gap-4">
              <div class="flex-1">
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                  {{ topic.name }}
                </h3>
                <p v-if="topic.description" class="mt-2 text-gray-600 dark:text-gray-400">
                  {{ topic.description }}
                </p>
                <div class="mt-4 flex flex-wrap gap-2">
                  <UBadge
                    v-if="topic.difficulty_level"
                    :color="getDifficultyColor(topic.difficulty_level)"
                    variant="subtle"
                  >
                    {{ getDifficultyLabel(topic.difficulty_level) }}
                  </UBadge>
                  <UBadge v-if="topic.estimated_time" color="gray" variant="subtle">
                    <UIcon name="i-heroicons-clock" class="mr-1" />
                    {{ topic.estimated_time }} min
                  </UBadge>
                </div>
              </div>
              <UIcon name="i-heroicons-chevron-right" class="text-2xl text-gray-400" />
            </div>
          </UCard>
        </div>

        <!-- Empty State -->
        <div v-else class="text-center py-12">
          <UIcon name="i-heroicons-inbox" class="mx-auto text-6xl text-gray-400" />
          <p class="mt-4 text-gray-600 dark:text-gray-400">
            Brak dostępnych tematów
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const levelSlug = route.params.level as string
const categorySlug = route.params.category as string
const supabase = useSupabaseClient()

const category = ref<any>(null)
const topics = ref<any[]>([])
const loading = ref(true)
const error = ref(false)

// Fetch data
onMounted(async () => {
  try {
    // Fetch education level
    const { data: level } = await supabase
      .from('education_levels')
      .select('id, name')
      .eq('slug', levelSlug)
      .eq('is_published', true)
      .single()

    if (!level) throw new Error('Level not found')

    // Fetch category with education level
    const { data: cat, error: catError } = await supabase
      .from('categories')
      .select('*, education_level:education_levels(*)')
      .eq('education_level_id', level.id)
      .eq('slug', categorySlug)
      .eq('is_published', true)
      .single()

    if (catError) throw catError

    category.value = cat

    // Fetch topics
    const { data: tops, error: topsError } = await supabase
      .from('topics')
      .select('*')
      .eq('category_id', cat.id)
      .eq('is_published', true)
      .order('display_order')

    if (topsError) throw topsError

    topics.value = tops || []
  } catch (err) {
    console.error('Error fetching data:', err)
    error.value = true
  } finally {
    loading.value = false
  }
})

function getDifficultyColor(level: string) {
  const colors: Record<string, string> = {
    basic: 'green',
    intermediate: 'yellow',
    advanced: 'red',
  }
  return colors[level] || 'gray'
}

function getDifficultyLabel(level: string) {
  const labels: Record<string, string> = {
    basic: 'Podstawowy',
    intermediate: 'Średniozaawansowany',
    advanced: 'Zaawansowany',
  }
  return labels[level] || level
}

// SEO
useHead(() => ({
  title: category.value ? `${category.value.name} - TylkoMatma` : 'TylkoMatma',
  meta: [
    {
      name: 'description',
      content: category.value?.description || `Tematy z kategorii ${category.value?.name}`,
    },
  ],
}))
</script>

