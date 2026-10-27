<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /** Membuat akun bawaan bila belum ada (aman dijalankan berulang). Data contoh: --class=CatatinSeeder */
    public function run(): void
    {
        User::firstOrCreate(['email' => 'admin@catatin.local'], ['name' => 'Admin', 'password' => 'catatin123']);
        User::firstOrCreate(['email' => 'user@gmail.com'], ['name' => 'User', 'password' => 'usercatatin']);
    }
}
