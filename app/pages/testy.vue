<template>
  <div class="bg-white dark:bg-gray-950">
    <!-- Header -->
    <div
      class="border-b border-gray-200 bg-gradient-to-b from-purple-50 to-white dark:border-gray-800 dark:from-gray-900 dark:to-gray-950"
    >
      <div class="container mx-auto px-4 py-12">
        <div class="mx-auto max-w-3xl text-center">
          <div class="mb-4 flex justify-center">
            <div
              class="flex h-16 w-16 items-center justify-center rounded-2xl bg-purple-100 dark:bg-purple-900"
            >
              <UIcon
                name="i-heroicons-clipboard-document-check"
                class="text-4xl text-purple-600 dark:text-purple-400"
              />
            </div>
          </div>
          <h1
            class="text-4xl font-bold tracking-tight text-gray-900 dark:text-white md:text-5xl"
          >
            Testy i sprawdziany
          </h1>
          <p class="mt-4 text-lg text-gray-600 dark:text-gray-400">
            Sprawdź swoją wiedzę z matematyki w praktyce
          </p>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="container mx-auto px-4 py-12">
      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center py-12">
        <UIcon
          name="i-heroicons-arrow-path"
          class="animate-spin text-4xl text-purple-600"
        />
      </div>

      <!-- Education Levels with Tests -->
      <div v-else-if="levelsWithTests.length > 0" class="space-y-8">
        <div
          v-for="level in levelsWithTests"
          :key="level.id"
          class="rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900"
        >
          <!-- Level Header -->
          <div class="mb-6 flex items-start justify-between">
            <div class="flex items-start gap-4">
              <div
                class="flex h-12 w-12 items-center justify-center rounded-lg bg-purple-100 dark:bg-purple-900"
              >
                <UIcon
                  name="i-heroicons-academic-cap"
                  class="text-2xl text-purple-600 dark:text-purple-400"
                />
              </div>
              <div>
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ level.name }}
                </h2>
                <p
                  v-if="level.description"
                  class="mt-1 text-gray-600 dark:text-gray-400"
                >
                  {{ level.description }}
                </p>
                <div class="mt-2 flex gap-4 text-sm text-gray-600 dark:text-gray-400">
                  <span v-if="level.categoriesCount">
                    <UIcon name="i-heroicons-folder" class="mr-1" />
                    {{ level.categoriesCount }} {{ level.categoriesCount === 1 ? 'kategoria' : level.categoriesCount < 5 ? 'kategorie' : 'kategorii' }}
                  </span>
                  <span v-if="level.testsCount">
                    <UIcon name="i-heroicons-clipboard-document-check" class="mr-1" />
                    {{ level.testsCount }} {{ level.testsCount === 1 ? 'test' : level.testsCount < 5 ? 'testy' : 'testów' }}
                  </span>
                </div>
              </div>
            </div>
            <UButton
              color="purple"
              variant="outline"
              @click="navigateTo(`/${level.slug}`)"
            >
              Przeglądaj
              <template #trailing>
                <UIcon name="i-heroicons-arrow-right" />
              </template>
            </UButton>
          </div>

          <!-- Categories with Tests Preview -->
          <div
            v-if="level.categories && level.categories.length > 0"
            class="space-y-4"
          >
            <div
              v-for="category in level.categories"
              :key="category.id"
              class="rounded-lg border border-gray-200 bg-gray-50 p-4 dark:border-gray-700 dark:bg-gray-800"
            >
              <div class="mb-3 flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <UIcon
                    :name="category.icon || 'i-heroicons-folder'"
                    class="text-lg text-purple-600 dark:text-purple-400"
                  />
                  <h3 class="font-semibold text-gray-900 dark:text-white">
                    {{ category.name }}
                  </h3>
                  <UBadge
                    v-if="category.topics && category.topics.length > 0"
                    color="purple"
                    variant="subtle"
                    size="xs"
                  >
                    {{ category.topics.length }} {{ category.topics.length === 1 ? 'temat' : category.topics.length < 5 ? 'tematy' : 'tematów' }}
                  </UBadge>
                </div>
                <UButton
                  size="xs"
                  color="gray"
                  variant="ghost"
                  @click="navigateTo(`/${level.slug}/${category.slug}`)"
                >
                  Zobacz wszystko
                </UButton>
              </div>

              <!-- Topics with Tests -->
              <div
                v-if="category.topics && category.topics.length > 0"
                class="grid gap-3 md:grid-cols-2"
              >
                <div
                  v-for="topic in category.topics.slice(0, 4)"
                  :key="topic.id"
                  class="cursor-pointer rounded-md border border-gray-200 bg-white p-3 transition-all hover:border-purple-500 hover:shadow-md dark:border-gray-700 dark:bg-gray-900 dark:hover:border-purple-500"
                  @click="navigateTo(`/${level.slug}/${category.slug}/${topic.slug}`)"
                >
                  <div class="flex items-start justify-between gap-2">
                    <div class="flex-1 min-w-0">
                      <h4 class="truncate text-sm font-medium text-gray-900 dark:text-white">
                        {{ topic.name }}
                      </h4>
                      <div class="mt-1 flex flex-wrap gap-2">
                        <UBadge
                          v-if="topic.difficulty_level"
                          :color="getDifficultyColor(topic.difficulty_level as string)"
                          variant="subtle"
                          size="xs"
                        >
                          {{ getDifficultyLabel(topic.difficulty_level) }}
                        </UBadge>
                        <UBadge
                          v-if="topic.testsCount && topic.testsCount > 0"
                          color="purple"
                          variant="subtle"
                          size="xs"
                        >
                          <UIcon name="i-heroicons-clipboard-document-check" class="mr-0.5" />
                          {{ topic.testsCount }}
                        </UBadge>
                      </div>
                    </div>
                    <UIcon
                      name="i-heroicons-chevron-right"
                      class="text-gray-400"
                    />
                  </div>
                </div>

                <!-- Show more indicator -->
                <div
                  v-if="category.topics.length > 4"
                  class="flex cursor-pointer items-center justify-center rounded-md border-2 border-dashed border-gray-300 bg-white p-3 transition-colors hover:border-purple-500 hover:bg-purple-50 dark:border-gray-700 dark:bg-gray-900 dark:hover:border-purple-500 dark:hover:bg-purple-900/20"
                  @click="navigateTo(`/${level.slug}/${category.slug}`)"
                >
                  <div class="text-center">
                    <UIcon
                      name="i-heroicons-plus-circle"
                      class="mx-auto text-2xl text-gray-400"
                    />
                    <p class="mt-1 text-xs font-medium text-gray-600 dark:text-gray-400">
                      +{{ category.topics.length - 4 }} więcej
                    </p>
                  </div>
                </div>
              </div>

              <!-- No Topics -->
              <div v-else class="py-4 text-center">
                <p class="text-sm text-gray-500 dark:text-gray-500">
                  Brak dostępnych tematów
                </p>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div v-else class="py-8 text-center">
            <UIcon
              name="i-heroicons-inbox"
              class="mx-auto text-4xl text-gray-400"
            />
            <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
              Brak dostępnych kategorii i testów
            </p>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="py-12 text-center">
        <UIcon
          name="i-heroicons-inbox"
          class="mx-auto text-6xl text-gray-400"
        />
        <p class="mt-4 text-gray-600 dark:text-gray-400">
          Brak dostępnych poziomów edukacji
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { EducationLevel, Category, Topic } from "~/types/database";
import { getDifficultyColor, getDifficultyLabel } from "~/utils/difficulty";

interface TopicWithTestCount extends Topic {
  testsCount?: number;
}

interface CategoryWithTopics extends Category {
  topics?: TopicWithTestCount[];
}

interface LevelWithTests extends EducationLevel {
  categories?: CategoryWithTopics[];
  categoriesCount?: number;
  testsCount?: number;
}

const supabase = useTypedSupabaseClient();
const loading = ref(true);
const levelsWithTests = ref<LevelWithTests[]>([]);

// Fetch education levels with their categories and topics (that have tests)
onMounted(async () => {
  try {
    // Fetch all published education levels
    const { data: levels, error: levelsError } = await supabase
      .from("education_levels")
      .select("*")
      .eq("is_published", true)
      .order("display_order");

    if (levelsError) throw levelsError;

    if (levels && levels.length > 0) {
      // Fetch categories and topics for each level
      const levelsWithData = await Promise.all(
        levels.map(async (level) => {
          // Fetch categories
          const { data: categories } = await supabase
            .from("categories")
            .select("*")
            .eq("education_level_id", level.id)
            .eq("is_published", true)
            .order("display_order");

          let totalTests = 0;
          const categoriesWithTopics = categories
            ? await Promise.all(
                categories.map(async (category) => {
                  // Fetch topics
                  const { data: topics } = await supabase
                    .from("topics")
                    .select("*")
                    .eq("category_id", category.id)
                    .eq("is_published", true)
                    .order("display_order");

                  // Count tests for each topic
                  const topicsWithTestCount = topics
                    ? await Promise.all(
                        topics.map(async (topic) => {
                          const { count } = await supabase
                            .from("tests")
                            .select("*", { count: "exact", head: true })
                            .eq("topic_id", topic.id)
                            .eq("is_published", true);

                          if (count) totalTests += count;

                          return {
                            ...topic,
                            testsCount: count || 0,
                          };
                        })
                      )
                    : [];

                  return {
                    ...category,
                    topics: topicsWithTestCount.filter(t => t.testsCount && t.testsCount > 0),
                  };
                })
              )
            : [];

          return {
            ...level,
            categories: categoriesWithTopics.filter(c => c.topics && c.topics.length > 0),
            categoriesCount: categoriesWithTopics.filter(c => c.topics && c.topics.length > 0).length,
            testsCount: totalTests,
          };
        })
      );

      levelsWithTests.value = levelsWithData.filter(l => l.testsCount && l.testsCount > 0);
    }
  } catch (error) {
    console.error("Error fetching data:", error);
  } finally {
    loading.value = false;
  }
});

// SEO
useHead({
  title: "Testy i sprawdziany - TylkoMatmaOnline",
  meta: [
    {
      name: "description",
      content:
        "Sprawdź swoją wiedzę z matematyki. Rozwiązuj testy i monitoruj swoje postępy w nauce.",
    },
    {
      name: "keywords",
      content:
        "matematyka, testy, sprawdziany, quiz, pytania, odpowiedzi, nauka",
    },
  ],
});
</script>
