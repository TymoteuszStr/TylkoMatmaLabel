<template>
  <div>
    <!-- Page Header -->
    <div class="mb-8 flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          Bank pytań
        </h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Zarządzaj pytaniami i odpowiedziami (A, B, C, D)
        </p>
      </div>
      <UButton color="primary" icon="i-heroicons-plus" @click="openCreateModal">
        Dodaj pytanie
      </UButton>
    </div>

    <!-- Filters -->
    <UCard class="mb-4">
      <div class="flex gap-4">
        <UInput
          v-model="searchQuery"
          placeholder="Szukaj pytania..."
          icon="i-heroicons-magnifying-glass"
          class="flex-1"
        />
        <USelectMenu
          v-model="filterDifficulty"
          :options="[
            { value: null, label: 'Wszystkie poziomy' },
            { value: 'basic', label: 'Podstawowy' },
            { value: 'intermediate', label: 'Średniozaawansowany' },
            { value: 'advanced', label: 'Zaawansowany' },
          ]"
          placeholder="Poziom trudności"
          value-attribute="value"
          option-attribute="label"
          class="w-64"
        />
      </div>
    </UCard>

    <!-- Questions List -->
    <UCard>
      <ClientOnly>
        <div v-if="loading" class="py-12 text-center">
          <UIcon
            name="i-heroicons-arrow-path"
            class="animate-spin text-2xl text-gray-400"
          />
        </div>

        <div
          v-else-if="filteredQuestions.length === 0"
          class="py-12 text-center text-gray-500 dark:text-gray-400"
        >
          {{
            searchQuery
              ? "Brak wyników wyszukiwania"
              : "Brak pytań. Dodaj pierwsze pytanie."
          }}
        </div>

        <div v-else class="divide-y divide-gray-200 dark:divide-gray-700">
          <div
            v-for="(question, idx) in paginatedQuestions"
            :key="question.id"
            class="py-4"
          >
            <div class="flex items-start justify-between gap-4">
              <div class="min-w-0 flex-1">
                <div class="flex items-center gap-3">
                  <span
                    class="text-sm font-medium text-gray-500 dark:text-gray-400"
                  >
                    #{{ idx + 1 + (currentPage - 1) * itemsPerPage }}
                  </span>
                  <UBadge
                    v-if="question.difficulty_level"
                    :color="getDifficultyColor(question.difficulty_level)"
                    variant="subtle"
                  >
                    {{ getDifficultyLabel(question.difficulty_level) }}
                  </UBadge>
                  <UBadge variant="subtle" color="blue">
                    {{ question.answers?.length || 0 }} odpowiedzi
                  </UBadge>
                </div>

                <p
                  class="mt-2 text-base font-medium text-gray-900 dark:text-white"
                >
                  {{ question.content }}
                </p>

                <div
                  v-if="question.answers && question.answers.length > 0"
                  class="mt-3 grid grid-cols-1 gap-2 sm:grid-cols-2"
                >
                  <div
                    v-for="answer in question.answers"
                    :key="answer.id"
                    class="flex items-center gap-2 rounded-lg border px-3 py-2"
                    :class="
                      answer.is_correct
                        ? 'border-green-300 bg-green-50 dark:border-green-700 dark:bg-green-900/20'
                        : 'border-gray-200 bg-gray-50 dark:border-gray-700 dark:bg-gray-800'
                    "
                  >
                    <span
                      class="flex h-6 w-6 shrink-0 items-center justify-center rounded text-xs font-bold"
                      :class="
                        answer.is_correct
                          ? 'bg-green-600 text-white'
                          : 'bg-gray-200 text-gray-700 dark:bg-gray-700 dark:text-gray-300'
                      "
                    >
                      {{ answer.label }}
                    </span>
                    <span
                      class="flex-1 text-sm"
                      :class="
                        answer.is_correct
                          ? 'font-medium text-green-900 dark:text-green-100'
                          : 'text-gray-700 dark:text-gray-300'
                      "
                    >
                      {{ answer.content }}
                    </span>
                    <UIcon
                      v-if="answer.is_correct"
                      name="i-heroicons-check-circle"
                      class="h-5 w-5 text-green-600 dark:text-green-400"
                    />
                  </div>
                </div>

                <p
                  v-if="question.explanation"
                  class="mt-2 text-sm text-gray-600 dark:text-gray-400"
                >
                  <span class="font-medium">Wyjaśnienie:</span>
                  {{ question.explanation }}
                </p>

                <div
                  class="mt-2 flex items-center gap-2 text-xs text-gray-500 dark:text-gray-500"
                >
                  <span>Utworzono: {{ formatDate(question.created_at) }}</span>
                  <span v-if="question.updated_at !== question.created_at">
                    | Edytowano: {{ formatDate(question.updated_at) }}
                  </span>
                </div>
              </div>

              <div class="flex shrink-0 gap-2">
                <UButton
                  color="gray"
                  variant="ghost"
                  icon="i-heroicons-pencil"
                  @click="editQuestion(question)"
                />
                <UButton
                  color="red"
                  variant="ghost"
                  icon="i-heroicons-trash"
                  @click="confirmDelete(question)"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div
          v-if="totalPages > 1"
          class="mt-4 flex items-center justify-between border-t border-gray-200 pt-4 dark:border-gray-700"
        >
          <div class="text-sm text-gray-500 dark:text-gray-400">
            Pytania {{ (currentPage - 1) * itemsPerPage + 1 }} -
            {{
              Math.min(currentPage * itemsPerPage, filteredQuestions.length)
            }}
            z
            {{ filteredQuestions.length }}
          </div>
          <div class="flex gap-2">
            <UButton
              color="gray"
              variant="outline"
              icon="i-heroicons-chevron-left"
              :disabled="currentPage === 1"
              @click="currentPage--"
            />
            <UButton
              color="gray"
              variant="outline"
              icon="i-heroicons-chevron-right"
              :disabled="currentPage === totalPages"
              @click="currentPage++"
            />
          </div>
        </div>
      </ClientOnly>
    </UCard>

    <!-- Create/Edit Modal -->
    <UModal v-model="isModalOpen" :ui="{ width: 'max-w-3xl' }">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">
            {{ editingQuestion ? "Edytuj pytanie" : "Dodaj nowe pytanie" }}
          </h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <UFormGroup label="Treść pytania" name="content" required>
            <UTextarea
              v-model="form.content"
              placeholder="np. Rozwiąż równanie: 2x + 6 = 14"
              :rows="3"
            />
          </UFormGroup>

          <UFormGroup label="Wyjaśnienie (opcjonalne)" name="explanation">
            <UTextarea
              v-model="form.explanation"
              placeholder="Wyjaśnienie poprawnej odpowiedzi (wyświetlane po rozwiązaniu)"
              :rows="2"
            />
          </UFormGroup>

          <UFormGroup label="Poziom trudności" name="difficulty_level">
            <USelectMenu
              v-model="form.difficulty_level"
              :options="difficultyOptions"
              placeholder="Wybierz poziom"
              value-attribute="value"
              option-attribute="label"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
            />
          </UFormGroup>

          <UFormGroup label="Odpowiedzi (A, B, C, D)" required>
            <p class="mb-3 text-sm text-gray-600 dark:text-gray-400">
              Zaznacz przycisk przy poprawnej odpowiedzi
            </p>
            <div class="space-y-3">
              <div
                v-for="(answer, index) in form.answers"
                :key="index"
                class="flex items-center gap-3 rounded-lg border p-3"
                :class="
                  form.correctAnswer === answer.label
                    ? 'border-green-500 bg-green-50 dark:border-green-600 dark:bg-green-900/20'
                    : 'border-gray-200 dark:border-gray-700'
                "
              >
                <div
                  class="flex h-8 w-8 shrink-0 items-center justify-center rounded font-bold"
                  :class="
                    form.correctAnswer === answer.label
                      ? 'bg-green-600 text-white'
                      : 'bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-300'
                  "
                >
                  {{ answer.label }}
                </div>
                <UInput
                  v-model="answer.content"
                  :placeholder="`Odpowiedź ${answer.label}`"
                  class="flex-1"
                  size="lg"
                />
                <label class="flex cursor-pointer items-center gap-2">
                  <input
                    v-model="form.correctAnswer"
                    type="radio"
                    :value="answer.label"
                    class="h-5 w-5 rounded-full border-gray-300 text-green-600 focus:ring-green-500"
                  />
                  <span class="text-sm font-medium">Poprawna</span>
                </label>
              </div>
            </div>
          </UFormGroup>

          <div class="flex justify-end gap-2 pt-4">
            <UButton color="gray" variant="outline" @click="closeModal">
              Anuluj
            </UButton>
            <UButton type="submit" color="primary" :loading="saving">
              {{ editingQuestion ? "Zapisz zmiany" : "Dodaj pytanie" }}
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

        <div class="space-y-3">
          <p class="text-gray-700 dark:text-gray-300">
            Czy na pewno chcesz usunąć to pytanie?
          </p>
          <div
            class="rounded-lg border border-gray-200 bg-gray-50 p-3 dark:border-gray-700 dark:bg-gray-800"
          >
            <p class="font-medium text-gray-900 dark:text-white">
              {{ questionToDelete?.content }}
            </p>
          </div>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Ta operacja jest nieodwracalna. Pytanie zostanie usunięte ze
            wszystkich testów.
          </p>
        </div>

        <template #footer>
          <div class="flex justify-end gap-2">
            <UButton color="gray" variant="outline" @click="isDeleting = false">
              Anuluj
            </UButton>
            <UButton color="red" :loading="deleting" @click="handleDelete">
              Usuń pytanie
            </UButton>
          </div>
        </template>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import type { Question, Answer, DifficultyLevel } from "~/types/database";

definePageMeta({
  layout: "admin",
  middleware: "admin",
});

const supabase = useTypedSupabaseClient();
const toast = useToast();

// Types
interface QuestionWithAnswers extends Question {
  answers?: Answer[];
}

// State
const questions = ref<QuestionWithAnswers[]>([]);
const loading = ref(true);
const isModalOpen = ref(false);
const editingQuestion = ref<QuestionWithAnswers | null>(null);
const saving = ref(false);
const isDeleting = ref(false);
const questionToDelete = ref<QuestionWithAnswers | null>(null);
const deleting = ref(false);

// Filter & Search
const searchQuery = ref("");
const filterDifficulty = ref<DifficultyLevel | null>(null);
const currentPage = ref(1);
const itemsPerPage = 10;

// Form
const form = ref({
  content: "",
  explanation: "" as string | null,
  difficulty_level: null as DifficultyLevel | null,
  correctAnswer: "A" as "A" | "B" | "C" | "D",
  answers: [
    { label: "A" as const, content: "" },
    { label: "B" as const, content: "" },
    { label: "C" as const, content: "" },
    { label: "D" as const, content: "" },
  ],
});

const difficultyOptions = [
  { value: "basic", label: "Podstawowy" },
  { value: "intermediate", label: "Średniozaawansowany" },
  { value: "advanced", label: "Zaawansowany" },
];

// Computed
const filteredQuestions = computed(() => {
  let result = questions.value;

  // Filter by search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    result = result.filter((q) => q.content.toLowerCase().includes(query));
  }

  // Filter by difficulty
  if (filterDifficulty.value) {
    result = result.filter(
      (q) => q.difficulty_level === filterDifficulty.value,
    );
  }

  return result;
});

const totalPages = computed(() =>
  Math.ceil(filteredQuestions.value.length / itemsPerPage),
);

const paginatedQuestions = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredQuestions.value.slice(start, end);
});

// Helpers
function getDifficultyColor(level: DifficultyLevel): string {
  const colors = {
    basic: "green",
    intermediate: "yellow",
    advanced: "red",
  };
  return colors[level] || "gray";
}

function getDifficultyLabel(level: DifficultyLevel): string {
  const labels = {
    basic: "Podstawowy",
    intermediate: "Średniozaawansowany",
    advanced: "Zaawansowany",
  };
  return labels[level] || level;
}

function formatDate(date: string): string {
  return new Date(date).toLocaleDateString("pl-PL", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

// Fetch questions
async function fetchQuestions() {
  loading.value = true;
  try {
    const { data, error } = await supabase
      .from("questions")
      .select("*, answers(*)")
      .order("created_at", { ascending: false });

    if (error) throw error;
    questions.value = (data || []) as QuestionWithAnswers[];
  } catch (error) {
    console.error("Failed to fetch questions:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się pobrać pytań",
      color: "red",
    });
  } finally {
    loading.value = false;
  }
}

// Modal
function openCreateModal() {
  editingQuestion.value = null;
  resetForm();
  isModalOpen.value = true;
}

function editQuestion(question: QuestionWithAnswers) {
  editingQuestion.value = question;
  form.value = {
    content: question.content,
    explanation: question.explanation || null,
    difficulty_level: question.difficulty_level || null,
    correctAnswer:
      (question.answers?.find((a) => a.is_correct)?.label as
        | "A"
        | "B"
        | "C"
        | "D") || "A",
    answers: ["A", "B", "C", "D"].map((label) => {
      const ans = question.answers?.find((a) => a.label === label);
      return {
        label: label as "A" | "B" | "C" | "D",
        content: ans?.content ?? "",
      };
    }),
  };
  isModalOpen.value = true;
}

function closeModal() {
  isModalOpen.value = false;
  editingQuestion.value = null;
  resetForm();
}

function resetForm() {
  form.value = {
    content: "",
    explanation: null,
    difficulty_level: null,
    correctAnswer: "A",
    answers: [
      { label: "A", content: "" },
      { label: "B", content: "" },
      { label: "C", content: "" },
      { label: "D", content: "" },
    ],
  };
}

// Submit
async function handleSubmit() {
  if (!form.value.content.trim()) {
    toast.add({ title: "Podaj treść pytania", color: "red" });
    return;
  }

  const emptyAnswers = form.value.answers.filter((a) => !a.content.trim());
  if (emptyAnswers.length > 0) {
    toast.add({
      title: "Wypełnij wszystkie odpowiedzi (A, B, C, D)",
      color: "red",
    });
    return;
  }

  saving.value = true;
  try {
    if (editingQuestion.value) {
      // Update question
      const { error: qError } = await supabase
        .from("questions")
        .update({
          content: form.value.content.trim(),
          explanation: form.value.explanation?.trim() || null,
          difficulty_level: form.value.difficulty_level,
        })
        .eq("id", editingQuestion.value.id);

      if (qError) throw qError;

      // Update answers
      for (const answer of form.value.answers) {
        const existingAnswer = editingQuestion.value.answers?.find(
          (a) => a.label === answer.label,
        );
        const answerData = {
          content: answer.content.trim(),
          is_correct: answer.label === form.value.correctAnswer,
          display_order:
            answer.label === "A"
              ? 1
              : answer.label === "B"
                ? 2
                : answer.label === "C"
                  ? 3
                  : 4,
        };

        if (existingAnswer) {
          await supabase
            .from("answers")
            .update(answerData)
            .eq("id", existingAnswer.id);
        } else {
          await supabase.from("answers").insert({
            question_id: editingQuestion.value.id,
            content: answer.content.trim(),
            label: answer.label,
            is_correct: answer.label === form.value.correctAnswer,
            display_order:
              answer.label === "A"
                ? 1
                : answer.label === "B"
                  ? 2
                  : answer.label === "C"
                    ? 3
                    : 4,
          });
        }
      }

      toast.add({ title: "Pytanie zaktualizowane", color: "green" });
    } else {
      // Create new question
      const { data: questionData, error: qError } = await supabase
        .from("questions")
        .insert({
          content: form.value.content.trim(),
          explanation: form.value.explanation?.trim() || null,
          difficulty_level: form.value.difficulty_level,
          tags: [],
        })
        .select("id")
        .single();

      if (qError) throw qError;
      if (!questionData) throw new Error("Failed to create question");

      // Create answers
      const answersToInsert = form.value.answers.map((answer, idx) => ({
        question_id: questionData.id,
        content: answer.content.trim(),
        label: answer.label,
        is_correct: answer.label === form.value.correctAnswer,
        display_order: idx + 1,
      }));

      const { error: aError } = await supabase
        .from("answers")
        .insert(answersToInsert);
      if (aError) throw aError;

      toast.add({ title: "Pytanie dodane", color: "green" });
    }

    await fetchQuestions();
    closeModal();
  } catch (error) {
    console.error("Failed to save question:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się zapisać pytania",
      color: "red",
    });
  } finally {
    saving.value = false;
  }
}

// Delete
function confirmDelete(question: QuestionWithAnswers) {
  questionToDelete.value = question;
  isDeleting.value = true;
}

async function handleDelete() {
  if (!questionToDelete.value) return;

  deleting.value = true;
  try {
    const { error } = await supabase
      .from("questions")
      .delete()
      .eq("id", questionToDelete.value.id);

    if (error) throw error;

    toast.add({ title: "Pytanie usunięte", color: "green" });
    await fetchQuestions();
    isDeleting.value = false;
    questionToDelete.value = null;
  } catch (error) {
    console.error("Failed to delete question:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się usunąć pytania",
      color: "red",
    });
  } finally {
    deleting.value = false;
  }
}

// Mount
onMounted(() => {
  fetchQuestions();
});

// Reset page on filter change
watch([searchQuery, filterDifficulty], () => {
  currentPage.value = 1;
});
</script>
