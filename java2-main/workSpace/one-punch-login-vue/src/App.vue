<script setup>
import { ref } from 'vue'
import SaitamaHero from './components/SaitamaHero.vue'
import LoginCard from './components/LoginCard.vue'
import RegisterCard from './components/RegisterCard.vue'
import HomePage from './components/HomePage.vue'
import LoadingOverlay from './components/LoadingOverlay.vue'
import { login, register } from './api'
import { loadCatalog } from './data/catalog'

// 全局状态：协调琦玉动画与登录/注册/加载/主页
const view = ref('login')    // 当前视图：login | register | loading | home
const serious = ref(false)   // 认真脸
const punching = ref(false)  // 出拳动画
const hitting = ref(false)   // 按钮闪光
const showImpact = ref(false) // "轰！！"冲击波
const message = ref(null)    // 表单提示 { text, type }
const user = ref(null)       // 登录后的英雄信息 { id, username, email, heroClass }

let tipTimer = null
// 首页四大板块数据的加载 Promise（数据来源：后端 GET /api/catalog）
let catalogTask = null

function onFocusChange(focused) {
  serious.value = focused
}

function switchView(target) {
  view.value = target
  message.value = null
  serious.value = false
}

function triggerPunch() {
  punching.value = false
  // 强制重启动画
  requestAnimationFrame(() => { punching.value = true })
}

function punchEffect(done) {
  hitting.value = true
  triggerPunch()
  showImpact.value = true
  setTimeout(() => {
    hitting.value = false
    punching.value = false
    showImpact.value = false
    done?.()
  }, 750)
}

// ===== 登录 =====
async function onLogin({ username, password, linkTip }) {
  if (linkTip) {
    showTip(linkTip, 'err')
    return
  }
  if (!username || !password) {
    showTip('英雄代号和密码都不能为空！', 'err')
    triggerPunch()
    setTimeout(() => (punching.value = false), 400)
    return
  }

  punchEffect(async () => {
    try {
      const res = await login({ username, password })
      if (res.code === 200) {
        // 登录成功 → 先播放"接入英雄协会系统"加载动画，再进入首页
        user.value = res.data
        message.value = null
        // 趁加载动画这段时间把板块数据拉下来，动画结束即可直接渲染
        catalogTask = loadCatalog().catch((e) => {
          console.error('[catalog] 板块数据加载失败：', e)
          return -1
        })
        setTimeout(() => { view.value = 'loading' }, 350)
      } else {
        showTip(res.message || '登录失败', 'err')
      }
    } catch (e) {
      showTip(e.message || '无法连接英雄协会服务器', 'err')
    }
  })
}

// ===== 注册 =====
async function onRegister({ codename, email, password, confirmPwd, heroClass }) {
  if (!codename || !email || !password || !confirmPwd) {
    showTip('所有字段都要填写，英雄不能偷懒！', 'err')
    triggerPunch()
    setTimeout(() => (punching.value = false), 400)
    return
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    showTip('邮箱格式不对，协会联络不到你！', 'err')
    return
  }
  if (password.length < 6) {
    showTip('密码至少 6 位，太弱可挡不住怪人！', 'err')
    return
  }
  if (password !== confirmPwd) {
    showTip('两次密码不一致，再认真一点！', 'err')
    return
  }

  punchEffect(async () => {
    try {
      const res = await register({ username: codename, email, password, heroClass })
      if (res.code === 200) {
        showTip(`登记成功！${heroClass}级英雄「${codename}」，快去登录吧。`, 'ok')
        // 注册成功后自动跳回登录页
        setTimeout(() => switchView('login'), 1800)
      } else {
        showTip(res.message || '注册失败', 'err')
      }
    } catch (e) {
      showTip(e.message || '无法连接英雄协会服务器', 'err')
    }
  })
}

// ===== 加载动画完成 → 进入首页 =====
// 等板块数据到位再进首页（已 catch 过，不会 reject），失败则给提示后照常进入
async function onLoadingDone() {
  if (catalogTask) {
    const total = await catalogTask
    if (total === -1) {
      showTip('板块数据拉取失败，可检查后端 8080 是否正常', 'err')
    }
    catalogTask = null
  }
  view.value = 'home'
}

// ===== 首页 =====
function onLogout() {
  user.value = null
  view.value = 'login'
  serious.value = false
  message.value = null
}

function showTip(text, type) {
  message.value = { text, type }
  clearTimeout(tipTimer)
  if (type === 'err') {
    tipTimer = setTimeout(() => (message.value = null), 2500)
  }
}
</script>

<template>
  <div class="speed-lines"></div>
  <div class="halftone"></div>
  <div class="impact-text" :class="{ show: showImpact }">轰！！</div>

  <!-- 登录成功后的加载过渡动画 -->
  <LoadingOverlay v-if="view === 'loading'" @done="onLoadingDone" />

  <!-- 登录后的英雄协会首页（整页） -->
  <HomePage
    v-else-if="view === 'home'"
    :hero="user"
    @logout="onLogout"
  />

  <div v-else class="stage">
    <SaitamaHero :serious="serious" :punching="punching" />

    <LoginCard
      v-if="view === 'login'"
      :message="message"
      :hitting="hitting"
      @focus-change="onFocusChange"
      @submit="onLogin"
      @go-register="switchView('register')"
    />
    <RegisterCard
      v-else
      :message="message"
      :hitting="hitting"
      @focus-change="onFocusChange"
      @submit="onRegister"
      @go-login="switchView('login')"
    />
  </div>
</template>

<style scoped>
.stage {
  position: relative;
  z-index: 2;
  display: flex;
  align-items: center;
  gap: 60px;
  padding: 40px;
}

@media (max-width: 800px) {
  .stage { flex-direction: column; gap: 30px; }
}
</style>
