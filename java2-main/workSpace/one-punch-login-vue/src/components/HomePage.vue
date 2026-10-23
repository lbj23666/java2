<script setup>
// 英雄协会首页（登录成功后进入）
// 风格：一拳超人海报风 —— 亮黄底、粗黑描边、漫画网点、红/绿/紫点缀
// 功能：顶部导航栏（板块切换 + 当前英雄 + 退出）
//       首页：四大板块入口 + 跨板块全局搜索
//       各板块：关键词搜索 + 该板块专属筛选 + 排序 + 结果高亮
// props:
//   hero - 登录返回的英雄信息 { id, username, email, heroClass }
// emits:
//   logout - 退出登录
import { computed, ref, watch } from 'vue'
import SearchPanel from './SearchPanel.vue'
import ResultCard from './ResultCard.vue'
import { catalog, LEVEL_ORDER, itemSearchText } from '../data/catalog'
import { matches } from '../utils/search'

const props = defineProps({
  hero: { type: Object, required: true }
})
const emit = defineEmits(['logout'])

const sections = catalog

// 首页用的「伪板块」：没有筛选和排序，只做跨板块关键词搜索
const homeSection = {
  key: 'home',
  label: '全部板块',
  placeholder: '跨板块搜索：英雄、怪人、灾害、公告…',
  hotwords: ['琦玉', '龙级', '在逃', '紧急', 'A市'],
  filters: [],
  sorts: []
}

const activeKey = ref('home')
const keyword = ref('')
const filters = ref({})
const sortKey = ref('')

const current = computed(() => sections.find((s) => s.key === activeKey.value))

/** 板块已配置的所有筛选组，值默认 all */
function defaultFilters(section) {
  const f = {}
  section.filters.forEach((g) => { f[g.key] = 'all' })
  return f
}

// 切换板块时重置关键词与筛选，避免上一板块的条件残留
watch(activeKey, (key) => {
  const s = sections.find((x) => x.key === key)
  keyword.value = ''
  if (s) {
    filters.value = defaultFilters(s)
    sortKey.value = s.sorts[0]?.k || ''
  } else {
    filters.value = {}
    sortKey.value = ''
  }
}, { immediate: true })

/** 通用比较器：各板块的 sorts key 在这里统一解释 */
function comparator(section, key) {
  const ord = LEVEL_ORDER[section.key] || {}
  if (key === 'name') return (a, b) => String(a.name).localeCompare(String(b.name), 'zh-Hans-CN')
  if (key === 'time') return (a, b) => (b.ts || 0) - (a.ts || 0)
  if (key === 'power' || key === 'bounty') return (a, b) => (b.weight || 0) - (a.weight || 0)
  // 默认按等级降序，同等级再按权重降序
  return (a, b) =>
    (ord[b.level] ?? 0) - (ord[a.level] ?? 0) || (b.weight || 0) - (a.weight || 0)
}

/** 在单个板块内搜索（关键词 + 该板块筛选 + 排序） */
function searchIn(section, kw = keyword.value, state = null) {
  let list = section.items.filter((it) =>
    section.filters.every((g) => {
      const selected = state ? state[g.key] : filters.value[g.key]
      return !selected || selected === 'all' || it[g.key] === selected
    })
  )
  if (String(kw ?? '').trim()) {
    list = list.filter((it) => matches(itemSearchText(it, section), kw))
  }
  const cmp = comparator(section, section === current.value ? sortKey.value : section.sorts[0]?.k)
  return cmp ? [...list].sort(cmp) : list
}

const results = computed(() => (current.value ? searchIn(current.value) : []))

// 首页跨板块搜索：按板块分组，只保留有命中的板块
const grouped = computed(() => {
  const kw = keyword.value
  if (!String(kw ?? '').trim()) return []
  return sections
    .map((s) => ({ section: s, hits: searchIn(s, kw, {}) }))
    .filter((g) => g.hits.length > 0)
})

const totalHits = computed(() => grouped.value.reduce((n, g) => n + g.hits.length, 0))

const activeFilterCount = computed(() =>
  current.value
    ? current.value.filters.filter((g) => filters.value[g.key] && filters.value[g.key] !== 'all').length
    : 0
)

function selectSection(key) {
  activeKey.value = key
}

function resetAll() {
  keyword.value = ''
  if (current.value) filters.value = defaultFilters(current.value)
}

const memberNo = computed(() => 'HA-' + String(props.hero?.id ?? 0).padStart(4, '0'))
const userRankColor = computed(() => {
  const map = { S: '#d03a2c', A: '#2a6fb8', B: '#2f8f46', C: '#8a7a63' }
  return map[props.hero?.heroClass] || map.C
})
</script>

<template>
  <div class="home">
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
          href="#"
          class="nav-item"
          :class="{ active: activeKey === 'home' }"
          @click.prevent="selectSection('home')"
        >首页</a>
        <a
          v-for="s in sections"
          :key="s.key"
          href="#"
          class="nav-item"
          :class="{ active: activeKey === s.key }"
          @click.prevent="selectSection(s.key)"
        >{{ s.label }}</a>
      </nav>

      <div class="user-chip">
        <span class="avatar" :style="{ background: userRankColor }">{{ hero.heroClass }}</span>
        <div class="who">
          <strong>{{ hero.username }}</strong>
          <small>{{ memberNo }}</small>
        </div>
        <button class="btn-logout" @click="emit('logout')">退出</button>
      </div>
    </header>

    <!-- ===== 首页：概览 + 跨板块搜索 ===== -->
    <section v-if="activeKey === 'home'" class="hero-zone">
      <h1 class="big-title">英雄<span>协会</span></h1>
      <p class="slogan">四大板块，一拳掌握 · Ctrl+K 快速搜索</p>

      <SearchPanel
        :keyword="keyword"
        :section="homeSection"
        :filters="filters"
        :sort-key="sortKey"
        :count="totalHits"
        :total="sections.reduce((n, s) => n + s.items.length, 0)"
        @update:keyword="keyword = $event"
        @update:filters="filters = $event"
        @update:sort-key="sortKey = $event"
      />

      <!-- 跨板块搜索结果 -->
      <div v-if="keyword.trim()" class="grouped">
        <p v-if="totalHits === 0" class="no-hit">
          没有找到「{{ keyword }}」相关内容 —— 也许已经被琦玉一拳清场了
        </p>
        <div v-for="g in grouped" :key="g.section.key" class="group">
          <div class="group-head">
            <span class="g-icon" :style="{ background: g.section.accent }">{{ g.section.icon }}</span>
            <strong>{{ g.section.label }}</strong>
            <span class="g-count">{{ g.hits.length }} 条</span>
            <button class="g-more" @click="selectSection(g.section.key)">查看全部 →</button>
          </div>
          <div class="grid">
            <ResultCard
              v-for="it in g.hits.slice(0, 4)"
              :key="it.id"
              :item="it"
              :section="g.section"
              :keyword="keyword"
            />
          </div>
        </div>
      </div>

      <!-- 板块入口 -->
      <div v-else class="entries">
        <button
          v-for="s in sections"
          :key="s.key"
          class="entry"
          :style="{ '--accent': s.accent }"
          @click="selectSection(s.key)"
        >
          <span class="e-icon" :style="{ background: s.accent }">{{ s.icon }}</span>
          <strong>{{ s.label }}</strong>
          <small>{{ s.slogan }}</small>
          <span class="e-count">{{ s.items.length }} {{ s.unit }}</span>
        </button>
      </div>
    </section>

    <!-- ===== 各板块搜索区 ===== -->
    <section v-else class="hero-zone">
      <h1 class="big-title">{{ current.title }}<span>{{ current.titleAccent }}</span></h1>
      <p class="slogan">{{ current.slogan }}</p>

      <SearchPanel
        :keyword="keyword"
        :section="current"
        :filters="filters"
        :sort-key="sortKey"
        :count="results.length"
        :total="current.items.length"
        @update:keyword="keyword = $event"
        @update:filters="filters = $event"
        @update:sort-key="sortKey = $event"
      />
    </section>

    <!-- ===== 结果卡片墙 ===== -->
    <main v-if="activeKey !== 'home'" class="grid">
      <ResultCard
        v-for="it in results"
        :key="it.id"
        :item="it"
        :section="current"
        :keyword="keyword"
      />

      <div v-if="results.length === 0" class="empty">
        <div class="empty-boom">轰！</div>
        <p>
          没有找到「{{ keyword || '当前筛选条件' }}」相关的{{ current.unit }}
          —— 可能已经被琦玉一拳清场了
        </p>
        <button class="chip on" @click="resetAll">查看全部{{ current.unit }}</button>
      </div>
    </main>

    <footer class="foot">
      HERO ASSOCIATION · 英雄协会总部 · 灾害等级：今日平和
      <span v-if="activeFilterCount"> · 已启用 {{ activeFilterCount }} 项筛选</span>
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
.nav-item {
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
.nav-item:hover { border-color: #14100e; background: #ffe9a3; transform: translateY(-2px); }
.nav-item.active {
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
  text-shadow: 1px 1px 0 rgba(0, 0, 0, .35);
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
  padding: 48px 24px 26px;
}
.big-title {
  font-size: 48px;
  font-weight: 900;
  color: #14100e;
  letter-spacing: 8px;
  text-shadow: 4px 4px 0 rgba(208, 58, 44, .35);
}
.big-title span { color: #d03a2c; }
.slogan {
  margin: 10px 0 26px;
  font-size: 13px;
  font-weight: 700;
  color: rgba(20, 16, 14, .6);
  letter-spacing: 3px;
}

/* ===== 板块入口卡片 ===== */
.entries {
  margin: 32px auto 0;
  max-width: 900px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}
.entry {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 22px 16px 18px;
  background: var(--paper);
  border: 4px solid var(--hero-dark);
  border-radius: 10px;
  box-shadow: 6px 6px 0 rgba(20, 16, 14, .85);
  cursor: pointer;
  font-family: inherit;
  transition: transform .12s, box-shadow .12s;
}
.entry:hover {
  transform: translate(-3px, -3px);
  box-shadow: 9px 9px 0 var(--accent);
}
.e-icon {
  width: 46px; height: 46px;
  display: flex; align-items: center; justify-content: center;
  font-size: 22px; font-weight: 900; color: #fff;
  border: 3px solid var(--hero-dark);
  border-radius: 50%;
  text-shadow: 1px 1px 0 rgba(0, 0, 0, .3);
}
.entry strong { font-size: 16px; font-weight: 900; letter-spacing: 2px; color: var(--hero-dark); }
.entry small { font-size: 11px; font-weight: 600; color: #6b5d4f; line-height: 1.5; text-align: center; }
.e-count {
  margin-top: 4px;
  padding: 3px 12px;
  font-size: 11px; font-weight: 800; letter-spacing: 1px;
  color: var(--hero-dark);
  background: var(--saitama-yellow);
  border: 2px solid var(--hero-dark);
  border-radius: 999px;
}

/* ===== 跨板块分组结果 ===== */
.grouped { max-width: 1080px; margin: 30px auto 0; padding: 0 28px; text-align: left; }
.group { margin-bottom: 26px; }
.group-head {
  display: flex; align-items: center; gap: 10px;
  padding-bottom: 8px; margin-bottom: 14px;
  border-bottom: 3px solid rgba(20, 16, 14, .25);
}
.g-icon {
  width: 28px; height: 28px;
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; font-weight: 900; color: #fff;
  border: 2px solid var(--hero-dark); border-radius: 50%;
}
.group-head strong { font-size: 15px; font-weight: 900; letter-spacing: 2px; color: var(--hero-dark); }
.g-count { font-size: 11px; font-weight: 700; color: rgba(20, 16, 14, .5); }
.g-more {
  margin-left: auto;
  padding: 4px 12px;
  font-size: 11px; font-weight: 800; letter-spacing: 1px;
  color: var(--cape-red);
  background: #fff;
  border: 2px solid var(--cape-red);
  border-radius: 4px;
  cursor: pointer;
  font-family: inherit;
}
.g-more:hover { background: var(--cape-red); color: #fff; }
.no-hit { text-align: center; font-size: 13px; font-weight: 700; color: #6b5d4f; padding: 30px 0; }

/* ===== 卡片墙 ===== */
.grid {
  max-width: 1080px;
  width: 100%;
  margin: 0 auto;
  padding: 20px 28px 50px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 18px;
}

/* 空结果 */
.empty {
  grid-column: 1 / -1;
  text-align: center;
  padding: 56px 20px;
  background: var(--paper);
  border: 4px dashed var(--hero-dark);
  border-radius: 10px;
}
.empty-boom {
  font-size: 56px;
  font-weight: 900;
  color: var(--cape-red);
  -webkit-text-stroke: 2px var(--hero-dark);
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
.chip {
  padding: 6px 16px;
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 2px;
  color: var(--hero-dark);
  background: var(--paper);
  border: 3px solid var(--hero-dark);
  border-radius: 999px;
  cursor: pointer;
  font-family: inherit;
  transition: all .12s;
}
.chip.on { background: var(--hero-dark); color: var(--saitama-yellow); }
.chip:hover { transform: translateY(-2px); box-shadow: 3px 3px 0 var(--hero-dark); }

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
  .big-title { font-size: 32px; letter-spacing: 4px; }
}
</style>
