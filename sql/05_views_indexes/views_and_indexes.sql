-- ============================================================
-- FILE: 05_views_indexes/views_and_indexes.sql
-- PROJECT: SQL & NoSQL Mobile Catalog Analysis — NMIMS Mumbai
-- DESC: Creates 3 reusable reporting VIEWs, 5 performance
--       INDEXes, and demonstrates EXPLAIN before/after
--       index creation to show query optimization.
-- ============================================================

USE mobile_catalog;

-- ============================================================
-- SECTION 1: VIEWS (Reusable Reporting Layers)
-- ============================================================

-- VIEW 1: vw_brand_summary
CREATE OR REPLACE VIEW vw_brand_summary AS
SELECT
    b.brand_name,
    COUNT(p.phone_id)                       AS total_models,
    ROUND(AVG(p.price), 2)                  AS avg_price_inr,
    MIN(p.price)                            AS min_price,
    MAX(p.price)                            AS max_price,
    ROUND(AVG(p.rating), 2)                 AS avg_rating,
    SUM(c.has_5g)                           AS models_with_5g,
    ROUND(100.0 * SUM(c.has_5g) / COUNT(*), 1) AS pct_5g
FROM phone p
JOIN brand b        ON p.brand_id        = b.brand_id
JOIN connectivity c ON p.connectivity_id = c.connectivity_id
WHERE p.price IS NOT NULL
GROUP BY b.brand_name, b.brand_id;

-- VIEW 2: vw_premium_phones
CREATE OR REPLACE VIEW vw_premium_phones AS
SELECT
    b.brand_name,
    p.model,
    p.price,
    p.rating,
    pr.processor_brand,
    pr.num_cores,
    s.refresh_rate                              AS hz,
    m.ram_capacity                              AS ram_gb,
    bt.fast_charging                            AS fast_charge_w,
    c.has_5g, c.has_nfc,
    CASE
        WHEN p.price BETWEEN 30000 AND 59999  THEN 'Flagship'
        WHEN p.price >= 60000                 THEN 'Ultra-Premium'
    END AS tier
FROM phone p
JOIN brand b        ON p.brand_id        = b.brand_id
JOIN processor pr   ON p.processor_id    = pr.processor_id
JOIN screen s       ON p.screen_id       = s.screen_id
JOIN memory m       ON p.memory_id       = m.memory_id
JOIN battery bt     ON p.battery_id      = bt.battery_id
JOIN connectivity c ON p.connectivity_id = c.connectivity_id
WHERE p.price >= 30000;

-- VIEW 3: vw_connectivity_matrix
CREATE OR REPLACE VIEW vw_connectivity_matrix AS
SELECT
    b.brand_name,
    COUNT(p.phone_id)                                              AS total_models,
    SUM(c.has_5g)                                                  AS five_g_models,
    SUM(c.has_nfc)                                                 AS nfc_models,
    SUM(c.has_ir_blaster)                                          AS ir_models,
    ROUND(100.0 * SUM(c.has_5g)         / COUNT(p.phone_id), 1)   AS pct_5g,
    ROUND(100.0 * SUM(c.has_nfc)        / COUNT(p.phone_id), 1)   AS pct_nfc,
    ROUND(100.0 * SUM(c.has_ir_blaster) / COUNT(p.phone_id), 1)   AS pct_ir
FROM phone p
JOIN brand b        ON p.brand_id        = b.brand_id
JOIN connectivity c ON p.connectivity_id = c.connectivity_id
GROUP BY b.brand_name, b.brand_id;

-- ============================================================
-- SECTION 2: PERFORMANCE INDEXES
-- ============================================================

CREATE INDEX idx_phone_brand       ON phone(brand_id);
CREATE INDEX idx_phone_price       ON phone(price);
CREATE INDEX idx_conn_5g           ON connectivity(has_5g);
CREATE INDEX idx_proc_brand        ON processor(processor_brand);
CREATE INDEX idx_phone_brand_price ON phone(brand_id, price);

-- ============================================================
-- SECTION 3: EXPLAIN ANALYSIS — Before vs. After Index
-- ============================================================

EXPLAIN
SELECT b.brand_name, p.model, p.price
FROM phone p
JOIN brand b ON p.brand_id = b.brand_id
WHERE p.price BETWEEN 20000 AND 50000
ORDER BY p.price DESC;
