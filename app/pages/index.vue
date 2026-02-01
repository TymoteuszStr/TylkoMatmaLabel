<template>
  <div>
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
            class="hover:shadow-lg transition-shadow cursor-pointer"
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
</template>

<script setup lang="ts">
const contentStore = useContentStore();

const { educationLevels } = storeToRefs(contentStore);
const loading = ref(false);

// Fetch education levels on mount
onMounted(async () => {
  loading.value = true;
  await contentStore.fetchEducationLevels();
  loading.value = false;
});

// SEO
useHead({
  title: "TylkoMatmaLabel - Nauka matematyki online",
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
