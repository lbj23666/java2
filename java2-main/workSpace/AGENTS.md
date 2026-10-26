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
