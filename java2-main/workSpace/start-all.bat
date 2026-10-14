@echo off
title 英雄协会 一键启动
REM ============================================================
REM  一拳超人·英雄协会 登录系统 一键启动脚本
REM  本文件是 GBK(ANSI) 编码, 用记事本/VSCode 修改时请保持 GBK 保存!
REM  开机后 node_modules / target 会被删除, 本脚本会自动补装补编.
REM  数据库不存在时会自动导入 sql/hero_association.sql
REM  注意: 每次重置后 Maven 可能要重新下载依赖, 后端最多等 5 分钟
REM ============================================================
cd /d "%~dp0"

set "CURL=%SystemRoot%\System32\curl.exe"

echo ================================================
echo    一拳超人 · 英雄协会 登录系统 一键启动
echo ================================================
echo.

REM ---------- 第 1 步: 检查 MySQL 与数据库 ----------
netstat -ano | findstr /c:":3306" | findstr /c:"LISTENING" >nul
if errorlevel 1 (
    echo [X] MySQL 服务没有在运行! 请先启动 MySQL 再重试本脚本
    pause
    goto :eof
)

set "MYSQL="
where mysql >nul 2>nul && set "MYSQL=mysql"
if not defined MYSQL for /d %%D in ("C:\Program Files\MySQL\MySQL Server*") do if exist "%%~D\bin\mysql.exe" set "MYSQL=%%~D\bin\mysql.exe"
if not defined MYSQL for /d %%D in ("C:\Program Files\MySQL\*") do if exist "%%~D\bin\mysql.exe" set "MYSQL=%%~D\bin\mysql.exe"

if defined MYSQL (
    "%MYSQL%" -uroot -p123456 -e "USE hero_association;" >nul 2>nul
    if errorlevel 1 (
        echo [1/4] 数据库不存在, 正在自动导入 hero_association ...
        "%MYSQL%" -uroot -p123456 --default-character-set=utf8mb4 < "springBootTest\sql\hero_association.sql" >nul 2>nul
        if errorlevel 1 (
            echo [X] 数据库导入失败! 请手动导入 springBootTest\sql\hero_association.sql
            pause
            goto :eof
        )
        echo [OK] 数据库导入成功
    ) else (
        echo [OK] 数据库 hero_association 正常
    )
) else (
    echo [!] 未找到 mysql 命令, 跳过数据库检查
)

REM ---------- 第 2 步: 后端 (8080) ----------
%CURL% -s -o NUL -m 2 --noproxy "*" http://127.0.0.1:8080/
if %errorlevel%==0 goto backend_ok

echo [2/4] 正在新窗口启动后端 Spring Boot (重置后首次启动需下载依赖, 最多约 5 分钟)...
start "英雄协会-后端(8080)" /D "%~dp0springBootTest" cmd /k run.bat
set /a n=0

:wait_backend
%SystemRoot%\System32\ping.exe -n 3 127.0.0.1 >nul
set /a n+=1
<nul set /p=.
%CURL% -s -o NUL -m 2 --noproxy "*" http://127.0.0.1:8080/
if %errorlevel%==0 goto backend_ok
if %n% lss 150 goto wait_backend
echo.
echo [X] 后端启动超时! 请查看"英雄协会-后端(8080)"窗口的报错
echo     常见原因: Maven 下载依赖慢 / MySQL 没有启动 / 8080 端口被占用
pause
goto :eof

:backend_ok
echo.
echo [OK] 后端就绪  http://127.0.0.1:8080
echo.

REM ---------- 第 3 步: 前端 (5173) ----------
%CURL% -s -o NUL -m 2 --noproxy "*" http://localhost:5173/
if %errorlevel%==0 goto frontend_ok

echo [3/4] 正在新窗口启动前端 Vite (开机后首次运行会自动安装依赖, 请稍等)...
start "英雄协会-前端(5173)" /D "%~dp0one-punch-login-vue" cmd /k start.bat
set /a n=0

:wait_frontend
%SystemRoot%\System32\ping.exe -n 3 127.0.0.1 >nul
set /a n+=1
<nul set /p=.
%CURL% -s -o NUL -m 2 --noproxy "*" http://localhost:5173/
if %errorlevel%==0 goto frontend_ok
if %n% lss 150 goto wait_frontend
echo.
echo [!] 前端窗口可能还在装依赖(开机后首次约 1~3 分钟), 若窗口报错请重跑 start-all.bat

:frontend_ok
echo.
echo [OK] 前端就绪  http://localhost:5173
echo.

REM ---------- 第 4 步: 打开浏览器 ----------
echo [4/4] 正在打开浏览器...
start "" "http://localhost:5173"
echo.
echo ================================================
echo   启动完成! 测试账号: 秃头披风侠  密码: 123456
echo   停止服务: 双击 stop-all.bat (或手动关闭两个窗口)
echo ================================================
pause
