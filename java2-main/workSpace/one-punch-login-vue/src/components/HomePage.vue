<script setup>
import { computed, ref } from 'vue'

// 英雄协会首页（登录成功后进入）
// 风格：一拳超人海报风 —— 亮黄底、粗黑描边、漫画网点、红/绿/紫点缀
// 功能：顶部导航栏（菜单 + 当前英雄 + 退出）、搜索栏（关键词搜索 + 等级筛选）、英雄图鉴卡片墙
// props:
//   hero - 登录返回的英雄信息 { id, username, email, heroClass }
// emits:
//   logout - 退出登录
const props = defineProps({
  hero: { type: Object, required: true }
})
const emit = defineEmits(['logout'])

const keyword = ref('')
const rankFilter = ref('all')

const navItems = ['首页', '英雄图鉴', '怪人通缉', '灾害预警', '协会公告']

// 英雄图鉴数据（本地静态，一拳超人角色）
const heroes = [
  { name: '琦玉', alias: '秃头披风侠', rank: 'S', tag: '一拳解决，兴趣使然的英雄' },
  { name: '杰诺斯', alias: '魔鬼改造人', rank: 'S', tag: '焚毁炮全功率输出，S级新人王' },
  { name: '战栗的龙卷', alias: '龙卷', rank: 'S', tag: '念动力大师，别惹她生气' },
  { name: '银色獠牙', alias: '邦古', rank: 'S', tag: '流水岩碎拳宗师，武道泰斗' },
  { name: '金属骑士', alias: '波佛伊博士', rank: 'S', tag: '远程操控的机械军团' },
  { name: '闪光弗莱士', alias: 'Flash', rank: 'S', tag: '神速剑术，快过闪电' },
  { name: '僵尸侠', alias: 'Zombieman', rank: 'S', tag: '不死之身，无限再生' },
  { name: '金属球棒', alias: '不良少年', rank: 'S', tag: '气势越高越强，一根球棒走天下' },
  { name: '背心尊者', alias: '背心军团长', rank: 'S', tag: '背心就是力量' },
  { name: '甜心假面', alias: 'Amai Mask', rank: 'A', tag: '偶像兼英雄，颜值即正义' },
  { name: '地狱的吹雪', alias: '吹雪组组长', rank: 'B', tag: '超能力姐妹中的妹妹，务实派' },
  { name: '无证骑士', alias: 'C级英雄', rank: 'C', tag: '自行车巡逻，永不放弃的男人' },
]

const rankMeta = {
  S: { label: 'S级', color: '#d03a2c' },
  A: { label: 'A级', color: '#2a6fb8' },
  B: { label: 'B级', color: '#2f8f46' },
  C: { label: 'C级', color: '#8a7a63' },
}

const rankChips = [
  { key: 'all', label: '全部' },
  { key: 'S', label: 'S级' },
  { key: 'A', label: 'A级' },
  { key: 'B', label: 'B级' },
  { key: 'C', label: 'C级' },
]

// 搜索 + 等级筛选
const filteredHeroes = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  return heroes.filter(h => {
    const rankOk = rankFilter.value === 'all' || h.rank === rankFilter.value
    const kwOk = !kw ||
      h.name.toLowerCase().includes(kw) ||
      h.alias.toLowerCase().includes(kw) ||
      h.tag.toLowerCase().includes(kw)
    return rankOk && kwOk
  })
})

const memberNo = computed(() => 'HA-' + String(props.hero?.id ?? 0).padStart(4, '0'))
const userRank = computed(() => rankMeta[props.hero?.heroClass] || rankMeta.C)

function doSearch() {
  // 输入即实时过滤，按钮点击时给一个聚焦反馈即可
}
</script>

<template>
  <div class="home">
    <div class="dots"></div>

    <!-- ===== 顶部导航栏 ===== -->
    <header class="navbar">
      <div class="logo">
        <span class="logo-punch">一拳</span>
        <div class="logo-text">
          <strong>英雄协会</strong>
          <small>HERO ASSOCIATION</small>
        </div>
      </div>

      <nav class="menu">
        <a
          v-for="(item, i) in navItems"
          :key="item"
          href="#"
          :class="{ active: i === 0 }"
          @click.prevent
        >{{ item }}</a>
      </nav>

      <div class="user-chip">
        <span class="avatar" :style="{ background: userRank.color }">{{ hero.heroClass }}</span>
        <div class="who">
          <strong>{{ hero.username }}</strong>
          <small>{{ memberNo }}</small>
        </div>
        <button class="btn-logout" @click="emit('logout')">退出</button>
      </div>
    </header>

    <!-- ===== 搜索区 ===== -->
    <section class="hero-zone">
      <h1 class="big-title">英雄<span>图鉴</span></h1>
      <p class="slogan">兴趣使然的英雄们，都在这里集结</p>

      <div class="search-bar">
        <input
          v-model="keyword"
          type="text"
          placeholder="搜索英雄 / 称号 / 关键词，比如：龙卷、S级、球棒…"
          @keyup.enter="doSearch"
        />
        <button class="btn-search" @click="doSearch">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round">
            <circle cx="10.5" cy="10.5" r="6.5"/>
            <path d="M15.5 15.5 L21 21"/>
          </svg>
          搜索
        </button>
      </div>

      <div class="chips">
        <button
          v-for="chip in rankChips"
          :key="chip.key"
          class="chip"
          :class="{ on: rankFilter === chip.key }"
          @click="rankFilter = chip.key"
        >{{ chip.label }}</button>
        <span class="count">共 {{ filteredHeroes.length }} 位英雄</span>
      </div>
    </section>

    <!-- ===== 英雄卡片墙 ===== -->
    <main class="grid">
      <article v-for="h in filteredHeroes" :key="h.name" class="hero-card">
        <div class="hc-avatar" :style="{ background: rankMeta[h.rank].color }">
          <span>{{ h.rank }}</span>
        </div>
        <div class="hc-body">
          <div class="hc-name">{{ h.name }}</div>
          <div class="hc-alias">{{ h.alias }}</div>
          <div class="hc-tag">{{ h.tag }}</div>
        </div>
        <div class="hc-rank" :style="{ color: rankMeta[h.rank].color }">{{ rankMeta[h.rank].label }}</div>
      </article>

      <!-- 空结果 -->
      <div v-if="filteredHeroes.length === 0" class="empty">
        <div class="empty-boom">轰！</div>
        <p>没有找到相关英雄 —— 可能已经被琦玉一拳清场了</p>
        <button class="chip on" @click="keyword = ''; rankFilter = 'all'">查看全部英雄</button>
      </div>
    </main>

    <footer class="foot">
      HERO ASSOCIATION · 英雄协会总部 · 灾害等级：今日平和
    </footer>
  </div>
</template>

<style scoped>
/* ===== 整页容器：亮黄漫画底 ===== */
.home {
  position: fixed;
  inset: 0;
  z-index: 5;
  overflow-y: auto;
  background: #f7c948;
  background-image:
    radial-gradient(rgba(20, 16, 14, .10) 1.5px, transparent 1.5px),
    linear-gradient(#f7c948, #f2b93b);
  background-size: 22px 22px, 100% 100%;
  display: flex;
  flex-direction: column;
}
.dots { display: none; }

/* ===== 导航栏 ===== */
.navbar {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  gap: 28px;
  padding: 0 28px;
  height: 68px;
  background: #fdf6e3;
  border-bottom: 4px solid #14100e;
  box-shadow: 0 4px 0 rgba(20, 16, 14, .18);
}
.logo { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
.logo-punch {
  background: #d03a2c;
  color: #fff;
  font-size: 15px;
  font-weight: 900;
  padding: 7px 9px;
  border: 3px solid #14100e;
  border-radius: 4px;
  transform: rotate(-3deg);
  box-shadow: 3px 3px 0 #14100e;
  letter-spacing: 2px;
}
.logo-text { display: flex; flex-direction: column; line-height: 1.1; }
.logo-text strong { font-size: 18px; font-weight: 900; color: #14100e; letter-spacing: 3px; }
.logo-text small { font-size: 10px; font-weight: 700; color: #d03a2c; letter-spacing: 2px; }

.menu { display: flex; gap: 4px; flex: 1; }
.menu a {
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 800;
  color: #14100e;
  text-decoration: none;
  letter-spacing: 2px;
  border: 3px solid transparent;
  border-radius: 4px;
  transition: all .12s;
}
.menu a:hover { border-color: #14100e; background: #f7c948; transform: translateY(-2px); }
.menu a.active {
  background: #14100e;
  color: #f7c948;
  border-color: #14100e;
  box-shadow: 3px 3px 0 rgba(20, 16, 14, .3);
}

.user-chip { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
.avatar {
  width: 38px; height: 38px;
  border: 3px solid #14100e;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-weight: 900; font-size: 16px;
  text-shadow: 1px 1px 0 rgba(0,0,0,.35);
}
.who { display: flex; flex-direction: column; line-height: 1.15; }
.who strong { font-size: 13px; font-weight: 800; color: #14100e; }
.who small { font-size: 10px; font-weight: 700; color: #8a7a63; letter-spacing: 1px; }
.btn-logout {
  margin-left: 4px;
  padding: 7px 14px;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 2px;
  color: #14100e;
  background: #fff;
  border: 3px solid #14100e;
  border-radius: 4px;
  cursor: pointer;
  transition: all .12s;
}
.btn-logout:hover { background: #14100e; color: #fdf6e3; }

/* ===== 搜索区 ===== */
.hero-zone {
  text-align: center;
  padding: 56px 24px 30px;
}
.big-title {
  font-size: 52px;
  font-weight: 900;
  color: #14100e;
  letter-spacing: 10px;
  text-shadow: 4px 4px 0 rgba(208, 58, 44, .35);
}
.big-title span { color: #d03a2c; }
.slogan {
  margin: 12px 0 30px;
  font-size: 14px;
  font-weight: 700;
  color: rgba(20, 16, 14, .6);
  letter-spacing: 4px;
}

.search-bar {
  display: flex;
  max-width: 560px;
  margin: 0 auto;
  background: #fdf6e3;
  border: 4px solid #14100e;
  border-radius: 6px;
  box-shadow: 7px 7px 0 #14100e;
  overflow: hidden;
}
.search-bar input {
  flex: 1;
  border: none;
  outline: none;
  background: transparent;
  padding: 15px 18px;
  font-size: 15px;
  font-weight: 600;
  color: #14100e;
  font-family: inherit;
}
.search-bar input::placeholder { color: rgba(20, 16, 14, .38); }
.btn-search {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 0 24px;
  font-size: 15px;
  font-weight: 900;
  letter-spacing: 3px;
  color: #fff;
  background: #d03a2c;
  border: none;
  border-left: 4px solid #14100e;
  cursor: pointer;
  transition: background .12s;
}
.btn-search:hover { background: #b52c20; }
.btn-search:active { transform: translateX(2px); }

.chips {
  margin-top: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  flex-wrap: wrap;
}
.chip {
  padding: 6px 16px;
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 2px;
  color: #14100e;
  background: #fdf6e3;
  border: 3px solid #14100e;
  border-radius: 999px;
  cursor: pointer;
  transition: all .12s;
}
.chip:hover { transform: translateY(-2px); box-shadow: 3px 3px 0 #14100e; }
.chip.on { background: #14100e; color: #f7c948; }
.count {
  font-size: 12px;
  font-weight: 700;
  color: rgba(20, 16, 14, .55);
  letter-spacing: 1px;
  margin-left: 8px;
}

/* ===== 英雄卡片墙 ===== */
.grid {
  flex: 1;
  max-width: 1080px;
  width: 100%;
  margin: 0 auto;
  padding: 20px 28px 50px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 18px;
}
.hero-card {
  position: relative;
  display: flex;
  gap: 14px;
  padding: 16px;
  background: #fdf6e3;
  border: 4px solid #14100e;
  border-radius: 8px;
  box-shadow: 6px 6px 0 rgba(20, 16, 14, .85);
  transition: transform .12s, box-shadow .12s;
  cursor: pointer;
}
.hero-card:hover {
  transform: translate(-3px, -3px);
  box-shadow: 9px 9px 0 rgba(20, 16, 14, .85);
}
.hero-card:active {
  transform: translate(2px, 2px);
  box-shadow: 3px 3px 0 rgba(20, 16, 14, .85);
}
.hc-avatar {
  flex-shrink: 0;
  width: 56px;
  height: 56px;
  border: 3px solid #14100e;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.hc-avatar span {
  font-size: 26px;
  font-weight: 900;
  color: #fff;
  text-shadow: 2px 2px 0 rgba(0, 0, 0, .35);
}
.hc-body { flex: 1; min-width: 0; }
.hc-name { font-size: 17px; font-weight: 900; color: #14100e; letter-spacing: 1px; }
.hc-alias { font-size: 11px; font-weight: 700; color: #d03a2c; letter-spacing: 1px; margin: 2px 0 6px; }
.hc-tag { font-size: 12px; font-weight: 600; color: #6b5d4f; line-height: 1.6; }
.hc-rank {
  position: absolute;
  top: 10px;
  right: 12px;
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 1px;
}

/* 空结果 */
.empty {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px 20px;
  background: #fdf6e3;
  border: 4px dashed #14100e;
  border-radius: 10px;
}
.empty-boom {
  font-size: 60px;
  font-weight: 900;
  color: #d03a2c;
  -webkit-text-stroke: 2px #14100e;
  transform: rotate(-6deg);
  margin-bottom: 14px;
}
.empty p {
  font-size: 14px;
  font-weight: 700;
  color: #6b5d4f;
  letter-spacing: 2px;
  margin-bottom: 20px;
}

/* 页脚 */
.foot {
  padding: 18px;
  text-align: center;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 3px;
  color: rgba(20, 16, 14, .5);
  border-top: 3px solid rgba(20, 16, 14, .2);
}

@media (max-width: 760px) {
  .menu { display: none; }
  .who { display: none; }
  .big-title { font-size: 36px; }
}
</style>
