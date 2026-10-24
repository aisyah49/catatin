<?php

namespace App\Http\Controllers;

use App\Models\Folder;
use App\Models\Memo;
use App\Models\Product;
use App\Models\Sheet;
use App\Support\DbGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

/**
 * Pintu data untuk tampilan Catatin (halaman Blade).
 * Tampilan lama memakai 4 operasi sederhana: ambil semua, ambil satu, simpan, hapus.
 * Controller ini menyediakan keempatnya untuk folders / products / memos / sheets.
 *
 * Isi data dikirim sebagai SATU teks JSON di kolom `payload`. Tujuannya supaya isi memo dan tabel
 * (teks kosong, spasi, HTML) tidak diubah oleh middleware Laravel (TrimStrings / ConvertEmptyStringsToNull).
 *
 * Semua simpan/hapus berjalan dalam transaksi (DbGuard::tx): error -> ROLLBACK otomatis.
 * Validasi dan riwayat tetap dikerjakan TRIGGER di database.
 */
class UiStoreController extends Controller
{
    private const MODELS = [
        'folders'  => Folder::class,
        'products' => Product::class,
        'memos'    => Memo::class,
        'sheets'   => Sheet::class,
    ];

    /** Aturan validasi per jenis data. */
    private function rules(string $entity): array
    {
        return match ($entity) {
            'folders' => ['name' => 'required|string|max:255', 'last_opened_at' => 'nullable|date'],
            'products' => [
                'folder_id' => 'required|integer|exists:folders,id', 'date' => 'required|date', 'name' => 'required|string|max:255',
                'price' => 'required|integer|min:0', 'box_qty' => 'nullable|integer|min:0', 'small_box_qty' => 'nullable|integer|min:0',
                'selling_price' => 'required|integer|min:0', 'photo' => 'nullable|string',
            ],
            'memos' => ['title' => 'nullable|string|max:255', 'date' => 'required|date', 'blocks' => 'nullable|array', 'from_sheet' => 'nullable|array'],
            'sheets' => [
                'name' => 'required|string|max:255', 'rows' => 'required|integer|min:1|max:1000', 'cols' => 'required|integer|min:1|max:100',
                'cells' => 'nullable|array', 'fmt' => 'nullable|array', 'imgs' => 'nullable|array', 'filter' => 'nullable|array',
            ],
        };
    }

    /**
     * Isi daftar yang RINGAN untuk satu jenis data (dipakai index() dan bundle()):
     *  - tabel : tanpa isi sel/foto (diambil saat tabel dibuka)
     *  - memo  : `src` foto dikosongkan (diambil lengkap lewat show() saat memo dibuka)
     *  - barang: tanpa kolom foto, hanya penanda `has_photo` (foto diambil per folder lewat productPhotos())
     * Foto bisa berukuran MB; memuatnya di setiap daftar membuat semua halaman lambat di server satu-jalur.
     */
    private function listRows(string $entity)
    {
        $q = (self::MODELS[$entity])::query();
        if ($entity === 'sheets') {
            $q->select('id', 'name', 'rows', 'cols', 'created_at', 'updated_at');
        }
        if ($entity === 'products') {
            $q->select('id', 'folder_id', 'date', 'name', 'price', 'box_qty', 'small_box_qty', 'selling_price', 'created_at', 'updated_at')
              ->selectRaw("(photo IS NOT NULL AND photo <> '') AS has_photo");
        }
        $rows = $q->orderBy('id')->get();
        if ($entity === 'memos') {
            $rows->each(function ($m) {
                $b = $m->blocks;
                if (is_array($b)) {
                    foreach ($b as $i => $blk) {
                        if (($blk['type'] ?? '') === 'image') { $b[$i]['src'] = null; }
                    }
                    $m->blocks = $b;
                }
            });
        }
        return $rows;
    }

    /** Ambil semua data satu jenis. */
    public function index(string $entity): JsonResponse
    {
        return response()->json($this->listRows($entity));
    }

    /**
     * SATU permintaan untuk semua daftar (folder, barang, memo, tabel, riwayat). `php artisan serve` hanya melayani satu
     * permintaan sekali waktu dan tiap permintaan memuat ulang Laravel, jadi 5 permintaan terpisah = 5x tunggu.
     */
    public function bundle(): JsonResponse
    {
        return response()->json([
            'folders'  => $this->listRows('folders'),
            'products' => $this->listRows('products'),
            'memos'    => $this->listRows('memos'),
            'sheets'   => $this->listRows('sheets'),
            'activity' => \App\Models\Activity::select('id', 'type', 'entity', 'entity_id', 'entity_name', 'undone', 'created_at')
                ->selectRaw('(snapshot IS NOT NULL) AS has_snapshot')->orderByDesc('id')->limit(80)->get(),
        ]);
    }

    /** Foto semua barang dalam satu folder: {id: dataUrl}. Dipanggil sesudah halaman folder tampil. */
    public function productPhotos(int $folder): JsonResponse
    {
        return response()->json((object) \App\Models\Product::where('folder_id', $folder)
            ->whereNotNull('photo')->where('photo', '<>', '')->pluck('photo', 'id')->all());
    }

    public function show(string $entity, int $id): JsonResponse
    {
        return response()->json((self::MODELS[$entity])::findOrFail($id));
    }

    /** Simpan. Tanpa $id = buat baru (POST); dengan $id = ubah atau pulihkan dengan id yang sama (PUT). */
    public function save(Request $r, string $entity, ?int $id = null): JsonResponse
    {
        $data = json_decode((string) $r->input('payload'), true);
        if (!is_array($data)) {
            return response()->json(['message' => 'Data tidak valid'], 422);
        }
        $data = Validator::make($data, $this->rules($entity))->validate();
        if ($entity === 'memos') {
            $data['title'] = $data['title'] ?? '';   // kolom title tidak boleh NULL
        }

        $model = DbGuard::tx(function () use ($entity, $id, $data) {
            $class = self::MODELS[$entity];
            return $id ? $class::updateOrCreate(['id' => $id], $data) : $class::create($data);
        });
        return response()->json($model->fresh(), $id ? 200 : 201);
    }

    /** Hapus. Folder ikut menghapus barangnya (FK cascade); trigger mencatat snapshot untuk "Urungkan". */
    public function destroy(string $entity, int $id): JsonResponse
    {
        DbGuard::tx(fn () => (self::MODELS[$entity])::whereKey($id)->get()->each->delete());
        return response()->json(['deleted' => true]);
    }
}
