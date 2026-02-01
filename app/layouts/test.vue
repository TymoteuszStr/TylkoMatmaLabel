<template>
  <div>
    <div class="min-h-screen bg-gray-50 dark:bg-gray-950">
      <!-- Minimal Header for Test -->
      <header
        class="border-b border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900"
      >
        <div class="container mx-auto px-4">
          <div class="flex h-14 items-center justify-between">
            <div class="flex items-center gap-2">
              <UIcon
                name="i-heroicons-academic-cap"
                class="text-xl text-primary-600"
              />
              <span class="text-lg font-bold">TylkoMatmaLabel</span>
            </div>

            <div class="flex items-center gap-2">
              <span class="text-sm text-gray-600 dark:text-gray-400">
                Test w toku
              </span>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content (Full Width for Test) -->
      <main>
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
// Minimal layout for focused test-taking experience
</script>
