-- 05_business_analysis.sql
-- Business metrics used to validate the Power BI dashboard.

-- 1. Orders by status.
SELECT
    order_status,
    COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 2. Product revenue from delivered orders.
SELECT
    ROUND(SUM(oi.price), 2) AS delivered_product_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- 3. Delivered orders.
SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';

-- 4. Average Order Value.
-- First aggregate items to order grain, then average the order totals.
SELECT ROUND(AVG(total_order), 2) AS average_order_value
FROM (
    SELECT
        oi.order_id,
        SUM(oi.price) AS total_order
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.order_id
) totals;

-- 5. Top 10 product categories by delivered-order revenue.
SELECT
    pt.product_category_name_english,
    SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY pt.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;

-- 6. Unique customers associated with delivered orders.
SELECT COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';

-- 7. Unique delivered-order customers by state.
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY unique_customers DESC;

-- 8. Average delivery time in days.
SELECT ROUND(
    AVG(
        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date - order_purchase_timestamp
            )
        ) / 86400
    ),
    2
) AS average_delivery_days
FROM orders
WHERE order_status = 'delivered';

-- 9. Number of late delivered orders.
SELECT COUNT(*) AS late_delivered_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date > order_estimated_delivery_date;

-- 10. Late delivery rate.
SELECT ROUND(
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) * 100.0 / COUNT(*),
    2
) AS late_delivery_rate_pct
FROM orders
WHERE order_status = 'delivered';

-- 11. Monthly delivered-order revenue.
-- The dashboard trend focuses on Jan 2017 through Aug 2018 after validating
-- that the source has irregular coverage at the temporal edges.
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= TIMESTAMP '2017-01-01'
  AND o.order_purchase_timestamp <  TIMESTAMP '2018-09-01'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;

-- FAN-OUT WARNING:
-- Avoid joining order_items + order_payments + order_reviews and then summing
-- monetary columns without pre-aggregating each table to a compatible grain.
