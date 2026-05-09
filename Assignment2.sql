-- ============================================================
--  Question 1
-- ============================================================

SELECT
    p.product_name,
    p.list_price,
    c.category_name
FROM production.products p
INNER JOIN production.categories c
    ON p.category_id = c.category_id
ORDER BY p.product_name ASC;



-- ============================================================
--  Question 2
-- ============================================================

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    o.order_id,
    o.order_date
FROM sales.customers c
INNER JOIN sales.orders o
    ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;



-- ============================================================
--  Question 3
-- ============================================================

SELECT
    p.product_name,
    p.list_price,
    c.category_name,
    b.brand_name
FROM production.products p
INNER JOIN production.categories c
    ON p.category_id = c.category_id
INNER JOIN production.brands b
    ON p.brand_id = b.brand_id
ORDER BY b.brand_name ASC,
         p.product_name ASC;



-- ============================================================
--  Question 4
-- ============================================================

SELECT
    p.product_name,
    oi.order_id,
    oi.item_id
FROM production.products p
LEFT JOIN sales.order_items oi
    ON p.product_id = oi.product_id
ORDER BY oi.order_id ASC;



-- ============================================================
--  Question 5
-- ============================================================

SELECT
    p.product_id,
    p.product_name
FROM production.products p
LEFT JOIN sales.order_items oi
    ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;



-- ============================================================
--  Question 6
-- ============================================================

SELECT
    s.store_name,
    s.store_id,
    o.order_id,
    o.order_date
FROM sales.stores s
LEFT JOIN sales.orders o
    ON s.store_id = o.store_id;



-- ============================================================
--  Question 7
-- ============================================================

SELECT
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM sales.staffs s
INNER JOIN sales.staffs m
    ON s.manager_id = m.staff_id;



-- ============================================================
--  Question 8
-- ============================================================

SELECT
    s.store_name,
    b.brand_name
FROM sales.stores s
CROSS JOIN production.brands b;

-- Expected rows = number of stores × number of brands
-- In BikeStores sample DB:
-- 3 stores × 9 brands = 27 rows



-- ============================================================
--  Question 9
-- ============================================================

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    o.order_id,
    o.order_date,
    p.product_name,
    p.list_price
FROM sales.customers c
INNER JOIN sales.orders o
    ON c.customer_id = o.customer_id
INNER JOIN sales.order_items oi
    ON o.order_id = oi.order_id
INNER JOIN production.products p
    ON oi.product_id = p.product_id
ORDER BY o.order_date ASC,
         full_name ASC;