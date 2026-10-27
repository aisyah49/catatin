<?php

namespace App\Models\Concerns;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

/**
 * Data milik satu akun. Setiap query otomatis dibatasi ke user yang sedang login,
 * dan setiap data baru otomatis diberi user_id akun itu. Akun baru = data kosong.
 * (Di artisan/seeder tidak ada user login, jadi pembatasan tidak aktif dan user_id diisi manual.)
 */
trait BelongsToUser
{
    protected static function bootBelongsToUser(): void
    {
        static::addGlobalScope('owner', function (Builder $q) {
            if (Auth::hasUser()) {
                $q->where($q->getModel()->getTable() . '.user_id', Auth::id());
            }
        });

        static::creating(function ($model) {
            if ($model->user_id === null && Auth::hasUser()) {
                $model->user_id = Auth::id();
            }
        });
    }
}
