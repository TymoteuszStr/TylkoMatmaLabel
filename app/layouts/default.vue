<template>
  <div>
    <div class="min-h-screen bg-gray-50 dark:bg-gray-950">
      <!-- Header -->
      <header class="sticky top-0 z-50 border-b border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
        <div class="container mx-auto px-4">
          <div class="flex h-16 items-center justify-between">
            <!-- Logo -->
            <NuxtLink to="/" class="flex items-center gap-2">
              <UIcon name="i-heroicons-academic-cap" class="text-2xl text-primary-600" />
              <span class="text-xl font-bold">TylkoMatma</span>
            </NuxtLink>

            <!-- Navigation -->
            <nav class="hidden items-center gap-6 md:flex">
              <NuxtLink
                to="/"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 dark:text-gray-300 dark:hover:text-primary-400"
              >
                Strona główna
              </NuxtLink>
              <NuxtLink
                v-if="isAdmin"
                to="/admin"
                class="text-sm font-medium text-gray-700 hover:text-primary-600 dark:text-gray-300 dark:hover:text-primary-400"
              >
                Panel Admin
              </NuxtLink>
            </nav>

            <!-- User Menu -->
            <div class="flex items-center gap-3">
              <!-- Dark Mode Toggle -->
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

              <!-- User Dropdown -->
              <ClientOnly>
                <UDropdown v-if="isAuthenticated" :items="userMenuItems">
                  <UButton
                    variant="ghost"
                    color="gray"
                    size="sm"
                    trailing-icon="i-heroicons-chevron-down"
                  >
                    <UAvatar
                      :src="profile?.avatar_url"
                      :alt="profile?.display_name || 'User'"
                      size="xs"
                    />
                    <span class="hidden sm:inline">{{ profile?.display_name }}</span>
                  </UButton>
                </UDropdown>

                <!-- Login Button -->
                <UButton v-else to="/auth/login" color="primary" size="sm">
                  Zaloguj się
                </UButton>
              </ClientOnly>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <main>
        <slot />
      </main>

      <!-- Footer -->
      <footer class="border-t border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
        <div class="container mx-auto px-4 py-8">
          <div class="flex flex-col items-center justify-between gap-4 md:flex-row">
            <div class="text-sm text-gray-600 dark:text-gray-400">
              © {{ currentYear }} TylkoMatma. Wszystkie prawa zastrzeżone.
            </div>
            <div class="flex gap-6">
              <NuxtLink
                to="/o-nas"
                class="text-sm text-gray-600 hover:text-primary-600 dark:text-gray-400 dark:hover:text-primary-400"
              >
                O nas
              </NuxtLink>
              <NuxtLink
                to="/kontakt"
                class="text-sm text-gray-600 hover:text-primary-600 dark:text-gray-400 dark:hover:text-primary-400"
              >
                Kontakt
              </NuxtLink>
            </div>
          </div>
        </div>
      </footer>
    </div>
  </div>
</template>

<script setup lang="ts">
const { isAuthenticated, isAdmin, profile, signOut } = useAuth()
const colorMode = useColorMode()

const isDark = computed({
  get: () => colorMode.value === 'dark',
  set: () => {
    colorMode.preference = colorMode.value === 'dark' ? 'light' : 'dark'
  },
})

const currentYear = new Date().getFullYear()

const toggleDarkMode = () => {
  isDark.value = !isDark.value
}

const userMenuItems = computed(() => [
  [
    {
      label: profile.value?.display_name || 'Profil',
      slot: 'account',
      disabled: true,
    },
  ],
  [
    {
      label: 'Mój profil',
      icon: 'i-heroicons-user',
      to: '/profile',
    },
    {
      label: 'Moje wyniki',
      icon: 'i-heroicons-chart-bar',
      to: '/wyniki',
    },
  ],
  [
    {
      label: 'Wyloguj',
      icon: 'i-heroicons-arrow-right-on-rectangle',
      click: async () => {
        await signOut()
        navigateTo('/auth/login')
      },
    },
  ],
])
</script>

