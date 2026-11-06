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

/**
 * 任务中心总览：英雄经验档案 + 任务列表（含完成状态）+ 最近完成记录
 * @param {number|string} userId
 */
export function fetchTasks(userId) {
  return get(`/api/tasks?userId=${encodeURIComponent(userId)}`)
}

/**
 * 完成一个任务
 * @param {number|string} userId
 * @param {string} taskId 形如 t-01
 * @returns {Promise<{code:number,message:string,data:{expGained:number,leveledUp:boolean,levelBefore:number,levelAfter:number,profile:object}}>}
 */
export function completeTask(userId, taskId) {
  return request('/api/tasks/complete', { userId, taskId })
}

// ============================================================
// 任务 2.0：任务板 + 互动流程
// ============================================================

/** 任务板：委托列表（可接取 / 进行中）+ 已完成 + 英雄档案 */
export function fetchMissionBoard(userId) {
  return get('/api/mission/board?userId=' + encodeURIComponent(userId))
}

/** 刷新任务板，抽出一批新任务 */
export function refreshMissions(userId) {
  return request('/api/mission/refresh', { userId })
}

/** 接取委托，返回开场剧情与全部回合（不含答案分数） */
export function startMission(userId, offerId) {
  return request('/api/mission/start', { userId, offerId })
}

/** 提交一个回合的选择，返回这一行动的反馈 */
export function answerMission(userId, offerId, seq, choice) {
  return request('/api/mission/answer', { userId, offerId, seq, choice })
}

/** 结算委托：按评分发经验，可能升级 */
export function settleMission(userId, offerId) {
  return request('/api/mission/settle', { userId, offerId })
}

/** 放弃进行中的委托 */
export function abandonMission(userId, offerId) {
  return request('/api/mission/abandon', { userId, offerId })
}
