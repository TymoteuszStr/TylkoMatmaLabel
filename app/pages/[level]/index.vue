<template>
  <div class="bg-white dark:bg-gray-950">
    <!-- Breadcrumb -->
    <div
      class="border-b border-gray-200 bg-gray-50 dark:border-gray-800 dark:bg-gray-900"
    >
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center gap-2 text-sm">
          <NuxtLink
            to="/"
            class="text-gray-600 hover:text-primary-600 dark:text-gray-400"
          >
            Strona główna
          </NuxtLink>
          <UIcon name="i-heroicons-chevron-right" class="text-gray-400" />
          <span class="font-medium text-gray-900 dark:text-white">
            {{ educationLevel?.name }}
          </span>
        </nav>
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

      <!-- Error State -->
      <div v-else-if="error" class="text-center">
        <UIcon
          name="i-heroicons-exclamation-triangle"
          class="mx-auto text-6xl text-red-500"
        />
        <h2 class="mt-4 text-2xl font-bold">Nie znaleziono poziomu edukacji</h2>
        <UButton to="/" class="mt-6" color="primary">
          Powrót do strony głównej
        </UButton>
      </div>

      <!-- Content -->
      <div v-else>
        <!-- Header -->
        <div class="mb-12">
          <h1 class="text-4xl font-bold text-gray-900 dark:text-white">
            {{ educationLevel?.name }}
          </h1>
          <p
            v-if="educationLevel?.description"
            class="mt-4 text-lg text-gray-600 dark:text-gray-400"
          >
            {{ educationLevel.description }}
          </p>
        </div>

        <!-- Categories Grid -->
        <div
          v-if="categories.length > 0"
          class="grid gap-6 md:grid-cols-2 lg:grid-cols-3"
        >
          <UCard
            v-for="category in categories"
            :key="category.id"
            :ui="{ body: { padding: 'p-6' } }"
            class="hover:shadow-lg transition-shadow cursor-pointer"
            @click="navigateTo(`/${levelSlug}/${category.slug}`)"
          >
            <div class="flex items-start gap-4">
              <div
                class="flex h-12 w-12 items-center justify-center rounded-lg bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  :name="category.icon || 'i-heroicons-folder'"
                  class="text-2xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <div class="flex-1">
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                  {{ category.name }}
                </h3>
                <p
                  v-if="category.description"
                  class="mt-2 text-sm text-gray-600 dark:text-gray-400"
                >
                  {{ category.description }}
                </p>
              </div>
            </div>
          </UCard>
        </div>

        <!-- Empty State -->
        <div v-else class="text-center py-12">
          <UIcon
            name="i-heroicons-inbox"
            class="mx-auto text-6xl text-gray-400"
          />
          <p class="mt-4 text-gray-600 dark:text-gray-400">
            Brak dostępnych kategorii
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { EducationLevel, Category } from "~/types/database";
import type { PostgrestError } from "@supabase/supabase-js";

const route = useRoute();
const levelSlug = route.params.level as string;

const supabase = useTypedSupabaseClient();

const educationLevel = ref<EducationLevel | null>(null);
const categories = ref<Category[]>([]);
const loading = ref(true);
const error = ref(false);

// Fetch data
onMounted(async () => {
  try {
    // Fetch education level
    const {
      data: level,
      error: levelError,
    }: { data: EducationLevel | null; error: PostgrestError | null } =
      await supabase
        .from("education_levels")
        .select("*")
        .eq("slug", levelSlug)
        .eq("is_published", true)
        .single();

    if (levelError) throw levelError;
    if (!level) throw new Error("Level not found");

    educationLevel.value = level as EducationLevel;

    // Fetch categories
    const { data: cats, error: catsError } = await supabase
      .from("categories")
      .select("*")
      .eq("education_level_id", level.id)
      .eq("is_published", true)
      .order("display_order");

    if (catsError) throw catsError;

    categories.value = cats || [];
  } catch (err) {
    console.error("Error fetching data:", err);
    error.value = true;
  } finally {
    loading.value = false;
  }
});

// SEO
useHead(() => ({
  title: educationLevel.value
    ? `${educationLevel.value.name} - TylkoMatmaLabel`
    : "TylkoMatmaLabel",
  meta: [
    {
      name: "description",
      content:
        educationLevel.value?.description ||
        `Materiały edukacyjne dla ${educationLevel.value?.name}`,
    },
  ],
}));
</script>
