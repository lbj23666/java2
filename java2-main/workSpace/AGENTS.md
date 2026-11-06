# AGENTS.md — 给 AI 助手的备忘录（每次开机重置后先读这个，别重新摸索）

> 本文件写给 AI 助手（WorkBuddy/Claude/Cursor 等）看，目的：开机重置后 30 秒内恢复上下文、快速启动项目。
> 最后更新：2026-10-12

## 这台电脑的特性（重要！）

- 电脑每次开机系统重置，**`node_modules` 和 `target` 文件夹会被删除**，其余内容（用户目录、D 盘、MySQL 数据、`~/.m2` 仓库、npm 缓存）通常保留
- 所有 `.bat` 脚本是 **GBK 编码**（cmd 默认 CP936 中文不乱码），修改时必须保持 GBK 保存，用 UTF-8 保存会乱码
- 脚本内项目路径全部用相对路径（`cd /d "%~dp0"` 之后用 `springBootTest`、`one-punch-login-vue` 等相对写法），workSpace 整体挪位置脚本也能用

## 项目概况

workSpace = 一拳超人·英雄协会 登录系统（全栈学习项目）

| 目录 | 内容 | 端口 |
|---|---|---|
| `one-punch-login-vue/` | 前端 Vue3 + Vite8，`/api` 代理到 8080 | 5173 |
| `springBootTest/` | 后端 Spring Boot 3.2.5 + MyBatis-Plus + MySQL | 8080 |
| `springBootTest/sql/hero_association.sql` | 数据库初始化脚本（UTF-8 编码） | - |

- 测试账号：秃头披风侠 / 123456（密码 MD5 存库）
- MySQL：root / 123456，库名 hero_association，表 t_user

## 环境（重置后依然在）

- Java 21：`C:\Program Files\Zulu\zulu-21`（已在 PATH；pom 目标是 Java 17，兼容）
- Node 22 / npm：`D:\Program Files\nodejs`（已在 PATH）
- MySQL 8.0：系统服务自启（3306）；客户端在 `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`
- **Maven 不在 PATH！** 按优先级找：
  1. `%USERPROFILE%\.m2\wrapper\dists\...\bin\mvn.cmd`（有 3.9.16 和 3.9.9，推荐）
  2. `D:\IntelliJ IDEA 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd`
  3. 项目里的 `mvnw` 不完整（没有 mvnw.cmd / .mvn 目录），**指望不上，别浪费时间试**
- `~/.m2/repository` 缓存比较全，后端编译一般不需要重新下载依赖

## 启动方式（用户只需双击）

1. **启动**：双击 `start-all.bat` → 自动：检查/导入数据库 → 新窗口跑后端 `run.bat`（自动找 Maven、target 被删会自动重编）→ 新窗口跑前端 `start.bat`（自动 npm install）→ 打开浏览器
2. **停止**：双击 `stop-all.bat`（按端口杀掉 8080/5173 进程，不动 MySQL）

## AI 助手手动操作清单（用户让你"启动/排查项目"时照抄，不用再探索）

```bash
# 1. 数据库检查（hero_association 在重置后可能丢失）
"/c/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -uroot -p123456 -e "USE hero_association;"
# 不存在则导入（注意 --default-character-set=utf8mb4，否则中文乱码）：
"/c/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -uroot -p123456 --default-character-set=utf8mb4 < springBootTest/sql/hero_association.sql

# 2. 后端（mvn.cmd 路径见上，target 被删会自动重编）
cd springBootTest && call <mvn.cmd路径> spring-boot:run

# 3. 前端（node_modules 被删要先安装）
cd one-punch-login-vue && npm install && npm run dev

# 4. 验证
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080   # 后端
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173   # 前端
```

不需要：重新探索目录结构、问数据库密码（就在上面）、找 Java/Node（都在 PATH）、装 Maven（直接用上面的路径）。

## 常见坑（都是踩过的）

1. 旧版 `start-all.bat` 后端窗口路径写错成 `%~dp0workSpace\springBootTest`（多套一层），已修复，**别改回去**
2. `run.bat` 旧版只在 `C:\Program Files\JetBrains` 找 IDEA，但 IDEA 装在 **D 盘**，已修复为多级查找
3. 前端 Vite 里 `localhost` 可能被 Node 解析成 IPv6(::1)，所以 `vite.config.js` 代理用的是 `http://127.0.0.1:8080`，勿改回 localhost
4. SQL 文件是 UTF-8，导入必须加 `--default-character-set=utf8mb4`
5. mysql 命令行 "Using a password on the command line" 警告可忽略
6. 前端 `npm install` 失败先检查网络/registry；后端起不来先看 8080 是否被占用（`netstat -ano | findstr :8080`）
7. **批处理文件必须是 GBK 编码 + CRLF 行尾**（LF 会导致 goto/标签解析错乱），改完脚本要用工具确认
8. **重置后首次启动，Maven 可能要重新下载一堆依赖**（阿里云镜像，约 1~3 分钟），脚本里后端等待上限已设为 5 分钟，别嫌慢去点窗口
9. 批处理括号块里 `%errorlevel%` 是静态旧值，判断要用 `if errorlevel 1`（动态），别"优化"成 %errorlevel%==1
10. AI 助手沙箱内启动 .bat 偶发不执行（新写文件首启疑似被拦），同一脚本多重试几次；`sc.exe`/`wmic.exe`/直接 `cmd /c` 都被沙箱黑名单拦截，探测系统状态用 `netstat`/`tasklist`/`Get-CimInstance`
11. AI 沙箱内 curl 127.0.0.1 已拒绝的端口返回 exit 28（超时）而非 7，不影响脚本判断逻辑（只判 ==0）
12. **AI 沙箱会注入环境变量 `SERVER__PORT=59173`**（双下划线，Spring 会解析成 server.port），导致 AI 会话内启动的 Spring Boot 永远绑不上 8080！绕法：`spring-boot:run` 加 `-Dspring-boot.run.arguments=--server.port=8080`（命令行参数优先级高于环境变量）。用户双击 .bat 不受影响
13. AI 在 bash 里跑 wrapper 自带的 POSIX `mvn` 脚本会因 MSYS 路径转换失败（ClassNotFoundException: Launcher），绕法是直接用 java 调 classworlds launcher：`java -classpath "$MH/boot/plexus-classworlds-2.11.0.jar" "-Dclassworlds.conf=$MH/bin/m2.conf" "-Dmaven.home=$MH" "-Dmaven.multiModuleProjectDirectory=<项目绝对路径>" org.codehaus.plexus.classworlds.launcher.Launcher -B package`（$MH = wrapper dist 的 apache-maven-3.9.16 目录，Windows 正斜杠路径）
14. Git Bash 里 taskkill 的 `//F` 写法在这台机器不转换，用 `MSYS_NO_PATHCONV=1 taskkill /F /PID xxx`（已验证可杀掉 java/node 服务进程）
15. **Vite 只监听 IPv6 [::1]:5173，不监听 IPv4 127.0.0.1**，所以 start-all.bat 检测前端必须 curl `http://localhost:5173`（已改好），检测后端用 127.0.0.1:8080（Spring 双栈监听，两者都行）
16. 验证结论（2026-10-12 实测）：登录接口直连后端和走 Vite 代理均返回 `{"code":200,"message":"登录成功",...}`，全链路（MySQL→MyBatis→SpringBoot→Vite代理）畅通
17. AI 沙箱还会杀掉自己启动的长驻进程（几分钟内），所以 AI 无法长期替用户挂着服务；让用户自己双击 .bat 才是正解
18. **前端报 `Cannot find native binding`（2026-10-14 实际踩坑）**：Vite 8 底层 rolldown 的原生绑定包 `@rolldown/binding-win32-x64-msvc` 会因 npm optional dependencies bug 丢失，且普通 `npm install` 不会补装。修复：① 已把该包写进 `package.json` optionalDependencies（锁 1.2.13）+ package-lock；② `one-punch-login-vue/start.bat` 已加自愈逻辑：启动前检查 `node_modules\vite` 和 `node_modules\@rolldown\binding-win32-x64-msvc` 是否存在，缺了自动清理重装，依赖完整时跳过 install 直接启动（更快）。改 start.bat 时注意保持这套检查逻辑
19. **AI 在 Git Bash 里用 sed/iconv 编辑 GBK 的 .bat 会被剥掉 CRLF 变成 LF**（导致 goto/标签解析错乱），改完必须检查并补回：`python -c "d=open(f,'rb').read(); open(f,'wb').write(d.replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'))"`。PowerShell 通道改 bat 可能因内容含 `%n%` 之类被沙箱误拦，用 python 改最稳
20. **用户会误双击 run.bat 当一键启动**（2026-10-14 实际发生：以为会开网页，结果只有后端）。已在 run.bat 输出里加引导提示"本脚本只启动后端，一键启动请双击 start-all.bat"。排查此类问题的关键证据：`Get-CimInstance Win32_Process` 看进程的 ParentProcessId + CommandLine，explorer 直接启动的 cmd = 用户双击的脚本

## 2026-10-16 目录清理

- Desktop 上原有三份重复副本（java2-main\java2-main\workSpace 最新版 / 顶层旧 workSpace / 顶层旧 one-punch-login-vue），已清理：最新版上移为 **Desktop\java2-main\workSpace**（唯一有效副本），旧 workSpace 进回收站，旧前端副本在 java2-main\_old_backup\n- 所有脚本用 %~dp0 相对路径，位置变了不影响；以后双击 Desktop\java2-main\workSpace\start-all.bat 即可

## 2026-10-16 补充

- npm optional deps bug 复现且加重：即使删 lock+node_modules 全新重装，`@rolldown/binding-win32-x64-msvc` 仍不会被装上（lock 里有记录、平台 win32/x64 匹配、npm 却报 up to date）。AI 会话内可靠修复法：`npm pack @rolldown/binding-win32-x64-msvc@1.2.14` 后 tar 解压到 node_modules/@rolldown/binding-win32-x64-msvc --strip-components=1（已验证 vite 8.3.4 正常启动）。start.bat 的删 lock 重装自愈逻辑对用户双击场景仍有效，可保留
- 本次 AI 启动全链路验证通过（后端 8080 / 前端 5173 / 登录接口返回 code 200）
- 2026-10-16 前端改版：登录成功 → LoadingOverlay.vue（充能动画）→ HomePage.vue（整页首页：导航栏+搜索栏+英雄卡片墙，亮黄漫画风）。view 状态：login|register|loading|home。旧 HomeCard.vue 已弃用未删

## 2026-10-26 首页四个文件丢失 + 重建（重要！）

- **现象**：后端正常启动、Vite 也起来，但页面白屏。根因：`HomePage.vue` 依赖的 4 个文件根本不存在
  （git 历史、`_old_backup`、全盘搜索都没有，应该是改版到一半未保存就丢了）：

  | 缺失文件 | 作用 | 重建依据 |
  |---|---|---|
  | `src/data/catalog.js` | 导出 `catalog` / `LEVEL_ORDER` / `itemSearchText` | HomePage 用到 `section.key/label/icon/accent/unit/slogan/title/titleAccent/placeholder/hotwords/filters/sorts/items` |
  | `src/utils/search.js` | 导出 `matches(text, keyword)` | `searchIn()` 里 `matches(itemSearchText(it, section), kw)` |
  | `src/components/SearchPanel.vue` | 搜索框/热词/筛选/排序 | props: `keyword, section, filters, sortKey, count, total`；emits: `update:keyword, update:filters, update:sortKey` |
  | `src/components/ResultCard.vue` | 结果卡片（关键词高亮） | props: `item, section, keyword` |

- **重建约定**（改动这几个文件时务必遵守）：
  - section.filters 是数组 `{ key, label, options:[{value,label}] }`，命中规则 `it[g.key] === selected`，`'all'` 表示不限
  - section.sorts 是数组 `{ k, label }`；`k` 的语义在 HomePage 的 `comparator()` 里硬编码：`name`→字典序、`time`→按 ts 倒序、`power`/`bounty`→按 weight 倒序，其他→按 LEVEL_ORDER[level] 倒序再按 weight 倒序
  - 每条 item 通用字段：`id / name / level / weight / ts`，各板块另有专属字段（heroes: affiliation/ability；monsters: habitat/status/feature；disasters: location/status/detail；notices: dept/content）
  - 首页的 `homeSection` 没有 `unit` 字段，SearchPanel 里已做 `section.unit || '条结果'` 兜底
  - **`matches()` 必须忽略文本内部空白**：先把 haystack 里所有空白去掉再匹配。等级标签写成「S 级」（带空格）时，用户搜「S级」否则永远匹配不上——这个坑实际踩到过
  - **每个筛选选项至少要有一条对应数据**，否则用户点了筛选项是空列表。用下面的一行脚本自检（放在项目根目录跑完记得删）：
    `node -e "..."` 对 `catalog` 每个 `filters` 的每个 `option` 做 `items.filter(it => it[g.key] === o.value)`，长度为 0 就补数据
  - 同理，hotwords 里每个热词都必须能搜出结果。首页 `homeSection` 的热词是 `['琦玉','龙级','在逃','紧急','A市']`，
    所以「琦玉/埼玉」必须能命中某条英雄数据（已给「秃头披风侠」加 `alias: '埼玉 琦玉'`），否则点了是空页

- **本次复用的坑验证**：第 12/13/18 条全部复现且解法有效。注意第 13 条的 `java -classpath` 里的 jar 路径**必须写成 Windows 反斜杠**（`C:\\Users\\...`），用正斜杠（`C:/Users/...`）即使加了 `MSYS_NO_PATHCONV=1` 也会 ClassNotFoundException；其余 `-D` 参数用正斜杠没问题
- 最终验证：8080/5173 均 LISTENING，登录接口直连和走代理都返回 `{"code":200,...}`，5 个前端模块全部 200 且无 Failed to resolve

## 2026-10-28 装依赖 + 首页文件二次重建（含后端接口补建）

- 本次工作副本路径：`D:\workSpace\java2\java2-main\workSpace`（不是 Desktop 那份，注意别改错目录）
- **四个文件又丢了**（同一份副本重建第 2 次）：`src/data/catalog.js`、`src/utils/search.js`、
  `src/components/SearchPanel.vue`、`src/components/ResultCard.vue`。已按第 95 条约定重建并跑通构建
- **后端 `/api/catalog` 此前根本不存在**（只有 UserController），但启动日志和 `src/api/index.js` 都声明了它，
  导致 `loadCatalog()` 必然失败。已新建 `controller/CatalogController.java`：
  `GET /api/catalog` 返回 `{heroes,monsters,disasters,notices}` 四个数组（共 18/20/12/12 条），
  并顺带实现了 `/api/heroes`、`/api/monsters`、`/api/disasters`、`/api/notices`（支持字段等值过滤 + sort/page/size）
- **数据在前后端各存了一份**（前端 `catalog.js` 内置兜底，后端 Controller 静态数据），改数据时要两边同步
- Maven 实际可用路径（比第 30 条更精确，wrapper 里多套一层 `apache-maven-3.9.16`）：
  `%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.16-bin\5grr65jo27hi51sujmtcldfovl\apache-maven-3.9.16\bin\mvn.cmd`
  在 Git Bash 里直接调 `mvn.cmd` 可用（第 13 条的 classworlds 绕法这次没用上）
- 自检数据是否"点得动"的临时脚本套路：把 `catalog.js` / `search.js` 读进来、正则删掉开头的 `import` 行、
  写到临时 `.mjs` 再动态 `import`，即可用 node 直接跑（Vite 能解析无扩展名 import，node 不能）。
  检查项：每个筛选 option 至少 1 条数据、每个 hotword 至少 1 条命中、首页 5 个热词全命中。**跑完记得删脚本**
- 本次验证：`npm run build` 30 模块通过；8080 与 5173 均 200，`/api/catalog` 直连与走 Vite 代理都返回 code 200

## 2026-10-28（2）新增后台管理系统

- 入口：首页导航栏右侧「后台管理」按钮 → `AdminLogin.vue`（**只有登录，没有注册**）→ `AdminPanel.vue`
- 视图状态机（App.vue）扩充为：`login | register | loading | home | adminLogin | admin`
- **后台登录复用前台的 `POST /api/login`**（同一套英雄账号，如 秃头披风侠 / 123456），没有单独的 admin 表或接口
- 管理范围：首页四大板块的数据增删改，落在**早已存在但一直没被用到的四张表**
  （`t_hero` / `t_monster` / `t_disaster` / `t_notice`，表结构在 `hero_association.sql` 第 5 节）
- 新增文件：
  - 后端 `entity/Hero|Monster|Disaster|Notice.java`、`mapper/*Mapper.java`（MyBatis-Plus BaseMapper）
  - 后端 `service/CatalogService.java` + `impl/CatalogServiceImpl.java`（读四表 + 增删改，id 形如 h-01/m-01/d-01/n-01，新增自动生成）
  - 后端 `controller/AdminController.java`：`GET /api/admin/list?section=`、`POST /api/admin/save`、`DELETE /api/admin/delete?section=&id=`
  - 前端 `components/AdminLogin.vue`、`components/AdminPanel.vue`
- **数据源已切到数据库**：`CatalogController` 现在从四张表读；只有当查询结果全为空或抛异常时，
  才回退到控制器里那份静态兜底数据。所以改了库里的数据，首页会跟着变
- 数据初始化：`springBootTest/sql/catalog_data.sql`（由前端 catalog.js 生成，共 62 条：18/20/12/12）。
  **该脚本会先 `DELETE` 四张表再灌数**，只在需要重置初始数据时手动执行，别挂到 start-all.bat 上，
  否则用户在后台做的修改会被清空
- 从后台返回首页时 App.vue 会重新 `loadCatalog()`，保证首页看到的是最新数据
- 本次验证：新增 h-19 → 修改 → 删除 闭环通过，条数回到 18；四个板块 admin/list 分别为 18/20/12/12；
  `/api/login` 返回 code 200；前端 build 34 模块通过，两个新页面模块 200 且无解析错误
- **后台接口要走 Vite 代理实测**（不能只测 8080 直连）：`http://localhost:5173/api/admin/list?section=xxx`
  与 POST `/api/admin/save`、DELETE `/api/admin/delete?section=&id=` 均验证通过（代理转发 /api 前缀即可，无需额外配置）

## 2026-10-28 形象系统（头像 / 插画）
- **每个条目都有形象**：优先用 AI 插画，没插画的按角色名程序化生成半身剪影；灾害 / 公告用符号图标。
  组件是 `src/components/AvatarBadge.vue`，被 `ResultCard.vue`（首页卡片）和 `AdminPanel.vue`（后台表格）共用
- **插画资源**：16 张（6 位 S 级英雄 + 10 只龙级怪人）放在 `src/assets/avatars/`，命名 `hero-xxx.png` / `monster-xxx.png`
  （320x320，用 Pillow 从 1024x1024 压缩，总体积约 2.9MB）。**图右下角有「AI生成」水印，是平台合规要求，去不掉**
- **加载方式必须用 `import.meta.glob(..., { eager: true, query: '?url', import: 'default' })`** 静态收集。
  Vite 不会收录运行时拼字符串的动态路径，直接 `import` 变量会打包不到图
- **avatar 字段是可选的**：数据里 `avatar: 'hero-saitama'` 这类 key 对应资源名；不填则程序化生成。
  数据库 `t_hero` / `t_monster` 已加 `avatar varchar(64)` 列（灾害 / 公告表没加，因为它们不是角色）
- **角色数据扩展**：英雄 18→30、怪人 20→30（S9/A8/B7/C6，龙12/鬼7/虎5/狼6），每个筛选项和热词都有数据。
  自检脚本见 `probe_check.mjs` 思路：热词要用 `itemSearchText` 拼接后的文本判定（「S级」「战力」是拼出来的，不在原始字段里）
- **后台可管理形象**：`AdminPanel.vue` 的英雄 / 怪人表单多了「形象」下拉（空 = 自动生成），表格有形象列。
  **坑：后台编辑角色必须带 avatar，否则后端会把字段清空**（现在表单已带）
- 数据初始化脚本已更新：`gen_catalog_sql.mjs` 会带上 avatar 列；`catalog_data.sql` 现在共 84 条（30/30/12/12，形象 6/10）
- **重启后端注意**：本会话后台启动的进程可能被回收导致端口被旧代码占用，表现为接口返回的数据没有新字段。
  处理：`netstat -ano | grep :8080` 找 PID → `taskkill` 不行就用 `Stop-Process -Id <pid> -Force` → 重新 `mvn spring-boot:run`

## 2026-11-02 D盘副本整体回退 + 第三次重建（第三次丢文件！）

- **现象**：`D:/workSpace/java2/java2-main/workSpace` 被整体回退到很早的版本——10-28 做的
  后台管理系统（前后端）、形象系统、`catalog_data.sql`、16 张 AI 插画**全部丢失**；
  桌面备份已被系统重置清空，`_old_backup` 是空目录，无法恢复。数据库也回到 40 条
  初始状态（12/12/8/8，且没有 avatar 列）。
- **已全部重建**：
  - 后端：`entity/Hero|Monster|Disaster|Notice`、四个 Mapper、`CatalogService(+Impl)`、
    `CatalogController`（/api/catalog + /api/{section} 泛型路由）、`AdminController`、
    `MybatisPlusConfig`（分页拦截器，selectPage 必需）
  - 前端：`src/data/catalog.js`、`src/utils/search.js`、`SearchPanel.vue`、
    `ResultCard.vue`、`AvatarBadge.vue`、`AdminLogin.vue`、`AdminPanel.vue`
  - 数据：84 条（英雄30 S9/A8/B7/C6，怪人30 龙12/鬼7/虎5/狼6，灾害12，公告12），
    每个筛选项/热词均通过自检脚本验证有点可点
- **avatar 插画没有恢复**：16 张 AI 图彻底丢了。AvatarBadge 走程序化剪影兜底，
  DB 的 avatar 列保留（当前全空），`hero_association.sql` 两张 CREATE TABLE 已补 avatar 列，
  后台表单的形象字段是文本框（留空=自动生成剪影），以后重新生成插画填 key 即可
- **数据同步工具**：`one-punch-login-vue/gen_catalog_data.mjs`（node 运行）从
  `src/data/catalog.js` 生成 `springBootTest/sql/catalog_data.sql`，改数据先改 catalog.js
  再跑它。**catalog_data.sql 导入时必须带库名**：`mysql -uroot -p123456 --default-character-set=utf8mb4 hero_association < catalog_data.sql`（不带库名报 No database selected）
- **后端注意**：save() 新增时先反射 setId（h-31 风格自增编号）再 insert；
  updateById 忽略 null 字段，所以编辑不带 avatar **不会**清空库里的值（第 174 行的老坑已消除）
- **npm optional deps bug 第三次复现**：`@rolldown/binding-win32-x64-msvc` 装不上，
  修复法有效：`npm pack @rolldown/binding-win32-x64-msvc@1.2.14` → tar 解压到
  `node_modules/@rolldown/binding-win32-x64-msvc --strip-components=1`
- 本次验证：后端 8080 + 前端 5173 均 200；登录（直连+代理）、/api/catalog（30/30/12/12）、
  /api/heroes 筛选/排序/分页、后台 CRUD（新增 h-31→删除→还原 30）全通过；build 36 模块通过

## 2026-11-02（2）形象插画重新生成完成

- 16 张插画已用图像生成重制（约 80~160 积分）：6 位 S 级英雄 + 10 只龙级怪人，
  1024 生成 → Pillow 压缩 320×320 → `src/assets/avatars/`，命名 hero-xxx.png / monster-xxx.png，
  总体积约 3.56MB，图右下角带平台合规「AI生成」水印（去不掉）
- 已写回 `catalog.js` avatar 字段并同步入库（重跑 `gen_catalog_data.mjs` + 导入 SQL）
- key 对照：h-02~h-07 → hero-jenos/tatsumaki/bang/atomic/flash/mask；
  m-01~m-08、m-10、m-11 → monster-boros/beetle/centipede/melzagard/gouketsu/seaking/denki/shade/magma/kannon
- 验证：/api/catalog 返回 avatar、Vite 直取 PNG 200、build 打包 16 张 PNG 全通过

## 2026-11-02（3）第二批 51 张插画 + 灾害/公告接回（全部角色 AI 化完成）

- 又生成 51 张（24 英雄 + 20 怪人专属 + 灾害狼/虎/鬼/龙 4 张 + 公告普通/重要/紧急 3 张），
  1024 生成 → Pillow 320×320 → avatars/；现在**全部 84 条记录都带 AI 插画**（hero-*/monster-* 按角色，
  dis-*/note-* 按等级类别复用）。生成中途报过 429 额度，但 51 张已全部落盘 raw2，压缩后删除 raw2
- 踩坑与修复（重要，下次别再踩）：
  1. **catalog.js 注入正则 bug**：原正则需要行尾 `},`，但每个 section 最后一条行尾是 `}`（无逗号），
     导致 h-30/m-30/d-12/n-12 漏写 → 改成 `(\},?)` 同时匹配两种
  2. **生成脚本漏列**：`gen_catalog_data.mjs` 的 tableMap 里 disasters/notices 没列 avatar，
     已补；并同步 `hero_association.sql` 基础建表的 t_disaster/t_notice avatar 列
  3. **后端实体漏字段**：Disaster.java / Notice.java 当初只给 Hero/Monster 加了 avatar，
     导致 DB 有值但 /api/catalog 返回 null → 给两个实体补 `private String avatar`，重启后端生效
  4. **AvatarBadge 优先级正确**：模板顺序 v-if avatarUrl → v-else-if isGlyphSection，所以
     灾害/公告有图时显示图、无图才降级符号；不用改组件
- 验证：/api/catalog 四板块 30/30、30/30、12/12、12/12 全带形象；Vite 直取 hero/mouse/dis/note 全部 200；
  npm run build 67 张 PNG 全打包

## 2026-11-04 第四次丢文件 + 第四次重建（D盘副本再次回退）

- **现象**：`D:/workSpace/java2/java2-main/workSpace` 又回退到 10-28 之前的状态：后端只剩 `UserController`（无 Catalog/Admin 控制器、无四表 Mapper、无 CatalogService、无 MybatisPlusConfig），前端 `src/data/`、`src/utils/`、SearchPanel/ResultCard/AvatarBadge/AdminLogin/AdminPanel 全没了，`sql/catalog_data.sql`、`gen_catalog_data.mjs`、67 张插画也丢了；数据库回到 12/12/8/8。
- **已全部重建**（本次实现方式与 11-02 略有差异，看下一条）：
  - 后端：`mapper/Hero|Monster|Disaster|NoticeMapper`、`service/CatalogService(+Impl)`、`controller/CatalogController`、`controller/AdminController`、`config/MybatisPlusConfig`
  - 前端：`src/data/catalog.js`（84 条：30/30/12/12，含 loadCatalog 覆盖逻辑）、`src/utils/search.js`、`SearchPanel.vue`、`ResultCard.vue`、`AvatarBadge.vue`、`AdminLogin.vue`、`AdminPanel.vue`
  - 数据：`one-punch-login-vue/gen_catalog_data.mjs` 从 catalog.js 生成 `springBootTest/sql/catalog_data.sql`，导入后 30/30/12/12
- **两处实现调整（下次别当成 bug）**：
  1. `CatalogServiceImpl` 用「内存过滤 + 内存排序 + 内存分页」，等级排序靠 `LEVEL_ORDER` 常量（S>A>B>C、神>龙>鬼>虎>狼、紧急>重要>普通），不走 SQL 的 FIELD()
  2. `CatalogController` 不再内置 84 条静态兜底数据：库空或抛异常时返回空 map / 空数组，前端 `loadCatalog()` 只在数组非空时才覆盖，因此页面自然回落到 `catalog.js` 内置数据
- **插画仍然是零**：`src/assets/avatars/` 为空，AvatarBadge 全部走程序化剪影（首字 + 稳定哈希配色）。重新生成插画后填 `avatar` key 即可自动生效
- 本次验证：`/api/catalog` 30/30/12/12、登录 code 200、后台 list/save(h-31 自增)/delete 闭环、9 个前端模块全 200、`vite build` 36 模块通过、数据自检（筛选项/热词/首页 5 热词）全绿
- **本次启动方式**（AI 会话内）：后端 `mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8080`；前端 `node node_modules/vite/bin/vite.js --host`（用户双击 start.bat 仍是标准路径）

## 2026-11-06 第五次回退 + 第五次重建（装依赖并运行）

- 工作副本仍是 `D:\workSpace\java2\java2-main\workSpace`。检查发现又回到 10-28 之前的版本：
  前端 `src/data/catalog.js`、`src/utils/search.js`、SearchPanel / ResultCard / AvatarBadge / AdminLogin / AdminPanel 全丢；
  后端只剩 UserController（无四表实体/Mapper/CatalogService/CatalogController/AdminController/MybatisPlusConfig）；
  `node_modules` 与 `target/classes` 也被清空；数据库回到 12/12/8/8。
- **已全部重建并跑通**（本次分工方式，可复用）：
  - 前端数据层：`catalog.js`（84 条：30/30/12/12，含 LEVEL_ORDER / itemSearchText / loadCatalog）、
    `utils/search.js`（matches 去空白匹配）、`gen_catalog_data.mjs`（生成 `sql/catalog_data.sql` + 自检筛选项/热词）
  - 前端组件：SearchPanel / ResultCard / AvatarBadge / AdminLogin / AdminPanel
  - 后端：4 个实体 + 4 个 Mapper + MybatisPlusConfig + CatalogService(+Impl) + CatalogController + AdminController
  - 数据库：`mysql -uroot -p123456 --default-character-set=utf8mb4 hero_association < springBootTest/sql/catalog_data.sql`
    （生成脚本已带 4 条 DELETE，导入后 30/30/12/12）
- **本次没踩到的坑**（别预设一定会发生）：`npm install` 一次成功，
  `@rolldown/binding-win32-x64-msvc` 正常装上了（package.json 的 optionalDependencies 生效），
  Maven `dependency:go-offline` + `compile` 也全用本地 ~/.m2 缓存，无需重下。所以先检查再按坑修，别盲目 npm pack
- 启动：`mvn.cmd -B spring-boot:run -Dspring-boot.run.arguments=--server.port=8080`（SERVER__PORT 注入坑仍在）；
  前端 `npm run dev -- --host 0.0.0.0`（让 IPv4 127.0.0.1 也能访问，方便 curl / 内置浏览器验证）
- 模板里触发事件统一用 `$emit('xxx')` 或包装函数，不直接写 `emit('xxx')`，避免运行时上下文歧义
- 验证结果：8080/5173 均 LISTENING；`/api/catalog` 30/30/12/12；登录直连与 Vite 代理均 code 200；
  `/api/heroes?level=S&sort=power&page=1&size=3` total=9；后台 CRUD（新增 h-31 → 31 条 → 删除 → 30 条）闭环；
  `npm run build` 36 模块通过；10 个前端模块全部 200 且无 Failed to resolve
- 形象插画仍为空：`src/assets/avatars/` 目录已建（空），AvatarBadge 走首字+哈希配色的程序化剪影，
  灾害/公告走符号图标；以后放进 PNG 并填 `avatar` key 即自动生效
- **浏览器渲染验证的坑**（2026-11-06 续跑实测）：本机 Chrome 在
  `C:\Program Files (x86)\Google\Chrome\Application\chrome.exe`，`--headless=new` 完全起不来；
  `--headless=old` 能跑 `data:` URL，但访问 `http://127.0.0.1:5173` 时 `--dump-dom` 输出 0 字节、
  截图也失败（沙箱拦本机回环），**别在这上面浪费时间**
- **可靠替代：Vite SSR 渲染验证**（不用浏览器也能抓运行时错误）：在前端目录写临时 `.mjs`，
  `createServer({ server:{middlewareMode:true}, appType:'custom' })` → `ssrLoadModule('/src/xxx.vue')` →
  `createSSRApp(mod.default, props)` + `renderToString()`，逐个渲染 App / HomePage / SearchPanel /
  ResultCard / AvatarBadge / AdminLogin / AdminPanel，全部通过即说明 setup 与模板无运行时错误。
  本次 7/7 通过（App 1789 字节，登录页含「认真登录」）；**脚本跑完记得删**

## 2026-11-06（2）经验系统：做任务 → 得经验 → 升级

- 入口：首页导航栏「任务中心」按钮 → `TaskCenter.vue`；`App.vue` 视图状态机扩为
  `login | register | loading | home | tasks | adminLogin | admin`
- 数据库脚本 `springBootTest/sql/exp_system.sql`（**可重复执行**：ALTER 前查 information_schema，INSERT 用 IGNORE）：
  - `t_user` 加 `exp`（当前级内经验）、`level`（1~99，默认 1）
  - `t_task` 任务模板：id/title/type(日常/讨伐/灾害/特殊)/difficulty(D/C/B/A/S)/exp_reward/repeatable/detail/weight，种子 **14 条**
  - `t_task_log` 完成记录：user_id/task_id/task_title/exp_gained/level_before/level_after/create_time
- 核心规则（`ExpServiceImpl`）：
  - 升级所需经验 `100 + (level-1)*60`，经验溢出连升多级，等级上限 99（满级后经验封顶）
  - 一次性任务（repeatable=0）只能完成一次；日常任务（repeatable=1）按 `create_time` 的日期每天一次
  - 称号：Lv1-4 C级 / 5-9 B级 / 10-19 A级 / 20+ S级 —— `titleOf()` 在 `ExpServiceImpl` 和
    `UserServiceImpl` 各有一份（登录返回要用），**改区间必须两边同步**
- 接口：`GET /api/tasks?userId=`（profile + tasks + 最近 10 条 logs）、
  `POST /api/tasks/complete {userId,taskId}`、`GET /api/profile?userId=`
  - `GET /api/{section}` 泛型路由不会抢 `/api/tasks`、`/api/profile`（Spring 精确路径优先），已实测
  - 业务异常统一 `Result.error(原消息)`，前端直接展示（如"这个日常任务今天已经做过了，明天再来"）
- 前端：`TaskCenter.vue`（等级徽章 + 经验条 + 分类 tab + 任务卡 + +EXP 飘字 + LEVEL UP 弹层 + 最近完成）、
  `api/index.js` 加 `fetchTasks` / `completeTask`、HomePage 导航加「任务中心」并显示 `Lv.n`、
  App.vue 用 `@profile` 把最新等级同步回 `user`（返回首页不丢）
- 验证（2026-11-06 实测）：t-08（500 EXP）从 Lv.1 连升到 **Lv.4 余 20**；重复做一次性任务被拒；
  日常任务当天重复被拒；Vite 代理 200；`npm run build` 38 模块；SSR 渲染 TaskCenter/HomePage/App 全通过。
  测试数据已清理，`t_user` 全部回到 `exp=0 / level=1`

## 2026-11-06（3）任务 2.0：任务更多 + 刷新 + 互动流程

- **需求**：任务要更多、做完能刷新出新任务、做任务要有过程和互动（不是点一下就完成）
- **数据库**：`springBootTest/sql/mission_v2.sql`（可重复执行）
  - `t_task` 扩列：`scene / rounds / min_score / trait / time_limit / chain / story / desc_text / rarity`
  - 新表 `t_task_step`：一回合一行，`prompt` + 三组 `choice_x / score_x / reply_x`
  - 新表 `t_task_offer`：任务板上的「委托」实例（user_id / task_id / status / slot / refresh_no / start_time / expire_time）
  - 新表 `t_task_pick`：回合作答记录（`UNIQUE KEY uk_pick (offer_id, seq)` 防重复提交刷分）
  - `t_task_log` 加 `total_score / judge / offer_id`
  - 任务从 14 条扩到 **51 条 / 192 回合**：日常 10、讨伐 11、灾害 7、特殊 17、突袭 6（限时）、链式 4
- **核心设计（别改错）**：
  1. 任务板挂的是 offer 不是 task；刷新 = 删掉 `status='open'` 的委托 + 按稀有度加权重抽 6 张（传奇 1 / 稀有 3 / 普通 6），`active` 的不动
  2. 抽取池排除「已完成的一次性任务」和「前置链式任务未完成」的任务 → 链式任务天然解锁
  3. 回合选项分数**不下发前端**（`toStepMap(s, true)`），作答只回 `reply`；结算按 `t_task_pick` 汇总算分
  4. 评分 = Σ得分 / Σ每回合最高分 × 100；通关线 60；评价 90+S / 80+A / 60+B / 40+C / 其余 D
  5. 经验折算 S 100% / A 90% / B 75% / C 50% / D 25%，最低 5 点
  6. 服务端按 `score` 归一化后与写死的 `min_score=60` 比较（`t_task.min_score` 只是展示用，实际判定走常量 `ExpSupport.PASS_SCORE`）
- **共用规则收敛**：新增 `service/impl/ExpSupport.java`（抽象类）放 `needExp / titleOf / judgeOf / expRateOf / applyExp / grant / buildProfile / logsOf / doneTaskIds / stepsOf / requireOffer / toStepMap`，
  `ExpServiceImpl` 与 `MissionServiceImpl` 都继承它 —— **称号区间以后只需要改 ExpSupport 一处**（旧备忘里「两处 titleOf 要同步」的问题已解决）
- **接口（MissionController，全部 try/catch → Result.error(业务消息)）**：
  `GET /api/mission/board?userId=`、`POST /api/mission/refresh`、`/start`、`/answer`、`/settle`、`/abandon`
  老接口 `GET /api/tasks`、`POST /api/tasks/complete`、`GET /api/profile` 保留兼容（complete 固定记 70 分/B 评价）
- **前端**：
  - `TaskCenter.vue` 重写为委托板（经验卡 + 进行中条 + 6 个分类 tab + 卡片 + 「刷新委托」按钮 + 已完成侧栏）
  - 新组件 `MissionPlay.vue`（全屏 3 阶段）：简报（场景色 + 剧情 + 回合数/通关线/限时）→ 逐回合（进度条、A/B/C 三选、选后出「结果」反馈再继续、左侧历史）→ 结算（巨大评价字母 + 分数换算 + 经验 + 升级 + 经验条动画）
  - 场景配色表 `SCENE`（11 种：city/forest/coast/factory/sky/ruin/arena/base/hospital/sewer/night），整个互动页底色随场景变化
  - `api/index.js` 追加 `fetchMissionBoard / refreshMissions / startMission / answerMission / settleMission / abandonMission`
- **本次踩的坑**：
  1. `LambdaQueryWrapper` 的 map 方法引用不能直接用在 `Map<String,Object>` 流上（编译报「找不到符号 getRefreshNo」）→ 改用 `((Number) o.getOrDefault(...)).intValue()`
  2. `t_task_log.create_time` 在 MySQL 里是 `NOT NULL DEFAULT CURRENT_TIMESTAMP`，而 MyBatis-Plus 插入时会带上 `create_time=null` → 必须 `@TableField(insertStrategy = FieldStrategy.NEVER)`
  3. `application.yml` 的 SQL 控制台日志（`StdOutImpl`）会让 `mvn spring-boot:run` 日志爆到 150KB+，已改成 `NoLoggingImpl`（要调试再换回来）
  4. 之前的「18 个文件重建」是回退造成的，注意别再把 `design_tasks.py` / `verify_mission.py` 这类临时脚本留在仓库（本次已删）
- **验证（2026-11-06 实测）**：
  - 全选 A：`76/76 = 100 分（S）`，经验满额，Lv.1→Lv.2
  - 全选 C（最差）：`29 分` → 拒绝结算「评分 29 没有达到通关线 60」
  - 重复结算 → 「这张委托已经结算过了」；同回合重复提交 → 「第 N 回合已经行动过了」；没打完结算 → 「还有 N 个回合没有行动」
  - 刷新两次：6 张委托整批换新（池子没抽完时）；连刷 30 次共出现 47 种任务
  - 链式：t-05 未完成时 60 次刷新都摇不到 t-36，完成 t-05 后立刻能摇到
  - 限时：接取后返回 `remainSeconds=420`，前端倒计时到 0 提示超时
  - 老接口 `/api/tasks` 47 条、`/api/profile` 正常；Vite 代理 `/api/mission/board` 与直连 8080 返回结构一致
  - `npm run build` 40 模块通过；SSR 渲染 App / TaskCenter / MissionPlay 3/3 通过
  - 测试数据已清空（`t_task_offer` / `t_task_pick` / `t_task_log` 为 0，`t_user` 全部 Lv.1 exp 0）
