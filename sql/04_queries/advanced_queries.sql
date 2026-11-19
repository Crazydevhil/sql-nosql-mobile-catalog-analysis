-- ============================================================
-- FILE: 04_queries/advanced_queries.sql
-- PROJECT: SQL & NoSQL Mobile Catalog Analysis — NMIMS Mumbai
-- DESC: 28 advanced, production-grade SQL queries across 7
--       analytical themes. Battle-tested for MySQL 8.0+
--       compatibility (strict ONLY_FULL_GROUP_BY compliant).
-- ============================================================

USE mobile_catalog;
SET SQL_SAFE_UPDATES = 0;

-- Q-01: All 5G phones under INR 30,000 that also have NFC
SELECT b.brand_name, p.model, p.price
FROM phone p
JOIN brand b        ON p.brand_id        = b.brand_id
JOIN connectivity c ON p.connectivity_id = c.connectivity_id
WHERE c.has_5g = 1 AND c.has_nfc = 1 AND p.price < 30000
ORDER BY p.price ASC;

-- Q-02: Top 10 highest-rated phones overall
SELECT b.brand_name, p.model, p.rating, p.price
FROM phone p JOIN brand b ON p.brand_id = b.brand_id
WHERE p.rating IS NOT NULL
ORDER BY p.rating DESC, p.price ASC LIMIT 10;

-- Q-03: Phones with IR Blaster AND fast charging above 65W
SELECT b.brand_name, p.model, bt.fast_charging AS fast_charging_w, p.price
FROM phone p
JOIN brand b        ON p.brand_id        = b.brand_id
JOIN connectivity c ON p.connectivity_id = c.connectivity_id
JOIN battery bt     ON p.battery_id      = bt.battery_id
WHERE c.has_ir_blaster = 1 AND bt.fast_charging > 65
ORDER BY bt.fast_charging DESC;

-- Q-04: Anti-Join — brands that have NO 5G models in their lineup
SELECT DISTINCT b.brand_name FROM brand b
LEFT JOIN (
    SELECT DISTINCT p.brand_id FROM phone p
    JOIN connectivity c ON p.connectivity_id = c.connectivity_id WHERE c.has_5g = 1
) fiveg ON b.brand_id = fiveg.brand_id
WHERE fiveg.brand_id IS NULL ORDER BY b.brand_name;

-- Q-05: Average price per brand — only brands with 5+ models
SELECT b.brand_name, COUNT(p.phone_id) AS total_models,
    ROUND(AVG(p.price), 2) AS avg_price_inr, MIN(p.price) AS cheapest, MAX(p.price) AS most_expensive
FROM phone p JOIN brand b ON p.brand_id = b.brand_id
WHERE p.price IS NOT NULL GROUP BY b.brand_name HAVING COUNT(p.phone_id) >= 5
ORDER BY avg_price_inr DESC;

-- Q-06: 5G adoption rate per brand
SELECT b.brand_name, COUNT(p.phone_id) AS total_models, SUM(c.has_5g) AS models_with_5g,
    ROUND(100.0 * SUM(c.has_5g) / COUNT(p.phone_id), 1) AS pct_5g
FROM phone p JOIN brand b ON p.brand_id = b.brand_id
JOIN connectivity c ON p.connectivity_id = c.connectivity_id
GROUP BY b.brand_name HAVING COUNT(p.phone_id) >= 3 ORDER BY pct_5g DESC;

-- Q-07: CASE WHEN — price-tier bucketing
SELECT b.brand_name, p.model, p.price,
    CASE
        WHEN p.price < 10000                 THEN 'Budget (< 10k)'
        WHEN p.price BETWEEN 10000 AND 29999 THEN 'Mid-Range (10k - 30k)'
        WHEN p.price BETWEEN 30000 AND 59999 THEN 'Flagship (30k - 60k)'
        WHEN p.price >= 60000                THEN 'Ultra-Premium (60k+)'
        ELSE 'Unpriced'
    END AS price_tier
FROM phone p JOIN brand b ON p.brand_id = b.brand_id ORDER BY p.price ASC;

-- Q-08: Cross-tabulation pivot — model counts across price tiers
SELECT b.brand_name,
    SUM(CASE WHEN p.price < 10000                 THEN 1 ELSE 0 END) AS budget,
    SUM(CASE WHEN p.price BETWEEN 10000 AND 29999 THEN 1 ELSE 0 END) AS mid_range,
    SUM(CASE WHEN p.price BETWEEN 30000 AND 59999 THEN 1 ELSE 0 END) AS flagship,
    SUM(CASE WHEN p.price >= 60000                THEN 1 ELSE 0 END) AS ultra_premium
FROM phone p JOIN brand b ON p.brand_id = b.brand_id GROUP BY b.brand_name ORDER BY b.brand_name;

-- Q-09: Processor brand market share (CTE)
WITH proc_counts AS (
    SELECT COALESCE(pr.processor_brand, 'unknown') AS processor_brand, COUNT(p.phone_id) AS model_count
    FROM phone p JOIN processor pr ON p.processor_id = pr.processor_id GROUP BY pr.processor_brand
)
SELECT processor_brand, model_count, ROUND(100.0 * model_count / SUM(model_count) OVER (), 1) AS market_share_pct
FROM proc_counts ORDER BY model_count DESC;

-- Q-10: Full phone spec sheet (all dimension tables)
SELECT b.brand_name, p.model, p.price, p.rating, pr.processor_brand, pr.num_cores,
    pr.processor_speed AS ghz, o.os_name AS os, c.has_5g, c.has_nfc, c.has_ir_blaster,
    bt.battery_capacity AS mah, bt.fast_charging AS fast_charge_w, s.screen_size AS inches,
    s.refresh_rate AS hz, s.resolution_width, s.resolution_height, m.ram_capacity AS ram_gb,
    m.internal_memory AS storage_gb, m.extended_memory_available, cam.num_rear_cameras,
    cam.primary_camera_rear AS rear_mp, cam.primary_camera_front AS front_mp
FROM phone p
JOIN brand b        ON p.brand_id        = b.brand_id
JOIN processor pr   ON p.processor_id    = pr.processor_id
JOIN os o           ON p.os_id           = o.os_id
JOIN connectivity c ON p.connectivity_id = c.connectivity_id
JOIN battery bt     ON p.battery_id      = bt.battery_id
JOIN screen s       ON p.screen_id       = s.screen_id
JOIN memory m       ON p.memory_id       = m.memory_id
JOIN camera cam     ON p.camera_id       = cam.camera_id
ORDER BY b.brand_name, p.model LIMIT 50;

-- Q-11: Snapdragon-powered phones with 120Hz+ screens
SELECT b.brand_name, p.model, pr.processor_brand, s.refresh_rate, p.price
FROM phone p JOIN brand b ON p.brand_id = b.brand_id
JOIN processor pr ON p.processor_id = pr.processor_id
JOIN screen s ON p.screen_id = s.screen_id
WHERE pr.processor_brand IN ('snapdragon', 'qualcomm') AND s.refresh_rate >= 120
ORDER BY s.refresh_rate DESC, p.price ASC;

-- Q-12: Brand connectivity breakdown summary
SELECT b.brand_name, COUNT(p.phone_id) AS total_models, SUM(c.has_5g) AS has_5g_count,
    SUM(c.has_nfc) AS has_nfc_count, SUM(c.has_ir_blaster) AS has_ir_count
FROM brand b LEFT JOIN phone p ON b.brand_id = p.brand_id
LEFT JOIN connectivity c ON p.connectivity_id = c.connectivity_id
GROUP BY b.brand_name ORDER BY total_models DESC;

-- Q-13: CTE — flag phones 20%+ above brand average price
WITH brand_avg AS (
    SELECT brand_id, ROUND(AVG(price), 2) AS avg_price FROM phone WHERE price IS NOT NULL GROUP BY brand_id
)
SELECT b.brand_name, p.model, p.price, ba.avg_price AS brand_avg_price,
    ROUND(p.price - ba.avg_price, 2) AS price_above_avg,
    CASE WHEN p.price > ba.avg_price * 1.20 THEN 'Premium Outlier' ELSE 'Within Range' END AS price_flag
FROM phone p JOIN brand b ON p.brand_id = b.brand_id
JOIN brand_avg ba ON p.brand_id = ba.brand_id WHERE p.price IS NOT NULL ORDER BY price_above_avg DESC;

-- Q-14: CTE — isolate top 3 brands and flagship devices
WITH top_brands AS (
    SELECT brand_id, COUNT(*) AS model_count, RANK() OVER (ORDER BY COUNT(*) DESC) AS brand_rank
    FROM phone GROUP BY brand_id
)
SELECT b.brand_name, p.model, p.price FROM phone p
JOIN brand b ON p.brand_id = b.brand_id JOIN top_brands tb ON p.brand_id = tb.brand_id
WHERE tb.brand_rank <= 3 AND p.price >= 50000 ORDER BY b.brand_name, p.price DESC;

-- Q-15: Multi-step CTE chain with NTILE quartiles
WITH brand_stats AS (
    SELECT b.brand_name, COUNT(p.phone_id) AS model_count, ROUND(AVG(p.price), 2) AS avg_price,
        ROUND(AVG(p.rating), 2) AS avg_rating
    FROM phone p JOIN brand b ON p.brand_id = b.brand_id WHERE p.price IS NOT NULL GROUP BY b.brand_name
),
ranked_brands AS (
    SELECT *, NTILE(4) OVER (ORDER BY avg_price DESC) AS price_quartile FROM brand_stats
)
SELECT brand_name, model_count, avg_price, avg_rating FROM ranked_brands
WHERE price_quartile = 1 ORDER BY avg_price DESC;

-- Q-16: RANK() top 3 most expensive phones per brand
WITH ranked_phones AS (
    SELECT b.brand_name, p.model, p.price,
        DENSE_RANK() OVER (PARTITION BY p.brand_id ORDER BY p.price DESC) AS price_rank
    FROM phone p JOIN brand b ON p.brand_id = b.brand_id WHERE p.price IS NOT NULL
)
SELECT brand_name, model, price, price_rank FROM ranked_phones WHERE price_rank <= 3 ORDER BY brand_name, price_rank;

-- Q-17: DENSE_RANK() brands by average rating
SELECT b.brand_name, ROUND(AVG(p.rating), 2) AS avg_rating,
    DENSE_RANK() OVER (ORDER BY AVG(p.rating) DESC) AS rating_rank
FROM phone p JOIN brand b ON p.brand_id = b.brand_id WHERE p.rating IS NOT NULL
GROUP BY b.brand_name ORDER BY rating_rank;

-- Q-18: ROW_NUMBER() per brand
SELECT b.brand_name, p.model, p.price,
    ROW_NUMBER() OVER (PARTITION BY b.brand_name ORDER BY p.price DESC) AS model_index
FROM phone p JOIN brand b ON p.brand_id = b.brand_id WHERE p.price IS NOT NULL;

-- Q-19: LAG() price step-down vs previous brand
WITH brand_pricing AS (
    SELECT b.brand_name, ROUND(AVG(p.price), 2) AS avg_price
    FROM phone p JOIN brand b ON p.brand_id = b.brand_id WHERE p.price IS NOT NULL GROUP BY b.brand_name
)
SELECT brand_name, avg_price, LAG(avg_price) OVER (ORDER BY avg_price DESC) AS prev_brand_avg,
    ROUND(avg_price - LAG(avg_price) OVER (ORDER BY avg_price DESC), 2) AS price_step_down
FROM brand_pricing ORDER BY avg_price DESC;

-- Q-20: LEAD() trailing competitor in catalog volume
WITH brand_volume AS (
    SELECT b.brand_name, COUNT(p.phone_id) AS model_count
    FROM phone p JOIN brand b ON p.brand_id = b.brand_id GROUP BY b.brand_name
)
SELECT brand_name, model_count, LEAD(brand_name) OVER (ORDER BY model_count DESC) AS trailing_brand,
    LEAD(model_count) OVER (ORDER BY model_count DESC) AS trailing_brand_count
FROM brand_volume ORDER BY model_count DESC;

-- Q-21: Running Total models mapped across price bands
WITH brand_stats AS (
    SELECT b.brand_name, COUNT(p.phone_id) AS model_count, ROUND(AVG(p.price), 2) AS avg_price
    FROM phone p JOIN brand b ON p.brand_id = b.brand_id GROUP BY b.brand_name
)
SELECT brand_name, model_count, avg_price, SUM(model_count) OVER (ORDER BY avg_price DESC) AS cumulative_models
FROM brand_stats ORDER BY avg_price DESC;

-- Q-22: 3-Brand Rolling Moving Average price
WITH brand_pricing AS (
    SELECT b.brand_name, ROUND(AVG(p.price), 2) AS avg_price
    FROM phone p JOIN brand b ON p.brand_id = b.brand_id WHERE p.price IS NOT NULL GROUP BY b.brand_name
)
SELECT brand_name, avg_price,
    ROUND(AVG(avg_price) OVER (ORDER BY avg_price DESC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING), 2) AS rolling_3_brand_avg
FROM brand_pricing ORDER BY avg_price DESC;

-- Q-23: Correlated subquery — phones above brand average price
SELECT b.brand_name, p.model, p.price FROM phone p JOIN brand b ON p.brand_id = b.brand_id
WHERE p.price > (SELECT AVG(p2.price) FROM phone p2 WHERE p2.brand_id = p.brand_id)
ORDER BY b.brand_name, p.price DESC;

-- Q-24: NOT EXISTS — brands where 100% of models support 5G
SELECT b.brand_name FROM brand b
WHERE EXISTS (SELECT 1 FROM phone p WHERE p.brand_id = b.brand_id)
  AND NOT EXISTS (
    SELECT 1 FROM phone p JOIN connectivity c ON p.connectivity_id = c.connectivity_id
    WHERE p.brand_id = b.brand_id AND c.has_5g = 0
) ORDER BY b.brand_name;

-- Q-25: Subquery in FROM — dominant screen refresh rate per brand
SELECT brand_name, dominant_refresh_rate, total_models_with_hz
FROM (
    SELECT b.brand_name, s.refresh_rate AS dominant_refresh_rate, COUNT(*) AS total_models_with_hz,
        ROW_NUMBER() OVER (PARTITION BY b.brand_name ORDER BY COUNT(*) DESC) AS rn
    FROM phone p JOIN brand b ON p.brand_id = b.brand_id JOIN screen s ON p.screen_id = s.screen_id
    WHERE s.refresh_rate IS NOT NULL GROUP BY b.brand_name, s.refresh_rate
) ranked WHERE rn = 1 ORDER BY brand_name;

-- Q-26: Refresh summary table using ON DUPLICATE KEY UPDATE
INSERT INTO price_analysis (brand_id, brand_name, avg_price, min_price, max_price, model_count)
SELECT b.brand_id, b.brand_name, ROUND(AVG(p.price), 2), MIN(p.price), MAX(p.price), COUNT(p.phone_id)
FROM phone p JOIN brand b ON p.brand_id = b.brand_id WHERE p.price IS NOT NULL
GROUP BY b.brand_id, b.brand_name
ON DUPLICATE KEY UPDATE avg_price = VALUES(avg_price), min_price = VALUES(min_price),
    max_price = VALUES(max_price), model_count = VALUES(model_count);

-- Q-27: Dynamic batch UPDATE
UPDATE price_analysis pa
JOIN (
    SELECT brand_id, ROUND(AVG(price), 2) AS recalculated_avg FROM phone WHERE price IS NOT NULL GROUP BY brand_id
) sub ON pa.brand_id = sub.brand_id SET pa.avg_price = sub.recalculated_avg;

-- Q-28: Check refreshed price analysis table
SELECT * FROM price_analysis ORDER BY avg_price DESC;
SET SQL_SAFE_UPDATES = 1;
