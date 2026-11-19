-- ============================================================
-- FILE: 03_dml_seeding/01_dimensions_seeding.sql
-- PROJECT: SQL & NoSQL Mobile Catalog Analysis — NMIMS Mumbai
-- DESC: Part 1 of Seeding — Lookup & Specification Dimensions
--       (brand, os, connectivity, processor, memory, camera)
-- ============================================================

USE mobile_catalog;
SET FOREIGN_KEY_CHECKS=0;
SET SQL_SAFE_UPDATES=0;

-- Clean previous data before reseeding to prevent Duplicate Key 1062 errors
TRUNCATE TABLE `phone`;
TRUNCATE TABLE `price_analysis`;
TRUNCATE TABLE `camera`;
TRUNCATE TABLE `memory`;
TRUNCATE TABLE `screen`;
TRUNCATE TABLE `battery`;
TRUNCATE TABLE `connectivity`;
TRUNCATE TABLE `os`;
TRUNCATE TABLE `processor`;
TRUNCATE TABLE `brand`;

-- 1. brand
INSERT INTO brand (brand_id, brand_name) VALUES
  (1, 'oneplus'), (2, 'samsung'), (3, 'motorola'), (4, 'realme'), (5, 'apple'),
  (6, 'xiaomi'), (7, 'nothing'), (8, 'oppo'), (9, 'vivo'), (10, 'poco'),
  (11, 'iqoo'), (12, 'jio'), (13, 'gionee'), (14, 'tecno'), (15, 'tesla'),
  (16, 'google'), (17, 'infinix'), (18, 'cola'), (19, 'letv'), (20, 'ikall'),
  (21, 'leeco'), (22, 'duoqin'), (23, 'nokia'), (24, 'lava'), (25, 'honor'),
  (26, 'nubia'), (27, 'redmi'), (28, 'asus'), (29, 'itel'), (30, 'royole'),
  (31, 'sony'), (32, 'oukitel'), (33, 'vertu'), (34, 'blu'), (35, 'lyf'),
  (36, 'huawei'), (37, 'zte'), (38, 'lenovo'), (39, 'lg'), (40, 'micromax'),
  (41, 'leitz'), (42, 'cat'), (43, 'doogee'), (44, 'tcl'), (45, 'sharp'),
  (46, 'blackview');

-- 2. os
INSERT INTO os (os_id, os_name) VALUES
  (1, 'android'),
  (2, 'ios'),
  (3, 'other'),
  (4, 'unknown');

-- 3. connectivity
INSERT INTO connectivity (connectivity_id, has_5g, has_nfc, has_ir_blaster) VALUES
  (1, 1, 1, 0), (2, 1, 0, 0), (3, 1, 0, 1), (4, 0, 0, 0),
  (5, 1, 1, 1), (6, 0, 1, 0), (7, 0, 0, 1), (8, 0, 1, 1);

-- 4. processor
INSERT INTO processor (processor_id, processor_brand, num_cores, processor_speed) VALUES
  (1, 'snapdragon', 8.0, 3.2), (2, 'snapdragon', 8.0, 2.2), (3, 'exynos', 8.0, 2.4),
  (4, 'dimensity', 8.0, 2.6), (5, 'bionic', 6.0, 3.22), (6, 'snapdragon', 8.0, 2.5),
  (7, 'dimensity', 8.0, 3.0), (8, 'dimensity', 8.0, 2.2), (9, 'helio', 8.0, 2.3),
  (10, 'dimensity', 8.0, 2.85), (11, 'helio', 8.0, 2.0), (12, 'snapdragon', 8.0, 2.0),
  (13, 'dimensity', 8.0, 3.2), (14, 'snapdragon', 8.0, 2.84), (15, 'bionic', 6.0, NULL),
  (16, 'dimensity', 8.0, 2.0), (17, 'snapdragon', 8.0, 2.4), (18, 'bionic', 6.0, 2.65),
  (19, 'dimensity', 8.0, 2.4), (20, 'exynos', 8.0, 2.9), (21, 'snapdragon', 8.0, 3.0),
  (22, 'snapdragon', 8.0, 2.36), (23, 'unisoc', 8.0, 1.8), (24, 'dimensity', 8.0, 3.1),
  (25, 'helio', 8.0, 2.2), (26, 'helio', 8.0, 2.05), (27, 'dimensity', 8.0, 2.5),
  (28, 'tiger', 4.0, 2.0), (29, 'exynos', 8.0, NULL), (30, 'snapdragon', 8.0, 2.9),
  (31, 'dimensity', 8.0, 3.05), (32, 'bionic', 6.0, 3.1), (33, 'helio', 4.0, 2.0),
  (34, 'unknown', 8.0, NULL), (35, 'google', 8.0, NULL), (36, 'snapdragon', 8.0, 2.3),
  (37, 'tiger', 8.0, 1.8), (38, 'unknown', 4.0, 1.4), (39, 'snapdragon', 8.0, 1.8),
  (40, 'bionic', NULL, NULL), (41, 'tiger', 8.0, 1.82), (42, 'exynos', 8.0, 2.0),
  (43, 'unknown', 4.0, 1.6), (44, 'tiger', 4.0, 1.8), (45, 'unknown', 8.0, 2.0),
  (46, 'google', 8.0, 2.85), (47, 'helio', 8.0, NULL), (48, 'snapdragon', 8.0, NULL),
  (49, 'google', 8.0, 2.8), (50, 'sc9863a', 8.0, 1.6), (51, 'unknown', 4.0, 1.3),
  (52, 'unisoc', 4.0, 1.6), (53, 'snapdragon', 4.0, 1.3), (54, 'unisoc', 8.0, 1.6),
  (55, 'exynos', 8.0, 2.73), (56, 'snapdragon', 8.0, 2.8), (57, 'exynos', 8.0, 2.7),
  (58, 'unisoc', 8.0, NULL), (59, 'unisoc', 8.0, 2.0), (60, 'spreadtrum', 4.0, 1.3),
  (61, 'bionic', 8.0, NULL), (62, 'snapdragon', NULL, NULL), (63, 'snapdragon', 8.0, 1.5),
  (64, 'snapdragon', 8.0, 2.96), (65, 'helio', 4.0, 1.3), (66, 'tiger', 8.0, 2.0),
  (67, 'unisoc', 4.0, 1.4), (68, 'helio', 8.0, 1.8), (69, 'snapdragon', 8.0, 2.35),
  (70, 'snapdragon', 4.0, 1.4), (71, 'fusion', 4.0, 2.37), (72, 'kirin', 8.0, 3.13),
  (73, 'dimensity', 8.0, NULL), (74, 'exynos', 8.0, 1.8), (75, 'exynos', 8.0, 2.3),
  (76, 'helio', 8.0, 1.99), (77, 'snapdragon', 8.0, 2.7), (78, 'unisoc', 4.0, 1.3),
  (79, 'unknown', 8.0, 2.2), (80, 'kirin', 8.0, 2.86), (81, 'snapdragon', 8.0, 1.95),
  (82, 'exynos', 8.0, 2.8), (83, 'mediatek', 4.0, 1.5), (84, 'kirin', 8.0, 2.2),
  (85, 'exynos', 8.0, 2.2), (86, 'kirin', 8.0, 2.36), (87, 'spreadtrum', 4.0, 1.4),
  (88, 'helio', 8.0, 2.1), (89, 'helio', 8.0, 2.5), (90, 'unknown', 8.0, 1.8),
  (91, 'snapdragon', 4.0, 1.2);

-- 5. memory
INSERT INTO memory (memory_id, ram_capacity, internal_memory, extended_memory_available, extended_upto) VALUES
  (1, 12.0, 256.0, 0, NULL), (2, 6.0, 128.0, 1, 1024.0), (3, 4.0, 64.0, 1, 1024.0),
  (4, 6.0, 128.0, 0, NULL), (5, 8.0, 256.0, 0, NULL), (6, 8.0, 128.0, 0, NULL),
  (7, 8.0, 128.0, 1, NULL), (8, 4.0, 128.0, 0, NULL), (9, 3.0, 32.0, 1, NULL),
  (10, 16.0, 256.0, 0, NULL), (11, 6.0, 64.0, 1, 1024.0), (12, 4.0, 128.0, 1, 1024.0),
  (13, 8.0, 128.0, 1, 1024.0), (14, 8.0, 256.0, 1, NULL), (15, 4.0, 64.0, 0, NULL),
  (16, 8.0, 256.0, 1, 1024.0), (17, 6.0, 128.0, 1, 512.0), (18, 4.0, 64.0, 1, 512.0),
  (19, 3.0, 32.0, 1, 1024.0), (20, 4.0, 64.0, 1, NULL), (21, 4.0, 32.0, 1, 512.0),
  (22, 6.0, 64.0, 1, 512.0), (23, 3.0, 64.0, 1, 1024.0), (24, 12.0, 256.0, 1, NULL),
  (25, 4.0, 32.0, 1, NULL), (26, 6.0, 128.0, 1, NULL), (27, 8.0, 128.0, 1, 256.0),
  (28, 2.0, 32.0, 1, 512.0), (29, 16.0, 512.0, 0, NULL), (30, 8.0, 128.0, 1, 2048.0),
  (31, 2.0, 64.0, 1, 128.0), (32, 8.0, 256.0, 1, 256.0), (33, 2.0, 32.0, 1, 1024.0),
  (34, 6.0, 128.0, 1, 256.0), (35, 4.0, 32.0, 0, NULL), (36, 3.0, 64.0, 0, NULL),
  (37, 4.0, 64.0, 1, 256.0), (38, 12.0, 256.0, 1, 1024.0), (39, 3.0, 32.0, 1, 256.0),
  (40, 4.0, 64.0, 1, 128.0), (41, 3.0, 32.0, 1, 128.0), (42, 8.0, 128.0, 1, 512.0),
  (43, 6.0, 256.0, 0, NULL), (44, 12.0, 128.0, 0, NULL), (45, 3.0, 64.0, 1, NULL),
  (46, 8.0, 256.0, 1, 512.0), (47, 6.0, 64.0, 1, NULL), (48, 6.0, 64.0, 0, NULL),
  (49, 4.0, 128.0, 1, 512.0), (50, 3.0, 32.0, 1, 512.0), (51, 6.0, 64.0, 1, 2048.0),
  (52, 18.0, 512.0, 0, NULL), (53, 8.0, 256.0, 1, 2048.0), (54, 6.0, 1024.0, 0, NULL),
  (55, 2.0, 32.0, 1, NULL), (56, 12.0, 512.0, 0, NULL), (57, 2.0, 32.0, 1, 32.0),
  (58, 4.0, 256.0, 0, NULL), (59, 4.0, 32.0, 1, 256.0), (60, 12.0, 512.0, 1, 1024.0),
  (61, 1.0, 16.0, 0, NULL), (62, 18.0, 256.0, 0, NULL), (63, 2.0, 64.0, 0, NULL),
  (64, 2.0, 32.0, 1, 256.0), (65, 6.0, 64.0, 1, 256.0), (66, 1.0, 16.0, 1, 128.0),
  (67, 3.0, 32.0, 1, 64.0), (68, 2.0, 64.0, 1, 1024.0), (69, 12.0, 512.0, 1, 256.0),
  (70, 4.0, 128.0, 1, 256.0), (71, 12.0, 512.0, 1, NULL), (72, 4.0, 128.0, 1, NULL),
  (73, 3.0, 16.0, 1, NULL), (74, 12.0, 128.0, 1, 1024.0), (75, 3.0, 32.0, 0, NULL),
  (76, 6.0, 512.0, 0, NULL), (77, 3.0, 64.0, 1, 128.0), (78, 2.0, 64.0, 1, 512.0),
  (79, 12.0, 256.0, 1, 512.0), (80, 2.0, 32.0, 1, 128.0), (81, 3.0, 64.0, 1, 512.0),
  (82, 8.0, 512.0, 0, NULL), (83, 1.0, 16.0, 1, NULL), (84, 2.0, 16.0, 1, 256.0),
  (85, 1.0, 16.0, 1, 32.0), (86, 3.0, 64.0, 1, 256.0), (87, 4.0, 32.0, 1, 128.0),
  (88, 4.0, 512.0, 0, NULL), (89, 2.0, 16.0, 0, NULL), (90, 12.0, 256.0, 1, 2048.0),
  (91, 1.0, 8.0, 0, NULL), (92, 12.0, 1024.0, 0, NULL), (93, 4.0, 64.0, 1, 64.0),
  (94, 2.0, 32.0, 0, NULL);

-- 6. camera (Sample of key sensor configurations)
INSERT INTO camera (camera_id, num_rear_cameras, num_front_cameras, primary_camera_rear, primary_camera_front) VALUES
  (1.0, 3.0, 1.0, 50.0, 16.0), (2.0, 3.0, 1.0, 64.0, 16.0), (3.0, 3.0, 1.0, 50.0, 13.0),
  (4.0, 3.0, 1.0, 108.0, 16.0), (5.0, 3.0, 1.0, 50.0, 8.0), (6.0, 2.0, 1.0, 12.0, 12.0),
  (7.0, 3.0, 1.0, 200.0, 16.0), (8.0, 2.0, 1.0, 50.0, 16.0), (9.0, 3.0, 1.0, 50.0, 32.0),
  (10.0, 2.0, 1.0, 108.0, 16.0), (11.0, 2.0, 1.0, 50.0, 8.0), (12.0, 4.0, 1.0, 200.0, 12.0),
  (13.0, 2.0, 1.0, 13.0, 5.0), (14.0, 3.0, 1.0, 64.0, 32.0), (15.0, 3.0, 1.0, 48.0, 13.0),
  (16.0, 3.0, 1.0, 12.0, 32.0), (17.0, 3.0, 1.0, 48.0, 12.0), (18.0, 3.0, 1.0, 64.0, 50.0),
  (19.0, 4.0, 1.0, 108.0, 32.0), (20.0, 4.0, 1.0, 108.0, 40.0), (21.0, 2.0, 1.0, 64.0, 32.0);

SET FOREIGN_KEY_CHECKS=1;
