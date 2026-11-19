-- ============================================================
-- FILE: 01_ddl/schema_ddl.sql
-- PROJECT: SQL & NoSQL Mobile Catalog Analysis — NMIMS Mumbai
-- DESC: Creates the mobile_catalog database and all 10
--       normalized (3NF) tables with PK / FK constraints.
-- ============================================================

CREATE DATABASE IF NOT EXISTS mobile_catalog
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mobile_catalog;

-- ── 1. brand ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS brand (
    brand_id    INT          NOT NULL AUTO_INCREMENT,
    brand_name  VARCHAR(60)  NOT NULL,
    PRIMARY KEY (brand_id),
    UNIQUE KEY uq_brand_name (brand_name)
);

-- ── 2. processor ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS processor (
    processor_id    INT           NOT NULL AUTO_INCREMENT,
    processor_brand VARCHAR(60)   NULL,
    num_cores       TINYINT       NULL,
    processor_speed DECIMAL(4,2)  NULL COMMENT 'GHz',
    PRIMARY KEY (processor_id)
);

-- ── 3. os ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS os (
    os_id   INT          NOT NULL AUTO_INCREMENT,
    os_name VARCHAR(40)  NULL,
    PRIMARY KEY (os_id),
    UNIQUE KEY uq_os_name (os_name)
);

-- ── 4. connectivity ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS connectivity (
    connectivity_id INT         NOT NULL AUTO_INCREMENT,
    has_5g          BOOLEAN     NOT NULL DEFAULT FALSE,
    has_nfc         BOOLEAN     NOT NULL DEFAULT FALSE,
    has_ir_blaster  BOOLEAN     NOT NULL DEFAULT FALSE,
    PRIMARY KEY (connectivity_id)
);

-- ── 5. battery ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS battery (
    battery_id              INT           NOT NULL AUTO_INCREMENT,
    battery_capacity        INT           NULL     COMMENT 'mAh',
    fast_charging_available BOOLEAN       NOT NULL DEFAULT FALSE,
    fast_charging           DECIMAL(5,1)  NULL     COMMENT 'Watts',
    PRIMARY KEY (battery_id)
);

-- ── 6. screen ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS screen (
    screen_id         INT           NOT NULL AUTO_INCREMENT,
    screen_size       DECIMAL(4,2)  NULL COMMENT 'inches',
    refresh_rate      SMALLINT      NULL COMMENT 'Hz',
    resolution_width  SMALLINT      NULL COMMENT 'pixels',
    resolution_height SMALLINT      NULL COMMENT 'pixels',
    PRIMARY KEY (screen_id)
);

-- ── 7. memory ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `memory` (
    memory_id                 INT      NOT NULL AUTO_INCREMENT,
    ram_capacity              SMALLINT NULL COMMENT 'GB',
    internal_memory           SMALLINT NULL COMMENT 'GB',
    extended_memory_available BOOLEAN  NOT NULL DEFAULT FALSE,
    extended_upto             SMALLINT NULL COMMENT 'GB',
    PRIMARY KEY (memory_id)
);

-- ── 8. camera ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS camera (
    camera_id           INT           NOT NULL AUTO_INCREMENT,
    num_rear_cameras    TINYINT       NULL,
    num_front_cameras   TINYINT       NULL,
    primary_camera_rear DECIMAL(6,2)  NULL COMMENT 'MP',
    primary_camera_front DECIMAL(6,2) NULL COMMENT 'MP',
    PRIMARY KEY (camera_id)
);

-- ── 9. phone (Fact / Core Table) ──────────────────────────────
CREATE TABLE IF NOT EXISTS phone (
    phone_id        INT            NOT NULL AUTO_INCREMENT,
    model           VARCHAR(120)   NOT NULL,
    price           DECIMAL(10,2)  NULL COMMENT 'INR',
    rating          DECIMAL(3,1)   NULL,
    brand_id        INT            NOT NULL,
    processor_id    INT            NOT NULL,
    os_id           INT            NOT NULL,
    connectivity_id INT            NOT NULL,
    battery_id      INT            NOT NULL,
    screen_id       INT            NOT NULL,
    memory_id       INT            NOT NULL,
    camera_id       INT            NOT NULL,
    PRIMARY KEY (phone_id),
    CONSTRAINT fk_phone_brand        FOREIGN KEY (brand_id)        REFERENCES brand(brand_id),
    CONSTRAINT fk_phone_processor    FOREIGN KEY (processor_id)    REFERENCES processor(processor_id),
    CONSTRAINT fk_phone_os           FOREIGN KEY (os_id)           REFERENCES os(os_id),
    CONSTRAINT fk_phone_connectivity FOREIGN KEY (connectivity_id) REFERENCES connectivity(connectivity_id),
    CONSTRAINT fk_phone_battery      FOREIGN KEY (battery_id)      REFERENCES battery(battery_id),
    CONSTRAINT fk_phone_screen       FOREIGN KEY (screen_id)       REFERENCES screen(screen_id),
    CONSTRAINT fk_phone_memory       FOREIGN KEY (memory_id)       REFERENCES memory(memory_id),
    CONSTRAINT fk_phone_camera       FOREIGN KEY (camera_id)       REFERENCES camera(camera_id)
);

-- ── 10. price_analysis (Summary / Analytical Table) ───────────
CREATE TABLE IF NOT EXISTS price_analysis (
    brand_id    INT           NOT NULL,
    brand_name  VARCHAR(60)   NOT NULL,
    avg_price   DECIMAL(10,2) NULL,
    min_price   DECIMAL(10,2) NULL,
    max_price   DECIMAL(10,2) NULL,
    model_count INT           NULL,
    PRIMARY KEY (brand_id),
    CONSTRAINT fk_pa_brand FOREIGN KEY (brand_id) REFERENCES brand(brand_id)
);
