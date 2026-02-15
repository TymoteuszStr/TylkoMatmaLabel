<template>
  <div class="relative my-6">
    <div class="absolute inset-0 flex items-center">
      <div class="w-full border-t border-gray-300 dark:border-gray-700"></div>
    </div>
    <div class="relative flex justify-center text-sm">
      <span class="bg-white dark:bg-gray-900 px-2 text-gray-500 dark:text-gray-400">
        {{ label }}
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  label?: string;
}

withDefaults(defineProps<Props>(), {
  label: "lub",
});
</script>
