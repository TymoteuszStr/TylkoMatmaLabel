<template>
  <div>
    <!-- Page Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
        Materiały
      </h1>
      <p class="mt-2 text-gray-600 dark:text-gray-400">
        Zarządzaj materiałami edukacyjnymi
      </p>
    </div>

    <!-- Coming Soon Card -->
    <UCard>
      <div class="py-16 text-center">
        <UIcon
          name="i-heroicons-document-text"
          class="mx-auto text-6xl text-gray-400 dark:text-gray-600"
        />
        <h2 class="mt-4 text-2xl font-bold text-gray-900 dark:text-white">
          Panel zarządzania materiałami
        </h2>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Ta sekcja będzie wkrótce dostępna
        </p>
        <UButton
          to="/admin"
          color="primary"
          class="mt-6"
        >
          Wróć do panelu głównego
        </UButton>
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'admin',
  middleware: 'admin',
})
</script>
