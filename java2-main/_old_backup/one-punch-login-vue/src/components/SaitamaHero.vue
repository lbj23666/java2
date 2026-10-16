<script setup>
// 琦玉老师角色组件
// props:
//   serious  - 是否切换为"认真脸"（输入框聚焦时）
//   punching - 是否播放出拳动画（登录提交时）
defineProps({
  serious: { type: Boolean, default: false },
  punching: { type: Boolean, default: false }
})
</script>

<template>
  <div class="hero-side">
    <div class="saitama" :class="{ punch: punching }">
      <div class="cape"></div>
      <div class="body-suit"><div class="belt"></div></div>
      <div class="fist l"></div>
      <div class="fist r"></div>
      <div class="head">
        <div class="face" :class="{ serious }">
          <div class="brow l"></div>
          <div class="brow r"></div>
          <div class="eye l"></div>
          <div class="eye r"></div>
          <div class="nose"></div>
          <div class="mouth"></div>
        </div>
      </div>
    </div>
    <div class="hero-name">埼 玉</div>
    <div class="hero-rank">B级英雄 · 兴趣使然的英雄</div>
  </div>
</template>

<style scoped>
.hero-side {
  text-align: center;
  user-select: none;
}

.saitama {
  position: relative;
  width: 220px;
  height: 280px;
  margin: 0 auto;
  transition: transform .15s;
}
.saitama.punch {
  animation: punchShake .35s ease;
}
@keyframes punchShake {
  0%   { transform: translateX(0) rotate(0); }
  25%  { transform: translateX(-14px) rotate(-4deg); }
  50%  { transform: translateX(10px) rotate(3deg); }
  75%  { transform: translateX(-6px) rotate(-2deg); }
  100% { transform: translateX(0); }
}

/* 披风 */
.cape {
  position: absolute;
  top: 78px;
  left: 50%;
  width: 190px;
  height: 190px;
  transform: translateX(-50%);
  background: linear-gradient(160deg, #fff, #e8e2d5);
  border-radius: 40% 40% 55% 55% / 30% 30% 70% 70%;
  z-index: 1;
  animation: capeWave 3s ease-in-out infinite;
  filter: drop-shadow(0 10px 14px rgba(0, 0, 0, .45));
}
@keyframes capeWave {
  0%, 100% { transform: translateX(-50%) skewX(0deg); }
  50%      { transform: translateX(-52%) skewX(-3deg); }
}

/* 光头 */
.head {
  position: absolute;
  top: 8px;
  left: 50%;
  transform: translateX(-50%);
  width: 130px;
  height: 140px;
  background: radial-gradient(circle at 38% 30%, #ffe9c9, #f3cf9f 70%, #e5b988);
  border-radius: 48% 48% 46% 46% / 55% 55% 42% 42%;
  z-index: 3;
  box-shadow: inset -8px -10px 0 rgba(0, 0, 0, .06);
}

/* 脸部线条（极简画风） */
.face { position: absolute; inset: 0; z-index: 4; }
.brow, .eye, .nose, .mouth {
  position: absolute;
  background: var(--ink);
  transition: all .15s;
}
.brow.l { top: 52px; left: 30px;  width: 26px; height: 4px; border-radius: 2px; transform: rotate(6deg); }
.brow.r { top: 52px; right: 30px; width: 26px; height: 4px; border-radius: 2px; transform: rotate(-6deg); }
.eye.l  { top: 66px; left: 34px;  width: 18px; height: 4px; border-radius: 2px; }
.eye.r  { top: 66px; right: 34px; width: 18px; height: 4px; border-radius: 2px; }
.nose   { top: 78px; left: 50%; width: 3px;  height: 18px; transform: translateX(-50%); border-radius: 2px; }
.mouth  { top: 110px; left: 50%; width: 30px; height: 4px; transform: translateX(-50%); border-radius: 2px; }

/* 认真脸模式 */
.serious .brow.l { transform: rotate(20deg);  top: 48px; }
.serious .brow.r { transform: rotate(-20deg); top: 48px; }
.serious .eye.l, .serious .eye.r { height: 6px; }
.serious .mouth { width: 14px; height: 6px; border-radius: 50%; }

/* 身体（黄色紧身衣） */
.body-suit {
  position: absolute;
  top: 138px;
  left: 50%;
  transform: translateX(-50%);
  width: 110px;
  height: 120px;
  background: linear-gradient(180deg, var(--saitama-yellow), var(--saitama-yellow-deep));
  border-radius: 30px 30px 18px 18px;
  z-index: 2;
}
.belt {
  position: absolute;
  bottom: 34px;
  left: 0;
  right: 0;
  height: 14px;
  background: var(--ink);
}
.belt::after {
  content: "";
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 18px;
  height: 18px;
  background: var(--saitama-yellow);
  border-radius: 50%;
}

/* 红手套拳头 */
.fist {
  position: absolute;
  width: 46px;
  height: 46px;
  background: radial-gradient(circle at 35% 30%, #e85a4a, var(--cape-red));
  border-radius: 40% 40% 45% 45%;
  z-index: 3;
  box-shadow: 0 4px 8px rgba(0, 0, 0, .35);
}
.fist.l { top: 175px; left: 8px; }
.fist.r { top: 175px; right: 8px; transition: transform .12s; }
.saitama.punch .fist.r {
  animation: punchOut .35s ease;
}
@keyframes punchOut {
  0%   { transform: translate(0, 0) scale(1); }
  40%  { transform: translate(60px, -20px) scale(1.35); }
  100% { transform: translate(0, 0) scale(1); }
}

.hero-name {
  margin-top: 18px;
  color: var(--saitama-yellow);
  font-size: 22px;
  font-weight: 900;
  letter-spacing: 4px;
  text-shadow: 0 2px 0 rgba(0, 0, 0, .5);
}
.hero-rank {
  margin-top: 6px;
  display: inline-block;
  padding: 4px 14px;
  background: var(--cape-red);
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 2px;
  border-radius: 4px;
  transform: rotate(-2deg);
}

@media (max-width: 800px) {
  .saitama { transform: scale(.75); margin-bottom: -40px; }
}
</style>
