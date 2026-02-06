<script setup>
import { 
  Download, 
  Github, 
  Sparkles, 
  Gamepad2, 
  Dumbbell, 
  Apple, 
  TrendingUp,
  Layout
} from 'lucide-vue-next'
import heroImage from './assets/logo.jpg'

const features = [
  { 
    icon: Layout, 
    title: '手绘风格 UI', 
    desc: '每一处线条都经过精心打磨，为您提供治愈且独特的视觉体验。' 
  },
  { 
    icon: Gamepad2, 
    title: '趣味互动', 
    desc: '可爱的卡皮巴拉陪伴您的每一次健身之旅，让运动不再枯燥。' 
  },
  { 
    icon: Dumbbell, 
    title: '训练追踪', 
    desc: '轻松创建健身计划，实时记录训练进展，见证自己的每一步成长。' 
  },
  { 
    icon: Apple, 
    title: '科学饮食', 
    desc: '内置详尽的食物数据库，帮助您平衡营养摄入，吃出健康好身材。' 
  },
  { 
    icon: TrendingUp, 
    title: '数据统计', 
    desc: '多维度的统计图表，直观展示您的运动时长、热量消耗等关键指标。' 
  },
  { 
    icon: Sparkles, 
    title: '完全本地', 
    desc: '您的数据存储在本地，不上传云端，最大程度保护您的个人隐私。' 
  }
]

const handleDownload = async () => {
  const ua = navigator.userAgent;
  const isIOS = /iPhone|iPad|iPod/i.test(ua);
  
  if (isIOS) {
    alert('暂不支持 iOS 系统，敬请期待！');
    return;
  }

  const triggerDownload = (url) => {
    const link = document.createElement('a');
    link.href = url;
    // 提取文件名作为下载名称
    const fileName = url.split('/').pop();
    link.download = fileName || 'capyfit.apk';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  try {
    const resp = await fetch('/__dev__/capy_conf.json');
    const conf = await resp.json();
    const downloadUrl = `${conf.urls.base}/${conf.urls.android['arm64-v8a']}`;
    triggerDownload(downloadUrl);
  } catch (e) {
    console.error('获取下载配置失败:', e);
    alert('下载失败，请稍后重试');
  }
};
</script>

<template>
  <div class="vp-home">
    <!-- Hero Section -->
    <header class="hero container">
      <div class="hero-main">
        <h1 class="name">
          <span class="clip">猛练豚</span>
        </h1>
        <p class="text">让健身像卡皮巴拉一样稳定而有趣。</p>
        <p class="tagline">基于 Flutter 的治愈系健身软件，全手绘视觉风格，极致的隐私保护。</p>
        
        <div class="actions">
          <a @click.prevent="handleDownload" href="javascript:void(0)" class="vp-button brand">
            立即下载 <Download :size="16" style="margin-left: 4px; vertical-align: middle;" />
          </a>
          <a href="https://github.com/GutsGo/CapyFitHub" class="vp-button alt">
            GitHub <Github :size="16" style="margin-left: 4px; vertical-align: middle;" />
          </a>
        </div>
      </div>
      
      <div class="hero-image">
        <div class="image-bg"></div>
        <img :src="heroImage" alt="CapyFit" class="image-src" />
      </div>
    </header>

    <!-- Features Section -->
    <section class="features container">
      <div class="grid">
        <div v-for="f in features" :key="f.title" class="item">
          <div class="feature-card">
            <div class="icon-box">
              <component :is="f.icon" :size="24" color="var(--brand-color)" />
            </div>
            <h2 class="title">{{ f.title }}</h2>
            <p class="details">{{ f.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
      <div class="container">
        <p class="message">Released under the MIT License.</p>
        <p class="copyright">Copyright © 2026-present CapyFit Team</p>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.vp-home {
  padding-bottom: 64px;
}

/* Hero Section */
.hero {
  display: flex;
  flex-direction: column-reverse; /* 移动端图片在上方 */
  align-items: center;
  text-align: center;
  padding: 48px 24px;
  gap: 32px;
}

@media (min-width: 960px) {
  .hero {
    flex-direction: row;
    text-align: left;
    padding: 96px 64px;
    justify-content: space-between;
    gap: 64px;
  }
}

.hero-main {
  width: 100%;
}

@media (min-width: 960px) {
  .hero-main {
    flex-shrink: 0;
    max-width: 592px;
  }
}

.name {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 8px;
  letter-spacing: -0.02em;
}

@media (min-width: 640px) {
  .name { font-size: 48px; }
}

.clip {
  background: var(--brand-gradient);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.text {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.2;
  color: var(--text-1);
}

@media (min-width: 640px) {
  .text { font-size: 48px; }
}

.tagline {
  padding-top: 12px;
  font-size: 18px;
  font-weight: 500;
  color: var(--text-2);
  margin-bottom: 32px;
  line-height: 1.5;
}

@media (min-width: 640px) {
  .tagline { font-size: 24px; }
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: center;
}

@media (min-width: 960px) {
  .actions {
    justify-content: flex-start;
  }
}

.hero-image {
  position: relative;
  width: 100%;
  max-width: 180px; /* 移动端图片稍微小一点更协调 */
  display: flex;
  justify-content: center;
  align-items: center;
}

@media (min-width: 640px) {
  .hero-image { max-width: 240px; }
}

@media (min-width: 960px) {
  .hero-image {
    flex-grow: 1;
  }
}

.image-src {
  width: 100%;
  height: auto;
  position: relative;
  z-index: 1;
  filter: drop-shadow(0 20px 50px rgba(0,0,0,0.1));
}

.image-bg {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 140%;
  height: 140%;
  background-image: linear-gradient(
    -45deg, 
    #7EB8A2 20%, 
    #E8A87C 40%, 
    #FFB7B2 60%, 
    #B39EB5 80%
  );
  opacity: 0.4;
  filter: blur(60px);
  border-radius: 50%;
  z-index: 0;
  animation: pulse 8s ease-in-out infinite alternate;
}

@media (min-width: 640px) {
  .image-bg { filter: blur(100px); }
}

@keyframes pulse {
  0% { transform: translate(-50%, -50%) scale(1); opacity: 0.35; }
  100% { transform: translate(-50%, -50%) scale(1.1); opacity: 0.45; }
}

/* Features Grid */
.features {
  padding: 48px 0;
}

@media (min-width: 960px) {
  .features { padding: 64px 0; }
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
  padding: 0 16px; /* 恢复移动端边距 */
}

@media (min-width: 640px) {
  .grid {
    gap: 24px;
    padding: 0; /* 平板及以上尺寸使用容器自带的 padding */
  }
}

.feature-card {
  height: 100%;
  padding: 24px;
  border-radius: 12px;
  background-color: var(--card-bg);
  border: 1px solid var(--border-color);
  transition: border-color 0.25s, transform 0.25s;
}

.feature-card:hover {
  border-color: var(--brand-light);
  transform: translateY(-4px);
}

.icon-box {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 20px;
  width: 48px;
  height: 48px;
  border-radius: 8px;
  background-color: rgba(139, 111, 92, 0.1);
}

.feature-card .title {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 8px;
  color: var(--text-1);
}

.feature-card .details {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-2);
  line-height: 1.6;
}

.footer {
  padding: 48px 24px;
  border-top: 1px solid var(--border-color);
  text-align: center;
}

.footer .message {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-2);
}

.footer .copyright {
  padding-top: 8px;
  font-size: 14px;
  font-weight: 400;
  color: var(--text-3);
}
</style>
