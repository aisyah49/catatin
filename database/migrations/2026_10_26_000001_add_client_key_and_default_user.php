<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

/**
 * MIGRATION 3 — dua hal, aman dijalankan di database yang sudah berisi data (tidak ada yang dihapus):
 *  1. Kolom `client_key` di folders/products/memos/sheets. Browser membuat kode unik untuk tiap data BARU,
 *     jadi kalau permintaan simpan terkirim dua kali (klik dobel, koneksi lambat, percobaan ulang),
 *     server mengenali kodenya dan tidak membuat data kedua.
 *  2. User login bawaan (hanya dibuat bila tabel users masih kosong), jadi tidak perlu impor SQL lagi.
 *     Login: admin@catatin.local / catatin123  -> GANTI sesudah masuk: php artisan catatin:user
 */
return new class extends Migration
{
    private const TABLES = ['folders', 'products', 'memos', 'sheets'];

    public function up(): void
    {
        foreach (self::TABLES as $table) {
            if (!Schema::hasColumn($table, 'client_key')) {
                Schema::table($table, function (Blueprint $t) {
                    $t->string('client_key', 64)->nullable()->unique();
                });
            }
        }

        if (DB::table('users')->count() === 0) {
            DB::table('users')->insert([
                'name'       => 'Admin',
                'email'      => 'admin@catatin.local',
                'password'   => Hash::make('catatin123'),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        foreach (self::TABLES as $table) {
            if (Schema::hasColumn($table, 'client_key')) {
                Schema::table($table, function (Blueprint $t) {
                    $t->dropUnique(['client_key']);
                    $t->dropColumn('client_key');
                });
            }
        }
    }
};
