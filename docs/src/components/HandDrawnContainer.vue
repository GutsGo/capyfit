<script setup>
defineProps({
  tag: {
    type: String,
    default: 'div'
  },
  padding: {
    type: String,
    default: '1.5rem'
  },
  backgroundColor: {
    type: String,
    default: 'white'
  }
})

// 生成随机的 border-radius 模拟手绘感
const getRandomRadius = () => {
    const r1 = Math.floor(Math.random() * 50) + 225;
    const r2 = Math.floor(Math.random() * 20) + 10;
    const r3 = Math.floor(Math.random() * 50) + 200;
    const r4 = Math.floor(Math.random() * 20) + 10;
    
    const r5 = Math.floor(Math.random() * 20) + 10;
    const r6 = Math.floor(Math.random() * 50) + 200;
    const r7 = Math.floor(Math.random() * 20) + 10;
    const r8 = Math.floor(Math.random() * 50) + 225;
    
    return `${r1}px ${r2}px ${r3}px ${r4}px / ${r5}px ${r6}px ${r7}px ${r8}px`;
}

const borderStyle = {
    borderRadius: getRandomRadius()
}
</script>

<template>
  <component 
    :is="tag" 
    class="hand-drawn-container" 
    :style="[borderStyle, { padding, backgroundColor }]"
  >
    <slot />
  </component>
</template>

<style scoped>
.hand-drawn-container {
  border: 2px solid var(--border-color);
  position: relative;
}

/* 伪元素增加“重影”手绘线效果 */
.hand-drawn-container::after {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border: 1px solid var(--border-color);
  opacity: 0.3;
  pointer-events: none;
  border-radius: inherit;
  transform: rotate(0.5deg) scale(1.01);
}
</style>
