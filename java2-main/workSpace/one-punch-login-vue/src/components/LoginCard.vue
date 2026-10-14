<script setup>
import { ref } from 'vue'

// 登录卡片组件
// emits:
//   focus-change - 输入框聚焦/失焦，用于切换琦玉"认真脸"
//   submit       - 提交登录 { username, password }
//   go-register  - 点击"注册英雄账号"
const emit = defineEmits(['focus-change', 'submit', 'go-register'])

const props = defineProps({
  // 登录结果提示 { text, type: 'err' | 'ok' }
  message: { type: Object, default: null },
  // 按钮是否处于"出拳"动画状态
  hitting: { type: Boolean, default: false }
})

const username = ref('')
const password = ref('')

function onSubmit() {
  emit('submit', { username: username.value.trim(), password: password.value.trim() })
}

function toastLink(text) {
  emit('submit', { username: '', password: '', linkTip: text })
}
</script>

<template>
  <div class="card">
    <h1>英雄<span>登录</span></h1>
    <p class="sub">登录英雄协会，登记你的英雄名号</p>

    <form autocomplete="off" @submit.prevent="onSubmit">
      <div class="field">
        <label>英雄代号</label>
        <input
          v-model="username"
          type="text"
          placeholder="例：秃头披风侠"
          @focus="emit('focus-change', true)"
          @blur="emit('focus-change', false)"
        >
      </div>
      <div class="field">
        <label>密　　码</label>
        <input
          v-model="password"
          type="password"
          placeholder="输入你的秘密口令"
          @focus="emit('focus-change', true)"
          @blur="emit('focus-change', false)"
        >
      </div>
      <button type="submit" class="btn-punch" :class="{ hit: hitting }">
        认真登录
        <span class="boom"></span>
      </button>
    </form>

    <div class="msg" :class="message?.type">{{ message?.text }}</div>

    <div class="links">
      <a href="#" @click.prevent="emit('go-register')">注册英雄账号</a>
      <a href="#" @click.prevent="toastLink('连琦玉老师都不会忘记密码哦')">忘记密码</a>
    </div>

    <div class="ok-stamp">OK</div>
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
  content: "HERO ASSOCIATION";
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
  margin: 6px 0 26px;
  font-size: 13px;
  color: #8a7a63;
  letter-spacing: 1px;
}

.field { margin-bottom: 18px; }
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
  padding: 13px 14px;
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

.links {
  margin-top: 20px;
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
  font-size: 30px;
  font-weight: 900;
  display: flex;
  align-items: center;
  justify-content: center;
  transform: rotate(14deg);
  background: rgba(253, 246, 227, .9);
  letter-spacing: 2px;
}

.msg {
  margin-top: 14px;
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
