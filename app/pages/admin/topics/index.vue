<template>
  <div>
    <!-- Page Header -->
    <div class="mb-8 flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Tematy</h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Zarządzaj tematami w systemie
        </p>
      </div>
      <UButton
        color="primary"
        icon="i-heroicons-plus"
        @click="isCreating = true"
      >
        Dodaj temat
      </UButton>
    </div>

    <!-- Topics List -->
    <UCard>
      <ClientOnly>
        <div v-if="loading" class="py-12 text-center">
          <UIcon
            name="i-heroicons-arrow-path"
            class="animate-spin text-2xl text-gray-400"
          />
        </div>

        <div
          v-else-if="topics.length === 0"
          class="py-12 text-center text-gray-500 dark:text-gray-400"
        >
          Brak tematów. Dodaj pierwszy temat.
        </div>

        <div v-else class="divide-y divide-gray-200 dark:divide-gray-700">
          <div
            v-for="topic in topics"
            :key="topic.id"
            class="flex items-center justify-between py-4"
          >
            <div class="flex-1">
              <div class="flex items-center gap-3">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                  {{ topic.name }}
                </h3>
                <UBadge
                  :color="topic.is_published ? 'green' : 'gray'"
                  variant="subtle"
                >
                  {{ topic.is_published ? "Opublikowany" : "Szkic" }}
                </UBadge>
              </div>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                {{ topic.description }}
              </p>
              <p class="mt-1 text-xs text-gray-500 dark:text-gray-500">
                Kategoria: {{ topic.categories?.name }} | Slug: {{ topic.slug }}
              </p>
            </div>

            <div class="flex items-center gap-2">
              <UButton
                color="gray"
                variant="ghost"
                icon="i-heroicons-pencil"
                @click="editTopic(topic)"
              />
              <UButton
                color="red"
                variant="ghost"
                icon="i-heroicons-trash"
                @click="confirmDelete(topic)"
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
            {{ editingTopic ? "Edytuj temat" : "Dodaj nowy temat" }}
          </h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <UFormGroup label="Tytuł" name="name" required>
            <UInput
              v-model="form.name"
              placeholder="np. Równania liniowe"
              size="lg"
            />
          </UFormGroup>

          <UFormGroup label="Slug" name="slug" required>
            <UInput
              v-model="form.slug"
              placeholder="np. rownania-liniowe"
              size="lg"
            />
          </UFormGroup>

          <UFormGroup label="Opis" name="description">
            <UTextarea
              v-model="form.description"
              placeholder="Krótki opis tematu"
              :rows="3"
            />
          </UFormGroup>

          <UFormGroup label="Kategoria" name="category_id" required>
            <USelectMenu
              v-model="form.category_id"
              :options="categories"
              placeholder="Wybierz kategorię"
              value-attribute="id"
              option-attribute="name"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
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
              {{ editingTopic ? "Zapisz zmiany" : "Utwórz temat" }}
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
          Czy na pewno chcesz usunąć temat
          <strong>{{ topicToDelete?.name }}</strong
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
import type { Topic, Category, TopicWithCategory, TopicUpdate, TopicInsert } from '~/types/database'

definePageMeta({
  layout: "admin",
  middleware: "admin",
});

const supabase = useTypedSupabaseClient();
const toast = useToast();

// State
const topics = ref<TopicWithCategory[]>([]);
const categories = ref<Category[]>([]);
const loading = ref(true);
const isCreating = ref(false);
const editingTopic = ref<Topic | null>(null);
const saving = ref(false);
const isDeleting = ref(false);
const topicToDelete = ref<Topic | null>(null);
const deleting = ref(false);

// Form
const form = ref({
  name: "",
  slug: "",
  description: "",
  category_id: "" as string,
  display_order: 1,
  is_published: true,
});

// Fetch topics
const fetchTopics = async () => {
  loading.value = true;
  try {
    const { data, error } = await supabase
      .from("topics")
      .select("*, categories(name)")
      .order("display_order", { ascending: true });

    if (error) throw error;
    topics.value = data || [];
  } catch (error) {
    console.error("Failed to fetch topics:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się pobrać tematów",
      color: "red",
    });
  } finally {
    loading.value = false;
  }
};

// Fetch categories
const fetchCategories = async () => {
  try {
    const { data, error } = await supabase
      .from("categories")
      .select("id, name")
      .order("name", { ascending: true });

    if (error) throw error;
    categories.value = data || [];
  } catch (error) {
    console.error("Failed to fetch categories:", error);
  }
};

// Edit topic
const editTopic = (topic: Topic) => {
  editingTopic.value = topic;
  form.value = {
    name: topic.name,
    slug: topic.slug,
    description: topic.description || "",
    category_id: topic.category_id,
    display_order: topic.display_order,
    is_published: topic.is_published,
  };
  isCreating.value = true;
};

// Cancel edit
const cancelEdit = () => {
  isCreating.value = false;
  editingTopic.value = null;
  form.value = {
    name: "",
    slug: "",
    description: "",
    category_id: "",
    display_order: 1,
    is_published: true,
  };
};

// Handle submit
const handleSubmit = async () => {
  saving.value = true;
  try {
    if (editingTopic.value) {
      // Update existing topic
      const updateData: TopicUpdate = form.value;
      const { error } = await supabase
        .from("topics")
        .update(updateData as never)
        .eq("id", editingTopic.value.id);

      if (error) throw error;

      toast.add({
        title: "Sukces",
        description: "Temat został zaktualizowany",
        color: "green",
      });
    } else {
      // Create new topic
      const insertData: TopicInsert = form.value;
      const { error } = await supabase.from("topics").insert(insertData as never);

      if (error) throw error;

      toast.add({
        title: "Sukces",
        description: "Temat został utworzony",
        color: "green",
      });
    }

    await fetchTopics();
    cancelEdit();
  } catch (error) {
    console.error("Failed to save topic:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się zapisać tematu",
      color: "red",
    });
  } finally {
    saving.value = false;
  }
};

// Confirm delete
const confirmDelete = (topic: Topic) => {
  topicToDelete.value = topic;
  isDeleting.value = true;
};

// Handle delete
const handleDelete = async () => {
  if (!topicToDelete.value) return;

  deleting.value = true;
  try {
    const { error } = await supabase
      .from("topics")
      .delete()
      .eq("id", topicToDelete.value.id);

    if (error) throw error;

    toast.add({
      title: "Sukces",
      description: "Temat został usunięty",
      color: "green",
    });

    await fetchTopics();
    isDeleting.value = false;
    topicToDelete.value = null;
  } catch (error) {
    console.error("Failed to delete topic:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się usunąć tematu",
      color: "red",
    });
  } finally {
    deleting.value = false;
  }
};

// Fetch on mount
onMounted(async () => {
  await fetchCategories();
  await fetchTopics();
});
</script>
