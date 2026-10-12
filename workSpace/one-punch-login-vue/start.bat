@echo off
REM ============================================================
REM  one-punch-login-vue 前端启动脚本 (GBK 编码, 修改请保持编码)
REM  node_modules 每次开机会被删除, 本脚本会自动重新安装依赖
REM ============================================================
cd /d "%~dp0"

if exist "node_modules\vite" (
    echo [1/2] 依赖已存在, 快速检查更新...
) else (
    echo [1/2] 正在安装依赖(开机后首次运行需要一点时间)...
)
call npm install --no-audit --no-fund
if errorlevel 1 (
    echo 依赖安装失败, 请检查网络或手动执行 npm install
    pause
    exit /b 1
)

echo [2/2] 启动 Vite 开发服务器(默认 http://localhost:5173)...
echo 按 Ctrl+C 可停止服务。
call npm run dev

pause
