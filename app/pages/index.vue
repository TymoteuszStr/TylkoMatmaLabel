<template>
  <div>
    <!-- Dashboard for Authenticated Users -->
    <div v-if="isAuthenticated" class="container mx-auto px-4 py-8">
      <!-- Welcome Section -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          Witaj, {{ profile?.display_name || 'Uczniu' }}! 👋
        </h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Kontynuuj swoją przygodę z matematyką
        </p>
      </div>

      <!-- Statistics Cards -->
      <ClientOnly>
        <div class="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <UCard>
            <div class="flex items-center gap-4">
              <div class="rounded-lg bg-primary-100 p-3 dark:bg-primary-900">
                <UIcon
                  name="i-heroicons-academic-cap"
                  class="text-2xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Ukończone tematy
                </p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ stats.completedTopics }}
                </p>
              </div>
            </div>
          </UCard>

          <UCard>
            <div class="flex items-center gap-4">
              <div class="rounded-lg bg-green-100 p-3 dark:bg-green-900">
                <UIcon
                  name="i-heroicons-check-badge"
                  class="text-2xl text-green-600 dark:text-green-400"
                />
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Zdane testy
                </p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ stats.passedTests }}
                </p>
              </div>
            </div>
          </UCard>

          <UCard>
            <div class="flex items-center gap-4">
              <div class="rounded-lg bg-orange-100 p-3 dark:bg-orange-900">
                <UIcon
                  name="i-heroicons-fire"
                  class="text-2xl text-orange-600 dark:text-orange-400"
                />
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Dni z rzędu
                </p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ stats.streak }}
                </p>
              </div>
            </div>
          </UCard>
        </div>
      </ClientOnly>

      <!-- Quick Actions -->
      <div class="mb-8 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <UCard
          class="cursor-pointer transition-shadow hover:shadow-lg"
          @click="navigateTo('/materialy')"
        >
          <div class="flex items-start gap-4">
            <div
              class="flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100 dark:bg-blue-900"
            >
              <UIcon
                name="i-heroicons-book-open"
                class="text-2xl text-blue-600 dark:text-blue-400"
              />
            </div>
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                Materiały
              </h3>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                Przeglądaj tematy i ucz się nowych rzeczy
              </p>
              <UButton
                size="sm"
                color="blue"
                variant="soft"
                class="mt-3"
              >
                Przeglądaj
                <template #trailing>
                  <UIcon name="i-heroicons-arrow-right" />
                </template>
              </UButton>
            </div>
          </div>
        </UCard>

        <UCard
          class="cursor-pointer transition-shadow hover:shadow-lg"
          @click="navigateTo('/testy')"
        >
          <div class="flex items-start gap-4">
            <div
              class="flex h-12 w-12 items-center justify-center rounded-lg bg-purple-100 dark:bg-purple-900"
            >
              <UIcon
                name="i-heroicons-clipboard-document-check"
                class="text-2xl text-purple-600 dark:text-purple-400"
              />
            </div>
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                Testy
              </h3>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                Sprawdź swoją wiedzę w praktyce
              </p>
              <UButton
                size="sm"
                color="purple"
                variant="soft"
                class="mt-3"
              >
                Rozwiąż test
                <template #trailing>
                  <UIcon name="i-heroicons-arrow-right" />
                </template>
              </UButton>
            </div>
          </div>
        </UCard>

        <UCard
          class="cursor-pointer transition-shadow hover:shadow-lg"
          @click="navigateTo('/profile')"
        >
          <div class="flex items-start gap-4">
            <div
              class="flex h-12 w-12 items-center justify-center rounded-lg bg-green-100 dark:bg-green-900"
            >
              <UIcon
                name="i-heroicons-user-circle"
                class="text-2xl text-green-600 dark:text-green-400"
              />
            </div>
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                Mój profil
              </h3>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                Zobacz szczegóły swojego konta
              </p>
              <UButton
                size="sm"
                color="green"
                variant="soft"
                class="mt-3"
              >
                Przejdź
                <template #trailing>
                  <UIcon name="i-heroicons-arrow-right" />
                </template>
              </UButton>
            </div>
          </div>
        </UCard>
      </div>

      <!-- Education Levels Section -->
      <section id="levels" class="rounded-lg bg-gray-50 p-6 dark:bg-gray-900">
        <div class="mb-6">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
            Poziomy edukacji
          </h2>
          <p class="mt-2 text-gray-600 dark:text-gray-400">
            Wybierz poziom i zacznij naukę
          </p>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="flex justify-center py-12">
          <UIcon
            name="i-heroicons-arrow-path"
            class="animate-spin text-4xl text-primary-600"
          />
        </div>

        <!-- Education Levels -->
        <div
          v-else-if="educationLevels.length > 0"
          class="grid gap-4 md:grid-cols-2 lg:grid-cols-3"
        >
          <UCard
            v-for="level in educationLevels"
            :key="level.id"
            :ui="{ body: { padding: 'p-4' } }"
            class="cursor-pointer transition-shadow hover:shadow-lg"
            @click="navigateTo(`/${level.slug}`)"
          >
            <div class="flex items-start gap-3">
              <div
                class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-academic-cap"
                  class="text-xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <div class="flex-1">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                  {{ level.name }}
                </h3>
                <p
                  v-if="level.description"
                  class="mt-1 text-sm text-gray-600 dark:text-gray-400"
                >
                  {{ level.description }}
                </p>
              </div>
            </div>
          </UCard>
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
      </section>
    </div>

    <!-- Landing Page for Unauthenticated Users -->
    <div v-else>
      <!-- Hero Section -->
      <section
        class="bg-gradient-to-b from-primary-50 to-white py-16 dark:from-gray-900 dark:to-gray-950 md:py-24"
      >
        <div class="container mx-auto px-4">
          <div class="mx-auto max-w-3xl text-center">
            <h1
              class="text-4xl font-bold tracking-tight text-gray-900 dark:text-white md:text-5xl lg:text-6xl"
            >
              Ucz się matematyki
              <span class="text-primary-600 dark:text-primary-400"
                >w przystępny sposób</span
              >
            </h1>
            <p class="mt-6 text-lg leading-8 text-gray-600 dark:text-gray-300">
              Kompleksowa platforma edukacyjna z materiałami, przykładami i
              testami. Wszystko czego potrzebujesz aby opanować matematykę na
              poziomie liceum.
            </p>
            <div class="mt-10 flex items-center justify-center gap-4">
              <UButton size="xl" to="#levels" color="primary">
                Zacznij naukę
                <template #trailing>
                  <UIcon name="i-heroicons-arrow-right" />
                </template>
              </UButton>
              <UButton size="xl" to="/auth/register" variant="outline">
                Utwórz konto
              </UButton>
            </div>
          </div>
        </div>
      </section>

      <!-- Features Section -->
      <section class="py-16 md:py-24">
        <div class="container mx-auto px-4">
          <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">
              Wszystko czego potrzebujesz
            </h2>
            <p class="mt-4 text-gray-600 dark:text-gray-400">
              Kompletny zestaw narzędzi do nauki matematyki
            </p>
          </div>

          <div class="mt-16 grid gap-8 md:grid-cols-3">
            <div class="flex flex-col items-center text-center">
              <div
                class="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-book-open"
                  class="text-3xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <h3
                class="mt-6 text-xl font-semibold text-gray-900 dark:text-white"
              >
                Materiały teoretyczne
              </h3>
              <p class="mt-2 text-gray-600 dark:text-gray-400">
                Przejrzyste wyjaśnienia, przykłady i wzory ułatwiające naukę
              </p>
            </div>

            <div class="flex flex-col items-center text-center">
              <div
                class="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-clipboard-document-check"
                  class="text-3xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <h3
                class="mt-6 text-xl font-semibold text-gray-900 dark:text-white"
              >
                Testy ABCD
              </h3>
              <p class="mt-2 text-gray-600 dark:text-gray-400">
                Sprawdź swoją wiedzę za pomocą interaktywnych testów
              </p>
            </div>

            <div class="flex flex-col items-center text-center">
              <div
                class="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-chart-bar"
                  class="text-3xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <h3
                class="mt-6 text-xl font-semibold text-gray-900 dark:text-white"
              >
                Śledź postępy
              </h3>
              <p class="mt-2 text-gray-600 dark:text-gray-400">
                Monitoruj swoje wyniki i postępy w nauce
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- Education Levels Section -->
      <section id="levels" class="bg-gray-50 py-16 dark:bg-gray-900 md:py-24">
        <div class="container mx-auto px-4">
          <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">
              Wybierz poziom edukacji
            </h2>
            <p class="mt-4 text-gray-600 dark:text-gray-400">
              Rozpocznij naukę od wybrania odpowiedniego poziomu
            </p>
          </div>

          <!-- Loading State -->
          <div v-if="loading" class="mt-12 flex justify-center">
            <UIcon
              name="i-heroicons-arrow-path"
              class="animate-spin text-4xl text-primary-600"
            />
          </div>

          <!-- Education Levels -->
          <div
            v-else-if="educationLevels.length > 0"
            class="mt-12 grid gap-6 md:grid-cols-2 lg:grid-cols-3"
          >
            <UCard
              v-for="level in educationLevels"
              :key="level.id"
              :ui="{ body: { padding: 'p-6' } }"
              class="cursor-pointer transition-shadow hover:shadow-lg"
              @click="navigateTo(`/${level.slug}`)"
            >
              <div class="flex items-start gap-4">
                <div
                  class="flex h-12 w-12 items-center justify-center rounded-lg bg-primary-100 dark:bg-primary-900"
                >
                  <UIcon
                    name="i-heroicons-academic-cap"
                    class="text-2xl text-primary-600 dark:text-primary-400"
                  />
                </div>
                <div class="flex-1">
                  <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                    {{ level.name }}
                  </h3>
                  <p
                    v-if="level.description"
                    class="mt-2 text-sm text-gray-600 dark:text-gray-400"
                  >
                    {{ level.description }}
                  </p>
                </div>
              </div>
            </UCard>
          </div>

          <!-- Empty State -->
          <div v-else class="mt-12 text-center">
            <UIcon
              name="i-heroicons-inbox"
              class="mx-auto text-6xl text-gray-400"
            />
            <p class="mt-4 text-gray-600 dark:text-gray-400">
              Brak dostępnych poziomów edukacji
            </p>
          </div>
        </div>
      </section>

      <!-- CTA Section -->
      <section class="py-16 md:py-24">
        <div class="container mx-auto px-4">
          <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">
              Gotowy na rozpoczęcie nauki?
            </h2>
            <p class="mt-4 text-gray-600 dark:text-gray-400">
              Utwórz konto i zacznij śledzić swoje postępy
            </p>
            <div class="mt-8 flex items-center justify-center gap-4">
              <UButton size="lg" to="/auth/register" color="primary">
                Zarejestruj się za darmo
              </UButton>
              <UButton size="lg" to="/auth/login" variant="outline">
                Mam już konto
              </UButton>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
const { isAuthenticated, profile } = useAuth();
const contentStore = useContentStore();
const supabase = useSupabaseClient();

const { educationLevels } = storeToRefs(contentStore);
const loading = ref(false);

// Stats
const stats = ref({
  completedTopics: 0,
  passedTests: 0,
  streak: 0,
});

// Fetch user statistics
const fetchStats = async () => {
  if (!isAuthenticated.value || !profile.value) return;

  try {
    // Fetch completed topics count
    const { count: topicsCount } = await supabase
      .from("user_progress")
      .select("*", { count: "exact", head: true })
      .eq("user_id", profile.value.id)
      .eq("status", "completed");

    // Fetch passed tests count
    const { count: testsCount } = await supabase
      .from("test_attempts")
      .select("*", { count: "exact", head: true })
      .eq("user_id", profile.value.id)
      .gte("score", 60); // Assuming 60% is passing score

    stats.value.completedTopics = topicsCount || 0;
    stats.value.passedTests = testsCount || 0;

    // Calculate streak (simplified - just days since last activity)
    const { data: recentProgress } = await supabase
      .from("user_progress")
      .select("last_accessed_at")
      .eq("user_id", profile.value.id)
      .order("last_accessed_at", { ascending: false })
      .limit(1);

    if (recentProgress && recentProgress.length > 0) {
      try {
        const item = recentProgress[0] as any;
        if (item?.last_accessed_at) {
          const lastAccess = new Date(item.last_accessed_at);
          const now = new Date();
          const diffDays = Math.floor(
            (now.getTime() - lastAccess.getTime()) / (1000 * 60 * 60 * 24)
          );
          stats.value.streak = diffDays === 0 ? 1 : 0;
        }
      } catch {
        // Ignore streak calculation errors
      }
    }
  } catch (error) {
    console.error("Failed to fetch stats:", error);
  }
};

// Fetch education levels on mount
onMounted(async () => {
  loading.value = true;
  await contentStore.fetchEducationLevels();
  loading.value = false;

  // Fetch stats if user is authenticated
  if (isAuthenticated.value) {
    await fetchStats();
  }
});

// Watch for authentication changes and fetch stats
watch(isAuthenticated, async (newValue) => {
  if (newValue) {
    await fetchStats();
  }
});

// SEO
useHead({
  title: "TylkoMatmaOnline - Nauka matematyki online",
  meta: [
    {
      name: "description",
      content:
        "Kompleksowa platforma edukacyjna do nauki matematyki. Materiały, testy i śledzenie postępów dla uczniów liceum.",
    },
    {
      name: "keywords",
      content: "matematyka, nauka, liceum, testy, materiały, edukacja",
    },
  ],
});
</script>
