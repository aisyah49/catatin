-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table catatin.activities
CREATE TABLE IF NOT EXISTS `activities` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('add','edit','delete') COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `entity_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `snapshot` json DEFAULT NULL,
  `undone` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `activities_created_at_index` (`created_at`),
  KEY `activities_entity_entity_id_index` (`entity`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.cache
CREATE TABLE IF NOT EXISTS `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.cache_locks
CREATE TABLE IF NOT EXISTS `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.failed_jobs
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for function catatin.fn_laba_per_pcs
DELIMITER //
CREATE FUNCTION `fn_laba_per_pcs`(p_price BIGINT UNSIGNED, p_box_qty INT UNSIGNED, p_sell BIGINT UNSIGNED) RETURNS decimal(14,2)
    DETERMINISTIC
BEGIN
                RETURN p_sell - fn_modal_per_pcs(p_price, p_box_qty);   -- NULL bila modal tidak bisa dihitung
            END//
DELIMITER ;

-- Dumping structure for function catatin.fn_modal_per_pcs
DELIMITER //
CREATE FUNCTION `fn_modal_per_pcs`(p_price BIGINT UNSIGNED, p_box_qty INT UNSIGNED) RETURNS decimal(14,2)
    DETERMINISTIC
BEGIN
                IF p_box_qty IS NULL OR p_box_qty = 0 THEN
                    RETURN NULL;           -- tidak bisa dihitung tanpa isi box
                END IF;
                RETURN ROUND(p_price / p_box_qty, 2);
            END//
DELIMITER ;

-- Dumping structure for function catatin.fn_total_modal_folder
DELIMITER //
CREATE FUNCTION `fn_total_modal_folder`(p_folder_id BIGINT UNSIGNED) RETURNS bigint unsigned
    READS SQL DATA
BEGIN
                RETURN (SELECT COALESCE(SUM(price), 0) FROM products WHERE folder_id = p_folder_id);
            END//
DELIMITER ;

-- Dumping structure for table catatin.folders
CREATE TABLE IF NOT EXISTS `folders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_opened_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `client_key` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `folders_client_key_unique` (`client_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.jobs
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.job_batches
CREATE TABLE IF NOT EXISTS `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.memos
CREATE TABLE IF NOT EXISTS `memos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `date` date NOT NULL,
  `blocks` json DEFAULT NULL,
  `from_sheet` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `client_key` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `memos_client_key_unique` (`client_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.migrations
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.password_reset_tokens
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.personal_access_tokens
CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.products
CREATE TABLE IF NOT EXISTS `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `folder_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` bigint unsigned NOT NULL DEFAULT '0',
  `box_qty` int unsigned DEFAULT NULL,
  `small_box_qty` int unsigned DEFAULT NULL,
  `selling_price` bigint unsigned NOT NULL DEFAULT '0',
  `photo` longtext COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `client_key` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_client_key_unique` (`client_key`),
  KEY `products_folder_id_date_index` (`folder_id`,`date`),
  KEY `products_name_index` (`name`),
  CONSTRAINT `products_folder_id_foreign` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.sessions
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.sheets
CREATE TABLE IF NOT EXISTS `sheets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rows` smallint unsigned NOT NULL DEFAULT '8',
  `cols` smallint unsigned NOT NULL DEFAULT '6',
  `cells` json DEFAULT NULL,
  `fmt` json DEFAULT NULL,
  `imgs` json DEFAULT NULL,
  `filter` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `client_key` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sheets_client_key_unique` (`client_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table catatin.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for view catatin.v_produk_laba
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `v_produk_laba` (
	`id` BIGINT(20) UNSIGNED NOT NULL,
	`folder_id` BIGINT(20) UNSIGNED NOT NULL,
	`name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`price` BIGINT(20) UNSIGNED NOT NULL,
	`box_qty` INT(10) UNSIGNED NULL,
	`selling_price` BIGINT(20) UNSIGNED NOT NULL,
	`modal_per_pcs` DECIMAL(14,2) NULL,
	`laba_per_pcs` DECIMAL(14,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for trigger catatin.trg_activities_bu
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_activities_bu` BEFORE UPDATE ON `activities` FOR EACH ROW BEGIN 
            IF NEW.type <> OLD.type OR NEW.entity <> OLD.entity OR NOT (NEW.entity_id <=> OLD.entity_id) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Riwayat tidak boleh diubah (hanya status undone)';
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_folders_ai
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_folders_ai` AFTER INSERT ON `folders` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('add','folder',NEW.id,NEW.name);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_folders_au
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_folders_au` AFTER UPDATE ON `folders` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 AND NOT (NEW.name <=> OLD.name) THEN   -- hanya bila nama berubah (membuka folder tidak dicatat)
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('edit','folder',NEW.id,NEW.name);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_folders_bd
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_folders_bd` BEFORE DELETE ON `folders` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name,snapshot)
                VALUES ('delete','folder',OLD.id,OLD.name,
                    JSON_OBJECT(
                        'folder', JSON_OBJECT('id',OLD.id,'name',OLD.name,'last_opened_at',OLD.last_opened_at,'created_at',OLD.created_at),
                        'products', COALESCE((SELECT JSON_ARRAYAGG(JSON_OBJECT('id',p.id,'folder_id',p.folder_id,'date',p.date,'name',p.name,'price',p.price,'box_qty',p.box_qty,'small_box_qty',p.small_box_qty,'selling_price',p.selling_price,'photo',p.photo)) FROM products p WHERE p.folder_id = OLD.id), JSON_ARRAY())
                    ));
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_folders_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_folders_bi` BEFORE INSERT ON `folders` FOR EACH ROW BEGIN
                IF NEW.name IS NULL OR TRIM(NEW.name) = '' THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nama folder tidak boleh kosong';
                END IF;
            END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_memos_ad
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_memos_ad` AFTER DELETE ON `memos` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name,snapshot)
                VALUES ('delete','memo',OLD.id,OLD.title,
                    JSON_OBJECT('id',OLD.id,'title',OLD.title,'date',OLD.date,'blocks',OLD.blocks,'from_sheet',OLD.from_sheet));
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_memos_ai
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_memos_ai` AFTER INSERT ON `memos` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('add','memo',NEW.id,NEW.title);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_memos_au
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_memos_au` AFTER UPDATE ON `memos` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('edit','memo',NEW.id,NEW.title);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_products_ad
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_products_ad` AFTER DELETE ON `products` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name,snapshot)
                VALUES ('delete','product',OLD.id,OLD.name,JSON_OBJECT('id',OLD.id,'folder_id',OLD.folder_id,'date',OLD.date,'name',OLD.name,'price',OLD.price,'box_qty',OLD.box_qty,'small_box_qty',OLD.small_box_qty,'selling_price',OLD.selling_price,'photo',OLD.photo));
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_products_ai
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_products_ai` AFTER INSERT ON `products` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('add','product',NEW.id,NEW.name);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_products_au
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_products_au` AFTER UPDATE ON `products` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('edit','product',NEW.id,NEW.name);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_products_bi
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_products_bi` BEFORE INSERT ON `products` FOR EACH ROW BEGIN
                    IF NEW.name IS NULL OR TRIM(NEW.name) = '' THEN
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nama barang tidak boleh kosong';
                    END IF;
                    SET NEW.name = TRIM(NEW.name);   -- rapikan spasi di awal/akhir
                END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_products_bu
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_products_bu` BEFORE UPDATE ON `products` FOR EACH ROW BEGIN
                    IF NEW.name IS NULL OR TRIM(NEW.name) = '' THEN
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nama barang tidak boleh kosong';
                    END IF;
                    SET NEW.name = TRIM(NEW.name);   -- rapikan spasi di awal/akhir
                END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_sheets_ad
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_sheets_ad` AFTER DELETE ON `sheets` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('delete','sheet',OLD.id,OLD.name);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger catatin.trg_sheets_ai
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_sheets_ai` AFTER INSERT ON `sheets` FOR EACH ROW BEGIN 
            IF COALESCE(@catatin_skip_log, 0) = 0 THEN
                INSERT INTO activities(type,entity,entity_id,entity_name) VALUES ('add','sheet',NEW.id,NEW.name);
            END IF; END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for view catatin.v_produk_laba
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `v_produk_laba`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_produk_laba` AS select `p`.`id` AS `id`,`p`.`folder_id` AS `folder_id`,`p`.`name` AS `name`,`p`.`price` AS `price`,`p`.`box_qty` AS `box_qty`,`p`.`selling_price` AS `selling_price`,`fn_modal_per_pcs`(`p`.`price`,`p`.`box_qty`) AS `modal_per_pcs`,`fn_laba_per_pcs`(`p`.`price`,`p`.`box_qty`,`p`.`selling_price`) AS `laba_per_pcs` from `products` `p`;

-- ------------------------------------------------------------
-- DATA AWAL (tidak perlu impor ulang saat ada pembaruan: cukup `php artisan migrate`)
-- Login bawaan: admin@catatin.local / catatin123  -> GANTI: php artisan catatin:user admin@catatin.local
-- ------------------------------------------------------------
INSERT INTO `migrations` (`migration`, `batch`)
SELECT v.m, 1 FROM (
  SELECT '0001_01_01_000000_create_users_table' AS m UNION ALL
  SELECT '0001_01_01_000001_create_cache_table' UNION ALL
  SELECT '0001_01_01_000002_create_jobs_table' UNION ALL
  SELECT '2026_10_22_000001_create_catatin_tables' UNION ALL
  SELECT '2026_10_22_000002_create_triggers_and_functions' UNION ALL
  SELECT '2026_10_22_075743_create_personal_access_tokens_table' UNION ALL
  SELECT '2026_10_26_000001_add_client_key_and_default_user'
) v
WHERE NOT EXISTS (SELECT 1 FROM `migrations` x WHERE x.`migration` = v.m);

INSERT INTO `users` (`name`, `email`, `password`, `created_at`, `updated_at`)
SELECT 'Admin', 'admin@catatin.local', '$2y$12$uDfzigtEwZr93mT6rEUfFOni0Oop0/lF3Zmw5DP/rGrK.6wRlbb0m', NOW(), NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `users`);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
