<template>
  <div
    class="flex min-h-screen items-center justify-center bg-gray-50 px-4 dark:bg-gray-950"
  >
    <div class="text-center">
      <UIcon
        name="i-heroicons-arrow-path"
        class="mx-auto mb-4 h-12 w-12 animate-spin text-primary-600"
      />
      <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
        Logowanie w toku...
      </h2>
      <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
        Proszę czekać, przetwarzamy Twoje logowanie.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
});

const route = useRoute();
const router = useRouter();
const supabase = useSupabaseClient();
const { initialize } = useAuth();

onMounted(async () => {
  try {
    // Get the session from the URL hash
    const { error } = await supabase.auth.getSession();

    if (error) {
      console.error("OAuth callback error:", error);
      router.push("/auth/login?error=oauth_failed");
      return;
    }

    // Initialize auth state (fetch profile)
    await initialize();

    // Redirect to the intended page or home
    const redirect = (route.query.redirect as string) || "/";
    router.push(redirect);
  } catch (error) {
    console.error("Callback error:", error);
    router.push("/auth/login?error=callback_failed");
  }
});
</script>
