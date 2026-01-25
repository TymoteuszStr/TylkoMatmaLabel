<template>
  <div class="flex min-h-screen items-center justify-center bg-gray-50 px-4 py-12 dark:bg-gray-950 sm:px-6 lg:px-8">
    <div class="w-full max-w-md">
      <div class="text-center">
        <NuxtLink to="/" class="inline-flex items-center justify-center gap-2">
          <UIcon name="i-heroicons-academic-cap" class="text-4xl text-primary-600" />
          <h1 class="text-3xl font-bold">TylkoMatma</h1>
        </NuxtLink>
        <h2 class="mt-6 text-2xl font-bold text-gray-900 dark:text-white">
          Zaloguj się do konta
        </h2>
        <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
          Lub
          <NuxtLink
            to="/auth/register"
            class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400"
          >
            zarejestruj nowe konto
          </NuxtLink>
        </p>
      </div>

      <UCard class="mt-8">
        <form @submit.prevent="handleLogin" class="space-y-6">
          <!-- Email Field -->
          <UFormGroup label="Email" name="email" required>
            <UInput
              v-model="form.email"
              type="email"
              placeholder="twoj@email.pl"
              size="lg"
              :disabled="loading"
              autocomplete="email"
            />
          </UFormGroup>

          <!-- Password Field -->
          <UFormGroup label="Hasło" name="password" required>
            <UInput
              v-model="form.password"
              type="password"
              placeholder="••••••••"
              size="lg"
              :disabled="loading"
              autocomplete="current-password"
            />
          </UFormGroup>

          <!-- Error Message -->
          <UAlert
            v-if="errorMessage"
            color="red"
            variant="subtle"
            :title="errorMessage"
            icon="i-heroicons-exclamation-circle"
          />

          <!-- Submit Button -->
          <UButton
            type="submit"
            color="primary"
            size="lg"
            block
            :loading="loading"
            :disabled="!form.email || !form.password"
          >
            Zaloguj się
          </UButton>
        </form>
      </UCard>

      <div class="mt-6 text-center">
        <NuxtLink
          to="/"
          class="text-sm text-gray-600 hover:text-primary-600 dark:text-gray-400 dark:hover:text-primary-400"
        >
          ← Powrót do strony głównej
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
})

const route = useRoute()
const router = useRouter()
const { signIn } = useAuth()

const form = reactive({
  email: '',
  password: '',
})

const loading = ref(false)
const errorMessage = ref('')

async function handleLogin() {
  loading.value = true
  errorMessage.value = ''

  const result = await signIn(form.email, form.password)

  loading.value = false

  if (result.success) {
    const redirect = route.query.redirect as string || '/'
    router.push(redirect)
  } else {
    errorMessage.value = result.error || 'Błąd logowania'
  }
}
</script>

