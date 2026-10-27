-- db_update_login.sql
-- Untuk database yang SUDAH ada isinya (folder/barang/memo/tabel tetap aman, tidak ada yang dihapus).
-- Menambah kolom anti-dobel (client_key), mencatat migrasinya, dan membuat user login bila belum ada user.
-- Aman dijalankan lebih dari sekali. (Alternatif tanpa SQL: jalankan `php artisan migrate` -- hasilnya sama.)

DELIMITER //
DROP PROCEDURE IF EXISTS catatin_add_client_key//
CREATE PROCEDURE catatin_add_client_key(IN tbl VARCHAR(64))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = 'client_key') THEN
    SET @q = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `client_key` VARCHAR(64) NULL, ADD UNIQUE KEY `', tbl, '_client_key_unique` (`client_key`)');
    PREPARE st FROM @q; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END//
DELIMITER ;

CALL catatin_add_client_key('folders');
CALL catatin_add_client_key('products');
CALL catatin_add_client_key('memos');
CALL catatin_add_client_key('sheets');
DROP PROCEDURE IF EXISTS catatin_add_client_key;

INSERT INTO `migrations` (`migration`, `batch`)
SELECT '2026_10_26_000001_add_client_key_and_default_user', COALESCE(MAX(`batch`), 0) + 1 FROM `migrations`
WHERE NOT EXISTS (SELECT 1 FROM `migrations` WHERE `migration` = '2026_10_26_000001_add_client_key_and_default_user');

-- Login bawaan: admin@catatin.local / catatin123 (hanya dibuat bila belum ada user sama sekali). GANTI setelah masuk.
INSERT INTO `users` (`name`, `email`, `password`, `created_at`, `updated_at`)
SELECT 'Admin', 'admin@catatin.local', '$2y$12$uDfzigtEwZr93mT6rEUfFOni0Oop0/lF3Zmw5DP/rGrK.6wRlbb0m', NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `users`);
