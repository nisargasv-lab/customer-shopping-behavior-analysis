-- Customer Shopping Behavior Analysis
-- SQL dialect: MySQL 8.0+
-- Adapted from a guided tutorial; queries and project documentation should be reviewed
-- against your own results before publishing.

CREATE DATABASE IF NOT EXISTS customer_behavior;
USE customer_behavior;

-- Preview the loaded dataset
SELECT *
FROM customer
LIMIT 20;

-- Q1. What is the total purchase revenue by gender?
SELECT
    gender,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;

-- Q2. Which customers used a discount and spent more than the average purchase amount?
SELECT
    customer_id,
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer)
ORDER BY purchase_amount DESC;

-- Q3. Which five products have the highest average review rating?
SELECT
    item_purchased,
    ROUND(AVG(review_rating), 2) AS average_review_rating
FROM customer
GROUP BY item_purchased
ORDER BY average_review_rating DESC
LIMIT 5;

-- Q4. Compare average purchase amounts for Standard and Express shipping.
SELECT
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Q5. Compare customer count, average spend, and total revenue by subscription status.
SELECT
    subscription_status,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(purchase_amount), 2) AS average_spend,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;

-- Q6. Which five products have the highest share of purchases with discounts applied?
SELECT
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_rate_pct
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate_pct DESC
LIMIT 5;

-- Q7. Segment customers using previous purchase history.
-- This is a simple rule-based segment, not a model of customer lifetime value.
WITH customer_type AS (
    SELECT
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM customer_type
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- Q8. Find the top three most-purchased items in each category.
WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC, item_purchased
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT
    item_rank,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3
ORDER BY category, item_rank;

-- Q9. Among customers with more than five previous purchases, compare subscription status.
SELECT
    subscription_status,
    COUNT(customer_id) AS repeat_buyer_count
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status
ORDER BY repeat_buyer_count DESC;

-- Q10. What is the revenue contribution by age group?
SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;
