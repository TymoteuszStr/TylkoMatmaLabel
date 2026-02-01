<template>
  <div class="content-block" :class="`content-block-${block.type}`">
    <!-- Text Block -->
    <div
      v-if="block.type === 'text'"
      class="prose prose-gray dark:prose-invert max-w-none"
    >
      <div v-html="renderedContent" />
    </div>

    <!-- Heading Block -->
    <template v-else-if="block.type === 'heading' && isObject(block.content)">
      <component
        :is="getHeadingTag(getNumber(block.content.level))"
        class="font-bold text-gray-900 dark:text-white"
        :class="getHeadingClass(getNumber(block.content.level))"
      >
        {{ getString(block.content.text) }}
      </component>
    </template>

    <!-- Image Block -->
    <figure
      v-else-if="block.type === 'image' && isObject(block.content)"
      class="my-6"
    >
      <NuxtImg
        :src="getString(block.content.url)"
        :alt="getString(block.content.alt) || 'Image'"
        class="rounded-lg w-full"
        loading="lazy"
      />
      <figcaption
        v-if="block.content.caption"
        class="mt-2 text-center text-sm text-gray-600 dark:text-gray-400"
      >
        {{ getString(block.content.caption) }}
      </figcaption>
    </figure>

    <!-- Formula Block (LaTeX) -->
    <div
      v-else-if="block.type === 'formula' && isObject(block.content)"
      class="my-6 overflow-x-auto"
    >
      <div
        class="flex justify-center p-4 bg-gray-50 dark:bg-gray-900 rounded-lg"
      >
        <code class="text-lg font-mono">{{
          getString(block.content.latex)
        }}</code>
      </div>
    </div>

    <!-- Code Block -->
    <div
      v-else-if="block.type === 'code' && isObject(block.content)"
      class="my-6"
    >
      <pre
        class="bg-gray-900 text-gray-100 rounded-lg p-4 overflow-x-auto"
      ><code>{{ getString(block.content.code) }}</code></pre>
    </div>

    <!-- Callout Block -->
    <UAlert
      v-else-if="block.type === 'callout' && isObject(block.content)"
      :color="getString(block.content.color) || 'primary'"
      :variant="getString(block.content.variant) || 'subtle'"
      :icon="getString(block.content.icon) || 'i-heroicons-information-circle'"
      :title="getString(block.content.title)"
      class="my-6"
    >
      <template #description>
        <div v-html="renderMarkdown(getString(block.content.text))" />
      </template>
    </UAlert>

    <!-- Table Block -->
    <div
      v-else-if="block.type === 'table' && isObject(block.content)"
      class="my-6 overflow-x-auto"
    >
      <table class="min-w-full divide-y divide-gray-300 dark:divide-gray-700">
        <thead
          v-if="Array.isArray(block.content.headers)"
          class="bg-gray-50 dark:bg-gray-900"
        >
          <tr>
            <th
              v-for="(header, idx) in block.content.headers"
              :key="idx"
              class="px-4 py-2 text-left text-sm font-semibold text-gray-900 dark:text-white"
            >
              {{ header }}
            </th>
          </tr>
        </thead>
        <tbody
          v-if="Array.isArray(block.content.rows)"
          class="divide-y divide-gray-200 dark:divide-gray-800 bg-white dark:bg-gray-950"
        >
          <tr v-for="(row, rowIdx) in block.content.rows" :key="rowIdx">
            <td
              v-for="(cell, cellIdx) in Array.isArray(row) ? row : []"
              :key="cellIdx"
              class="px-4 py-2 text-sm text-gray-700 dark:text-gray-300"
            >
              {{ cell }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Divider Block -->
    <hr
      v-else-if="block.type === 'divider'"
      class="my-8 border-gray-300 dark:border-gray-700"
    />

    <!-- Fallback -->
    <div v-else class="my-4 p-4 bg-gray-100 dark:bg-gray-800 rounded-lg">
      <p class="text-sm text-gray-600 dark:text-gray-400">
        Nieobsługiwany typ bloku: {{ block.type }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { marked } from "marked";
import type { ContentBlock, Json } from "~/types/database";

const props = defineProps<{
  block: ContentBlock;
}>();

// Type guards for content
function isObject(value: Json): value is Record<string, Json | undefined> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function getString(value: Json | undefined): string {
  return typeof value === "string" ? value : "";
}

function getNumber(value: Json | undefined): number {
  return typeof value === "number" ? value : 1;
}

const renderedContent = computed(() => {
  const content = props.block.content;
  if (props.block.type === "text" && isObject(content)) {
    const markdown = content.markdown;
    if (typeof markdown === "string") {
      return renderMarkdown(markdown);
    }
  }
  if (isObject(content)) {
    return getString(content.text);
  }
  return "";
});

function renderMarkdown(text: string) {
  return marked(text);
}

function getHeadingTag(level: number) {
  return `h${Math.min(Math.max(level, 1), 6)}`;
}

function getHeadingClass(level: number) {
  const classes: Record<number, string> = {
    1: "text-4xl",
    2: "text-3xl",
    3: "text-2xl",
    4: "text-xl",
    5: "text-lg",
    6: "text-base",
  };
  return classes[level] || "text-lg";
}
</script>

<style scoped>
.content-block {
  @apply mb-4;
}

/* Prose styles for markdown content */
.prose {
  @apply text-gray-700 dark:text-gray-300;
}

.prose :deep(p) {
  @apply mb-4;
}

.prose :deep(strong) {
  @apply font-semibold text-gray-900 dark:text-white;
}

.prose :deep(em) {
  @apply italic;
}

.prose :deep(a) {
  @apply text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 underline;
}

.prose :deep(ul) {
  @apply list-disc pl-6 mb-4;
}

.prose :deep(ol) {
  @apply list-decimal pl-6 mb-4;
}

.prose :deep(li) {
  @apply mb-2;
}

.prose :deep(code) {
  @apply bg-gray-100 dark:bg-gray-800 px-1 py-0.5 rounded text-sm font-mono;
}

.prose :deep(blockquote) {
  @apply border-l-4 border-primary-600 pl-4 italic text-gray-600 dark:text-gray-400;
}
</style>
