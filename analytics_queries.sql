-- TOP PRODUCTS
SELECT p.item_name,SUM(oi.quantity) qty
FROM online_retail_app.order_items oi
JOIN online_retail_app.product_items p
ON oi.item_id=p.item_id
GROUP BY p.item_name
ORDER BY qty DESC;

-- MONTHLY REVENUE
SELECT DATE_TRUNC('month',paid_on) sales_month,
SUM(total_amount) revenue
FROM online_retail_app.payment
GROUP BY sales_month;

-- LOW STOCK
SELECT *
FROM online_retail_app.product_items
WHERE stock_count < 10;

-- CTE
WITH customer_spending AS(
SELECT c.customer_id,
SUM(p.total_amount) total_spent
FROM online_retail_app.customers c
JOIN online_retail_app.orders o ON c.customer_id=o.ordered_by
JOIN online_retail_app.payment p ON o.payment_id=p.payment_id
GROUP BY c.customer_id
)
SELECT * FROM customer_spending;

-- WINDOW FUNCTION
SELECT customer_id,total_spent,
RANK() OVER(ORDER BY total_spent DESC) customer_rank
FROM(
SELECT c.customer_id,
SUM(p.total_amount) total_spent
FROM online_retail_app.customers c
JOIN online_retail_app.orders o ON c.customer_id=o.ordered_by
JOIN online_retail_app.payment p ON o.payment_id=p.payment_id
GROUP BY c.customer_id
)x;
