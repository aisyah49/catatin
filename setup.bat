@echo off
REM ============================================================================
REM  Setup otomatis Catatin (Windows + Laragon). SATU FOLDER saja: project Laravel dibuat di folder ini.
REM  Cara pakai: buka Terminal Laragon, masuk ke folder ini (cd D:\laragon\www\catatin), lalu ketik: setup.bat
REM  Syarat: Laragon sudah Start All (MySQL menyala).
REM ============================================================================
set DBNAME=catatin
set DBUSER=root
set DBPASS=
set SRC=%~dp0
cd /d "%SRC%"

if exist "%SRC%artisan" (
  echo.
  echo Catatin sudah terpasang di folder ini. Untuk menyalakan: php artisan serve
  echo Untuk memasang ulang dari nol, hapus semua isi folder ini kecuali file zip/setup, lalu ekstrak zip lagi.
  exit /b 0
)

echo [1/6] Membuat database %DBNAME% ...
if "%DBPASS%"=="" (set MY=mysql -u %DBUSER%) else (set MY=mysql -u %DBUSER% -p%DBPASS%)
%MY% -e "CREATE DATABASE IF NOT EXISTS %DBNAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if errorlevel 1 (echo Gagal membuat database. Pastikan MySQL menyala dan jalankan dari Terminal Laragon. & exit /b 1)

echo [2/6] Mengunduh Laravel (tahap ini bisa 2-10 menit) ...
if exist "%SRC%_laravel_tmp" rmdir /s /q "%SRC%_laravel_tmp"
call composer create-project laravel/laravel "%SRC%_laravel_tmp" --no-interaction || exit /b 1

echo [3/6] Menggabungkan Laravel dengan file Catatin di folder ini ...
REM Simpan dulu route milik Catatin supaya tidak tertimpa / mengganggu install:api
move /Y routes\api.php routes\_api_catatin.php >nul
move /Y routes\web.php routes\_web_catatin.php >nul
REM Salin isi Laravel ke folder ini. /XC /XN /XO = jangan menimpa file Catatin yang sudah ada.
robocopy "%SRC%_laravel_tmp" "%SRC%." /E /XC /XN /XO /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (echo Gagal menyalin file Laravel. & exit /b 1)
rmdir /s /q "%SRC%_laravel_tmp"
del /q bootstrap\cache\*.php >nul 2>&1
call composer dump-autoload -q
call php artisan install:api --no-interaction
move /Y routes\_api_catatin.php routes\api.php >nul
move /Y routes\_web_catatin.php routes\web.php >nul

echo [4/6] Mengisi .env ...
powershell -NoProfile -Command "(Get-Content .env) -replace '^DB_CONNECTION=.*','DB_CONNECTION=mysql' -replace '^#? ?DB_HOST=.*','DB_HOST=127.0.0.1' -replace '^#? ?DB_PORT=.*','DB_PORT=3306' -replace '^#? ?DB_DATABASE=.*','DB_DATABASE=%DBNAME%' -replace '^#? ?DB_USERNAME=.*','DB_USERNAME=%DBUSER%' -replace '^#? ?DB_PASSWORD=.*','DB_PASSWORD=%DBPASS%' | Set-Content .env"
call php artisan config:clear >nul

echo [5/6] Migrasi (tabel, trigger, function) + data contoh. Isi database %DBNAME% dikosongkan dulu ...
call php artisan migrate:fresh --drop-views --force || exit /b 1
call php artisan db:seed --class=CatatinSeeder --force

echo [6/6] Selesai. Buka http://127.0.0.1:8000  (jangan tutup jendela ini)
call php artisan serve
