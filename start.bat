@echo off
setlocal enabledelayedexpansion

REM ==== 引数チェック ====
if "%~1"=="" (
    echo Usage: %~nx0 PROJECT_NAME HOST_NAME
    echo  例: %~nx0 cloud_sougyotecho xn--pckua2a7gp15o89zb.com
    exit /b 1
)

if "%~2"=="" (
    echo Usage: %~nx0 PROJECT_NAME HOST_NAME
    exit /b 1
)

set "PROJECT=%~1"
set "HOST=%~2"

REM このbatファイルが置いてあるディレクトリ（ルート）
set "ROOT_DIR=%~dp0"

echo.
echo ==== Scrapy プロジェクト作成 ====
scrapy startproject "%PROJECT%"
if errorlevel 1 (
    echo [ERROR] scrapy startproject で失敗しました
    exit /b 1
)

cd "%PROJECT%" || (
    echo [ERROR] プロジェクトディレクトリ %PROJECT% に移動できません
    exit /b 1
)

echo.
echo ==== Spider 作成 ====
scrapy genspider "%PROJECT%spider" "%HOST%"
if errorlevel 1 (
    echo [ERROR] scrapy genspider で失敗しました
    exit /b 1
)

echo.
echo ==== 共通ファイルをプロジェクト直下にコピー ====

REM ここに「ルートに置いてあるファイル名」を列挙
REM 必要に応じて編集してください
for %%F in (
    export.py
    reorder.py
    Dockerfile
    k3s
    Makefile
) do (
    if exist "%ROOT_DIR%%%F" (
        echo copy "%ROOT_DIR%%%F" "%CD%"
        copy /Y "%ROOT_DIR%%%F" "%CD%" >nul
    ) else (
        echo [WARN] %ROOT_DIR%%%F が見つかりませんでした
    )
)

echo.
echo ==== uv で依存関係を追加 ====
REM uv が PATH に入っている前提
uv init
uv add scrapy scrapy-redis pandas
if errorlevel 1 (
    echo [ERROR] uv add で失敗しました
    exit /b 1
)

echo.
echo ==== 完了しました =====
echo プロジェクト: %PROJECT%
echo ホスト      : %HOST%

endlocal
