<template>
  <div>
    <!-- Page Header -->
    <div class="mb-8 flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          Poziomy edukacji
        </h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Zarządzaj poziomami edukacyjnymi w systemie
        </p>
      </div>
      <UButton
        color="primary"
        icon="i-heroicons-plus"
        @click="isCreating = true"
      >
        Dodaj poziom
      </UButton>
    </div>

    <!-- Levels List -->
    <UCard>
      <ClientOnly>
        <div v-if="loading" class="py-12 text-center">
          <UIcon name="i-heroicons-arrow-path" class="animate-spin text-2xl text-gray-400" />
        </div>

        <div v-else-if="levels.length === 0" class="py-12 text-center text-gray-500 dark:text-gray-400">
          Brak poziomów edukacji. Dodaj pierwszy poziom.
        </div>

        <div v-else class="divide-y divide-gray-200 dark:divide-gray-700">
          <div
            v-for="level in levels"
            :key="level.id"
            class="flex items-center justify-between py-4"
          >
            <div class="flex-1">
              <div class="flex items-center gap-3">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                  {{ level.name }}
                </h3>
                <UBadge
                  :color="level.is_published ? 'green' : 'gray'"
                  variant="subtle"
                >
                  {{ level.is_published ? 'Opublikowany' : 'Szkic' }}
                </UBadge>
              </div>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                {{ level.description }}
              </p>
              <p class="mt-1 text-xs text-gray-500 dark:text-gray-500">
                Slug: {{ level.slug }} | Kolejność: {{ level.display_order }}
              </p>
            </div>

            <div class="flex items-center gap-2">
              <UButton
                color="gray"
                variant="ghost"
                icon="i-heroicons-pencil"
                @click="editLevel(level)"
              />
              <UButton
                color="red"
                variant="ghost"
                icon="i-heroicons-trash"
                @click="confirmDelete(level)"
              />
            </div>
          </div>
        </div>
      </ClientOnly>
    </UCard>

    <!-- Create/Edit Modal -->
    <UModal v-model="isCreating">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">
            {{ editingLevel ? 'Edytuj poziom' : 'Dodaj nowy poziom' }}
          </h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <UFormGroup label="Nazwa" name="name" required>
            <UInput
              v-model="form.name"
              placeholder="np. Szkoła Podstawowa"
              size="lg"
            />
          </UFormGroup>

          <UFormGroup label="Slug" name="slug" required>
            <UInput
              v-model="form.slug"
              placeholder="np. szkola-podstawowa"
              size="lg"
            />
          </UFormGroup>

          <UFormGroup label="Opis" name="description">
            <UTextarea
              v-model="form.description"
              placeholder="Krótki opis poziomu edukacji"
              :rows="3"
            />
          </UFormGroup>

          <UFormGroup label="Kolejność wyświetlania" name="display_order" required>
            <UInput
              v-model.number="form.display_order"
              type="number"
              placeholder="1"
              size="lg"
            />
          </UFormGroup>

          <UFormGroup label="Status" name="is_published">
            <UToggle v-model="form.is_published" />
            <span class="ml-2 text-sm text-gray-600 dark:text-gray-400">
              {{ form.is_published ? 'Opublikowany' : 'Szkic' }}
            </span>
          </UFormGroup>

          <div class="flex justify-end gap-2">
            <UButton
              color="gray"
              variant="outline"
              @click="cancelEdit"
            >
              Anuluj
            </UButton>
            <UButton
              type="submit"
              color="primary"
              :loading="saving"
            >
              {{ editingLevel ? 'Zapisz zmiany' : 'Utwórz poziom' }}
            </UButton>
          </div>
        </form>
      </UCard>
    </UModal>

    <!-- Delete Confirmation Modal -->
    <UModal v-model="isDeleting">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold text-red-600 dark:text-red-400">
            Potwierdź usunięcie
          </h3>
        </template>

        <p class="text-gray-700 dark:text-gray-300">
          Czy na pewno chcesz usunąć poziom <strong>{{ levelToDelete?.name }}</strong>?
          Ta operacja jest nieodwracalna.
        </p>

        <template #footer>
          <div class="flex justify-end gap-2">
            <UButton
              color="gray"
              variant="outline"
              @click="isDeleting = false"
            >
              Anuluj
            </UButton>
            <UButton
              color="red"
              :loading="deleting"
              @click="handleDelete"
            >
              Usuń
            </UButton>
          </div>
        </template>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'admin',
  middleware: 'admin',
})

const supabase = useSupabaseClient()
const toast = useToast()

// State
const levels = ref<any[]>([])
const loading = ref(true)
const isCreating = ref(false)
const editingLevel = ref<any | null>(null)
const saving = ref(false)
const isDeleting = ref(false)
const levelToDelete = ref<any | null>(null)
const deleting = ref(false)

// Form
const form = ref({
  name: '',
  slug: '',
  description: '',
  display_order: 1,
  is_published: true,
})

// Fetch levels
const fetchLevels = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('education_levels')
      .select('*')
      .order('display_order', { ascending: true })

    if (error) throw error
    levels.value = data || []
  } catch (error) {
    console.error('Failed to fetch levels:', error)
    toast.add({
      title: 'Błąd',
      description: 'Nie udało się pobrać poziomów edukacji',
      color: 'red',
    })
  } finally {
    loading.value = false
  }
}

// Edit level
const editLevel = (level: any) => {
  editingLevel.value = level
  form.value = {
    name: level.name,
    slug: level.slug,
    description: level.description || '',
    display_order: level.display_order,
    is_published: level.is_published,
  }
  isCreating.value = true
}

// Cancel edit
const cancelEdit = () => {
  isCreating.value = false
  editingLevel.value = null
  form.value = {
    name: '',
    slug: '',
    description: '',
    display_order: 1,
    is_published: true,
  }
}

// Handle submit
const handleSubmit = async () => {
  saving.value = true
  try {
    if (editingLevel.value) {
      // Update existing level
      const { error } = await supabase
        .from('education_levels')
        .update(form.value)
        .eq('id', editingLevel.value.id)

      if (error) throw error

      toast.add({
        title: 'Sukces',
        description: 'Poziom został zaktualizowany',
        color: 'green',
      })
    } else {
      // Create new level
      const { error } = await supabase
        .from('education_levels')
        .insert(form.value)

      if (error) throw error

      toast.add({
        title: 'Sukces',
        description: 'Poziom został utworzony',
        color: 'green',
      })
    }

    await fetchLevels()
    cancelEdit()
  } catch (error) {
    console.error('Failed to save level:', error)
    toast.add({
      title: 'Błąd',
      description: 'Nie udało się zapisać poziomu',
      color: 'red',
    })
  } finally {
    saving.value = false
  }
}

// Confirm delete
const confirmDelete = (level: any) => {
  levelToDelete.value = level
  isDeleting.value = true
}

// Handle delete
const handleDelete = async () => {
  if (!levelToDelete.value) return

  deleting.value = true
  try {
    const { error } = await supabase
      .from('education_levels')
      .delete()
      .eq('id', levelToDelete.value.id)

    if (error) throw error

    toast.add({
      title: 'Sukces',
      description: 'Poziom został usunięty',
      color: 'green',
    })

    await fetchLevels()
    isDeleting.value = false
    levelToDelete.value = null
  } catch (error) {
    console.error('Failed to delete level:', error)
    toast.add({
      title: 'Błąd',
      description: 'Nie udało się usunąć poziomu',
      color: 'red',
    })
  } finally {
    deleting.value = false
  }
}

// Fetch on mount
onMounted(() => {
  fetchLevels()
})
</script>
