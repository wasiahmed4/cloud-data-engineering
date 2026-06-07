-- ============================================================
-- Q1.
-- The marketing team frequently runs campaigns filtered by brand.
-- Create an appropriate index to improve searches by brand_id.
-- Then run the query to confirm it returns results correctly.
-- ============================================================

CREATE NONCLUSTERED INDEX IX_products_brand_id
ON production.products (brand_id);

SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE brand_id = 3;


-- ============================================================
-- Q2.
-- The finance team runs monthly reports filtered by order_date.
-- Create an index to make date-range filtering more efficient.
-- ============================================================

CREATE NONCLUSTERED INDEX IX_orders_order_date
ON sales.orders (order_date);


-- ============================================================
-- Q3.
-- Create a view showing pending and processing orders with:
-- order_id, customer full name, phone, email,
-- order_date, and readable status labels.
-- Then query the view.
-- ============================================================

CREATE VIEW vw_order_followup
AS
SELECT
    o.order_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.phone,
    c.email,
    o.order_date,
    CASE
        WHEN o.order_status = 1 THEN 'Pending'
        WHEN o.order_status = 2 THEN 'Processing'
    END AS order_status
FROM sales.orders o
JOIN sales.customers c
    ON c.customer_id = o.customer_id
WHERE o.order_status IN (1,2);

SELECT *
FROM vw_order_followup;


-- ============================================================
-- Q4.
-- Create a view showing:
-- store_name, product_name, brand_name,
-- category_name, quantity.
-- Then find products with fewer than 3 units remaining.
-- ============================================================

CREATE VIEW vw_inventory
AS
SELECT
    s.store_name,
    p.product_name,
    b.brand_name,
    c.category_name,
    st.quantity
FROM production.stocks st
JOIN sales.stores s
    ON s.store_id = st.store_id
JOIN production.products p
    ON p.product_id = st.product_id
JOIN production.brands b
    ON b.brand_id = p.brand_id
JOIN production.categories c
    ON c.category_id = p.category_id;

SELECT *
FROM vw_inventory
WHERE quantity < 3;


-- ============================================================
-- Q5.
-- Show the top 2 best-selling products per store
-- based on total quantity sold.
-- ============================================================

WITH sales_cte AS
(
    SELECT
        o.store_id,
        oi.product_id,
        SUM(oi.quantity) AS total_quantity,
        ROW_NUMBER() OVER
        (
            PARTITION BY o.store_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS rn
    FROM sales.orders o
    JOIN sales.order_items oi
        ON oi.order_id = o.order_id
    GROUP BY
        o.store_id,
        oi.product_id
)
SELECT
    store_id,
    product_id,
    total_quantity,
    rn
FROM sales_cte
WHERE rn <= 2;


-- ============================================================
-- Q6.
-- Find the 2nd most expensive product in each category.
-- ============================================================

WITH price_rank AS
(
    SELECT
        category_id,
        product_name,
        list_price,
        DENSE_RANK() OVER
        (
            PARTITION BY category_id
            ORDER BY list_price DESC
        ) AS price_rank
    FROM production.products
)
SELECT
    category_id,
    product_name,
    list_price,
    price_rank
FROM price_rank
WHERE price_rank = 2;


-- ============================================================
-- Q7.
-- Identify duplicate customer rows
-- (same first_name, last_name, and phone).
-- Return only duplicates, not the first occurrence.
-- ============================================================

WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY
                   first_name,
                   last_name,
                   phone
               ORDER BY customer_id
           ) AS rn
    FROM test_customers
)
SELECT *
FROM duplicate_cte
WHERE rn > 1;


-- ============================================================
-- Q8.
-- For each month in 2017, show:
-- month, net_sales, previous_month_sales, difference.
-- ============================================================

WITH monthly_sales AS
(
    SELECT
        MONTH(o.order_date) AS month_no,
        SUM(
            oi.quantity *
            oi.list_price *
            (1 - oi.discount)
        ) AS net_sales
    FROM sales.orders o
    JOIN sales.order_items oi
        ON oi.order_id = o.order_id
    WHERE YEAR(o.order_date) = 2017
    GROUP BY MONTH(o.order_date)
)
SELECT
    month_no,
    net_sales,
    LAG(net_sales)
        OVER (ORDER BY month_no)
        AS previous_month_sales,
    net_sales -
    LAG(net_sales)
        OVER (ORDER BY month_no)
        AS difference
FROM monthly_sales;


-- ============================================================
-- Q9.
-- Show each product's price compared to the next
-- cheaper product in the same category.
-- ============================================================

SELECT
    product_name,
    list_price,
    LEAD(list_price)
        OVER
        (
            PARTITION BY category_id
            ORDER BY list_price DESC
        ) AS next_lower_price
FROM production.products
ORDER BY
    category_id,
    list_price DESC;


-- ============================================================
-- Q10.
-- Show each customer's full name, phone, and email.
-- Replace missing phone with email.
-- If both are missing, show 'No Contact Info'.
-- ============================================================

SELECT
    first_name + ' ' + last_name AS full_name,
    COALESCE(
        phone,
        email,
        'No Contact Info'
    ) AS contact_info,
    email
FROM sales.customers
ORDER BY
    last_name,
    first_name;