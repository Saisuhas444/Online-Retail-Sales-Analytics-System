-- PROFESSIONAL RETAIL DATABASE SCHEMA
DROP SCHEMA IF EXISTS online_retail_app CASCADE;
CREATE SCHEMA online_retail_app;

CREATE TABLE online_retail_app.customers(
customer_id TEXT PRIMARY KEY,
first_name TEXT NOT NULL,
last_name TEXT NOT NULL,
email_id TEXT UNIQUE NOT NULL,
customer_password TEXT NOT NULL,
contact TEXT UNIQUE,
sign_up_on DATE DEFAULT CURRENT_DATE,
last_login TIMESTAMP
);

CREATE TABLE online_retail_app.employees(
employee_id TEXT PRIMARY KEY,
first_name TEXT NOT NULL,
last_name TEXT NOT NULL,
email_id TEXT UNIQUE
);

CREATE TABLE online_retail_app.product_categories(
category_id TEXT PRIMARY KEY,
category_name TEXT UNIQUE NOT NULL
);

CREATE TABLE online_retail_app.suppliers(
supplier_id TEXT PRIMARY KEY,
supplier_name TEXT NOT NULL
);

CREATE TABLE online_retail_app.product_items(
item_id TEXT PRIMARY KEY,
item_name TEXT NOT NULL,
category_id TEXT REFERENCES online_retail_app.product_categories(category_id),
supplier_id TEXT REFERENCES online_retail_app.suppliers(supplier_id),
amount NUMERIC(10,2),
stock_count INT DEFAULT 0
);

CREATE TABLE online_retail_app.payment(
payment_id TEXT PRIMARY KEY,
total_amount NUMERIC(12,2),
payment_mode TEXT,
paid_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
is_success BOOLEAN DEFAULT TRUE
);

CREATE TABLE online_retail_app.orders(
order_id TEXT PRIMARY KEY,
ordered_by TEXT REFERENCES online_retail_app.customers(customer_id),
payment_id TEXT REFERENCES online_retail_app.payment(payment_id),
ordered_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE online_retail_app.order_items(
order_item_id SERIAL PRIMARY KEY,
order_id TEXT REFERENCES online_retail_app.orders(order_id),
item_id TEXT REFERENCES online_retail_app.product_items(item_id),
quantity INT DEFAULT 1
);

CREATE TABLE online_retail_app.product_reviews(
review_id TEXT PRIMARY KEY,
customer_id TEXT REFERENCES online_retail_app.customers(customer_id),
item_id TEXT REFERENCES online_retail_app.product_items(item_id),
rating INT CHECK(rating BETWEEN 1 AND 5),
review_text TEXT
);

CREATE INDEX idx_product_name ON online_retail_app.product_items(item_name);
CREATE INDEX idx_customer_email ON online_retail_app.customers(email_id);

CREATE VIEW online_retail_app.sales_summary AS
SELECT p.item_name,SUM(oi.quantity) total_qty,
SUM(oi.quantity*p.amount) revenue
FROM online_retail_app.order_items oi
JOIN online_retail_app.product_items p ON oi.item_id=p.item_id
GROUP BY p.item_name;
