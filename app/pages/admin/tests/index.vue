<template>
  <div>
    <!-- Page Header -->
    <div class="mb-8 flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          Testy
        </h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Zarządzaj testami, pytaniami i odpowiedziami
        </p>
      </div>
      <UButton
        color="primary"
        icon="i-heroicons-plus"
        @click="openCreateModal"
      >
        Dodaj test
      </UButton>
    </div>

    <!-- Tests List -->
    <UCard>
      <ClientOnly>
        <div v-if="loading" class="py-12 text-center">
          <UIcon
            name="i-heroicons-arrow-path"
            class="animate-spin text-2xl text-gray-400"
          />
        </div>

        <div
          v-else-if="tests.length === 0"
          class="py-12 text-center text-gray-500 dark:text-gray-400"
        >
          Brak testów. Dodaj pierwszy test.
        </div>

        <div v-else class="divide-y divide-gray-200 dark:divide-gray-700">
          <div
            v-for="test in tests"
            :key="test.id"
            class="py-4"
          >
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <div class="flex items-center gap-3">
                  <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
                    {{ test.title }}
                  </h3>
                  <UBadge
                    :color="test.is_published ? 'green' : 'gray'"
                    variant="subtle"
                  >
                    {{ test.is_published ? "Opublikowany" : "Szkic" }}
                  </UBadge>
                  <UBadge variant="subtle" color="primary">
                    {{ getQuestionCount(test) }} pytań
                  </UBadge>
                </div>
                <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
                  {{ test.description || "Brak opisu" }}
                </p>
                <p class="mt-1 text-xs text-gray-500 dark:text-gray-500">
                  <span v-if="test.topics">
                    Temat: {{ test.topics.name }}
                    <span v-if="test.topics.categories"> | {{ test.topics.categories.name }}</span>
                  </span>
                  <span v-else-if="test.categories">
                    Kategoria: {{ test.categories.name }}
                  </span>
                  <span v-else>—</span>
                  <span v-if="test.time_limit"> | Limit: {{ test.time_limit }} min</span>
                  <span> | Próg: {{ test.passing_score }}%</span>
                </p>
              </div>

              <div class="flex items-center gap-2">
                <UButton
                  color="gray"
                  variant="ghost"
                  icon="i-heroicons-pencil"
                  @click="editTest(test)"
                />
                <UDropdown
                  :items="[
                    [
                      {
                        label: 'Dodaj nowe pytanie',
                        icon: 'i-heroicons-plus-circle',
                        click: () => openAddQuestion(test),
                      },
                      {
                        label: 'Wybierz z banku pytań',
                        icon: 'i-heroicons-magnifying-glass',
                        click: () => openSelectQuestion(test),
                      },
                    ],
                  ]"
                >
                  <UButton
                    color="primary"
                    variant="ghost"
                    icon="i-heroicons-plus"
                    title="Dodaj pytanie"
                  />
                </UDropdown>
                <UButton
                  color="gray"
                  variant="ghost"
                  icon="i-heroicons-chevron-down"
                  :class="{ 'rotate-180': expandedTestId === test.id }"
                  @click="toggleExpandTest(test.id)"
                />
                <UButton
                  color="red"
                  variant="ghost"
                  icon="i-heroicons-trash"
                  @click="confirmDelete(test)"
                />
              </div>
            </div>

            <!-- Expanded: Questions list -->
            <div
              v-if="expandedTestId === test.id && test.test_questions?.length"
              class="mt-4 rounded-lg border border-gray-200 bg-gray-50 p-4 dark:border-gray-700 dark:bg-gray-900/50"
            >
              <h4 class="mb-3 text-sm font-medium text-gray-700 dark:text-gray-300">
                Pytania w teście
              </h4>
              <div class="space-y-3">
                <div
                  v-for="(tq, idx) in test.test_questions"
                  :key="tq.id"
                  class="flex items-start justify-between gap-4 rounded-lg border border-gray-200 bg-white p-3 dark:border-gray-700 dark:bg-gray-800"
                >
                  <div class="min-w-0 flex-1">
                    <p class="font-medium text-gray-900 dark:text-white">
                      {{ idx + 1 }}. {{ tq.questions?.content }}
                    </p>
                    <div class="mt-2 flex flex-wrap gap-2">
                      <span
                        v-for="ans in tq.questions?.answers"
                        :key="ans.id"
                        class="text-xs"
                        :class="ans.is_correct ? 'text-green-600 dark:text-green-400 font-medium' : 'text-gray-500 dark:text-gray-400'"
                      >
                        {{ ans.label }}: {{ ans.content }}
                        <span v-if="ans.is_correct">✓</span>
                      </span>
                    </div>
                  </div>
                  <div class="flex shrink-0 gap-1">
                    <UButton
                      size="xs"
                      variant="ghost"
                      icon="i-heroicons-pencil"
                      @click="editQuestion(test, tq.questions as Question & { answers: Answer[] })"
                    />
                    <UButton
                      size="xs"
                      variant="ghost"
                      color="red"
                      icon="i-heroicons-trash"
                      @click="removeQuestionFromTest(test, tq)"
                    />
                  </div>
                </div>
              </div>
            </div>
            <div
              v-else-if="expandedTestId === test.id && (!test.test_questions || test.test_questions.length === 0)"
              class="mt-4 rounded-lg border border-dashed border-gray-300 p-4 text-center text-gray-500 dark:border-gray-600 dark:text-gray-400"
            >
              Brak pytań. Kliknij „+” aby dodać pierwsze pytanie.
            </div>
          </div>
        </div>
      </ClientOnly>
    </UCard>

    <!-- Create/Edit Test Modal -->
    <UModal v-model="isTestModalOpen" :ui="{ width: 'max-w-2xl' }">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">
            {{ editingTest ? "Edytuj test" : "Dodaj nowy test" }}
          </h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleTestSubmit">
          <UFormGroup label="Poziom edukacji" name="level_id">
            <USelectMenu
              v-model="form.level_id"
              :options="levelOptions"
              placeholder="Wybierz poziom"
              value-attribute="id"
              option-attribute="name"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
              @update:model-value="onLevelChange"
            />
          </UFormGroup>

          <UFormGroup label="Kategoria" name="category_id">
            <USelectMenu
              v-model="form.category_id"
              :options="categoryOptions"
              placeholder="Wybierz kategorię"
              value-attribute="id"
              option-attribute="name"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
              :disabled="!form.level_id"
              @update:model-value="onCategoryChange"
            />
          </UFormGroup>

          <UFormGroup label="Temat" name="topic_id">
            <USelectMenu
              v-model="form.topic_id"
              :options="topicOptions"
              placeholder="Wybierz temat (opcjonalnie)"
              value-attribute="id"
              option-attribute="name"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
              :disabled="!form.category_id"
            />
          </UFormGroup>

          <UFormGroup label="Tytuł testu" name="title" required>
            <UInput
              v-model="form.title"
              placeholder="np. Test: Równania liniowe"
              size="lg"
            />
          </UFormGroup>

          <UFormGroup label="Opis" name="description">
            <UTextarea
              v-model="form.description"
              placeholder="Opis testu dla uczniów"
              :rows="3"
            />
          </UFormGroup>

          <div class="grid grid-cols-2 gap-4">
            <UFormGroup label="Limit czasu (min)" name="time_limit">
              <UInput
                v-model.number="form.time_limit"
                type="number"
                placeholder="np. 15"
                min="0"
              />
            </UFormGroup>
            <UFormGroup label="Próg zdania (%)" name="passing_score" required>
              <UInput
                v-model.number="form.passing_score"
                type="number"
                placeholder="70"
                min="0"
                max="100"
              />
            </UFormGroup>
          </div>

          <div class="space-y-2">
            <UFormGroup label="Opcje">
              <div class="space-y-2">
                <div class="flex items-center gap-2">
                  <UToggle v-model="form.is_published" />
                  <span class="text-sm">Opublikowany</span>
                </div>
                <div class="flex items-center gap-2">
                  <UToggle v-model="form.show_correct_answers" />
                  <span class="text-sm">Pokaż poprawne odpowiedzi po teście</span>
                </div>
                <div class="flex items-center gap-2">
                  <UToggle v-model="form.randomize_questions" />
                  <span class="text-sm">Losowa kolejność pytań</span>
                </div>
                <div class="flex items-center gap-2">
                  <UToggle v-model="form.randomize_answers" />
                  <span class="text-sm">Losowa kolejność odpowiedzi</span>
                </div>
              </div>
            </UFormGroup>
          </div>

          <div class="flex justify-end gap-2">
            <UButton color="gray" variant="outline" @click="closeTestModal">
              Anuluj
            </UButton>
            <UButton type="submit" color="primary" :loading="saving">
              {{ editingTest ? "Zapisz zmiany" : "Utwórz test" }}
            </UButton>
          </div>
        </form>
      </UCard>
    </UModal>

    <!-- Add/Edit Question Modal -->
    <UModal v-model="isQuestionModalOpen" :ui="{ width: 'max-w-2xl' }">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">
            {{ editingQuestion ? "Edytuj pytanie" : "Dodaj pytanie do testu" }}
          </h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleQuestionSubmit">
          <UFormGroup label="Treść pytania" name="content" required>
            <UTextarea
              v-model="questionForm.content"
              placeholder="np. Rozwiąż równanie: 2x + 6 = 14"
              :rows="3"
            />
          </UFormGroup>

          <UFormGroup label="Wyjaśnienie (po udzieleniu odpowiedzi)" name="explanation">
            <UTextarea
              v-model="questionForm.explanation"
              placeholder="Opcjonalne wyjaśnienie poprawnej odpowiedzi"
              :rows="2"
            />
          </UFormGroup>

          <UFormGroup label="Poziom trudności" name="difficulty_level">
            <USelectMenu
              v-model="questionForm.difficulty_level"
              :options="difficultyOptions"
              placeholder="Wybierz poziom"
              value-attribute="value"
              option-attribute="label"
              :ui-menu="{ option: { base: 'cursor-pointer' } }"
            />
          </UFormGroup>

          <UFormGroup label="Odpowiedzi" required>
            <p class="mb-2 text-sm text-gray-500 dark:text-gray-400">
              Zaznacz prawidłową odpowiedź
            </p>
            <div class="space-y-3">
              <div
                v-for="(answer, index) in questionForm.answers"
                :key="index"
                class="flex items-center gap-3 rounded-lg border border-gray-200 p-3 dark:border-gray-700"
              >
                <div class="flex w-8 shrink-0 items-center justify-center rounded bg-primary-100 font-bold text-primary-700 dark:bg-primary-900 dark:text-primary-300">
                  {{ answer.label }}
                </div>
                <UInput
                  v-model="answer.content"
                  :placeholder="`Odpowiedź ${answer.label}`"
                  class="flex-1"
                />
                <label class="flex cursor-pointer items-center gap-2">
                  <input
                    v-model="questionForm.correctAnswer"
                    type="radio"
                    :value="answer.label"
                    class="rounded-full border-gray-300 text-primary-600 focus:ring-primary-500"
                  />
                  <span class="text-sm">Poprawna</span>
                </label>
              </div>
            </div>
          </UFormGroup>

          <div class="flex justify-end gap-2">
            <UButton color="gray" variant="outline" @click="closeQuestionModal">
              Anuluj
            </UButton>
            <UButton type="submit" color="primary" :loading="savingQuestion">
              {{ editingQuestion ? "Zapisz pytanie" : "Dodaj pytanie" }}
            </UButton>
          </div>
        </form>
      </UCard>
    </UModal>

    <!-- Select Existing Question Modal -->
    <UModal v-model="isSelectQuestionModalOpen" :ui="{ width: 'max-w-4xl' }">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">
            Wybierz pytanie z banku pytań
          </h3>
        </template>

        <div class="space-y-4">
          <!-- Search -->
          <UInput
            v-model="questionSearch"
            placeholder="Szukaj pytania..."
            icon="i-heroicons-magnifying-glass"
            size="lg"
          />

          <!-- Questions List -->
          <div v-if="loadingAvailableQuestions" class="py-12 text-center">
            <UIcon
              name="i-heroicons-arrow-path"
              class="animate-spin text-2xl text-gray-400"
            />
          </div>

          <div
            v-else-if="filteredAvailableQuestions.length === 0"
            class="py-12 text-center text-gray-500 dark:text-gray-400"
          >
            {{ questionSearch ? 'Brak wyników wyszukiwania' : 'Wszystkie pytania są już w tym teście' }}
          </div>

          <div v-else class="max-h-96 space-y-3 overflow-y-auto">
            <div
              v-for="question in filteredAvailableQuestions"
              :key="question.id"
              class="cursor-pointer rounded-lg border p-4 transition-colors hover:border-primary-500 hover:bg-primary-50 dark:hover:bg-primary-950"
              :class="
                selectedQuestionToAdd?.id === question.id
                  ? 'border-primary-500 bg-primary-50 dark:bg-primary-950'
                  : 'border-gray-200 dark:border-gray-700'
              "
              @click="selectedQuestionToAdd = question"
            >
              <div class="flex items-start justify-between gap-4">
                <div class="flex-1">
                  <div class="mb-2 flex items-center gap-2">
                    <UBadge
                      v-if="question.difficulty_level"
                      :color="
                        question.difficulty_level === 'basic'
                          ? 'green'
                          : question.difficulty_level === 'intermediate'
                            ? 'yellow'
                            : 'red'
                      "
                      variant="subtle"
                      size="xs"
                    >
                      {{
                        question.difficulty_level === 'basic'
                          ? 'Podstawowy'
                          : question.difficulty_level === 'intermediate'
                            ? 'Średniozaawansowany'
                            : 'Zaawansowany'
                      }}
                    </UBadge>
                  </div>
                  <p class="font-medium text-gray-900 dark:text-white">
                    {{ question.content }}
                  </p>
                  <div
                    v-if="question.answers && question.answers.length > 0"
                    class="mt-2 flex flex-wrap gap-2"
                  >
                    <span
                      v-for="ans in question.answers"
                      :key="ans.id"
                      class="text-xs"
                      :class="
                        ans.is_correct
                          ? 'font-medium text-green-600 dark:text-green-400'
                          : 'text-gray-500 dark:text-gray-400'
                      "
                    >
                      {{ ans.label }}: {{ ans.content }}
                      <span v-if="ans.is_correct">✓</span>
                    </span>
                  </div>
                </div>
                <UIcon
                  v-if="selectedQuestionToAdd?.id === question.id"
                  name="i-heroicons-check-circle"
                  class="h-6 w-6 shrink-0 text-primary-600"
                />
              </div>
            </div>
          </div>
        </div>

        <template #footer>
          <div class="flex justify-end gap-2">
            <UButton color="gray" variant="outline" @click="closeSelectQuestionModal">
              Anuluj
            </UButton>
            <UButton
              color="primary"
              :disabled="!selectedQuestionToAdd"
              :loading="addingExistingQuestion"
              @click="addExistingQuestionToTest"
            >
              Dodaj do testu
            </UButton>
          </div>
        </template>
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
          Czy na pewno chcesz usunąć test
          <strong>{{ testToDelete?.title }}</strong>?
          Wszystkie powiązania z pytaniami zostaną usunięte. Ta operacja jest nieodwracalna.
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
  Test,
  Question,
  Answer,
  TestQuestion,
  Topic,
  Category,
  EducationLevel,
} from "~/types/database";
import type { DifficultyLevel } from "~/types/database";

definePageMeta({
  layout: "admin",
  middleware: "admin",
});

const supabase = useTypedSupabaseClient();
const toast = useToast();

// Types for API responses
interface TestWithRelations extends Test {
  topics?: Topic & { categories?: { name: string } };
  categories?: Category;
  test_questions?: Array<
    TestQuestion & {
      questions: Question & { answers: Answer[] };
    }
  >;
}

// State
const tests = ref<TestWithRelations[]>([]);
const levels = ref<EducationLevel[]>([]);
const categories = ref<Category[]>([]);
const topics = ref<Topic[]>([]);
const loading = ref(true);
const isTestModalOpen = ref(false);
const editingTest = ref<Test | null>(null);
const saving = ref(false);
const isDeleting = ref(false);
const testToDelete = ref<Test | null>(null);
const deleting = ref(false);

// Question modal state
const isQuestionModalOpen = ref(false);
const testForQuestion = ref<Test | null>(null);
const editingQuestion = ref<(Question & { answers: Answer[] }) | null>(null);
const savingQuestion = ref(false);
const expandedTestId = ref<string | null>(null);

// Select existing question modal state
const isSelectQuestionModalOpen = ref(false);
const testForSelectQuestion = ref<Test | null>(null);
const availableQuestions = ref<(Question & { answers: Answer[] })[]>([]);
const loadingAvailableQuestions = ref(false);
const questionSearch = ref('');
const selectedQuestionToAdd = ref<(Question & { answers: Answer[] }) | null>(null);
const addingExistingQuestion = ref(false);

function toggleExpandTest(testId: string) {
  expandedTestId.value = expandedTestId.value === testId ? null : testId;
}

// Form
const form = ref({
  level_id: "" as string,
  category_id: "" as string,
  topic_id: "" as string | null,
  title: "",
  description: "" as string | null,
  time_limit: null as number | null,
  passing_score: 70,
  is_published: false,
  show_correct_answers: true,
  randomize_questions: false,
  randomize_answers: false,
});

const questionForm = ref({
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

// Computed options
const levelOptions = computed(() => levels.value);
const categoryOptions = computed(() =>
  categories.value.filter((c) => c.education_level_id === form.value.level_id)
);
const topicOptions = computed(() =>
  topics.value.filter((t) => t.category_id === form.value.category_id)
);

// Computed for filtered available questions
const filteredAvailableQuestions = computed(() => {
  if (!questionSearch.value) return availableQuestions.value;
  
  const search = questionSearch.value.toLowerCase();
  return availableQuestions.value.filter((q) =>
    q.content.toLowerCase().includes(search)
  );
});

// Helpers
function getQuestionCount(test: TestWithRelations): number {
  return test.test_questions?.length ?? 0;
}

// Fetch data
async function fetchTests() {
  loading.value = true;
  try {
    const { data, error } = await supabase
      .from("tests")
      .select(
        `
        *,
        topics (
          name,
          categories (name)
        ),
        categories (name),
        test_questions (
          id,
          display_order,
          points,
          questions (
            id,
            content,
            explanation,
            difficulty_level,
            answers (*)
          )
        )
      `
      )
      .order("created_at", { ascending: false });

    if (error) throw error;
    tests.value = (data || []) as TestWithRelations[];
  } catch (error) {
    console.error("Failed to fetch tests:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się pobrać testów",
      color: "red",
    });
  } finally {
    loading.value = false;
  }
}

async function fetchLevels() {
  const { data } = await supabase
    .from("education_levels")
    .select("*")
    .order("display_order", { ascending: true });
  levels.value = data || [];
}

async function fetchCategories() {
  const { data } = await supabase
    .from("categories")
    .select("*")
    .order("display_order", { ascending: true });
  categories.value = data || [];
}

async function fetchTopics() {
  const { data } = await supabase
    .from("topics")
    .select("*")
    .order("display_order", { ascending: true });
  topics.value = data || [];
}

// Level/Category change handlers
function onLevelChange() {
  form.value.category_id = "";
  form.value.topic_id = null;
}

function onCategoryChange() {
  form.value.topic_id = null;
}

// Test modal
function openCreateModal() {
  editingTest.value = null;
  resetTestForm();
  isTestModalOpen.value = true;
}

function editTest(test: Test) {
  editingTest.value = test;
  form.value = {
    level_id: "",
    category_id: "",
    topic_id: null,
    title: test.title,
    description: test.description || null,
    time_limit: test.time_limit,
    passing_score: test.passing_score,
    is_published: test.is_published,
    show_correct_answers: test.show_correct_answers,
    randomize_questions: test.randomize_questions,
    randomize_answers: test.randomize_answers,
  };

  // Set level/category/topic from test
  if (test.topic_id) {
    const topic = topics.value.find((t) => t.id === test.topic_id);
    if (topic) {
      const category = categories.value.find((c) => c.id === topic.category_id);
      if (category) {
        form.value.level_id = category.education_level_id;
        form.value.category_id = category.id;
        form.value.topic_id = topic.id;
      }
    }
  } else if (test.category_id) {
    const category = categories.value.find((c) => c.id === test.category_id);
    if (category) {
      form.value.level_id = category.education_level_id;
      form.value.category_id = category.id;
    }
  }

  isTestModalOpen.value = true;
}

function closeTestModal() {
  isTestModalOpen.value = false;
  editingTest.value = null;
  resetTestForm();
}

function resetTestForm() {
  form.value = {
    level_id: "",
    category_id: "",
    topic_id: null,
    title: "",
    description: null,
    time_limit: null,
    passing_score: 70,
    is_published: false,
    show_correct_answers: true,
    randomize_questions: false,
    randomize_answers: false,
  };
}

async function handleTestSubmit() {
  if (!form.value.title.trim()) {
    toast.add({ title: "Podaj tytuł testu", color: "red" });
    return;
  }

  if (!form.value.topic_id && !form.value.category_id) {
    toast.add({
      title: "Wybierz temat lub kategorię",
      description: "Test musi być przypisany do tematu lub kategorii",
      color: "red",
    });
    return;
  }

  saving.value = true;
  try {
    const testData = {
      topic_id: form.value.topic_id || null,
      category_id: form.value.topic_id ? null : form.value.category_id,
      title: form.value.title.trim(),
      description: form.value.description?.trim() || null,
      time_limit: form.value.time_limit,
      passing_score: form.value.passing_score,
      is_published: form.value.is_published,
      show_correct_answers: form.value.show_correct_answers,
      randomize_questions: form.value.randomize_questions,
      randomize_answers: form.value.randomize_answers,
    };

    if (editingTest.value) {
      const { error } = await supabase
        .from("tests")
        .update(testData)
        .eq("id", editingTest.value.id);

      if (error) throw error;
      toast.add({ title: "Test zaktualizowany", color: "green" });
    } else {
      const { error } = await supabase.from("tests").insert(testData);

      if (error) throw error;
      toast.add({ title: "Test utworzony", color: "green" });
    }

    await fetchTests();
    closeTestModal();
  } catch (error) {
    console.error("Failed to save test:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się zapisać testu",
      color: "red",
    });
  } finally {
    saving.value = false;
  }
}

// Question modal
function openAddQuestion(test: Test) {
  testForQuestion.value = test;
  editingQuestion.value = null;
  resetQuestionForm();
  isQuestionModalOpen.value = true;
}

function editQuestion(test: Test, questionWithAnswers: Question & { answers: Answer[] }) {
  testForQuestion.value = test;
  editingQuestion.value = questionWithAnswers;
  questionForm.value = {
    content: questionWithAnswers.content,
    explanation: questionWithAnswers.explanation || null,
    difficulty_level: questionWithAnswers.difficulty_level || null,
    correctAnswer:
      (questionWithAnswers.answers.find((a) => a.is_correct)?.label as "A" | "B" | "C" | "D") ||
      "A",
    answers: ["A", "B", "C", "D"].map((label) => {
      const ans = questionWithAnswers.answers.find((a) => a.label === label);
      return {
        label: label as "A" | "B" | "C" | "D",
        content: ans?.content ?? "",
      };
    }),
  };
  isQuestionModalOpen.value = true;
}

function closeQuestionModal() {
  isQuestionModalOpen.value = false;
  testForQuestion.value = null;
  editingQuestion.value = null;
  resetQuestionForm();
}

function resetQuestionForm() {
  questionForm.value = {
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

// Select existing question modal
async function openSelectQuestion(test: Test) {
  testForSelectQuestion.value = test;
  selectedQuestionToAdd.value = null;
  questionSearch.value = '';
  isSelectQuestionModalOpen.value = true;
  
  // Fetch questions that are NOT already in this test
  await fetchAvailableQuestions(test.id);
}

async function fetchAvailableQuestions(testId: string) {
  loadingAvailableQuestions.value = true;
  try {
    // Get all questions with answers
    const { data: allQuestions, error: qError } = await supabase
      .from('questions')
      .select('*, answers(*)')
      .order('created_at', { ascending: false });

    if (qError) throw qError;

    // Get questions already in this test
    const { data: testQuestions, error: tqError } = await supabase
      .from('test_questions')
      .select('question_id')
      .eq('test_id', testId);

    if (tqError) throw tqError;

    const usedQuestionIds = new Set(testQuestions?.map((tq) => tq.question_id) || []);
    
    // Filter out questions already in test
    availableQuestions.value = (allQuestions || []).filter(
      (q) => !usedQuestionIds.has(q.id)
    ) as (Question & { answers: Answer[] })[];
  } catch (error) {
    console.error('Failed to fetch available questions:', error);
    toast.add({
      title: 'Błąd',
      description: 'Nie udało się pobrać pytań',
      color: 'red',
    });
  } finally {
    loadingAvailableQuestions.value = false;
  }
}

function closeSelectQuestionModal() {
  isSelectQuestionModalOpen.value = false;
  testForSelectQuestion.value = null;
  selectedQuestionToAdd.value = null;
  questionSearch.value = '';
  availableQuestions.value = [];
}

async function addExistingQuestionToTest() {
  if (!selectedQuestionToAdd.value || !testForSelectQuestion.value) return;

  addingExistingQuestion.value = true;
  try {
    // Get max display_order for this test
    const maxOrder = (tests.value
      .find((t) => t.id === testForSelectQuestion.value?.id)
      ?.test_questions?.length ?? 0);

    // Add question to test
    const { error } = await supabase.from('test_questions').insert({
      test_id: testForSelectQuestion.value.id,
      question_id: selectedQuestionToAdd.value.id,
      display_order: maxOrder + 1,
      points: 1,
    });

    if (error) throw error;

    toast.add({ 
      title: 'Pytanie dodane do testu', 
      color: 'green' 
    });

    await fetchTests();
    closeSelectQuestionModal();
  } catch (error) {
    console.error('Failed to add question to test:', error);
    toast.add({
      title: 'Błąd',
      description: 'Nie udało się dodać pytania do testu',
      color: 'red',
    });
  } finally {
    addingExistingQuestion.value = false;
  }
}

async function removeQuestionFromTest(
  test: Test,
  tq: TestQuestion & { questions: Question & { answers: Answer[] } }
) {
  if (!confirm("Usunąć to pytanie z testu? Pytanie pozostanie w bazie.")) return;

  try {
    const { error } = await supabase
      .from("test_questions")
      .delete()
      .eq("id", tq.id);

    if (error) throw error;
    toast.add({ title: "Pytanie usunięte z testu", color: "green" });
    await fetchTests();
  } catch (error) {
    console.error("Failed to remove question:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się usunąć pytania z testu",
      color: "red",
    });
  }
}

async function handleQuestionSubmit() {
  if (!questionForm.value.content.trim()) {
    toast.add({ title: "Podaj treść pytania", color: "red" });
    return;
  }

  const emptyAnswers = questionForm.value.answers.filter((a) => !a.content.trim());
  if (emptyAnswers.length > 0) {
    toast.add({
      title: "Wypełnij wszystkie odpowiedzi (A, B, C, D)",
      color: "red",
    });
    return;
  }

  if (!testForQuestion.value) return;

  savingQuestion.value = true;
  try {
    if (editingQuestion.value) {
      // Update question
      const { error: qError } = await supabase
        .from("questions")
        .update({
          content: questionForm.value.content.trim(),
          explanation: questionForm.value.explanation?.trim() || null,
          difficulty_level: questionForm.value.difficulty_level,
        })
        .eq("id", editingQuestion.value.id);

      if (qError) throw qError;

      // Update answers
      for (const answer of questionForm.value.answers) {
        const existingAnswer = editingQuestion.value.answers.find(
          (a) => a.label === answer.label
        );
        const answerData = {
          content: answer.content.trim(),
          is_correct: answer.label === questionForm.value.correctAnswer,
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
            is_correct: answer.label === questionForm.value.correctAnswer,
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
          content: questionForm.value.content.trim(),
          explanation: questionForm.value.explanation?.trim() || null,
          difficulty_level: questionForm.value.difficulty_level,
          tags: [],
        })
        .select("id")
        .single();

      if (qError) throw qError;
      if (!questionData) throw new Error("Failed to create question");

      // Create answers
      const answersToInsert = questionForm.value.answers.map((answer, idx) => ({
        question_id: questionData.id,
        content: answer.content.trim(),
        label: answer.label,
        is_correct: answer.label === questionForm.value.correctAnswer,
        display_order: idx + 1,
      }));

      const { error: aError } = await supabase.from("answers").insert(answersToInsert);
      if (aError) throw aError;

      // Link to test
      const maxOrder = (tests.value
        .find((t) => t.id === testForQuestion.value?.id)
        ?.test_questions?.length ?? 0);

      const { error: tqError } = await supabase.from("test_questions").insert({
        test_id: testForQuestion.value.id,
        question_id: questionData.id,
        display_order: maxOrder + 1,
        points: 1,
      });

      if (tqError) throw tqError;

      toast.add({ title: "Pytanie dodane do testu", color: "green" });
    }

    await fetchTests();
    closeQuestionModal();
  } catch (error) {
    console.error("Failed to save question:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się zapisać pytania",
      color: "red",
    });
  } finally {
    savingQuestion.value = false;
  }
}

// Delete
function confirmDelete(test: Test) {
  testToDelete.value = test;
  isDeleting.value = true;
}

async function handleDelete() {
  if (!testToDelete.value) return;

  deleting.value = true;
  try {
    const { error } = await supabase
      .from("tests")
      .delete()
      .eq("id", testToDelete.value.id);

    if (error) throw error;

    toast.add({ title: "Test usunięty", color: "green" });
    await fetchTests();
    isDeleting.value = false;
    testToDelete.value = null;
  } catch (error) {
    console.error("Failed to delete test:", error);
    toast.add({
      title: "Błąd",
      description: "Nie udało się usunąć testu",
      color: "red",
    });
  } finally {
    deleting.value = false;
  }
}

// Mount
onMounted(async () => {
  await Promise.all([fetchLevels(), fetchCategories(), fetchTopics()]);
  await fetchTests();
});
</script>
