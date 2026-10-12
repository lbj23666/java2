@echo off
REM ============================================================
REM  hero-association 后端启动脚本 (GBK 编码, 修改请保持编码)
REM  双击即可编译并启动 Spring Boot 服务(端口 8080)
REM  target 每次开机会被删除, mvn 会自动重新编译, 无需担心
REM  前提: MySQL 已启动, hero_association 库已导入(start-all.bat 会自动导入)
REM ============================================================
cd /d "%~dp0"

REM ---------- 找一个能用的 Maven ----------
set "MVN="
where mvn >nul 2>nul && set "MVN=mvn"
if not defined MVN for /f "delims=" %%F in ('dir /s /b "%USERPROFILE%\.m2\wrapper\dists\mvn.cmd" 2^>nul ^| findstr /i /c:"\bin\mvn.cmd"') do if not defined MVN set "MVN=%%F"
if not defined MVN for /d %%D in ("D:\IntelliJ IDEA*") do if exist "%%~D\plugins\maven\lib\maven3\bin\mvn.cmd" set "MVN=%%~D\plugins\maven\lib\maven3\bin\mvn.cmd"
if not defined MVN for /d %%D in ("%ProgramFiles%\JetBrains\IntelliJ IDEA*") do if exist "%%~D\plugins\maven\lib\maven3\bin\mvn.cmd" set "MVN=%%~D\plugins\maven\lib\maven3\bin\mvn.cmd"

if not defined MVN (
    echo [X] 没有找到 Maven!
    echo     已尝试: PATH / %USERPROFILE%\.m2\wrapper / D:\IntelliJ IDEA*
    echo     解决: 用 IDEA 打开 springBootTest 项目, 点绿色三角运行
    pause
    exit /b 1
)

echo 使用 Maven: %MVN%
echo 正在编译并启动英雄协会后端(首次运行需下载依赖, 请耐心等待)...
echo 启动成功后访问 http://localhost:8080 , 按 Ctrl+C 停止服务。
call "%MVN%" spring-boot:run

pause
