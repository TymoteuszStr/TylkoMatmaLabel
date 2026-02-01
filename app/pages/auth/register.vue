<template>
  <div
    class="flex min-h-screen items-center justify-center bg-gray-50 px-4 py-12 dark:bg-gray-950 sm:px-6 lg:px-8"
  >
    <div class="w-full max-w-md">
      <div class="text-center">
        <NuxtLink to="/" class="inline-flex items-center justify-center gap-2">
          <UIcon
            name="i-heroicons-academic-cap"
            class="text-4xl text-primary-600"
          />
          <h1 class="text-3xl font-bold">TylkoMatmaLabel</h1>
        </NuxtLink>
        <h2 class="mt-6 text-2xl font-bold text-gray-900 dark:text-white">
          Utwórz nowe konto
        </h2>
        <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
          Lub
          <NuxtLink
            to="/auth/login"
            class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400"
          >
            zaloguj się na istniejące
          </NuxtLink>
        </p>
      </div>

      <UCard class="mt-8">
        <form @submit.prevent="handleRegister" class="space-y-6">
          <!-- Display Name Field -->
          <UFormGroup label="Imię i nazwisko" name="displayName" required>
            <UInput
              v-model="form.displayName"
              placeholder="Jan Kowalski"
              size="lg"
              :disabled="loading"
            />
          </UFormGroup>

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
            <div class="relative">
              <UInput
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="••••••••"
                size="lg"
                :disabled="loading"
                autocomplete="new-password"
                :ui="{ base: 'pr-12' }"
              />
              <button
                type="button"
                @click="showPassword = !showPassword"
                class="absolute top-1/2 -translate-y-1/2 right-3 cursor-pointer z-10"
                tabindex="-1"
              >
                <UIcon
                  :name="
                    showPassword ? 'i-heroicons-eye-slash' : 'i-heroicons-eye'
                  "
                  class="h-5 w-5 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                />
              </button>
            </div>
            <template #hint>
              <span class="text-xs text-gray-500 dark:text-gray-400">
                Minimum 8 znaków
              </span>
            </template>
          </UFormGroup>

          <!-- Confirm Password Field -->
          <UFormGroup label="Potwierdź hasło" name="confirmPassword" required>
            <div class="relative">
              <UInput
                v-model="form.confirmPassword"
                :type="showConfirmPassword ? 'text' : 'password'"
                placeholder="••••••••"
                size="lg"
                :disabled="loading"
                autocomplete="new-password"
                :ui="{ base: 'pr-12' }"
              />
              <button
                type="button"
                @click="showConfirmPassword = !showConfirmPassword"
                class="absolute top-1/2 -translate-y-1/2 right-3 cursor-pointer z-10"
                tabindex="-1"
              >
                <UIcon
                  :name="
                    showConfirmPassword
                      ? 'i-heroicons-eye-slash'
                      : 'i-heroicons-eye'
                  "
                  class="h-5 w-5 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                />
              </button>
            </div>
          </UFormGroup>

          <!-- Error Message -->
          <UAlert
            v-if="errorMessage"
            color="red"
            variant="subtle"
            :title="errorMessage"
            icon="i-heroicons-exclamation-circle"
          />

          <!-- Success Message -->
          <UAlert
            v-if="successMessage"
            color="green"
            variant="subtle"
            :title="successMessage"
            icon="i-heroicons-check-circle"
          />

          <!-- Submit Button -->
          <UButton
            type="submit"
            color="primary"
            size="lg"
            block
            :loading="loading"
            :disabled="!canSubmit"
          >
            Zarejestruj się
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
});

const router = useRouter();
const { signUp } = useAuth();

const form = reactive({
  displayName: "",
  email: "",
  password: "",
  confirmPassword: "",
});

const loading = ref(false);
const errorMessage = ref("");
const successMessage = ref("");
const showPassword = ref(false);
const showConfirmPassword = ref(false);

const canSubmit = computed(() => {
  return (
    form.displayName &&
    form.email &&
    form.password &&
    form.confirmPassword &&
    form.password.length >= 8 &&
    form.password === form.confirmPassword
  );
});

async function handleRegister() {
  if (!canSubmit.value) return;

  if (!form.displayName) {
    errorMessage.value = "Imię i nazwisko jest wymagane";
    return;
  }

  if (form.password !== form.confirmPassword) {
    errorMessage.value = "Hasła nie są zgodne";
    return;
  }

  if (form.password.length < 8) {
    errorMessage.value = "Hasło musi mieć co najmniej 8 znaków";
    return;
  }

  loading.value = true;
  errorMessage.value = "";
  successMessage.value = "";

  const result = await signUp(form.email, form.password, form.displayName);

  loading.value = false;

  if (result.success) {
    successMessage.value = "Konto utworzone! Przekierowywanie...";
    setTimeout(() => {
      router.push("/");
    }, 1500);
  } else {
    errorMessage.value = result.error || "Błąd rejestracji";
  }
}
</script>
