import { defineStore } from 'pinia'
import type { Test, TestWithQuestions, QuestionWithAnswers, Answer } from '~/types/database'

interface TestAnswer {
  questionId: string
  answerId: string
  answerLabel: string
}

interface TestResult {
  score: number
  totalQuestions: number
  correctAnswers: number
  incorrectAnswers: number
  answers: Record<string, {
    selected: string
    correct: string
    isCorrect: boolean
  }>
}

export const useTestStore = defineStore('test', () => {
  const supabase = useSupabaseClient()

  // State
  const currentTest = ref<TestWithQuestions | null>(null)
  const testAnswers = ref<Map<string, TestAnswer>>(new Map())
  const testStartTime = ref<Date | null>(null)
  const testResult = ref<TestResult | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Computed
  const answeredCount = computed(() => testAnswers.value.size)
  const totalQuestions = computed(() => currentTest.value?.test_questions?.length || 0)
  const progress = computed(() => {
    if (totalQuestions.value === 0) return 0
    return Math.round((answeredCount.value / totalQuestions.value) * 100)
  })

  const timeElapsed = computed(() => {
    if (!testStartTime.value) return 0
    return Math.floor((Date.now() - testStartTime.value.getTime()) / 1000)
  })

  // Actions
  async function fetchTest(testId: string) {
    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('tests')
        .select(`
          *,
          test_questions(
            *,
            question:questions(
              *,
              answers(*)
            )
          )
        `)
        .eq('id', testId)
        .eq('is_published', true)
        .single()

      if (fetchError) throw fetchError

      currentTest.value = data as TestWithQuestions
      return data
    } catch (err: any) {
      error.value = err.message
      console.error('Failed to fetch test:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  function startTest() {
    testStartTime.value = new Date()
    testAnswers.value.clear()
    testResult.value = null
  }

  function answerQuestion(questionId: string, answerId: string, answerLabel: string) {
    testAnswers.value.set(questionId, {
      questionId,
      answerId,
      answerLabel,
    })
  }

  function submitTest() {
    if (!currentTest.value) {
      error.value = 'No test loaded'
      return null
    }

    const result: TestResult = {
      score: 0,
      totalQuestions: totalQuestions.value,
      correctAnswers: 0,
      incorrectAnswers: 0,
      answers: {},
    }

    // Calculate score
    currentTest.value.test_questions?.forEach((tq: any) => {
      const userAnswer = testAnswers.value.get(tq.question.id)
      const correctAnswer = tq.question.answers.find((a: Answer) => a.is_correct)

      if (userAnswer && correctAnswer) {
        const isCorrect = userAnswer.answerId === correctAnswer.id

        result.answers[tq.question.id] = {
          selected: userAnswer.answerLabel,
          correct: correctAnswer.label,
          isCorrect,
        }

        if (isCorrect) {
          result.correctAnswers++
        } else {
          result.incorrectAnswers++
        }
      }
    })

    result.score = Math.round((result.correctAnswers / result.totalQuestions) * 100)
    testResult.value = result

    return result
  }

  function resetTest() {
    currentTest.value = null
    testAnswers.value.clear()
    testStartTime.value = null
    testResult.value = null
    error.value = null
  }

  return {
    // State
    currentTest,
    testAnswers,
    testStartTime,
    testResult,
    loading,
    error,

    // Computed
    answeredCount,
    totalQuestions,
    progress,
    timeElapsed,

    // Actions
    fetchTest,
    startTest,
    answerQuestion,
    submitTest,
    resetTest,
  }
})

