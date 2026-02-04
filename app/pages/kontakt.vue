<template>
  <div>
    <!-- Hero Section -->
    <section
      class="bg-gradient-to-b from-primary-50 to-white py-16 dark:from-gray-900 dark:to-gray-950 md:py-24"
    >
      <div class="container mx-auto px-4">
        <div class="mx-auto max-w-3xl text-center">
          <h1
            class="text-4xl font-bold tracking-tight text-gray-900 dark:text-white md:text-5xl"
          >
            Kontakt
          </h1>
          <p class="mt-6 text-lg leading-8 text-gray-600 dark:text-gray-300">
            Masz pytania? Skontaktuj się z nami
          </p>
        </div>
      </div>
    </section>

    <!-- Contact Information Section -->
    <section class="py-16 md:py-24">
      <div class="container mx-auto px-4">
        <div class="mx-auto max-w-5xl">
          <div class="grid gap-8 md:grid-cols-3">
            <!-- Email -->
            <UCard :ui="{ body: { padding: 'p-6' } }">
              <div class="text-center">
                <div
                  class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
                >
                  <UIcon
                    name="i-heroicons-envelope"
                    class="text-3xl text-primary-600 dark:text-primary-400"
                  />
                </div>
                <h3
                  class="mt-4 text-lg font-semibold text-gray-900 dark:text-white"
                >
                  Email
                </h3>
                <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
                  Napisz do nas
                </p>
                <a
                  href="mailto:kontakt@TylkoMatmaOnline.pl"
                  class="mt-3 block text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
                >
                  kontakt@TylkoMatmaOnline.pl
                </a>
              </div>
            </UCard>

            <!-- Phone -->
            <UCard :ui="{ body: { padding: 'p-6' } }">
              <div class="text-center">
                <div
                  class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
                >
                  <UIcon
                    name="i-heroicons-phone"
                    class="text-3xl text-primary-600 dark:text-primary-400"
                  />
                </div>
                <h3
                  class="mt-4 text-lg font-semibold text-gray-900 dark:text-white"
                >
                  Telefon
                </h3>
                <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
                  Zadzwoń do nas
                </p>
                <a
                  href="tel:+48123456789"
                  class="mt-3 block text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
                >
                  +48 123 456 789
                </a>
              </div>
            </UCard>

            <!-- Address -->
            <UCard :ui="{ body: { padding: 'p-6' } }">
              <div class="text-center">
                <div
                  class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
                >
                  <UIcon
                    name="i-heroicons-map-pin"
                    class="text-3xl text-primary-600 dark:text-primary-400"
                  />
                </div>
                <h3
                  class="mt-4 text-lg font-semibold text-gray-900 dark:text-white"
                >
                  Adres
                </h3>
                <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
                  Odwiedź nas
                </p>
                <p class="mt-3 text-primary-600 dark:text-primary-400">
                  ul. Wrocławska <br />
                  31-226 Kraków
                </p>
              </div>
            </UCard>
          </div>
        </div>
      </div>
    </section>

    <!-- Contact Form Section -->
    <section class="bg-gray-50 py-16 dark:bg-gray-900 md:py-24">
      <div class="container mx-auto px-4">
        <div class="mx-auto max-w-2xl">
          <div class="text-center">
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">
              Wyślij wiadomość
            </h2>
            <p class="mt-4 text-gray-600 dark:text-gray-400">
              Odpowiemy tak szybko jak to możliwe
            </p>
          </div>

          <UCard class="mt-8" :ui="{ body: { padding: 'p-6 sm:p-8' } }">
            <form @submit.prevent="handleSubmit" class="space-y-6">
              <!-- Name -->
              <UFormGroup label="Imię i nazwisko" required>
                <UInput
                  v-model="form.name"
                  placeholder="Jan Kowalski"
                  size="lg"
                  :disabled="loading"
                />
              </UFormGroup>

              <!-- Email -->
              <UFormGroup label="Email" required>
                <UInput
                  v-model="form.email"
                  type="email"
                  placeholder="jan.kowalski@example.com"
                  size="lg"
                  :disabled="loading"
                />
              </UFormGroup>

              <!-- Subject -->
              <UFormGroup label="Temat" required>
                <UInput
                  v-model="form.subject"
                  placeholder="W czym możemy pomóc?"
                  size="lg"
                  :disabled="loading"
                />
              </UFormGroup>

              <!-- Message -->
              <UFormGroup label="Wiadomość" required>
                <UTextarea
                  v-model="form.message"
                  placeholder="Opisz swoją sprawę..."
                  :rows="6"
                  :disabled="loading"
                />
              </UFormGroup>

              <!-- Submit Button -->
              <div class="flex justify-end">
                <UButton
                  type="submit"
                  size="lg"
                  :loading="loading"
                  :disabled="!isFormValid"
                >
                  Wyślij wiadomość
                </UButton>
              </div>
            </form>
          </UCard>
        </div>
      </div>
    </section>

    <!-- FAQ Section -->
    <section class="py-16 md:py-24">
      <div class="container mx-auto px-4">
        <div class="mx-auto max-w-3xl">
          <div class="text-center">
            <h2 class="text-3xl font-bold text-gray-900 dark:text-white">
              Najczęściej zadawane pytania
            </h2>
          </div>

          <UAccordion
            class="mt-8"
            :items="faqItems"
            :ui="{ wrapper: 'space-y-3' }"
          />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
const form = ref({
  name: "",
  email: "",
  subject: "",
  message: "",
});

const loading = ref(false);

const isFormValid = computed(() => {
  return (
    form.value.name.trim() !== "" &&
    form.value.email.trim() !== "" &&
    form.value.subject.trim() !== "" &&
    form.value.message.trim() !== ""
  );
});

const handleSubmit = async () => {
  if (!isFormValid.value) return;

  loading.value = true;

  // Symulacja wysyłania formularza
  await new Promise((resolve) => setTimeout(resolve, 1500));

  // TODO: Tutaj dodać faktyczne wysyłanie formularza
  alert(
    "Wiadomość została wysłana! (To tylko przykład - formularz nie jest jeszcze podłączony)",
  );

  // Reset formularza
  form.value = {
    name: "",
    email: "",
    subject: "",
    message: "",
  };

  loading.value = false;
};

const faqItems = [
  {
    label: "Czy korzystanie z platformy jest darmowe?",
    content:
      "Tak! TylkoMatmaOnline oferuje bezpłatny dostęp do wszystkich materiałów edukacyjnych i testów. Wystarczy się zarejestrować.",
    defaultOpen: true,
  },
  {
    label: "Dla kogo jest przeznaczona platforma?",
    content:
      "Platforma jest dedykowana uczniom szkół ponadpodstawowych (liceum, technikum), którzy chcą rozwijać swoje umiejętności matematyczne.",
  },
  {
    label: "Jak często dodawane są nowe materiały?",
    content:
      "Regularnie aktualizujemy naszą bazę materiałów. Nowe tematy i testy pojawiają się co tydzień.",
  },
  {
    label: "Czy mogę śledzić swoje postępy?",
    content:
      "Tak! Po zalogowaniu masz dostęp do profilu, gdzie możesz śledzić swoje wyniki z testów i postępy w nauce.",
  },
  {
    label: "Jak mogę zgłosić błąd lub problem?",
    content:
      "Możesz skorzystać z formularza kontaktowego powyżej lub napisać bezpośrednio na adres kontakt@TylkoMatmaOnline.pl",
  },
];

// SEO
useHead({
  title: "Kontakt - TylkoMatmaOnline",
  meta: [
    {
      name: "description",
      content:
        "Skontaktuj się z zespołem TylkoMatmaOnline. Odpowiadamy na pytania i pomagamy w nauce matematyki.",
    },
  ],
});
</script>
