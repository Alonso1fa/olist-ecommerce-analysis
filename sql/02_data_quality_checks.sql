-- 02_data_quality_checks.sql
-- Representative profiling and validation queries used before finalizing the model.

-- Customers: physical customer records vs logical customers.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS distinct_unique_customers
FROM customers;

-- Logical customers appearing in multiple customer records.
SELECT customer_unique_id, COUNT(*) AS records
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY records DESC;

-- Order status distribution.
SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Validate order-item composite key.
SELECT order_id, order_item_id, COUNT(*) AS duplicates
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Payments: demonstrate one-to-many behavior.
SELECT order_id, COUNT(*) AS payment_records
FROM order_payments
GROUP BY order_id
ORDER BY payment_records DESC
LIMIT 20;

-- Review ID is not globally unique.
SELECT review_id, COUNT(*) AS records
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY records DESC;

-- Validate review composite-key candidate.
SELECT review_id, order_id, COUNT(*) AS records
FROM order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

-- Raw geolocation volume and exact distinct rows.
SELECT COUNT(*) AS raw_rows
FROM geolocation;

SELECT COUNT(*) AS distinct_complete_rows
FROM (
    SELECT DISTINCT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    FROM geolocation
) d;

-- ZIPs associated with more than one city/state combination.
SELECT geolocation_zip_code_prefix,
       COUNT(DISTINCT (geolocation_city, geolocation_state)) AS location_combinations
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT (geolocation_city, geolocation_state)) > 1
ORDER BY location_combinations DESC;

-- ZIPs associated with more than one state.
SELECT geolocation_zip_code_prefix,
       COUNT(DISTINCT geolocation_state) AS states
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_state) > 1
ORDER BY states DESC;

-- Product categories missing from translation lookup.
SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- Temporal boundaries.
SELECT
    MIN(order_purchase_timestamp) AS min_purchase_timestamp,
    MAX(order_purchase_timestamp) AS max_purchase_timestamp
FROM orders;

-- Monthly order counts used to inspect edge-period coverage.
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(*) AS orders
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY month;

-- Customer ZIP coverage against cleaned geography (run after 03).
SELECT COUNT(DISTINCT c.customer_zip_code_prefix) AS missing_customer_zips
FROM customers c
LEFT JOIN geolocation_clean g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

-- Seller ZIP coverage against cleaned geography (run after 03).
SELECT COUNT(DISTINCT s.seller_zip_code_prefix) AS missing_seller_zips
FROM sellers s
LEFT JOIN geolocation_clean g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;
