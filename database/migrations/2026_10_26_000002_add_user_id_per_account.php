<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

/**
 * MIGRATION 4 — data dipisah PER AKUN.
 *  1. Kolom user_id di folders/products/memos/sheets/activities.
 *  2. Membuat akun user@gmail.com (pw: usercatatin). Data lama yang sudah ada (belum punya pemilik) menjadi milik akun ini,
 *     jadi tidak ada yang hilang. Akun lain / akun baru mulai KOSONG.
 *  3. Trigger riwayat dibuat ulang agar baris riwayat ikut mencatat user_id pemilik datanya.
 * Aman dijalankan di database yang sudah berisi data.
 */
return new class extends Migration
{
    private const TABLES = ['folders', 'products', 'memos', 'sheets', 'activities'];

    public function up(): void
    {
        foreach (self::TABLES as $table) {
            if (!Schema::hasColumn($table, 'user_id')) {
                Schema::table($table, function (Blueprint $t) {
                    $t->foreignId('user_id')->nullable()->constrained('users')->cascadeOnDelete();
                });
            }
        }

        $user = DB::table('users')->where('email', 'user@gmail.com')->first();
        $uid = $user->id ?? DB::table('users')->insertGetId([
            'name' => 'User', 'email' => 'user@gmail.com', 'password' => Hash::make('usercatatin'),
            'created_at' => now(), 'updated_at' => now(),
        ]);

        // Data lama tanpa pemilik -> milik user@gmail.com. Riwayat otomatis dimatikan supaya tidak tercatat sebagai "edit".
        DB::statement('SET @catatin_skip_log = 1');
        foreach (self::TABLES as $table) {
            DB::table($table)->whereNull('user_id')->update(['user_id' => $uid]);
        }
        DB::statement('SET @catatin_skip_log = 0');

        $this->recreateTriggers();
    }

    public function down(): void
    {
        foreach (self::TABLES as $table) {
            if (Schema::hasColumn($table, 'user_id')) {
                Schema::table($table, function (Blueprint $t) {
                    $t->dropConstrainedForeignId('user_id');
                });
            }
        }
        // Trigger kembali ke versi migration 2 bila migration itu dijalankan ulang (migrate:fresh).
    }

    private function recreateTriggers(): void
    {
        $skip = 'COALESCE(@catatin_skip_log, 0) = 0';
        $productJson = fn (string $r) => "JSON_OBJECT('id',$r.id,'folder_id',$r.folder_id,'date',$r.date,'name',$r.name,"
            . "'price',$r.price,'box_qty',$r.box_qty,'small_box_qty',$r.small_box_qty,"
            . "'selling_price',$r.selling_price,'photo',$r.photo)";
        $ins = fn (string $type, string $entity, string $row, string $name) =>
            "IF $skip THEN INSERT INTO activities(type,entity,entity_id,entity_name,user_id) VALUES ('$type','$entity',$row.id,$row.$name,$row.user_id); END IF;";

        $this->trigger('trg_products_ai', 'AFTER INSERT ON products', $ins('add', 'product', 'NEW', 'name'));
        $this->trigger('trg_products_au', 'AFTER UPDATE ON products', $ins('edit', 'product', 'NEW', 'name'));
        $this->trigger('trg_products_ad', 'AFTER DELETE ON products', "
            IF $skip THEN
                INSERT INTO activities(type,entity,entity_id,entity_name,snapshot,user_id)
                VALUES ('delete','product',OLD.id,OLD.name," . $productJson('OLD') . ",OLD.user_id);
            END IF;");

        $this->trigger('trg_folders_ai', 'AFTER INSERT ON folders', $ins('add', 'folder', 'NEW', 'name'));
        $this->trigger('trg_folders_au', 'AFTER UPDATE ON folders', "
            IF $skip AND NOT (NEW.name <=> OLD.name) THEN
                INSERT INTO activities(type,entity,entity_id,entity_name,user_id) VALUES ('edit','folder',NEW.id,NEW.name,NEW.user_id);
            END IF;");
        $this->trigger('trg_folders_bd', 'BEFORE DELETE ON folders', "
            IF $skip THEN
                INSERT INTO activities(type,entity,entity_id,entity_name,snapshot,user_id)
                VALUES ('delete','folder',OLD.id,OLD.name,
                    JSON_OBJECT(
                        'folder', JSON_OBJECT('id',OLD.id,'name',OLD.name,'last_opened_at',OLD.last_opened_at,'created_at',OLD.created_at),
                        'products', COALESCE((SELECT JSON_ARRAYAGG(" . $productJson('p') . ") FROM products p WHERE p.folder_id = OLD.id), JSON_ARRAY())
                    ), OLD.user_id);
            END IF;");

        $this->trigger('trg_memos_ai', 'AFTER INSERT ON memos', $ins('add', 'memo', 'NEW', 'title'));
        $this->trigger('trg_memos_au', 'AFTER UPDATE ON memos', $ins('edit', 'memo', 'NEW', 'title'));
        $this->trigger('trg_memos_ad', 'AFTER DELETE ON memos', "
            IF $skip THEN
                INSERT INTO activities(type,entity,entity_id,entity_name,snapshot,user_id)
                VALUES ('delete','memo',OLD.id,OLD.title,
                    JSON_OBJECT('id',OLD.id,'title',OLD.title,'date',OLD.date,'blocks',OLD.blocks,'from_sheet',OLD.from_sheet),OLD.user_id);
            END IF;");

        $this->trigger('trg_sheets_ai', 'AFTER INSERT ON sheets', $ins('add', 'sheet', 'NEW', 'name'));
        $this->trigger('trg_sheets_ad', 'AFTER DELETE ON sheets', $ins('delete', 'sheet', 'OLD', 'name'));
    }

    private function trigger(string $name, string $when, string $body): void
    {
        DB::unprepared("DROP TRIGGER IF EXISTS $name");
        DB::unprepared("CREATE TRIGGER $name $when FOR EACH ROW BEGIN $body END");
    }
};
