<template>
  <div>
    <div class="mb-6 flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          Kategorie
        </h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Zarządzaj kategoriami treści
        </p>
      </div>
      <UButton
        color="primary"
        icon="i-heroicons-plus"
        @click="showCreateModal = true"
      >
        Dodaj kategorię
      </UButton>
    </div>

    <!-- Filters -->
    <UCard class="mb-6">
      <UFormGroup label="Poziom edukacji">
        <USelect
          v-model="selectedLevel"
          :options="levelOptions"
          placeholder="Wszystkie poziomy"
        />
      </UFormGroup>
    </UCard>

    <!-- Categories Table -->
    <UCard>
      <UTable :rows="filteredCategories" :columns="columns" :loading="loading">
        <template #name-data="{ row }">
          <div class="flex items-center gap-2">
            <UIcon
              v-if="row.icon"
              :name="row.icon"
              class="text-xl text-primary-600"
            />
            <div>
              <div class="font-medium">{{ row.name }}</div>
              <div class="text-sm text-gray-500">
                {{ row.education_level?.name }}
              </div>
            </div>
          </div>
        </template>

        <template #is_published-data="{ row }">
          <UBadge :color="row.is_published ? 'green' : 'gray'" variant="subtle">
            {{ row.is_published ? "Opublikowany" : "Szkic" }}
          </UBadge>
        </template>

        <template #actions-data="{ row }">
          <div class="flex gap-2">
            <UButton
              icon="i-heroicons-pencil"
              size="xs"
              variant="ghost"
              @click="editCategory(row)"
            />
            <UButton
              icon="i-heroicons-trash"
              size="xs"
              variant="ghost"
              color="red"
              @click="deleteCategory(row)"
            />
          </div>
        </template>
      </UTable>
    </UCard>

    <!-- Create/Edit Modal -->
    <UModal v-model="showCreateModal">
      <UCard>
        <template #header>
          <h3 class="text-xl font-bold">
            {{ editingCategory ? "Edytuj kategorię" : "Nowa kategoria" }}
          </h3>
        </template>

        <form @submit.prevent="saveCategory" class="space-y-4">
          <UFormGroup label="Poziom edukacji" required>
            <USelect
              v-model="form.education_level_id"
              :options="levelOptions"
              placeholder="Wybierz poziom"
            />
          </UFormGroup>

          <UFormGroup label="Nazwa" required>
            <UInput
              v-model="form.name"
              placeholder="np. Analiza matematyczna"
            />
          </UFormGroup>

          <UFormGroup label="Slug" required>
            <UInput
              v-model="form.slug"
              placeholder="analiza-matematyczna"
              @input="
                form.slug = $event.target.value
                  .toLowerCase()
                  .replace(/\s+/g, '-')
              "
            />
          </UFormGroup>

          <UFormGroup label="Opis">
            <UTextarea v-model="form.description" rows="3" />
          </UFormGroup>

          <UFormGroup label="Ikona (heroicons)">
            <UInput v-model="form.icon" placeholder="i-heroicons-calculator" />
          </UFormGroup>

          <UFormGroup label="Kolejność">
            <UInput
              v-model="form.display_order"
              type="number"
              placeholder="0"
            />
          </UFormGroup>

          <UFormGroup>
            <UCheckbox v-model="form.is_published" label="Opublikowany" />
          </UFormGroup>

          <div class="flex justify-end gap-3">
            <UButton
              type="button"
              variant="outline"
              @click="showCreateModal = false"
            >
              Anuluj
            </UButton>
            <UButton type="submit" color="primary" :loading="saving">
              {{ editingCategory ? "Zapisz" : "Utwórz" }}
            </UButton>
          </div>
        </form>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import type { Category, EducationLevel } from "~/types/database";

definePageMeta({
  layout: "admin",
  middleware: "admin",
});

const supabase = useTypedSupabaseClient();
const toast = useToast();

const categories = ref<Category[]>([]);
const levels = ref<EducationLevel[]>([]);
const loading = ref(true);
const saving = ref(false);
const showCreateModal = ref(false);
const editingCategory = ref<Category | null>(null);
const selectedLevel = ref("");

const form = reactive({
  education_level_id: "",
  name: "",
  slug: "",
  description: "",
  icon: "",
  display_order: 0,
  is_published: false,
});

const columns = [
  { key: "name", label: "Nazwa" },
  { key: "slug", label: "Slug" },
  { key: "display_order", label: "Kolejność" },
  { key: "is_published", label: "Status" },
  { key: "actions", label: "" },
];

const levelOptions = computed(() => [
  { value: "", label: "Wszystkie poziomy" },
  ...levels.value.map((level) => ({
    value: level.id,
    label: level.name,
  })),
]);

const filteredCategories = computed(() => {
  if (!selectedLevel.value) return categories.value;
  return categories.value.filter(
    (c) => c.education_level_id === selectedLevel.value,
  );
});

async function fetchData() {
  loading.value = true;
  try {
    const [categoriesRes, levelsRes] = await Promise.all([
      supabase
        .from("categories")
        .select("*, education_level:education_levels(*)")
        .order("display_order"),
      supabase.from("education_levels").select("*").order("display_order"),
    ]);

    categories.value = categoriesRes.data || [];
    levels.value = levelsRes.data || [];
  } catch (error) {
    console.error("Error fetching data:", error);
    toast.add({ title: "Błąd pobierania danych", color: "red" });
  } finally {
    loading.value = false;
  }
}

function editCategory(category: Category) {
  editingCategory.value = category;
  Object.assign(form, {
    education_level_id: category.education_level_id,
    name: category.name,
    slug: category.slug,
    description: category.description || "",
    icon: category.icon || "",
    display_order: category.display_order,
    is_published: category.is_published,
  });
  showCreateModal.value = true;
}

async function saveCategory() {
  saving.value = true;
  try {
    if (editingCategory.value) {
      const { error } = await supabase
        .from("categories")
        .update(form)
        .eq("id", editingCategory.value.id);

      if (error) throw error;
      toast.add({ title: "Kategoria zaktualizowana", color: "green" });
    } else {
      const { error } = await supabase.from("categories").insert(form);

      if (error) throw error;
      toast.add({ title: "Kategoria utworzona", color: "green" });
    }

    showCreateModal.value = false;
    resetForm();
    await fetchData();
  } catch (error: unknown) {
    console.error("Error saving category:", error);
    const errorMessage = error instanceof Error ? error.message : "Błąd zapisu";
    toast.add({ title: errorMessage, color: "red" });
  } finally {
    saving.value = false;
  }
}

async function deleteCategory(category: Category) {
  if (!confirm(`Czy na pewno chcesz usunąć kategorię "${category.name}"?`))
    return;

  try {
    const { error } = await supabase
      .from("categories")
      .delete()
      .eq("id", category.id);

    if (error) throw error;
    toast.add({ title: "Kategoria usunięta", color: "green" });
    await fetchData();
  } catch (error: unknown) {
    console.error("Error deleting category:", error);
    const errorMessage =
      error instanceof Error ? error.message : "Błąd usuwania";
    toast.add({ title: errorMessage, color: "red" });
  }
}

function resetForm() {
  editingCategory.value = null;
  Object.assign(form, {
    education_level_id: "",
    name: "",
    slug: "",
    description: "",
    icon: "",
    display_order: 0,
    is_published: false,
  });
}

onMounted(() => {
  fetchData();
});

watch(showCreateModal, (value) => {
  if (!value) resetForm();
});
</script>
