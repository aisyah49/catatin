<?php

use Illuminate\Support\Facades\Route;

// Beranda = aplikasi Catatin (tampilan Blade: resources/views/catatin.blade.php)
Route::get('/', fn () => view('catatin'));
