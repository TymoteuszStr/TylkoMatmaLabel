<template>
  <div class="bg-white dark:bg-gray-950">
    <!-- Header -->
    <div
      class="border-b border-gray-200 bg-gradient-to-b from-primary-50 to-white dark:border-gray-800 dark:from-gray-900 dark:to-gray-950"
    >
      <div class="container mx-auto px-4 py-12">
        <div class="mx-auto max-w-3xl text-center">
          <div class="mb-4 flex justify-center">
            <div
              class="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary-100 dark:bg-primary-900"
            >
              <UIcon
                name="i-heroicons-book-open"
                class="text-4xl text-primary-600 dark:text-primary-400"
              />
            </div>
          </div>
          <h1
            class="text-4xl font-bold tracking-tight text-gray-900 dark:text-white md:text-5xl"
          >
            Materiały edukacyjne
          </h1>
          <p class="mt-4 text-lg text-gray-600 dark:text-gray-400">
            Wybierz poziom edukacji i zacznij naukę matematyki
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
          class="animate-spin text-4xl text-primary-600"
        />
      </div>

      <!-- Education Levels with Categories -->
      <div v-else-if="levelsWithCategories.length > 0" class="space-y-8">
        <div
          v-for="level in levelsWithCategories"
          :key="level.id"
          class="rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900"
        >
          <!-- Level Header -->
          <div class="mb-6 flex items-start justify-between">
            <div class="flex items-start gap-4">
              <div
                class="flex h-12 w-12 items-center justify-center rounded-lg bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-academic-cap"
                  class="text-2xl text-primary-600 dark:text-primary-400"
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
              </div>
            </div>
            <UButton
              color="primary"
              variant="outline"
              @click="navigateTo(`/${level.slug}`)"
            >
              Zobacz wszystko
              <template #trailing>
                <UIcon name="i-heroicons-arrow-right" />
              </template>
            </UButton>
          </div>

          <!-- Categories Preview -->
          <div
            v-if="level.categories && level.categories.length > 0"
            class="grid gap-4 md:grid-cols-2 lg:grid-cols-3"
          >
            <UCard
              v-for="category in level.categories.slice(0, 6)"
              :key="category.id"
              :ui="{ body: { padding: 'p-4' } }"
              class="cursor-pointer transition-shadow hover:shadow-lg"
              @click="navigateTo(`/${level.slug}/${category.slug}`)"
            >
              <div class="flex items-start gap-3">
                <div
                  class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-50 dark:bg-primary-900/50"
                >
                  <UIcon
                    :name="category.icon || 'i-heroicons-folder'"
                    class="text-xl text-primary-600 dark:text-primary-400"
                  />
                </div>
                <div class="flex-1 min-w-0">
                  <h3
                    class="truncate font-semibold text-gray-900 dark:text-white"
                  >
                    {{ category.name }}
                  </h3>
                  <p
                    v-if="category.description"
                    class="mt-1 line-clamp-2 text-sm text-gray-600 dark:text-gray-400"
                  >
                    {{ category.description }}
                  </p>
                </div>
              </div>
            </UCard>

            <!-- Show more indicator -->
            <UCard
              v-if="level.categories.length > 6"
              :ui="{ body: { padding: 'p-4' } }"
              class="cursor-pointer border-2 border-dashed border-gray-300 bg-gray-50 transition-colors hover:border-primary-500 hover:bg-primary-50 dark:border-gray-700 dark:bg-gray-800 dark:hover:border-primary-500 dark:hover:bg-primary-900/20"
              @click="navigateTo(`/${level.slug}`)"
            >
              <div class="flex h-full items-center justify-center">
                <div class="text-center">
                  <UIcon
                    name="i-heroicons-plus-circle"
                    class="mx-auto text-3xl text-gray-400 dark:text-gray-600"
                  />
                  <p class="mt-2 text-sm font-medium text-gray-600 dark:text-gray-400">
                    +{{ level.categories.length - 6 }} więcej
                  </p>
                </div>
              </div>
            </UCard>
          </div>

          <!-- Empty State -->
          <div v-else class="py-8 text-center">
            <UIcon
              name="i-heroicons-inbox"
              class="mx-auto text-4xl text-gray-400"
            />
            <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
              Brak dostępnych kategorii
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
import type { EducationLevel, Category } from "~/types/database";

interface LevelWithCategories extends EducationLevel {
  categories?: Category[];
}

const supabase = useTypedSupabaseClient();
const loading = ref(true);
const levelsWithCategories = ref<LevelWithCategories[]>([]);

// Fetch education levels with their categories
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
      // Fetch categories for each level
      const levelsWithCats = await Promise.all(
        levels.map(async (level) => {
          const { data: categories } = await supabase
            .from("categories")
            .select("*")
            .eq("education_level_id", level.id)
            .eq("is_published", true)
            .order("display_order");

          return {
            ...level,
            categories: categories || [],
          };
        })
      );

      levelsWithCategories.value = levelsWithCats;
    }
  } catch (error) {
    console.error("Error fetching data:", error);
  } finally {
    loading.value = false;
  }
});

// SEO
useHead({
  title: "Materiały edukacyjne - TylkoMatmaOnline",
  meta: [
    {
      name: "description",
      content:
        "Przeglądaj materiały edukacyjne z matematyki. Tematy, wyjaśnienia i przykłady dla każdego poziomu edukacji.",
    },
    {
      name: "keywords",
      content:
        "matematyka, materiały, nauka, liceum, tematy, wyjaśnienia, przykłady",
    },
  ],
});
</script>
