@echo off
REM ============================================================
REM  one-punch-login-vue 前端启动脚本 (GBK 编码, 修改请保持编码)
REM  1. node_modules 每次开机会被删除, 本脚本会自动重装依赖
REM  2. Vite 8 底层 rolldown 的原生绑定包 (@rolldown/binding-win32-x64-msvc)
REM     会因 npm optional dependencies bug 意外丢失, vite 启动时报
REM     "Cannot find native binding", 本脚本检测到缺失会自动修复
REM  3. 依赖完整时跳过 npm install, 加快日常启动速度
REM ============================================================
cd /d "%~dp0"

set "BROKEN=0"
if not exist "node_modules\vite" set "BROKEN=1"
if not exist "node_modules\@rolldown\binding-win32-x64-msvc" set "BROKEN=1"
if "%BROKEN%"=="0" goto run

if exist "node_modules" (
    echo [1/2] 依赖不完整(rolldown 原生绑定缺失), 自动清理重装...
    rd /s /q "node_modules"
) else (
    echo [1/2] 正在安装依赖(开机后首次运行需要一点时间)...
)
call npm install --no-audit --no-fund
if errorlevel 1 (
    echo.
    echo [X] 依赖安装失败! 常见原因: 网络不通 / npm 源有问题
    echo     排查: 手动执行 npm install 看具体报错
    pause
    exit /b 1
)

REM 保险起见: 装完再查一次原生绑定, 还缺就删锁定文件彻底重装
if not exist "node_modules\@rolldown\binding-win32-x64-msvc" (
    echo [!] 原生绑定仍未装上, 删除 package-lock 后重新完整安装...
    del /q "package-lock.json" >nul 2>nul
    rd /s /q "node_modules"
    call npm install --no-audit --no-fund
    if errorlevel 1 (
        echo [X] 二次安装仍失败, 请检查网络后重试
        pause
        exit /b 1
    )
)

:run
echo [2/2] 启动 Vite 开发服务器(默认 http://localhost:5173)...
echo 按 Ctrl+C 可停止服务。
call npm run dev

echo.
echo [!] Vite 已退出。若是报错退出, 重跑一次本脚本会自动修复依赖。
pause
