<script setup>
import { computed, ref } from 'vue'

// 英雄主页卡片（登录成功后展示）
// props:
//   hero    - 登录返回的英雄信息 { id, username, email, heroClass }
//   hitting - 按钮是否处于"出拳"动画状态
// emits:
//   logout - 退出登录
//   patrol - 外出巡逻（触发琦玉出拳动画）
const props = defineProps({
  hero: { type: Object, required: true },
  hitting: { type: Boolean, default: false }
})
const emit = defineEmits(['logout', 'patrol'])

const quotes = [
  '我秃了，也变强了。',
  '兴趣使然的英雄，今天也要一拳解决怪人。',
  '超市特卖比打怪人重要多了！',
  '变强的秘诀：每天100个俯卧撑、100个仰卧起坐、100个深蹲、10公里跑，坚持三年，不开空调。',
  '认真起来，连我自己都害怕。',
  '一拳就够了。'
]
const quote = ref(quotes[Math.floor(Math.random() * quotes.length)])

const rankMeta = computed(() => {
  const map = {
    C: { label: 'C级 · 新人英雄', color: '#8a7a63' },
    B: { label: 'B级 · 小有名气', color: '#2f8f46' },
    A: { label: 'A级 · 精英英雄', color: '#2a6fb8' },
    S: { label: 'S级 · 传说存在', color: '#d03a2c' }
  }
  return map[props.hero?.heroClass] || map.C
})

const memberNo = computed(() => 'HA-' + String(props.hero?.id ?? 0).padStart(4, '0'))

function onPatrol() {
  quote.value = quotes[Math.floor(Math.random() * quotes.length)]
  emit('patrol')
}
</script>

<template>
  <div class="card">
    <h1>英雄<span>主页</span></h1>
    <p class="sub">欢迎回来，协会的荣耀因你而闪耀</p>

    <!-- 英雄证主体 -->
    <div class="license">
      <div class="avatar" :style="{ background: rankMeta.color }">
        <span class="rank-letter">{{ hero.heroClass }}</span>
      </div>
      <div class="info">
        <div class="codename">{{ hero.username }}</div>
        <div class="rank-badge" :style="{ background: rankMeta.color }">
          {{ rankMeta.label }}
        </div>
        <div class="meta">
          <span class="k">会员编号</span>
          <span class="v">{{ memberNo }}</span>
        </div>
        <div class="meta">
          <span class="k">联络邮箱</span>
          <span class="v">{{ hero.email }}</span>
        </div>
      </div>
    </div>

    <!-- 每日语录 -->
    <div class="quote">
      <span class="q-mark">“</span>{{ quote }}<span class="q-mark">”</span>
    </div>

    <!-- 操作按钮 -->
    <button type="button" class="btn-punch" :class="{ hit: hitting }" @click="onPatrol">
      外出巡逻
      <span class="boom"></span>
    </button>
    <button type="button" class="btn-logout" @click="emit('logout')">
      退出登录
    </button>

    <div class="ok-stamp">在役</div>
  </div>
</template>

<style scoped>
.card {
  width: 380px;
  background: var(--paper);
  border: 4px solid var(--ink);
  border-radius: 6px;
  box-shadow:
    10px 10px 0 var(--saitama-yellow),
    10px 10px 0 4px var(--ink),
    0 30px 60px rgba(0, 0, 0, .5);
  padding: 36px 34px 30px;
  position: relative;
}
.card::before {
  content: "HERO LICENSE";
  position: absolute;
  top: -16px;
  left: 24px;
  background: var(--cape-red);
  color: #fff;
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 3px;
  padding: 6px 12px;
  border: 3px solid var(--ink);
  border-radius: 4px;
  transform: rotate(-2deg);
}

h1 {
  font-size: 30px;
  font-weight: 900;
  color: var(--ink);
  letter-spacing: 2px;
}
h1 span { color: var(--cape-red); }
.sub {
  margin: 6px 0 24px;
  font-size: 13px;
  color: #8a7a63;
  letter-spacing: 1px;
}

/* ===== 英雄证 ===== */
.license {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #fff;
  border: 3px solid var(--ink);
  border-radius: 6px;
  box-shadow: 4px 4px 0 rgba(43, 33, 24, .15);
}
.avatar {
  flex-shrink: 0;
  width: 84px;
  height: 84px;
  border: 3px solid var(--ink);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}
.avatar::after {
  content: "";
  position: absolute;
  inset: -8px;
  border: 2px dashed rgba(43, 33, 24, .35);
  border-radius: 50%;
}
.rank-letter {
  font-size: 40px;
  font-weight: 900;
  color: #fff;
  text-shadow: 2px 2px 0 rgba(0, 0, 0, .35);
}
.info { flex: 1; min-width: 0; }
.codename {
  font-size: 20px;
  font-weight: 900;
  color: var(--ink);
  letter-spacing: 1px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.rank-badge {
  display: inline-block;
  margin: 6px 0 10px;
  padding: 3px 10px;
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1px;
  border-radius: 3px;
  border: 2px solid var(--ink);
}
.meta {
  display: flex;
  font-size: 12px;
  line-height: 1.8;
}
.meta .k {
  flex-shrink: 0;
  width: 64px;
  color: #8a7a63;
  font-weight: 700;
}
.meta .v {
  color: var(--ink);
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* ===== 语录 ===== */
.quote {
  margin: 18px 0;
  padding: 12px 16px;
  background: rgba(247, 201, 72, .18);
  border-left: 4px solid var(--saitama-yellow-deep);
  border-radius: 0 4px 4px 0;
  font-size: 13px;
  font-weight: 600;
  color: var(--ink);
  line-height: 1.7;
}
.q-mark {
  color: var(--cape-red);
  font-size: 18px;
  font-weight: 900;
}

/* ===== 按钮 ===== */
.btn-punch {
  width: 100%;
  margin-top: 6px;
  padding: 15px;
  font-size: 17px;
  font-weight: 900;
  letter-spacing: 6px;
  color: #fff;
  background: linear-gradient(180deg, #e85a4a, var(--cape-red));
  border: 3px solid var(--ink);
  border-radius: 4px;
  cursor: pointer;
  box-shadow: 5px 5px 0 var(--ink);
  transition: transform .1s, box-shadow .1s;
  position: relative;
  overflow: hidden;
}
.btn-punch:hover  { transform: translate(-2px, -2px); box-shadow: 7px 7px 0 var(--ink); }
.btn-punch:active { transform: translate(3px, 3px);   box-shadow: 2px 2px 0 var(--ink); }
.btn-punch .boom {
  position: absolute;
  inset: 0;
  background: radial-gradient(circle, rgba(255, 255, 255, .9), transparent 60%);
  opacity: 0;
  pointer-events: none;
}
.btn-punch.hit .boom { animation: boomFlash .4s ease; }
@keyframes boomFlash {
  0%   { opacity: 1; }
  100% { opacity: 0; }
}

.btn-logout {
  width: 100%;
  margin-top: 12px;
  padding: 11px;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 3px;
  color: var(--ink);
  background: #fff;
  border: 3px solid var(--ink);
  border-radius: 4px;
  cursor: pointer;
  transition: all .12s;
}
.btn-logout:hover {
  background: var(--ink);
  color: var(--paper);
}

.ok-stamp {
  position: absolute;
  right: -22px;
  bottom: -22px;
  width: 84px;
  height: 84px;
  border: 5px solid var(--cape-red);
  border-radius: 50%;
  color: var(--cape-red);
  font-size: 26px;
  font-weight: 900;
  display: flex;
  align-items: center;
  justify-content: center;
  transform: rotate(14deg);
  background: rgba(253, 246, 227, .9);
  letter-spacing: 2px;
}

@media (max-width: 800px) {
  .card { width: 92vw; max-width: 380px; }
}
</style>
