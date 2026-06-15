-- SCHEMA
DROP SCHEMA IF EXISTS online_retail_app CASCADE;
CREATE SCHEMA online_retail_app;

---------------------------------------------------
-- USERS
---------------------------------------------------

CREATE TABLE online_retail_app.customers (
    customer_id TEXT PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email_id TEXT UNIQUE NOT NULL,
    customer_password TEXT NOT NULL,
    contact TEXT UNIQUE,
    sign_up_on DATE DEFAULT CURRENT_DATE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---------------------------------------------------
-- EMPLOYMENT
---------------------------------------------------

CREATE TABLE online_retail_app.employment_type (
    employment_type_id TEXT PRIMARY KEY,
    employment_type TEXT NOT NULL,
    internal_employee BOOLEAN DEFAULT TRUE,
    vendor_name TEXT
);

CREATE TABLE online_retail_app.employees (
    employee_id TEXT PRIMARY KEY,
    employee_type TEXT REFERENCES online_retail_app.employment_type(employment_type_id),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email_id TEXT UNIQUE,
    contact TEXT UNIQUE,
    registered_on DATE DEFAULT CURRENT_DATE,
    contract_expiry DATE
);

---------------------------------------------------
-- CATEGORIES
---------------------------------------------------

CREATE TABLE online_retail_app.product_categories (
    category_id TEXT PRIMARY KEY,
    category_name TEXT UNIQUE NOT NULL,
    description TEXT
);

---------------------------------------------------
-- SUPPLIERS
---------------------------------------------------

CREATE TABLE online_retail_app.suppliers (
    supplier_id TEXT PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    email_id TEXT,
    contact TEXT,
    address TEXT
);

---------------------------------------------------
-- PRODUCTS
---------------------------------------------------

CREATE TABLE online_retail_app.product_items (
    item_id TEXT PRIMARY KEY,
    item_code TEXT UNIQUE,
    item_name TEXT NOT NULL,
    category_id TEXT REFERENCES online_retail_app.product_categories(category_id),
    supplier_id TEXT REFERENCES online_retail_app.suppliers(supplier_id),
    item_type TEXT,
    item_description TEXT,
    item_image JSON,
    amount NUMERIC(10,2) NOT NULL,
    discount NUMERIC(5,2) DEFAULT 0,
    stock_count INT DEFAULT 0 CHECK(stock_count >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---------------------------------------------------
-- REVIEWS
---------------------------------------------------

CREATE TABLE online_retail_app.product_reviews (
    review_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES online_retail_app.customers(customer_id),
    item_id TEXT REFERENCES online_retail_app.product_items(item_id),
    rating INT CHECK(rating BETWEEN 1 AND 5),
    review_text TEXT,
    reviewed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---------------------------------------------------
-- CART
---------------------------------------------------

CREATE TABLE online_retail_app.shopping_cart (
    cart_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES online_retail_app.customers(customer_id),
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE online_retail_app.cart_items (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id TEXT REFERENCES online_retail_app.shopping_cart(cart_id),
    item_id TEXT REFERENCES online_retail_app.product_items(item_id),
    quantity INT DEFAULT 1 CHECK(quantity > 0)
);

---------------------------------------------------
-- WISHLIST
---------------------------------------------------

CREATE TABLE online_retail_app.wishlist (
    wishlist_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES online_retail_app.customers(customer_id),
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE online_retail_app.wishlist_items (
    wishlist_item_id SERIAL PRIMARY KEY,
    wishlist_id TEXT REFERENCES online_retail_app.wishlist(wishlist_id),
    item_id TEXT REFERENCES online_retail_app.product_items(item_id)
);

---------------------------------------------------
-- PAYMENT
---------------------------------------------------

CREATE TABLE online_retail_app.payment (
    payment_id TEXT PRIMARY KEY,
    total_amount NUMERIC(12,2),
    payment_mode TEXT,
    paid_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_success BOOLEAN DEFAULT FALSE
);

---------------------------------------------------
-- ORDERS
---------------------------------------------------

CREATE TABLE online_retail_app.orders (
    order_id TEXT PRIMARY KEY,
    ordered_by TEXT REFERENCES online_retail_app.customers(customer_id),
    payment_id TEXT REFERENCES online_retail_app.payment(payment_id),
    is_delivered BOOLEAN DEFAULT FALSE,
    delivery_date DATE,
    delivered_by TEXT REFERENCES online_retail_app.employees(employee_id),
    ordered_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE online_retail_app.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id TEXT REFERENCES online_retail_app.orders(order_id),
    item_id TEXT REFERENCES online_retail_app.product_items(item_id),
    quantity INT DEFAULT 1 CHECK(quantity > 0)
);

---------------------------------------------------
-- DELIVERY TRACKING
---------------------------------------------------

CREATE TABLE online_retail_app.order_delivery (
    row_id SERIAL PRIMARY KEY,
    order_id TEXT REFERENCES online_retail_app.orders(order_id),
    delivery_stage TEXT,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---------------------------------------------------
-- INVENTORY LOG
---------------------------------------------------

CREATE TABLE online_retail_app.inventory_transactions (
    transaction_id TEXT PRIMARY KEY,
    item_id TEXT REFERENCES online_retail_app.product_items(item_id),
    transaction_type TEXT,
    quantity INT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---------------------------------------------------
-- CUSTOMER ADDRESS
---------------------------------------------------

CREATE TABLE online_retail_app.customer_addresses (
    address_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES online_retail_app.customers(customer_id),
    house_no TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    pincode TEXT,
    country TEXT
);

---------------------------------------------------
-- INDEXES
---------------------------------------------------

CREATE INDEX idx_customer_email
ON online_retail_app.customers(email_id);

CREATE INDEX idx_product_name
ON online_retail_app.product_items(item_name);

CREATE INDEX idx_order_customer
ON online_retail_app.orders(ordered_by);

CREATE INDEX idx_payment_date
ON online_retail_app.payment(paid_on);

---------------------------------------------------
-- ANALYTICS VIEW
---------------------------------------------------

CREATE VIEW online_retail_app.sales_summary AS
SELECT
    p.item_name,
    COUNT(oi.order_item_id) AS total_orders,
    SUM(p.amount * oi.quantity) AS total_sales
FROM online_retail_app.order_items oi
JOIN online_retail_app.product_items p
ON oi.item_id = p.item_id
GROUP BY p.item_name;
