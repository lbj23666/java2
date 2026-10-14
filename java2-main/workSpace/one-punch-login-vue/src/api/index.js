// 后端接口封装
// 开发环境通过 Vite 代理将 /api 转发到 http://localhost:8080

async function request(url, body) {
  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  })
  if (!resp.ok) {
    throw new Error(`网络异常（HTTP ${resp.status}），请确认后端已启动`)
  }
  return resp.json() // 后端统一返回 { code, message, data }
}

/**
 * 登录
 * @param {{ username: string, password: string }} payload
 */
export function login(payload) {
  return request('/api/login', payload)
}

/**
 * 注册
 * @param {{ username: string, email: string, password: string, heroClass: string }} payload
 */
export function register(payload) {
  return request('/api/register', payload)
}
