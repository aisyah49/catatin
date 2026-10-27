<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

/**
 * Membuat user baru atau mengganti password user yang sudah ada.
 *   php artisan catatin:user budi@toko.com --name=Budi --password=rahasia123
 * Bila --password dikosongkan, password ditanyakan (tidak tampil di layar).
 */
class CatatinUser extends Command
{
    protected $signature = 'catatin:user {email} {--name=} {--password=}';
    protected $description = 'Buat user login Catatin, atau ganti password bila emailnya sudah ada';

    public function handle(): int
    {
        $email = trim((string) $this->argument('email'));
        $password = $this->option('password') ?: $this->secret('Password (minimal 8 karakter)');
        if (strlen((string) $password) < 8) {
            $this->error('Password minimal 8 karakter.');
            return self::FAILURE;
        }

        $user = User::where('email', $email)->first();
        if ($user) {
            $user->forceFill(['password' => Hash::make($password)])->save();
            $this->info("Password {$email} sudah diganti.");
        } else {
            User::create(['name' => $this->option('name') ?: strstr($email, '@', true), 'email' => $email, 'password' => $password]);
            $this->info("User {$email} dibuat.");
        }
        return self::SUCCESS;
    }
}
