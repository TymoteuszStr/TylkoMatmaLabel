<template>
  <div>
    <!-- Page Header -->
    <div class="mb-8 flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          Materiały
        </h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Zarządzaj materiałami edukacyjnymi w tematach
        </p>
      </div>
      <UButton
        color="primary"
        icon="i-heroicons-plus"
        @click="openCreateModal"
      >
        Dodaj materiał
      </UButton>
    </div>

    <!-- Materials List -->
    <UCard>
      <ClientOnly>
        <div v-if="loading" class="py-12 text-center">
          <UIcon
            name="i-heroicons-arrow-path"
            class="animate-spin text-2xl text-gray-400"
          />
        </div>

        <div
          v-else-if="materials.length === 0"
          class="py-12 text-center text-gray-500 dark:text-gray-400"
        >
          Brak materiałów. Dodaj pierwszy materiał.
        </div>

        <div v-else class="divide-y divide-gray-200 dark:divide-gray-700">
          <div
            v-for="material in materials"
            :key="material.id"
            class="flex items-center justify-between py-4"
          >
            <div class="flex-1">
              <div class="flex items-center gap-3">
                <UIcon
                  :name="getMaterialIcon(material.type)"
                  class="text-xl text-primary-600 dark:text-primary-400"
                />
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                  {{ material.title }}
                </h3>
                <UBadge
                  :color="getMaterialColor(material.type)"
                  variant="subtle"
                >
                  {{ getMaterialLabel(material.type) }}
                </UBadge>
                <UBadge
                  :color="material.is_published ? 'green' : 'gray'"
                  variant="subtle"
                >
                  {{ material.is_published ? "Opublikowany" : "Szkic" }}
                </UBadge>
              </div>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                Temat: {{ material.topics?.name }}
                <span v-if="material.topics?.categories?.name">
                  | Kategoria: {{ material.topics.categories.name }}
                </span>
              </p>
              <p class="mt-1 text-xs text-gray-500 dark:text-gray-500">
                Kolejność: {{ material.display_order }}
              </p>
            </div>

            <div class="flex items-center gap-2">
              <UButton
                color="gray"
                variant="ghost"
                icon="i-heroicons-pencil"
                @click="editMaterial(material)"
              />
              <UButton
                color="red"
                variant="ghost"
                icon="i-heroicons-trash"
                @click="confirmDelete(material)"
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
            {{ editingMaterial ? "Edytuj materiał" : "Dodaj nowy materiał" }}
          </h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <UFormGroup label="Temat" name="topic_id" required>
            <USelectMenu
              v-model="form.topic_id"
              :options="topicOptions"
              placeholder="Wybierz temat"
              value-attribute="id"
              option-attribute="label"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
            />
          </UFormGroup>

          <UFormGroup label="Tytuł" name="title" required>
            <UInput
              v-model="form.title"
              placeholder="np. Wprowadzenie do pochodnych"
              size="lg"
            />
          </UFormGroup>

          <UFormGroup label="Typ materiału" name="type" required>
            <USelectMenu
              v-model="form.type"
              :options="materialTypeOptions"
              placeholder="Wybierz typ"
              value-attribute="value"
              option-attribute="label"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
            />
          </UFormGroup>

          <UFormGroup label="Treść (Markdown)" name="content">
            <UTextarea
              v-model="form.contentMarkdown"
              placeholder="Wpisz treść w formacie Markdown..."
              :rows="10"
              class="font-mono text-sm"
            />
          </UFormGroup>

          <UFormGroup
            label="Kolejność wyświetlania"
            name="display_order"
            required
          >
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
              {{ form.is_published ? "Opublikowany" : "Szkic" }}
            </span>
          </UFormGroup>

          <div class="flex justify-end gap-2">
            <UButton color="gray" variant="outline" @click="cancelEdit">
              Anuluj
            </UButton>
            <UButton type="submit" color="primary" :loading="saving">
              {{ editingMaterial ? "Zapisz zmiany" : "Utwórz materiał" }}
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
          Czy na pewno chcesz usunąć materiał
          <strong>{{ materialToDelete?.title }}</strong
          >? Ta operacja jest nieodwracalna.
        </p>

        <template #footer>
          <div class="flex justify-end gap-2">
            <UButton color="gray" variant="outline" @click="isDeleting = false">
              Anuluj
            </UButton>
            <UButton color="red" :loading="deleting" @click="handleDelete">
              Usuń
            </UButton>
          </div>
        </template>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import type {
  Material,
  MaterialInsert,
  MaterialUpdate,
  MaterialWithTopic,
  MaterialType,
} from "~/types/database";
import {
  getMaterialColor,
  getMaterialIcon,
  getMaterialLabel,
} from "~/utils/material";

definePageMeta({
  layout: "admin",
  middleware: "admin",
});

const supabase = useTypedSupabaseClient();
const toast = useToast();

// State
const materials = ref<MaterialWithTopic[]>([]);
const topics = ref<Array<{ id: string; name: string; slug: string; categories?: { name: string } }>>([]);
const loading = ref(true);
const isCreating = ref(false);
const editingMaterial = ref<Material | null>(null);
const saving = ref(false);
const isDeleting = ref(false);
const materialToDelete = ref<Material | null>(null);
const deleting = ref(false);

// Form
const form = ref({
  topic_id: "" as string,
  title: "",
  type: "theory" as MaterialType,
  contentMarkdown: "",
  display_order: 1,
  is_published: true,
});

// Material type options for select
const materialTypeOptions = [
  { value: "theory", label: "Teoria" },
  { value: "example", label: "Przykład" },
  { value: "exercise", label: "Ćwiczenie" },
  { value: "summary", label: "Podsumowanie" },
];

// Topic options - computed for USelectMenu (with label for display)
const topicOptions = computed(() =>
  topics.value.map((t) => ({
    ...t,
    label: t.categories?.name
      ? `${t.name} (${t.categories.name})`
      : t.name,
  }))
);

// Helper: extract markdown from content blocks
function extractMarkdownFromContent(content: unknown): string {
  if (!Array.isArray(content) || content.length === 0) return "";
  const firstBlock = content[0];
  if (
    firstBlock &&
    typeof firstBlock === "object" &&
    "type" in firstBlock &&
    firstBlock.type === "text" &&
    "content" in firstBlock &&
    firstBlock.content &&
    typeof firstBlock.content === "object" &&
    "markdown" in firstBlock.content
  ) {
    return String((firstBlock.content as { markdown: string }).markdown);
  }
  return "";
}

// Helper: create content blocks from markdown
function createContentFromMarkdown(markdown: string) {
  return [
    {
      id: crypto.randomUUID(),
      type: "text",
      content: { markdown: markdown || "" },
      order: 0,
    },
  ];
}

// Fetch materials
const fetchMaterials = async () => {
  loading.value = true;
  try {
    const { data, error } = await supabase
      .from("materials")
      .select("*, topics(name, slug, categories(name))")
      .order("display_order", { ascending: true });

    if (error) throw error;
    materials.value = (data || []) as MaterialWithTopic[];
  } catch (error) {
    console.error("Failed to fetch materials:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się pobrać materiałów",
      color: "red",
    });
  } finally {
    loading.value = false;
  }
};

// Fetch topics
const fetchTopics = async () => {
  try {
    const { data, error } = await supabase
      .from("topics")
      .select("id, name, slug, categories(name)")
      .order("name", { ascending: true });

    if (error) throw error;
    topics.value = data || [];
  } catch (error) {
    console.error("Failed to fetch topics:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się pobrać tematów",
      color: "red",
    });
  }
};

// Open create modal
const openCreateModal = () => {
  editingMaterial.value = null;
  form.value = {
    topic_id: "",
    title: "",
    type: "theory",
    contentMarkdown: "",
    display_order: 1,
    is_published: true,
  };
  isCreating.value = true;
};

// Edit material
const editMaterial = (material: Material) => {
  editingMaterial.value = material;
  form.value = {
    topic_id: material.topic_id,
    title: material.title,
    type: material.type,
    contentMarkdown: extractMarkdownFromContent(material.content),
    display_order: material.display_order,
    is_published: material.is_published,
  };
  isCreating.value = true;
};

// Cancel edit
const cancelEdit = () => {
  isCreating.value = false;
  editingMaterial.value = null;
  form.value = {
    topic_id: "",
    title: "",
    type: "theory",
    contentMarkdown: "",
    display_order: 1,
    is_published: true,
  };
};

// Handle submit
const handleSubmit = async () => {
  if (!form.value.topic_id) {
    toast.add({
      title: "Błąd",
      description: "Wybierz temat",
      color: "red",
    });
    return;
  }

  saving.value = true;
  try {
    const content = createContentFromMarkdown(form.value.contentMarkdown);

    if (editingMaterial.value) {
      const updateData: MaterialUpdate = {
        topic_id: form.value.topic_id,
        title: form.value.title,
        type: form.value.type,
        display_order: form.value.display_order,
        is_published: form.value.is_published,
        content,
      };
      const { error } = await supabase
        .from("materials")
        .update(updateData as never)
        .eq("id", editingMaterial.value.id);

      if (error) throw error;

      toast.add({
        title: "Sukces",
        description: "Materiał został zaktualizowany",
        color: "green",
      });
    } else {
      const insertData: MaterialInsert = {
        topic_id: form.value.topic_id,
        title: form.value.title,
        type: form.value.type,
        display_order: form.value.display_order,
        is_published: form.value.is_published,
        content,
      };
      const { error } = await supabase
        .from("materials")
        .insert(insertData as never);

      if (error) throw error;

      toast.add({
        title: "Sukces",
        description: "Materiał został utworzony",
        color: "green",
      });
    }

    await fetchMaterials();
    cancelEdit();
  } catch (error) {
    console.error("Failed to save material:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się zapisać materiału",
      color: "red",
    });
  } finally {
    saving.value = false;
  }
};

// Confirm delete
const confirmDelete = (material: Material) => {
  materialToDelete.value = material;
  isDeleting.value = true;
};

// Handle delete
const handleDelete = async () => {
  if (!materialToDelete.value) return;

  deleting.value = true;
  try {
    const { error } = await supabase
      .from("materials")
      .delete()
      .eq("id", materialToDelete.value.id);

    if (error) throw error;

    toast.add({
      title: "Sukces",
      description: "Materiał został usunięty",
      color: "green",
    });

    await fetchMaterials();
    isDeleting.value = false;
    materialToDelete.value = null;
  } catch (error) {
    console.error("Failed to delete material:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się usunąć materiału",
      color: "red",
    });
  } finally {
    deleting.value = false;
  }
};

// Fetch on mount
onMounted(async () => {
  await fetchTopics();
  await fetchMaterials();
});
</script>
