-- FUNCTIONS
CREATE OR REPLACE FUNCTION online_retail_app.get_total_sales()
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE total_sales NUMERIC;
BEGIN
SELECT COALESCE(SUM(total_amount),0)
INTO total_sales
FROM online_retail_app.payment;
RETURN total_sales;
END;
$$;

-- PROCEDURE
CREATE OR REPLACE PROCEDURE online_retail_app.update_stock(
p_item_id TEXT,
p_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
UPDATE online_retail_app.product_items
SET stock_count=stock_count-p_quantity
WHERE item_id=p_item_id;
END;
$$;

-- TRIGGER
CREATE OR REPLACE FUNCTION online_retail_app.reduce_inventory()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
UPDATE online_retail_app.product_items
SET stock_count=stock_count-NEW.quantity
WHERE item_id=NEW.item_id;
RETURN NEW;
END;
$$;

CREATE TRIGGER trg_reduce_inventory
AFTER INSERT ON online_retail_app.order_items
FOR EACH ROW
EXECUTE FUNCTION online_retail_app.reduce_inventory();
