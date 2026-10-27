<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\RateLimiter;
<<<<<<< HEAD
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

/** Login / daftar / logout dengan sesi (cookie). Akun baru otomatis kosong: data tiap akun terpisah (user_id). */
=======
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

/** Login / logout dengan sesi (cookie). Tidak ada pendaftaran terbuka: user dibuat lewat `php artisan catatin:user`. */
>>>>>>> 85f42d1908541fe39e4ca44d548d884aa2e9774c
class AuthController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'email'    => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        // Batasi percobaan salah: 5x per menit untuk kombinasi email + IP (mencegah tebak-tebakan password).
        $throttleKey = Str::lower($data['email']) . '|' . $request->ip();
        if (RateLimiter::tooManyAttempts($throttleKey, 5)) {
            $detik = RateLimiter::availableIn($throttleKey);
            throw ValidationException::withMessages(['email' => "Terlalu banyak percobaan. Coba lagi dalam {$detik} detik."]);
        }

        if (!Auth::attempt(['email' => $data['email'], 'password' => $data['password']], $request->boolean('remember'))) {
            RateLimiter::hit($throttleKey, 60);
            throw ValidationException::withMessages(['email' => 'Email atau password salah.']);
        }

        RateLimiter::clear($throttleKey);
        $request->session()->regenerate();           // cegah session fixation
        return redirect()->intended('/');
    }

<<<<<<< HEAD
    public function showRegister()
    {
        return view('auth.register');
    }

    public function register(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name'     => ['required', 'string', 'max:100'],
            'email'    => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ], [
            'email.unique'       => 'Email ini sudah terdaftar.',
            'password.min'       => 'Password minimal 6 karakter.',
            'password.confirmed' => 'Konfirmasi password tidak sama.',
        ]);

        $user = User::create($data);                 // password di-hash oleh cast 'hashed'
        Auth::login($user, true);
        $request->session()->regenerate();
        return redirect('/');                        // akun baru: belum ada folder/memo/tabel
    }

=======
>>>>>>> 85f42d1908541fe39e4ca44d548d884aa2e9774c
    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login');
    }
}
