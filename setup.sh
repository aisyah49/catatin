#!/usr/bin/env bash
# Setup otomatis Catatin (Linux/macOS). SATU FOLDER: project Laravel dibuat di folder ini.  Jalankan: bash setup.sh
set -e
DBNAME=${DBNAME:-catatin}; DBUSER=${DBUSER:-root}; DBPASS=${DBPASS:-}
SRC="$(cd "$(dirname "$0")" && pwd)"; cd "$SRC"
[ -f artisan ] && { echo "Sudah terpasang. Nyalakan dengan: php artisan serve"; exit 0; }

echo "[1/6] Membuat database $DBNAME ..."
mysql -u "$DBUSER" ${DBPASS:+-p"$DBPASS"} -e "CREATE DATABASE IF NOT EXISTS $DBNAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "[2/6] Mengunduh Laravel ..."
rm -rf _laravel_tmp
composer create-project laravel/laravel _laravel_tmp --no-interaction

echo "[3/6] Menggabungkan Laravel dengan file Catatin ..."
mv routes/api.php routes/_api_catatin.php; mv routes/web.php routes/_web_catatin.php
cp -an _laravel_tmp/. .          # -n = jangan menimpa file Catatin yang sudah ada
rm -rf _laravel_tmp; rm -f bootstrap/cache/*.php
composer dump-autoload -q
php artisan install:api --no-interaction || true
mv routes/_api_catatin.php routes/api.php; mv routes/_web_catatin.php routes/web.php

echo "[4/6] Mengisi .env ..."
sed -i.bak -E "s|^DB_CONNECTION=.*|DB_CONNECTION=mysql|; s|^#? ?DB_HOST=.*|DB_HOST=127.0.0.1|; s|^#? ?DB_PORT=.*|DB_PORT=3306|; s|^#? ?DB_DATABASE=.*|DB_DATABASE=$DBNAME|; s|^#? ?DB_USERNAME=.*|DB_USERNAME=$DBUSER|; s|^#? ?DB_PASSWORD=.*|DB_PASSWORD=$DBPASS|" .env
php artisan config:clear

echo "[5/6] Migrasi (tabel, trigger, function) + data contoh ..."
php artisan migrate:fresh --drop-views --force
php artisan db:seed --class=CatatinSeeder --force

echo "[6/6] Selesai. Server di http://127.0.0.1:8000"
php artisan serve
