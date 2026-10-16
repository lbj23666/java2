<script setup>
import { ref } from 'vue'

// 注册卡片组件
// emits:
//   focus-change - 输入框聚焦/失焦，用于切换琦玉"认真脸"
//   submit       - 提交注册 { codename, email, password, heroClass }
//   go-login     - 点击"返回登录"
const emit = defineEmits(['focus-change', 'submit', 'go-login'])

defineProps({
  // 注册结果提示 { text, type: 'err' | 'ok' }
  message: { type: Object, default: null },
  // 按钮是否处于"出拳"动画状态
  hitting: { type: Boolean, default: false }
})

const codename = ref('')
const email = ref('')
const password = ref('')
const confirmPwd = ref('')
const heroClass = ref('C')

const classOptions = [
  { value: 'C', label: 'C级 · 新人英雄' },
  { value: 'B', label: 'B级 · 小有名气' },
  { value: 'A', label: 'A级 · 精英英雄' },
  { value: 'S', label: 'S级 · 传说存在' }
]

function onSubmit() {
  emit('submit', {
    codename: codename.value.trim(),
    email: email.value.trim(),
    password: password.value,
    confirmPwd: confirmPwd.value,
    heroClass: heroClass.value
  })
}
</script>

<template>
  <div class="card">
    <h1>英雄<span>注册</span></h1>
    <p class="sub">加入英雄协会，开启你的英雄之路</p>

    <form autocomplete="off" @submit.prevent="onSubmit">
      <div class="field">
        <label>英雄代号</label>
        <input
          v-model="codename"
          type="text"
          placeholder="例：秃头披风侠"
          @focus="emit('focus-change', true)"
          @blur="emit('focus-change', false)"
        >
      </div>
      <div class="field">
        <label>联络邮箱</label>
        <input
          v-model="email"
          type="email"
          placeholder="hero@association.com"
          @focus="emit('focus-change', true)"
          @blur="emit('focus-change', false)"
        >
      </div>
      <div class="field">
        <label>密　　码</label>
        <input
          v-model="password"
          type="password"
          placeholder="至少 6 位"
          @focus="emit('focus-change', true)"
          @blur="emit('focus-change', false)"
        >
      </div>
      <div class="field">
        <label>确认密码</label>
        <input
          v-model="confirmPwd"
          type="password"
          placeholder="再输入一次密码"
          @focus="emit('focus-change', true)"
          @blur="emit('focus-change', false)"
        >
      </div>
      <div class="field">
        <label>申请等级</label>
        <div class="class-picker">
          <button
            v-for="opt in classOptions"
            :key="opt.value"
            type="button"
            class="class-chip"
            :class="{ active: heroClass === opt.value }"
            @click="heroClass = opt.value"
          >{{ opt.value }}</button>
        </div>
        <p class="class-tip">{{ classOptions.find(o => o.value === heroClass).label }}</p>
      </div>
      <button type="submit" class="btn-punch" :class="{ hit: hitting }">
        认真注册
        <span class="boom"></span>
      </button>
    </form>

    <div class="msg" :class="message?.type">{{ message?.text }}</div>

    <div class="links">
      <a href="#" @click.prevent="emit('go-login')">已有账号？返回登录</a>
      <a href="#" @click.prevent="emit('go-login')">先随便看看</a>
    </div>

    <div class="ok-stamp">参上</div>
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
  content: "HERO REGISTRY";
  position: absolute;
  top: -16px;
  left: 24px;
  background: var(--saitama-yellow-deep);
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
  margin: 6px 0 22px;
  font-size: 13px;
  color: #8a7a63;
  letter-spacing: 1px;
}

.field { margin-bottom: 14px; }
.field label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  color: var(--ink);
  letter-spacing: 2px;
  margin-bottom: 8px;
}
.field input {
  width: 100%;
  padding: 12px 14px;
  font-size: 15px;
  border: 3px solid var(--ink);
  border-radius: 4px;
  background: #fff;
  outline: none;
  transition: box-shadow .15s, transform .15s;
}
.field input:focus {
  box-shadow: 4px 4px 0 var(--saitama-yellow);
  transform: translate(-2px, -2px);
}

/* 等级选择 */
.class-picker {
  display: flex;
  gap: 8px;
}
.class-chip {
  flex: 1;
  padding: 9px 0;
  font-size: 16px;
  font-weight: 900;
  color: var(--ink);
  background: #fff;
  border: 3px solid var(--ink);
  border-radius: 4px;
  cursor: pointer;
  transition: all .12s;
}
.class-chip:hover { transform: translateY(-2px); }
.class-chip.active {
  background: var(--saitama-yellow);
  box-shadow: 3px 3px 0 var(--ink);
  transform: translate(-1px, -1px);
}
.class-chip.active:last-child {
  background: var(--cape-red);
  color: #fff;
}
.class-tip {
  margin-top: 7px;
  font-size: 12px;
  color: #8a7a63;
  letter-spacing: 1px;
}

.btn-punch {
  width: 100%;
  margin-top: 6px;
  padding: 14px;
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

.links {
  margin-top: 18px;
  display: flex;
  justify-content: space-between;
  font-size: 13px;
}
.links a {
  color: #8a7a63;
  text-decoration: none;
  font-weight: 600;
}
.links a:hover { color: var(--cape-red); text-decoration: underline; }

.ok-stamp {
  position: absolute;
  right: -22px;
  bottom: -22px;
  width: 84px;
  height: 84px;
  border: 5px solid var(--cape-red);
  border-radius: 50%;
  color: var(--cape-red);
  font-size: 24px;
  font-weight: 900;
  display: flex;
  align-items: center;
  justify-content: center;
  transform: rotate(14deg);
  background: rgba(253, 246, 227, .9);
  letter-spacing: 2px;
}

.msg {
  margin-top: 12px;
  min-height: 20px;
  text-align: center;
  font-size: 13px;
  font-weight: 700;
}
.msg.err { color: var(--cape-red); }
.msg.ok  { color: #2f8f46; }

@media (max-width: 800px) {
  .card { width: 92vw; max-width: 380px; }
}
</style>
