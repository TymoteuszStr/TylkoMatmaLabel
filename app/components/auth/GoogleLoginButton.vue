<template>
  <UButton
    type="button"
    color="white"
    size="lg"
    block
    :loading="loading"
    @click="handleClick"
    variant="outline"
  >
    <template #leading>
      <UIcon name="i-logos-google-icon" class="h-5 w-5" />
    </template>
    {{ label }}
  </UButton>
</template>

<script setup lang="ts">
interface Props {
  loading?: boolean;
  label?: string;
}

withDefaults(defineProps<Props>(), {
  loading: false,
  label: "Kontynuuj z Google",
});

const emit = defineEmits<{
  click: [];
}>();

function handleClick() {
  emit("click");
}
</script>
