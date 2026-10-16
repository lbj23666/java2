<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

// 登录成功 → 进入首页之间的过渡加载动画
// 风格：一拳超人漫画风 —— 亮黄底、速度线、红拳套反复出拳、充能条 0→100%
// 满格后打出"轰！！"冲击帧，然后 emit('done')
const emit = defineEmits(['done'])

const pct = ref(0)          // 充能进度
const impacting = ref(false) // 满格后的冲击帧
let timer = null

onMounted(() => {
  const start = Date.now()
  const DURATION = 2400 // 充能总时长
  timer = setInterval(() => {
    const t = Date.now() - start
    // 非线性推进：前快后慢，更像"充能"
    pct.value = Math.min(100, Math.round(100 * (1 - Math.exp(-t / 700))))
    if (t >= DURATION) {
      pct.value = 100
      clearInterval(timer)
      impacting.value = true
      setTimeout(() => emit('done'), 620)
    }
  }, 40)
})

onUnmounted(() => clearInterval(timer))
</script>

<template>
  <div class="loading-overlay">
    <div class="speed-lines"></div>
    <div class="dots"></div>

    <!-- 反复出拳的红拳套 -->
    <div class="fist-track">
      <div class="fist">
        <svg viewBox="0 0 130 110" xmlns="http://www.w3.org/2000/svg">
          <!-- 袖口（白色） -->
          <rect x="4" y="38" width="26" height="36" rx="6" fill="#fdf6e3" stroke="#14100e" stroke-width="5"/>
          <!-- 拳面主体（红拳套） -->
          <rect x="28" y="20" width="62" height="62" rx="16" fill="#d03a2c" stroke="#14100e" stroke-width="5"/>
          <!-- 四指关节 -->
          <circle cx="44" cy="22" r="12" fill="#d03a2c" stroke="#14100e" stroke-width="5"/>
          <circle cx="62" cy="20" r="12" fill="#d03a2c" stroke="#14100e" stroke-width="5"/>
          <circle cx="80" cy="22" r="12" fill="#d03a2c" stroke="#14100e" stroke-width="5"/>
          <!-- 拇指 -->
          <ellipse cx="94" cy="62" rx="16" ry="12" fill="#d03a2c" stroke="#14100e" stroke-width="5"/>
          <!-- 高光 -->
          <path d="M38 34 q10 -8 22 -6" fill="none" stroke="#ff9d8f" stroke-width="5" stroke-linecap="round"/>
        </svg>
      </div>
      <div class="punch-lines">
        <span></span><span></span><span></span>
      </div>
    </div>

    <!-- 标题与充能条 -->
    <h2 class="title">正在接入<span>英雄协会</span>系统</h2>
    <p class="sub">认真一拳 · 传送中</p>

    <div class="meter">
      <div class="meter-fill" :style="{ width: pct + '%' }"></div>
      <span class="meter-text">{{ pct }}%</span>
    </div>

    <div class="tips">
      <span>安全检查</span><b>·</b><span>英雄档案载入</span><b>·</b><span>灾害预警同步</span>
    </div>

    <!-- 满格冲击帧 -->
    <div class="boom" v-if="impacting">轰！！</div>
    <div class="flash" v-if="impacting"></div>
  </div>
</template>

<style scoped>
.loading-overlay {
  position: fixed;
  inset: 0;
  z-index: 50;
  background: #f7c948;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

/* 漫画速度线 */
.speed-lines {
  position: absolute;
  inset: -50%;
  background:
    repeating-conic-gradient(
      from 0deg at 50% 50%,
      rgba(20, 16, 14, 0.06) 0deg 2deg,
      transparent 2deg 7deg
    );
  animation: spin 14s linear infinite;
  pointer-events: none;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* 网点 */
.dots {
  position: absolute;
  inset: 0;
  background-image: radial-gradient(rgba(20, 16, 14, .12) 1.6px, transparent 1.6px);
  background-size: 20px 20px;
  pointer-events: none;
}

/* ===== 出拳动画 ===== */
.fist-track {
  position: relative;
  height: 150px;
  width: 320px;
  margin-bottom: 18px;
}
.fist {
  position: absolute;
  left: 0;
  top: 20px;
  width: 130px;
  animation: punch 1.15s cubic-bezier(.6, 0, .2, 1) infinite;
  filter: drop-shadow(5px 5px 0 rgba(20, 16, 14, .35));
}
@keyframes punch {
  0%   { transform: translateX(0) rotate(0deg); }
  30%  { transform: translateX(-14px) rotate(-6deg); }  /* 后拉蓄力 */
  55%  { transform: translateX(150px) rotate(2deg); }   /* 快速出拳 */
  70%  { transform: translateX(138px) rotate(2deg); }   /* 轻微回弹 */
  100% { transform: translateX(0) rotate(0deg); }
}
.punch-lines span {
  position: absolute;
  left: 150px;
  height: 6px;
  background: #14100e;
  border-radius: 3px;
  opacity: 0;
}
.punch-lines span:nth-child(1) { top: 38px; width: 90px;  animation: streak 1.15s infinite; }
.punch-lines span:nth-child(2) { top: 72px; width: 120px; animation: streak 1.15s .04s infinite; }
.punch-lines span:nth-child(3) { top: 106px; width: 70px; animation: streak 1.15s .08s infinite; }
@keyframes streak {
  0%, 30%  { opacity: 0; transform: translateX(0) scaleX(.3); }
  55%      { opacity: .55; transform: translateX(28px) scaleX(1); }
  75%, 100%{ opacity: 0; }
}

/* ===== 文案 ===== */
.title {
  position: relative;
  font-size: 34px;
  font-weight: 900;
  color: #14100e;
  letter-spacing: 4px;
}
.title span { color: #d03a2c; }
.sub {
  position: relative;
  margin: 8px 0 26px;
  font-size: 13px;
  font-weight: 700;
  color: rgba(20, 16, 14, .55);
  letter-spacing: 6px;
}

/* ===== 充能条 ===== */
.meter {
  position: relative;
  width: min(420px, 80vw);
  height: 34px;
  background: #fdf6e3;
  border: 4px solid #14100e;
  border-radius: 6px;
  box-shadow: 6px 6px 0 #14100e;
  overflow: hidden;
}
.meter-fill {
  height: 100%;
  background: linear-gradient(90deg, #e8a812, #d03a2c);
  transition: width .12s linear;
}
.meter-text {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 15px;
  font-weight: 900;
  color: #14100e;
  letter-spacing: 2px;
  mix-blend-mode: multiply;
}

.tips {
  position: relative;
  margin-top: 20px;
  font-size: 12px;
  font-weight: 700;
  color: rgba(20, 16, 14, .6);
  letter-spacing: 2px;
}
.tips b { margin: 0 10px; color: #d03a2c; }

/* ===== 冲击帧 ===== */
.boom {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 130px;
  font-weight: 900;
  color: #f7c948;
  -webkit-text-stroke: 6px #14100e;
  letter-spacing: 14px;
  animation: boomIn .6s cubic-bezier(.2, 1.4, .4, 1) forwards;
  z-index: 3;
}
@keyframes boomIn {
  0%   { transform: translate(-50%, -50%) scale(0) rotate(-10deg); }
  60%  { transform: translate(-50%, -50%) scale(1.25) rotate(4deg); }
  100% { transform: translate(-50%, -50%) scale(1.05) rotate(0); }
}
.flash {
  position: absolute;
  inset: 0;
  background: #fff;
  animation: flashOut .6s ease forwards;
  z-index: 2;
}
@keyframes flashOut {
  0% { opacity: .95; }
  100% { opacity: 0; }
}
</style>
