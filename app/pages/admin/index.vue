<template>
  <div>
    <!-- Page Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
        Panel Administratora
      </h1>
      <p class="mt-2 text-gray-600 dark:text-gray-400">
        Zarządzaj platformą edukacyjną TylkoMatmaOnline
      </p>
    </div>

    <!-- Statistics Overview -->
    <div class="mb-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
      <UCard>
        <div class="flex items-center gap-4">
          <div class="rounded-lg bg-blue-100 p-3 dark:bg-blue-900">
            <UIcon
              name="i-heroicons-academic-cap"
              class="text-2xl text-blue-600 dark:text-blue-400"
            />
          </div>
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400">
              Poziomy edukacji
            </p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ stats.levels }}
            </p>
          </div>
        </div>
      </UCard>

      <UCard>
        <div class="flex items-center gap-4">
          <div class="rounded-lg bg-green-100 p-3 dark:bg-green-900">
            <UIcon
              name="i-heroicons-folder"
              class="text-2xl text-green-600 dark:text-green-400"
            />
          </div>
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400">Kategorie</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ stats.categories }}
            </p>
          </div>
        </div>
      </UCard>

      <UCard>
        <div class="flex items-center gap-4">
          <div class="rounded-lg bg-purple-100 p-3 dark:bg-purple-900">
            <UIcon
              name="i-heroicons-book-open"
              class="text-2xl text-purple-600 dark:text-purple-400"
            />
          </div>
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400">Tematy</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ stats.topics }}
            </p>
          </div>
        </div>
      </UCard>

      <UCard>
        <div class="flex items-center gap-4">
          <div class="rounded-lg bg-orange-100 p-3 dark:bg-orange-900">
            <UIcon
              name="i-heroicons-users"
              class="text-2xl text-orange-600 dark:text-orange-400"
            />
          </div>
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400">Użytkownicy</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ stats.users }}
            </p>
          </div>
        </div>
      </UCard>
    </div>

    <!-- Quick Actions -->
    <UCard class="mb-8">
      <template #header>
        <h2 class="text-xl font-semibold">Szybkie akcje</h2>
      </template>

      <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <UButton
          to="/admin/levels"
          color="primary"
          variant="outline"
          size="lg"
          block
          icon="i-heroicons-academic-cap"
        >
          Zarządzaj poziomami
        </UButton>

        <UButton
          to="/admin/categories"
          color="primary"
          variant="outline"
          size="lg"
          block
          icon="i-heroicons-folder"
        >
          Zarządzaj kategoriami
        </UButton>

        <UButton
          to="/admin/topics"
          color="primary"
          variant="outline"
          size="lg"
          block
          icon="i-heroicons-book-open"
        >
          Zarządzaj tematami
        </UButton>

        <UButton
          to="/admin/materials"
          color="primary"
          variant="outline"
          size="lg"
          block
          icon="i-heroicons-document-text"
        >
          Zarządzaj materiałami
        </UButton>

        <UButton
          to="/admin/tests"
          color="primary"
          variant="outline"
          size="lg"
          block
          icon="i-heroicons-clipboard-document-check"
        >
          Zarządzaj testami
        </UButton>

        <UButton
          to="/admin/questions"
          color="primary"
          variant="outline"
          size="lg"
          block
          icon="i-heroicons-question-mark-circle"
        >
          Zarządzaj pytaniami
        </UButton>
      </div>
    </UCard>

    <!-- Recent Activity -->
    <UCard>
      <template #header>
        <h2 class="text-xl font-semibold">Ostatnia aktywność</h2>
      </template>

      <div class="space-y-4">
        <div
          v-if="recentActivity.length === 0"
          class="py-8 text-center text-gray-500 dark:text-gray-400"
        >
          Brak ostatniej aktywności
        </div>

        <div
          v-for="activity in recentActivity"
          :key="activity.id"
          class="flex items-start gap-4 border-b border-gray-200 pb-4 last:border-0 dark:border-gray-700"
        >
          <div class="rounded-lg bg-gray-100 p-2 dark:bg-gray-800">
            <UIcon
              :name="getActivityIcon(activity.type)"
              class="text-lg text-gray-600 dark:text-gray-400"
            />
          </div>
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              {{ activity.title }}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {{ formatDate(activity.timestamp) }}
            </p>
          </div>
        </div>
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import type { Topic } from "~/types/database";
import type { PostgrestError } from "@supabase/supabase-js";

definePageMeta({
  layout: "admin",
  middleware: "admin",
});

const supabase = useSupabaseClient();

// Stats
const stats = ref({
  levels: 0,
  categories: 0,
  topics: 0,
  users: 0,
});

// Recent activity
interface ActivityItem {
  id: string;
  type: string;
  title: string;
  timestamp: string;
  user?: string;
}

const recentActivity = ref<ActivityItem[]>([]);

// Fetch statistics
const fetchStats = async () => {
  try {
    // Fetch counts
    const [levelsResult, categoriesResult, topicsResult, usersResult] =
      await Promise.all([
        supabase
          .from("education_levels")
          .select("id", { count: "exact", head: true }),
        supabase
          .from("categories")
          .select("id", { count: "exact", head: true }),
        supabase.from("topics").select("id", { count: "exact", head: true }),
        supabase
          .from("user_profiles")
          .select("id", { count: "exact", head: true }),
      ]);

    stats.value = {
      levels: levelsResult.count || 0,
      categories: categoriesResult.count || 0,
      topics: topicsResult.count || 0,
      users: usersResult.count || 0,
    };
  } catch (error) {
    console.error("Failed to fetch stats:", error);
  }
};

// Fetch recent activity (you can expand this based on your needs)
const fetchRecentActivity = async () => {
  try {
    // For now, fetch recent topics as activity
    const {
      data,
      error,
    }: { data: Topic[] | null; error: PostgrestError | null } = await supabase
      .from("topics")
      .select("id, name, created_at")
      .order("created_at", { ascending: false })
      .limit(5);

    if (error) throw error;
    if (!data) throw new Error("No data returned");
    if (data) {
      recentActivity.value = data.map((topic) => ({
        id: topic.id,
        type: "topic",
        title: `Utworzono nowy temat: ${topic.name}`,
        timestamp: topic.created_at,
      }));
    }
  } catch (error) {
    console.error("Failed to fetch recent activity:", error);
  }
};

// Get activity icon based on type
const getActivityIcon = (type: string) => {
  const icons: Record<string, string> = {
    topic: "i-heroicons-book-open",
    category: "i-heroicons-folder",
    test: "i-heroicons-clipboard-document-check",
    user: "i-heroicons-user",
  };
  return icons[type] || "i-heroicons-bell";
};

// Format date
const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return "Przed chwilą";
  if (diffMins < 60) return `${diffMins} min temu`;
  if (diffHours < 24) return `${diffHours} godz. temu`;
  if (diffDays < 7) return `${diffDays} dni temu`;

  return date.toLocaleDateString("pl-PL", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
};

// Fetch data on mount
onMounted(() => {
  fetchStats();
  fetchRecentActivity();
});
</script>
