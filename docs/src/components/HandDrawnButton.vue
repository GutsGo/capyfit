<script setup>
defineProps({
  label: String,
  primary: Boolean,
  href: String
})
</script>

<template>
  <a v-if="href" :href="href" class="hand-drawn-button" :class="{ primary }">
    <slot />
    {{ label }}
  </a>
  <button v-else class="hand-drawn-button" :class="{ primary }">
    <slot />
    {{ label }}
  </button>
</template>

<style scoped>
.hand-drawn-button {
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
</style>
