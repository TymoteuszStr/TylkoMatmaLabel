<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950">
    <div class="container mx-auto px-4 py-8">
      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center py-12">
        <UIcon
          name="i-heroicons-arrow-path"
          class="animate-spin text-4xl text-primary-600"
        />
      </div>

      <!-- Test Not Started -->
      <div v-else-if="!testStarted && currentTest" class="mx-auto max-w-2xl">
        <UCard>
          <div class="space-y-6">
            <div class="text-center">
              <UIcon
                name="i-heroicons-clipboard-document-check"
                class="mx-auto text-6xl text-primary-600"
              />
              <h1 class="mt-4 text-3xl font-bold text-gray-900 dark:text-white">
                {{ currentTest.title }}
              </h1>
              <p
                v-if="currentTest.description"
                class="mt-2 text-gray-600 dark:text-gray-400"
              >
                {{ currentTest.description }}
              </p>
            </div>

            <div
              class="space-y-4 border-t border-gray-200 pt-6 dark:border-gray-800"
            >
              <div class="flex items-center justify-between">
                <span
                  class="text-sm font-medium text-gray-700 dark:text-gray-300"
                  >Liczba pytań</span
                >
                <span class="text-sm text-gray-900 dark:text-white">{{
                  totalQuestions
                }}</span>
              </div>
              <div
                v-if="currentTest.time_limit"
                class="flex items-center justify-between"
              >
                <span
                  class="text-sm font-medium text-gray-700 dark:text-gray-300"
                  >Limit czasu</span
                >
                <span class="text-sm text-gray-900 dark:text-white"
                  >{{ currentTest.time_limit }} minut</span
                >
              </div>
              <div class="flex items-center justify-between">
                <span
                  class="text-sm font-medium text-gray-700 dark:text-gray-300"
                  >Próg zaliczenia</span
                >
                <span class="text-sm text-gray-900 dark:text-white"
                  >{{ currentTest.passing_score }}%</span
                >
              </div>
            </div>

            <UButton block color="primary" size="xl" @click="handleStartTest">
              Rozpocznij test
            </UButton>
          </div>
        </UCard>
      </div>

      <!-- Test In Progress -->
      <div v-else-if="testStarted && !testResult" class="mx-auto max-w-4xl">
        <!-- Progress Bar -->
        <UCard class="mb-6">
          <div class="flex items-center justify-between gap-4">
            <div class="flex-1">
              <div class="mb-2 flex items-center justify-between text-sm">
                <span class="font-medium text-gray-700 dark:text-gray-300">
                  Postęp: {{ answeredCount }} / {{ totalQuestions }}
                </span>
                <span class="text-gray-600 dark:text-gray-400">
                  {{ progress }}%
                </span>
              </div>
              <UProgress :value="progress" color="primary" />
            </div>
            <div
              v-if="currentTest?.time_limit"
              class="flex items-center gap-2 text-gray-700 dark:text-gray-300"
            >
              <UIcon name="i-heroicons-clock" />
              <span class="font-medium">{{ formatTime(timeElapsed) }}</span>
            </div>
          </div>
        </UCard>

        <!-- Questions -->
        <div class="space-y-6">
          <UCard
            v-for="(tq, index) in currentTest?.test_questions"
            :key="tq.id"
          >
            <div class="space-y-4">
              <!-- Question Header -->
              <div class="flex items-start gap-3">
                <div
                  class="flex h-8 w-8 items-center justify-center rounded-full bg-primary-100 text-sm font-bold text-primary-700 dark:bg-primary-900 dark:text-primary-300"
                >
                  {{ index + 1 }}
                </div>
                <div class="flex-1">
                  <p class="text-lg font-medium text-gray-900 dark:text-white">
                    {{ tq.question.content }}
                  </p>
                </div>
              </div>

              <!-- Answers -->
              <div class="space-y-2 pl-11">
                <label
                  v-for="answer in tq.question.answers"
                  :key="answer.id"
                  class="flex cursor-pointer items-center gap-3 rounded-lg border border-gray-300 p-4 transition-colors hover:bg-gray-50 dark:border-gray-700 dark:hover:bg-gray-900"
                  :class="{
                    'bg-primary-50 border-primary-600 dark:bg-primary-950 dark:border-primary-400':
                      isAnswerSelected(tq.question.id, answer.id),
                  }"
                >
                  <input
                    type="radio"
                    :name="`question-${tq.question.id}`"
                    :value="answer.id"
                    :checked="isAnswerSelected(tq.question.id, answer.id)"
                    @change="
                      handleAnswerSelect(
                        tq.question.id,
                        answer.id,
                        answer.label,
                      )
                    "
                    class="h-4 w-4 text-primary-600 focus:ring-primary-500"
                  />
                  <span class="font-medium text-gray-700 dark:text-gray-300"
                    >{{ answer.label }}.</span
                  >
                  <span class="text-gray-900 dark:text-white">{{
                    answer.content
                  }}</span>
                </label>
              </div>
            </div>
          </UCard>
        </div>

        <!-- Submit Button -->
        <UCard class="mt-6 sticky bottom-4">
          <div class="flex items-center justify-between gap-4">
            <div class="text-sm text-gray-600 dark:text-gray-400">
              <span v-if="answeredCount < totalQuestions">
                Odpowiedz na wszystkie pytania aby zakończyć test
              </span>
              <span
                v-else
                class="font-medium text-green-600 dark:text-green-400"
              >
                Wszystkie pytania zostały udzielone!
              </span>
            </div>
            <UButton
              color="primary"
              size="lg"
              :disabled="answeredCount < totalQuestions"
              @click="handleSubmitTest"
            >
              Zakończ test
            </UButton>
          </div>
        </UCard>
      </div>

      <!-- Test Results -->
      <div v-else-if="testResult" class="mx-auto max-w-2xl">
        <UCard>
          <div class="space-y-6">
            <!-- Score Display -->
            <div class="text-center">
              <div
                class="mx-auto flex h-32 w-32 items-center justify-center rounded-full"
                :class="
                  testResult.score >= (currentTest?.passing_score || 60)
                    ? 'bg-green-100 dark:bg-green-900'
                    : 'bg-red-100 dark:bg-red-900'
                "
              >
                <div>
                  <div
                    class="text-4xl font-bold"
                    :class="
                      testResult.score >= (currentTest?.passing_score || 60)
                        ? 'text-green-700 dark:text-green-300'
                        : 'text-red-700 dark:text-red-300'
                    "
                  >
                    {{ testResult.score }}%
                  </div>
                  <div
                    class="text-sm"
                    :class="
                      testResult.score >= (currentTest?.passing_score || 60)
                        ? 'text-green-600 dark:text-green-400'
                        : 'text-red-600 dark:text-red-400'
                    "
                  >
                    {{
                      testResult.score >= (currentTest?.passing_score || 60)
                        ? "Zaliczono"
                        : "Niezaliczono"
                    }}
                  </div>
                </div>
              </div>
              <h2 class="mt-6 text-2xl font-bold text-gray-900 dark:text-white">
                Test zakończony!
              </h2>
            </div>

            <!-- Stats -->
            <div
              class="space-y-3 border-t border-gray-200 pt-6 dark:border-gray-800"
            >
              <div class="flex items-center justify-between">
                <span
                  class="text-sm font-medium text-gray-700 dark:text-gray-300"
                  >Poprawne odpowiedzi</span
                >
                <span
                  class="text-sm font-bold text-green-600 dark:text-green-400"
                >
                  {{ testResult.correctAnswers }} /
                  {{ testResult.totalQuestions }}
                </span>
              </div>
              <div class="flex items-center justify-between">
                <span
                  class="text-sm font-medium text-gray-700 dark:text-gray-300"
                  >Niepoprawne odpowiedzi</span
                >
                <span class="text-sm font-bold text-red-600 dark:text-red-400">
                  {{ testResult.incorrectAnswers }}
                </span>
              </div>
              <div class="flex items-center justify-between">
                <span
                  class="text-sm font-medium text-gray-700 dark:text-gray-300"
                  >Czas trwania</span
                >
                <span class="text-sm text-gray-900 dark:text-white">
                  {{ formatTime(timeElapsed) }}
                </span>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex gap-3 flex-col">
              <UButton block variant="outline" @click="handleRetakeTest">
                Powtórz test
              </UButton>
              <UButton block color="primary" @click="handleBackToTopic">
                Powrót do tematu
              </UButton>
            </div>
          </div>
        </UCard>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: "test",
  middleware: "auth",
});

const route = useRoute();
const router = useRouter();
const testStore = useTestStore();
const { user } = useAuth();

const testId = route.params.id as string;
const levelSlug = route.params.level as string;
const categorySlug = route.params.category as string;
const topicSlug = route.params.topic as string;

const {
  currentTest,
  testResult,
  answeredCount,
  totalQuestions,
  progress,
  timeElapsed,
} = storeToRefs(testStore);
const loading = ref(true);
const testStarted = ref(false);

onMounted(async () => {
  await testStore.fetchTest(testId);
  loading.value = false;
});

function handleStartTest() {
  testStore.startTest();
  testStarted.value = true;
}

function isAnswerSelected(questionId: string, answerId: string) {
  const answer = testStore.testAnswers.get(questionId);
  return answer?.answerId === answerId;
}

function handleAnswerSelect(
  questionId: string,
  answerId: string,
  answerLabel: string,
) {
  testStore.answerQuestion(questionId, answerId, answerLabel);
}

function handleSubmitTest() {
  testStore.submitTest();

  // Save test attempt if user is logged in
  if (user.value) {
    testStore.saveTestAttempt(testId, user.value.sub);
  }
}

function handleRetakeTest() {
  testStore.resetTest();
  testStarted.value = false;
  loading.value = true;
  testStore.fetchTest(testId).then(() => {
    loading.value = false;
  });
}

function handleBackToTopic() {
  router.push(`/${levelSlug}/${categorySlug}/${topicSlug}`);
}

function formatTime(seconds: number) {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, "0")}`;
}

onBeforeUnmount(() => {
  // Cleanup when leaving the page
  if (testStarted.value && !testResult.value) {
    // Warn user if they're leaving mid-test
    // This is handled by the browser's beforeunload event
  }
});
</script>
