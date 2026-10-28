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

async function get(url) {
  const resp = await fetch(url, { method: 'GET' })
  if (!resp.ok) {
    throw new Error(`网络异常（HTTP ${resp.status}），请确认后端已启动`)
  }
  return resp.json()
}

async function del(url) {
  const resp = await fetch(url, { method: 'DELETE' })
  if (!resp.ok) {
    throw new Error(`网络异常（HTTP ${resp.status}），请确认后端已启动`)
  }
  return resp.json()
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

/**
 * 首页四大板块全量数据（英雄名录 / 怪人档案 / 灾害警报 / 协会公告）
 * @returns {Promise<{ code: number, message: string, data: Record<string, any[]> }>}
 */
export function fetchCatalog() {
  return get('/api/catalog')
}

/**
 * 单板块查询（带筛选与排序，可选分页）
 * @param {'heroes'|'monsters'|'disasters'|'notices'} section
 * @param {Record<string, string|number>} params 如 { level: 'S', sort: 'power', page: 1, size: 5 }
 */
/**
 * 后台管理：查询某板块全部记录
 * @param {'heroes'|'monsters'|'disasters'|'notices'} section
 */
export function fetchAdminList(section) {
  return get(`/api/admin/list?section=${encodeURIComponent(section)}`)
}

/**
 * 后台管理：新增或更新一条记录（payload 带 id 为更新）
 * @param {Record<string, any>} payload 形如 { section: 'heroes', name: '...', level: 'S' }
 */
export function saveAdminItem(payload) {
  return request('/api/admin/save', payload)
}

/**
 * 后台管理：删除一条记录
 */
export function deleteAdminItem(section, id) {
  return del(`/api/admin/delete?section=${encodeURIComponent(section)}&id=${encodeURIComponent(id)}`)
}

export function fetchSection(section, params = {}) {
  const qs = Object.keys(params)
    .filter((k) => params[k] !== undefined && params[k] !== null && params[k] !== '')
    .map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`)
    .join('&')
  return get(`/api/${section}${qs ? '?' + qs : ''}`)
}
