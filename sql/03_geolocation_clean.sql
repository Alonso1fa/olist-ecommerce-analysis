-- 03_geolocation_clean.sql
-- Build one analytical geography row per ZIP prefix.
--
-- Strategy:
-- 1. Count each city/state combination within a ZIP.
-- 2. Rank combinations by frequency.
-- 3. Keep the most frequent city/state.
-- 4. Average DISTINCT coordinate pairs to reduce the influence of exact duplicate rows.

DROP TABLE IF EXISTS geolocation_clean;

CREATE TABLE geolocation_clean AS
WITH location_counts AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        COUNT(*) AS location_frequency
    FROM geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
),
ranked_locations AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        location_frequency,
        ROW_NUMBER() OVER (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY location_frequency DESC,
                     geolocation_state,
                     geolocation_city
        ) AS rn
    FROM location_counts
),
distinct_coordinates AS (
    SELECT DISTINCT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng
    FROM geolocation
    WHERE geolocation_lat IS NOT NULL
      AND geolocation_lng IS NOT NULL
),
coordinate_averages AS (
    SELECT
        geolocation_zip_code_prefix,
        AVG(geolocation_lat) AS geolocation_lat,
        AVG(geolocation_lng) AS geolocation_lng
    FROM distinct_coordinates
    GROUP BY geolocation_zip_code_prefix
)
SELECT
    r.geolocation_zip_code_prefix,
    c.geolocation_lat,
    c.geolocation_lng,
    r.geolocation_city,
    r.geolocation_state
FROM ranked_locations r
LEFT JOIN coordinate_averages c
    ON r.geolocation_zip_code_prefix = c.geolocation_zip_code_prefix
WHERE r.rn = 1;

ALTER TABLE geolocation_clean
ADD PRIMARY KEY (geolocation_zip_code_prefix);

-- Validation: one row per ZIP.
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS distinct_zips
FROM geolocation_clean;
