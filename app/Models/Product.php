<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Barang di dalam folder. Validasi & pencatatan riwayat dikerjakan TRIGGER di database. */
class Product extends Model
{
    protected $guarded = [];
    protected $casts = ['date' => 'date:Y-m-d'];

    public function folder(): BelongsTo
    {
        return $this->belongsTo(Folder::class);
    }
}
