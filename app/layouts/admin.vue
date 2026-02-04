<template>
  <div>
    <div class="min-h-screen bg-gray-50 dark:bg-gray-950">
      <!-- Admin Header -->
      <header
        class="sticky top-0 z-50 border-b border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900"
      >
        <div class="container mx-auto px-4">
          <div class="flex h-16 items-center justify-between">
            <!-- Logo & Admin Badge -->
            <div class="flex items-center gap-4">
              <NuxtLink to="/" class="flex items-center gap-2">
                <UIcon
                  name="i-heroicons-academic-cap"
                  class="text-2xl text-primary-600"
                />
                <span class="text-xl font-bold">TylkoMatmaOnline</span>
              </NuxtLink>
              <UBadge color="primary" variant="subtle">Admin</UBadge>
            </div>

            <!-- User Menu -->
            <div class="flex items-center gap-3">
              <ClientOnly>
                <UButton
                  variant="ghost"
                  color="gray"
                  size="sm"
                  square
                  @click="toggleDarkMode"
                >
                  <UIcon
                    :name="isDark ? 'i-heroicons-moon' : 'i-heroicons-sun'"
                    class="text-lg"
                  />
                </UButton>
              </ClientOnly>

              <ClientOnly>
                <UDropdown :items="userMenuItems">
                  <UButton
                    variant="ghost"
                    color="gray"
                    size="sm"
                    trailing-icon="i-heroicons-chevron-down"
                  >
                    <UAvatar
                      :src="profile?.avatar_url"
                      :alt="profile?.display_name || 'Admin'"
                      size="xs"
                    />
                    <span class="hidden sm:inline">{{
                      profile?.display_name
                    }}</span>
                  </UButton>
                </UDropdown>
              </ClientOnly>
            </div>
          </div>
        </div>
      </header>

      <div class="flex">
        <!-- Sidebar -->
        <aside
          class="hidden w-64 border-r border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 lg:block"
        >
          <nav class="space-y-1 p-4">
            <NuxtLink
              v-for="item in navigationItems"
              :key="item.to"
              :to="item.to"
              class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors"
              :class="
                isCurrentRoute(item.to)
                  ? 'bg-primary-50 text-primary-700 dark:bg-primary-950 dark:text-primary-300'
                  : 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800'
              "
            >
              <UIcon :name="item.icon" class="text-lg" />
              {{ item.label }}
            </NuxtLink>
          </nav>
        </aside>

        <!-- Main Content -->
        <main class="flex-1">
          <div class="container mx-auto p-6">
            <slot />
          </div>
        </main>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { profile, signOut } = useAuth();
const route = useRoute();
const colorMode = useColorMode();

const isDark = computed({
  get: () => colorMode.value === "dark",
  set: () => {
    colorMode.preference = colorMode.value === "dark" ? "light" : "dark";
  },
});

const toggleDarkMode = () => {
  isDark.value = !isDark.value;
};

const navigationItems = [
  {
    label: "Dashboard",
    icon: "i-heroicons-home",
    to: "/admin",
  },
  {
    label: "Poziomy edukacji",
    icon: "i-heroicons-academic-cap",
    to: "/admin/levels",
  },
  {
    label: "Kategorie",
    icon: "i-heroicons-folder",
    to: "/admin/categories",
  },
  {
    label: "Tematy",
    icon: "i-heroicons-book-open",
    to: "/admin/topics",
  },
  {
    label: "Materiały",
    icon: "i-heroicons-document-text",
    to: "/admin/materials",
  },
  {
    label: "Testy",
    icon: "i-heroicons-clipboard-document-check",
    to: "/admin/tests",
  },
  {
    label: "Pytania",
    icon: "i-heroicons-question-mark-circle",
    to: "/admin/questions",
  },
];

const isCurrentRoute = (path: string) => {
  if (path === "/admin") {
    return route.path === "/admin";
  }
  return route.path.startsWith(path);
};

const userMenuItems = computed(() => [
  [
    {
      label: profile.value?.display_name || "Admin",
      slot: "account",
      disabled: true,
    },
  ],
  [
    {
      label: "Strona główna",
      icon: "i-heroicons-arrow-left",
      to: "/",
    },
    {
      label: "Ustawienia",
      icon: "i-heroicons-cog",
      to: "/admin/settings",
    },
  ],
  [
    {
      label: "Wyloguj",
      icon: "i-heroicons-arrow-right-on-rectangle",
      click: async () => {
        await signOut();
        navigateTo("/auth/login");
      },
    },
  ],
]);
</script>
