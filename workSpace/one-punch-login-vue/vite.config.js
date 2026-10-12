import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      // 前端请求 /api 时转发到 Spring Boot 后端，解决跨域
      // 用 127.0.0.1 而不是 localhost：避免 Node 把 localhost 解析成 IPv6(::1) 导致连不上
      '/api': {
        target: 'http://127.0.0.1:8080',
        changeOrigin: true
      }
    }
  }
})
