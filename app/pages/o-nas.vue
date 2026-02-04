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
            O nas
          </h1>
          <p class="mt-6 text-lg leading-8 text-gray-600 dark:text-gray-300">
            Poznaj historię i misję platformy TylkoMatmaOnline
          </p>
        </div>
      </div>
    </section>

    <!-- Mission Section -->
    <section class="py-16 md:py-24">
      <div class="container mx-auto px-4">
        <div class="mx-auto max-w-6xl">
          <div class="grid gap-12 md:grid-cols-3">
            <div class="flex flex-col items-center text-center">
              <div
                class="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-light-bulb"
                  class="text-3xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <h2 class="mt-6 text-2xl font-bold text-gray-900 dark:text-white">
                Nasza misja
              </h2>
              <p class="mt-4 text-gray-600 dark:text-gray-400">
                TylkoMatmaOnline to platforma edukacyjna stworzona z myślą o
                uczniach, którzy chcą opanować matematykę w przystępny i
                efektywny sposób. Wierzymy, że każdy może polubić matematykę,
                jeśli zostanie ona przedstawiona we właściwy sposób.
              </p>
            </div>

            <div class="flex flex-col items-center text-center">
              <div
                class="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-rocket-launch"
                  class="text-3xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <h2 class="mt-6 text-2xl font-bold text-gray-900 dark:text-white">
                Nasza wizja
              </h2>
              <p class="mt-4 text-gray-600 dark:text-gray-400">
                Dążymy do stworzenia kompleksowej platformy edukacyjnej, która
                pomoże tysiącom uczniów w Polsce osiągnąć sukces w nauce
                matematyki. Chcemy sprawić, by nauka była przyjemnością, a nie
                przymusem.
              </p>
            </div>

            <div class="flex flex-col items-center text-center">
              <div
                class="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 dark:bg-primary-900"
              >
                <UIcon
                  name="i-heroicons-trophy"
                  class="text-3xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <h2 class="mt-6 text-2xl font-bold text-gray-900 dark:text-white">
                Nasz cel
              </h2>
              <p class="mt-4 text-gray-600 dark:text-gray-400">
                Naszym celem jest demokratyzacja dostępu do wysokiej jakości
                edukacji matematycznej. Chcemy, aby każdy uczeń, niezależnie od
                miejsca zamieszkania czy możliwości finansowych, miał szansę
                rozwinąć swój potencjał matematyczny i osiągnąć sukces na
                maturze.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Team Section -->
    <section class="bg-gray-50 py-16 dark:bg-gray-900 md:py-24">
      <div class="container mx-auto px-4">
        <div class="mx-auto max-w-2xl text-center">
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white">
            Nasz zespół
          </h2>
          <p class="mt-4 text-gray-600 dark:text-gray-400">
            Profesjonaliści zaangażowani w rozwój edukacji
          </p>
        </div>

        <div class="mt-12 grid gap-8 md:grid-cols-2">
          <UCard :ui="{ body: { padding: 'p-6' } }">
            <div class="text-center">
              <UAvatar
                src="https://ui-avatars.com/api/?name=Maciej+Dudek&background=6366f1&color=fff&size=128"
                alt="Maciej Dudek"
                size="xl"
                class="mx-auto"
              />
              <h3
                class="mt-4 text-xl font-semibold text-gray-900 dark:text-white"
              >
                Maciej Dudek
              </h3>
              <p class="text-sm text-primary-600 dark:text-primary-400">
                Co-Founder & Lead Teacher
              </p>
              <p class="mt-3 text-sm text-gray-600 dark:text-gray-400">
                Nauczyciel matematyki z 10-letnim stażem. Odpowiada za jakość
                materiałów edukacyjnych oraz nauczania.
              </p>
            </div>
          </UCard>

          <UCard :ui="{ body: { padding: 'p-6' } }">
            <div class="text-center">
              <UAvatar
                src="https://ui-avatars.com/api/?name=Tymoteusz+Stróżniak&background=6366f1&color=fff&size=128"
                alt="Tymoteusz Stróżniak"
                size="xl"
                class="mx-auto"
              />
              <h3
                class="mt-4 text-xl font-semibold text-gray-900 dark:text-white"
              >
                Tymoteusz Stróżniak
              </h3>
              <p class="text-sm text-primary-600 dark:text-primary-400">
                Co-Founder & Lead Developer
              </p>
              <p class="mt-3 text-sm text-gray-600 dark:text-gray-400">
                Specjalista od platform edukacyjnych. Tworzy intuicyjne i
                funkcjonalne rozwiązania technologiczne.
              </p>
            </div>
          </UCard>
        </div>
      </div>
    </section>

    <!-- Stats Section -->
    <section class="py-16 md:py-24">
      <div class="container mx-auto px-4">
        <div class="mx-auto max-w-4xl">
          <div class="grid gap-8 md:grid-cols-3">
            <div class="text-center">
              <div
                class="text-4xl font-bold text-primary-600 dark:text-primary-400"
              >
                5000+
              </div>
              <div
                class="mt-2 text-sm font-medium text-gray-600 dark:text-gray-400"
              >
                Aktywnych użytkowników
              </div>
            </div>

            <div class="text-center">
              <div
                class="text-4xl font-bold text-primary-600 dark:text-primary-400"
              >
                200+
              </div>
              <div
                class="mt-2 text-sm font-medium text-gray-600 dark:text-gray-400"
              >
                Tematów matematycznych
              </div>
            </div>

            <div class="text-center">
              <div
                class="text-4xl font-bold text-primary-600 dark:text-primary-400"
              >
                10000+
              </div>
              <div
                class="mt-2 text-sm font-medium text-gray-600 dark:text-gray-400"
              >
                Rozwiązanych testów
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
// SEO
useHead({
  title: "O nas - TylkoMatmaOnline",
  meta: [
    {
      name: "description",
      content:
        "Poznaj historię i misję platformy TylkoMatmaOnline - kompleksowej platformy do nauki matematyki online.",
    },
  ],
});
</script>
