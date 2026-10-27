<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
<<<<<<< HEAD
    /** Membuat akun bawaan bila belum ada (aman dijalankan berulang). Data contoh: --class=CatatinSeeder */
    public function run(): void
    {
        User::firstOrCreate(['email' => 'admin@catatin.local'], ['name' => 'Admin', 'password' => 'catatin123']);
        User::firstOrCreate(['email' => 'user@gmail.com'], ['name' => 'User', 'password' => 'usercatatin']);
=======
    /** Membuat user login bawaan bila belum ada (aman dijalankan berulang). Data contoh: --class=CatatinSeeder */
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@catatin.local'],
            ['name' => 'Admin', 'password' => 'catatin123'],   // di-hash otomatis oleh cast 'hashed' pada model User
        );
>>>>>>> 85f42d1908541fe39e4ca44d548d884aa2e9774c
    }
}
