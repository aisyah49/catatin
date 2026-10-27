# Catatin — versi Laravel + Database (trigger, function, commit/rollback)

Folder ini adalah **tambahan file** untuk project Laravel 11/12 baru. Datanya sama dengan aplikasi HTML (folder, barang, memo, tabel, riwayat), tetapi disimpan di MySQL/MariaDB dan dijaga oleh database itu sendiri.

## Tampilan web
Beranda `/` menampilkan aplikasi Catatin (Blade: `resources/views/catatin.blade.php`). Semua data dibaca dan disimpan ke MySQL lewat `UiStoreController`; riwayat ditulis trigger, dan tombol Urungkan memanggil `UndoService`.

## Memperbarui project yang sudah terpasang
Salin ulang `app/`, `database/`, `resources/`, `routes/` ke `catatin-api`, lalu jalankan di folder itu: `php artisan migrate:fresh --seed --seeder=CatatinSeeder` (ini menghapus data lama di database `catatin`).

## Cara pasang otomatis (satu folder)
1. Ekstrak zip ke satu folder kosong, misalnya `D:\laragon\www\catatin`.
2. Laragon: Start All, buka Terminal, lalu ketik `cd D:\laragon\www\catatin` dan `setup.bat`.
Skrip membuat database, mengunduh Laravel LANGSUNG ke folder ini (digabung dengan file Catatin), mengisi `.env`, migrasi + data contoh, lalu menyalakan server di http://127.0.0.1:8000. Ubah `DBUSER` / `DBPASS` di bagian atas skrip bila MySQL-mu memakai password.
Nanti membuka lagi: Terminal Laragon -> `cd D:\laragon\www\catatin` -> `php artisan serve`.

## Cara pasang manual
```bash
composer create-project laravel/laravel catatin-api
cd catatin-api
php artisan install:api                 # membuat routes/api.php (Laravel 11/12)
# salin isi folder ini (app/, database/, routes/api.php) ke project, timpa bila diminta
# edit .env: DB_CONNECTION=mysql, DB_DATABASE=catatin, DB_USERNAME=..., DB_PASSWORD=...
php artisan migrate
php artisan db:seed --class=CatatinSeeder
php artisan serve
```
Catatan MySQL: bila server memakai binary log, jalankan sekali `SET GLOBAL log_bin_trust_function_creators = 1;` agar FUNCTION boleh dibuat.

## Apa yang sudah ada

| Konsep | Di mana | Fungsinya |
|---|---|---|
| **FUNCTION** | `fn_modal_per_pcs`, `fn_laba_per_pcs`, `fn_total_modal_folder` (migration 2) | Hitung modal/laba per pcs dan total modal folder langsung di database |
| **VIEW** | `v_produk_laba` | Daftar barang + modal & laba per pcs (memakai function di atas) |
| **TRIGGER validasi** | `trg_products_bi/bu`, `trg_folders_bi` | Menolak nama kosong (`SIGNAL 45000`); merapikan spasi nama |
| **TRIGGER riwayat** | `trg_*_ai / au / ad / bd` | Menulis tabel `activities` otomatis saat tambah/ubah/hapus, termasuk snapshot untuk "Urungkan" |
| **TRIGGER pengaman** | `trg_activities_bu` | Riwayat tidak bisa diubah, hanya kolom `undone` |
| **COMMIT/ROLLBACK otomatis** | `App\Support\DbGuard::tx()` (`DB::transaction`) | Dipakai di semua simpan/ubah/hapus; error di tengah = semua dibatalkan |
| **COMMIT/ROLLBACK manual** | `ProductController::bulkStore` | `beginTransaction` / `commit` / `rollBack` untuk impor barang all-or-nothing |
| **Transaksi + kunci baris** | `UndoService` | Urungkan folder + barangnya dalam satu transaksi, `lockForUpdate` mencegah dobel |
| **Transaksi** | `SheetMemoService`, `CatatinSeeder` | Salin Tabel ke Memo dan seeding dibuat utuh atau tidak sama sekali |

Setiap file diberi komentar berbahasa Indonesia yang menjelaskan fungsinya.

## Endpoint (awalan `/api`)
`GET/POST /folders`, `PUT/DELETE /folders/{id}`, `POST /folders/{id}/open` · `GET/POST /folders/{id}/products`, `POST /folders/{id}/products/bulk`, `PUT/DELETE /products/{id}` · `GET/POST/PUT/DELETE /memos` · `GET/POST/PUT/DELETE /sheets`, `POST /sheets/{id}/copy-to-memo` · `GET /activities`, `POST /activities/{id}/undo`

## Mencoba cepat
```bash
curl -X POST localhost:8000/api/folders -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name":"Belanja Baru"}'
curl -X POST localhost:8000/api/folders/1/products -H 'Accept: application/json' -H 'Content-Type: application/json' \
     -d '{"date":"2026-10-22","name":"   ","price":1000,"selling_price":2000}'    # -> 422 dari trigger
curl localhost:8000/api/activities            # riwayat yang ditulis trigger
```

## Yang belum teruji
Kode ini baru diperiksa sintaks PHP-nya (`php -l`). Server MySQL dan Composer/Packagist tidak bisa dipakai di lingkungan tempat file ini dibuat, jadi migration, trigger, dan endpoint **belum pernah dijalankan**. Jalankan `php artisan migrate` dan contoh `curl` di atas; bila ada error SQL, kirim pesannya untuk diperbaiki.
Tampilan web sudah tersambung ke API ini, dan login sudah ada (lihat di bawah).

## Login (wajib masuk dulu)
Semua halaman dan `/api/*` hanya bisa dibuka setelah login (sesi + cookie, token CSRF otomatis). Tidak ada pendaftaran terbuka, jadi orang asing tidak bisa membuat akun sendiri.
- Login bawaan: **admin@catatin.local / catatin123**, dibuat otomatis oleh `php artisan migrate` bila tabel `users` masih kosong. **Segera ganti.**
- Tambah user / ganti password: `php artisan catatin:user budi@toko.com --name=Budi --password=rahasia123` (tanpa `--password`, password ditanyakan).
- Tombol keluar ada di pojok kanan atas aplikasi (ikon ⎋). Percobaan password salah dibatasi 5x per menit.
- Data (folder, barang, memo, tabel) dipakai bersama oleh semua user yang bisa login; belum dipisah per user.

## Memperbarui database TANPA impor ulang
Cukup `php artisan migrate`: menambah kolom `client_key` dan membuat user bawaan, data lama tetap aman. Bila hosting tidak punya terminal, impor `db_update_login.sql` (phpMyAdmin) ke database yang sudah ada. `db_catatin.sql` hanya untuk database KOSONG (sudah berisi kolom baru + user bawaan).
Habis deploy file baru, jalankan `php artisan optimize:clear` supaya rute dan konfigurasi lama tidak tertinggal.

## Anti data dobel
Setiap data baru (folder, barang, memo, tabel) dikirim browser bersama kode unik `client_key` (kolom UNIQUE). Bila permintaan yang sama masuk dua kali (klik dobel, koneksi lambat, percobaan ulang otomatis), server memakai data yang sudah ada dan tidak membuat yang kedua.

## Indikator offline / sinkronisasi
Indikator di topbar kini menunjukkan status nyata: Offline, Menyimpan…, Belum tersinkron, Tersimpan. Di HP muncul spanduk di atas layar (offline, menyinkronkan, berhasil, atau gagal + tombol "Coba lagi"). Saat internet kembali, simpan otomatis (memo, folder, barang) dan tabel yang tertunda dikirim sungguhan, dan dicoba ulang tiap 15 detik bila masih gagal. Batasan: perubahan offline hanya bertahan selama halaman tetap terbuka (belum ada antrean permanen di perangkat).


## Akun & data per akun
- Halaman `/login` dan `/register`. Akun baru otomatis **kosong** (belum ada folder, barang, memo, tabel, riwayat); data tiap akun terpisah lewat kolom `user_id`.
- Akun bawaan: `user@gmail.com` / `usercatatin` (dibuat migration `2026_10_26_000002_add_user_id_per_account`; data lama yang sudah ada menjadi milik akun ini).
- Cara pasang: `php artisan migrate` (database lama aman), atau `php artisan migrate:fresh --seed --seeder=CatatinSeeder` untuk database baru + data contoh di akun `user@gmail.com`.
