@echo off
title 英雄协会 停止服务
REM ============================================================
REM  一拳超人·英雄协会 停止脚本 (GBK 编码, 修改请保持编码)
REM  停止后端(8080)和前端(5173), 不会动 MySQL 系统服务
REM ============================================================
cd /d "%~dp0"

echo ================================================
echo    一拳超人 · 英雄协会 停止服务
echo ================================================
echo.

call :killport 8080
call :killport 5173

echo.
echo [OK] 全部停止. MySQL(3306) 是系统服务, 未受影响.
echo.
pause
goto :eof

:killport
set "found="
for /f "tokens=5" %%A in ('netstat -ano ^| findstr /c:":%1 " ^| findstr /c:"LISTENING"') do (
    taskkill /F /PID %%A >nul 2>nul
    set "found=1"
)
if defined found (echo [OK] 端口 %1 已停止) else (echo [--] 端口 %1 本来就没有运行)
goto :eof
