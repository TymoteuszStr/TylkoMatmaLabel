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
          <NuxtLink
            :to="`/${levelSlug}`"
            class="text-gray-600 hover:text-primary-600 dark:text-gray-400"
          >
            {{ topic?.category?.education_level?.name }}
          </NuxtLink>
          <UIcon name="i-heroicons-chevron-right" class="text-gray-400" />
          <NuxtLink
            :to="`/${levelSlug}/${categorySlug}`"
            class="text-gray-600 hover:text-primary-600 dark:text-gray-400"
          >
            {{ topic?.category?.name }}
          </NuxtLink>
          <UIcon name="i-heroicons-chevron-right" class="text-gray-400" />
          <span class="font-medium text-gray-900 dark:text-white">
            {{ topic?.name }}
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
        <h2 class="mt-4 text-2xl font-bold">Nie znaleziono tematu</h2>
        <UButton
          :to="`/${levelSlug}/${categorySlug}`"
          class="mt-6"
          color="primary"
        >
          Powrót do kategorii
        </UButton>
      </div>

      <!-- Content -->
      <div v-else class="grid gap-8 lg:grid-cols-4">
        <!-- Sidebar -->
        <aside class="lg:col-span-1">
          <UCard>
            <div class="space-y-4">
              <div>
                <h3
                  class="text-sm font-medium text-gray-500 dark:text-gray-400"
                >
                  Poziom trudności
                </h3>
                <UBadge
                  v-if="topic?.difficulty_level"
                  :color="getDifficultyColor(topic.difficulty_level)"
                  variant="subtle"
                  class="mt-1"
                >
                  {{ getDifficultyLabel(topic.difficulty_level) }}
                </UBadge>
              </div>
              <div v-if="topic?.estimated_time">
                <h3
                  class="text-sm font-medium text-gray-500 dark:text-gray-400"
                >
                  Szacowany czas
                </h3>
                <p class="mt-1 text-sm text-gray-900 dark:text-white">
                  {{ topic.estimated_time }} minut
                </p>
              </div>
              <div
                v-if="
                  topic?.learning_objectives &&
                  topic.learning_objectives.length > 0
                "
              >
                <h3
                  class="text-sm font-medium text-gray-500 dark:text-gray-400"
                >
                  Cele nauki
                </h3>
                <ul
                  class="mt-2 space-y-1 text-sm text-gray-900 dark:text-white"
                >
                  <li
                    v-for="(objective, idx) in topic.learning_objectives"
                    :key="idx"
                    class="flex gap-2"
                  >
                    <UIcon
                      name="i-heroicons-check-circle"
                      class="text-green-600 mt-0.5"
                    />
                    <span>{{ objective }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </UCard>
        </aside>

        <!-- Main Content -->
        <div class="lg:col-span-3 space-y-8">
          <!-- Header -->
          <div>
            <h1 class="text-4xl font-bold text-gray-900 dark:text-white">
              {{ topic?.name }}
            </h1>
            <p
              v-if="topic?.description"
              class="mt-4 text-lg text-gray-600 dark:text-gray-400"
            >
              {{ topic.description }}
            </p>
          </div>

          <!-- Materials -->
          <div v-if="materials.length > 0">
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Materiały
            </h2>
            <div class="space-y-6">
              <UCard
                v-for="material in materials"
                :key="material.id"
                :ui="{ body: { padding: 'p-6' } }"
              >
                <div class="flex items-start gap-3 mb-4">
                  <UIcon
                    :name="getMaterialIcon(material.type)"
                    class="text-2xl text-primary-600 dark:text-primary-400 mt-1"
                  />
                  <div>
                    <h3
                      class="text-xl font-semibold text-gray-900 dark:text-white"
                    >
                      {{ material.title }}
                    </h3>
                    <UBadge
                      :color="getMaterialColor(material.type)"
                      variant="subtle"
                      class="mt-1"
                    >
                      {{ getMaterialLabel(material.type) }}
                    </UBadge>
                  </div>
                </div>

                <!-- Render Material Content -->
                <div
                  v-if="material.content && material.content.length > 0"
                  class="prose prose-gray dark:prose-invert max-w-none"
                >
                  <ContentRenderer
                    v-for="block in material.content"
                    :key="block.id"
                    :block="block"
                  />
                </div>
              </UCard>
            </div>
          </div>

          <!-- Tests -->
          <div v-if="tests.length > 0">
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
              Testy sprawdzające
            </h2>
            <div class="space-y-4">
              <UCard
                v-for="test in tests"
                :key="test.id"
                :ui="{ body: { padding: 'p-6' } }"
                class="hover:shadow-lg transition-shadow cursor-pointer"
                @click="
                  navigateTo(
                    `/${levelSlug}/${categorySlug}/${topicSlug}/test/${test.id}`,
                  )
                "
              >
                <div class="flex items-start justify-between gap-4">
                  <div class="flex-1">
                    <h3
                      class="text-xl font-semibold text-gray-900 dark:text-white"
                    >
                      {{ test.title }}
                    </h3>
                    <p
                      v-if="test.description"
                      class="mt-2 text-gray-600 dark:text-gray-400"
                    >
                      {{ test.description }}
                    </p>
                    <div class="mt-4 flex flex-wrap gap-2">
                      <UBadge color="primary" variant="subtle">
                        <UIcon
                          name="i-heroicons-clipboard-document-check"
                          class="mr-1"
                        />
                        Test
                      </UBadge>
                      <UBadge
                        v-if="test.time_limit"
                        color="gray"
                        variant="subtle"
                      >
                        <UIcon name="i-heroicons-clock" class="mr-1" />
                        {{ test.time_limit }} min
                      </UBadge>
                      <UBadge color="gray" variant="subtle">
                        Próg zaliczenia: {{ test.passing_score }}%
                      </UBadge>
                    </div>
                  </div>
                  <UButton color="primary" icon="i-heroicons-arrow-right" />
                </div>
              </UCard>
            </div>
          </div>

          <!-- Empty State -->
          <div
            v-if="materials.length === 0 && tests.length === 0"
            class="text-center py-12"
          >
            <UIcon
              name="i-heroicons-inbox"
              class="mx-auto text-6xl text-gray-400"
            />
            <p class="mt-4 text-gray-600 dark:text-gray-400">
              Brak dostępnych materiałów i testów
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type {
  TopicWithRelations,
  Material,
  Test,
  Category,
} from "~/types/database";
import type { PostgrestError } from "@supabase/supabase-js";
import { getDifficultyColor, getDifficultyLabel } from "~/utils/difficulty";
import {
  getMaterialColor,
  getMaterialIcon,
  getMaterialLabel,
} from "~/utils/material";

const route = useRoute();

const levelSlug = route.params.level as string;
const categorySlug = route.params.category as string;
const topicSlug = route.params.topic as string;
const supabase = useTypedSupabaseClient();

const topic = ref<TopicWithRelations | null>(null);
const materials = ref<Material[]>([]);
const tests = ref<Test[]>([]);
const loading = ref(true);
const error = ref(false);

// Fetch data
onMounted(async () => {
  try {
    // Fetch education level
    const {
      data: level,
    }: { data: { id: string } | null; error: PostgrestError | null } =
      await supabase
        .from("education_levels")
        .select("id")
        .eq("slug", levelSlug)
        .eq("is_published", true)
        .single();

    if (!level) throw new Error("Level not found");

    // Fetch category
    const {
      data: category,
    }: { data: Category | null; error: PostgrestError | null } = await supabase
      .from("categories")
      .select("id, name, education_level:education_levels(name)")
      .eq("education_level_id", level.id)
      .eq("slug", categorySlug)
      .eq("is_published", true)
      .single();

    if (!category) throw new Error("Category not found");
    // Fetch topic with relations
    const {
      data: top,
      error: topError,
    }: { data: TopicWithRelations | null; error: PostgrestError | null } =
      await supabase
        .from("topics")
        .select(
          `
        *,
        category:categories(
          *,
          education_level:education_levels(*)
        )
      `,
        )
        .eq("category_id", category.id)
        .eq("slug", topicSlug)
        .eq("is_published", true)
        .single();

    if (topError) throw topError;
    if (!top) throw new Error("Topic not found");
    topic.value = top;

    // Fetch materials
    const { data: mats } = await supabase
      .from("materials")
      .select("*")
      .eq("topic_id", top.id)
      .eq("is_published", true)
      .order("display_order");

    materials.value = mats || [];

    // Fetch tests
    const { data: testData } = await supabase
      .from("tests")
      .select("*")
      .eq("topic_id", top.id)
      .eq("is_published", true)
      .order("created_at", { ascending: false });

    tests.value = testData || [];
  } catch (err) {
    console.error("Error fetching data:", err);
    error.value = true;
  } finally {
    loading.value = false;
  }
});

// SEO
useHead(() => ({
  title: topic.value?.seo_title || `${topic.value?.name} - TylkoMatmaOnline`,
  meta: [
    {
      name: "description",
      content: topic.value?.seo_description || topic.value?.description || "",
    },
    {
      name: "keywords",
      content: topic.value?.seo_keywords || "",
    },
  ],
}));
</script>
