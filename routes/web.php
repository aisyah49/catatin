<?php

use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// Login (hanya untuk tamu) dan logout
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:30,1');
<<<<<<< HEAD
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:10,1');
=======
>>>>>>> 85f42d1908541fe39e4ca44d548d884aa2e9774c
});
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth')->name('logout');

// Beranda = aplikasi Catatin (tampilan Blade: resources/views/catatin.blade.php). Wajib login.
Route::get('/', fn () => view('catatin'))->middleware('auth');
