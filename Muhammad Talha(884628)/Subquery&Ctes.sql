NAME : MUHAMMAD TALHA
Assignment : Chapters 1–6 (BikeStores)
Roll number: 884628


--Q1. List customers from the state of NY who have no phone number on
file. Show their first name, last name, email and city with
the aliases First Name, Last Name, Email and
City. Sort by last name, then first name, and
return only the first 10 rows;

SELECT TOP 10
       c.first_name + ' ' + c.last_name AS full_name,
       c.city,
       c.email,
       c.phone
FROM sales.customers as c
WHERE state = 'NY'
AND phone = 'N/A'
order by c.first_name,
       c.last_name;


--Q2. Find products with a model year of 2017 or 2018, a list price between 500 and 1500,
whose name contains Trek but does not contain Kids. Show product_id,
product_name, model_year and list_price, sorted by list_price from highest to lowest.

SELECT model_year,
       list_price,
       product_id,
       product_name
FROM production.products 
where model_year IN (2017, 2018)
AND list_price BETWEEN 500 and 1500
AND product_name LIKE '%Trek%'
AND product_name NOT LIKE '%Kids%'
ORDER BY list_price DESC;

--Q3. (a) List the distinct values of order_status in sales.orders. 
(b) List orders that have not been shipped yet, placed at store 1 or 3 during 2018.
Show order_id, customer_id, store_id, order_date 
and required_date, sorted by order_date.

SELECT DISTINCT
       order_status
FROM sales.orders
Select 
       order_id,
       customer_id,
       order_date,
       store_id,
       required_date
From sales.orders
where shipped_date IS NULL
AND store_id IN (1, 3)
AND order_date >= '2018-01-01'
AND order_date < '2019-01-01'
ORDER BY order_date;

--Q4. For order_id = 1, show one row per order line with: 
order_id, order_date, customer full name, product_name, brand_name,
category_name, quantity, list_price, discount and line_revenue,
where line_revenue = quantity * list_price * (1 - discount) from sales.order_items.

SELECT
    oi.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.order_items AS oi
JOIN sales.orders AS o
    ON o.order_id = oi.order_id
JOIN sales.customers AS c
    ON c.customer_id = o.customer_id
JOIN production.products AS p
    ON p.product_id = oi.product_id
JOIN production.brands AS b
    ON b.brand_id = p.brand_id
JOIN production.categories AS cat
    ON cat.category_id = p.category_id
WHERE oi.order_id = 1
ORDER BY oi.item_id;

--Q5. Show every staff member with their store_name and their manager's full name.
Staff who have no manager must still appear, with the manager shown as 'No Manager'.

SELECT s.staff_id,
       CONCAT(s.first_name, ' ', s.last_name) AS staff_full_name,
       st.store_name,
       CASE
           WHEN m.staff_id IS NULL THEN 'No Manager'
           ELSE CONCAT(m.first_name, ' ', m.last_name)
       END AS manager_full_name
FROM sales.staffs as s
LEFT JOIN sales.stores as st
 ON s.store_id = st.store_id
LEFT JOIN sales.staffs as m
 ON m.staff_id = s.manager_id
order by s.staff_id;

--Q6. List products that have never been ordered. Show product_id,
product_name, brand_name and model_year.
SELECT 
      p.product_name,
      p.product_id,
      p.model_year,
      b.brand_name
FROM production.products as p
inner join production.brands as b
 ON p.brand_id = b.brand_id
LEFT JOIN sales.order_items as oi
 ON oi.product_id = p.product_id
where oi.product_id is null
ORDER BY p.product_id;
      
--Q7. (a) Create a view sales.vw_order_line_details that returns the 
    Q4 details for all orders, also including store_name and order_status. 
    (b) Query the view to return all order lines from January 2018, sorted by order_date, then order_id.
CREATE OR ALTER VIEW sales.vw_order_line_details
AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    s.store_name,
    oi.item_id,
    oi.product_id,
    p.product_name,
    oi.quantity,
    oi.list_price,
    oi.discount
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN sales.stores AS s
    ON s.store_id = o.store_id
INNER JOIN production.products AS p
    ON p.product_id = oi.product_id;
SELECT
    order_id,
    order_date,
    order_status,
    store_name,
    item_id,
    product_id,
    product_name,
    quantity,
    list_price,
    discount
FROM sales.vw_order_line_details
WHERE order_date >= '20180101'
  AND order_date <  '20180201'
ORDER BY order_date, order_id;
--Q8. (a) Create a view production.vw_product_catalog with product_id, product_name,brand_name,
     category_name, model_year and list_price.
    (b) Using only this view, return all Electric Bikes priced above 3000,
    sorted by price from highest to lowest.
    
    CREATE OR ALTER VIEW production.vw_product_catalog
AS
SELECT
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    p.model_year,
    p.list_price
FROM production.products AS p
INNER JOIN production.brands AS b
    ON b.brand_id = p.brand_id
INNER JOIN production.categories AS c
    ON c.category_id = p.category_id;
SELECT
    product_id,
    product_name,
    brand_name,
    category_name,
    model_year,
    list_price
FROM production.vw_product_catalog
WHERE category_name = 'Electric Bikes'
  AND list_price > 3000
ORDER BY list_price DESC;

--Q9. Using sales.vw_order_line_details, show the total number of distinct orders and 
    total revenue for each store in each year.Sort by store_name, then year.

SELECT
    store_name,
    YEAR(order_date) AS [year],
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity * list_price * (1 - discount)) AS total_revenue
FROM sales.vw_order_line_details
GROUP BY store_name, YEAR(order_date)
ORDER BY store_name, [year];

--Q10. For each brand, show the number of products and the minimum, average and maximum list price.
     Keep only brands with more than 10 products, sorted by average price from highest to lowest.

SELECT
    brand_name,
    COUNT(*) AS product_count,
    MIN(list_price) AS min_list_price,
    AVG(list_price) AS avg_list_price,
    MAX(list_price) AS max_list_price
FROM production.vw_product_catalog
GROUP BY brand_name
HAVING COUNT(*) > 10
ORDER BY AVG(list_price) DESC;

--Q11. Find products whose list price is higher than the average list price of their own category.
       Show product_name, category_name, list_price and the categories average price.

       WITH products_with_category_avg AS (
    SELECT
        product_name,
        category_name,
        list_price,
        AVG(list_price) OVER (PARTITION BY category_name) AS category_avg_price
    FROM production.vw_product_catalog
)
SELECT
    product_name,
    category_name,
    list_price,
    category_avg_price
FROM products_with_category_avg
WHERE list_price > category_avg_price;

--Q12. Find customers who placed at least one order in 2016 but no orders in 2018.Show customer_id, full name,
     email and state. Write the query twice: once with IN / NOT IN and once with EXISTS / NOT EXISTS.

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    c.state
FROM sales.customers AS c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM sales.orders AS o
    WHERE o.order_date >= '20160101'
      AND o.order_date <  '20170101'
)
AND c.customer_id NOT IN (
    SELECT o.customer_id
    FROM sales.orders AS o
    WHERE o.order_date >= '20180101'
      AND o.order_date <  '20190101'
      AND o.customer_id IS NOT NULL
);
 --NOT EXIST--
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    c.state
FROM sales.customers AS c
WHERE EXISTS (
    SELECT 1
    FROM sales.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_date >= '20160101'
      AND o.order_date <  '20170101'
)
AND NOT EXISTS (
    SELECT 1
    FROM sales.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_date >= '20180101'
      AND o.order_date <  '20190101'
);

Q13. Using two CTEs in one WITH clause, first calculate the total revenue for each store, then the average of
     those store totals. Return only the stores whose revenue is above the average,
     with store_name, total_revenue, average and the difference.

     WITH store_revenue AS (
    SELECT
        store_name,
        SUM(quantity * list_price * (1 - discount)) AS total_revenue
    FROM sales.vw_order_line_details
    GROUP BY store_name
),
store_average AS (
    SELECT AVG(total_revenue) AS average_revenue
    FROM store_revenue
)
SELECT
    sr.store_name,
    sr.total_revenue,
    sa.average_revenue AS [average],
    sr.total_revenue - sa.average_revenue AS difference
FROM store_revenue AS sr
CROSS JOIN store_average AS sa
WHERE sr.total_revenue > sa.average_revenue;

--Q14. Using a recursive CTE, build the staff hierarchy starting from the staff member with no manager.
       Show staff_id, staff full name, manager_id, level (top = 1) and a reporting path such as
       Fabiola Jackson > Mireya Copeland > Genna Serrano.

WITH staff_hierarchy AS (
    -- Anchor: the top-level staff member has no manager.
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.manager_id,
        CAST(1 AS INT) AS [level],
        CAST(CONCAT(s.first_name, ' ', s.last_name) AS NVARCHAR(MAX)) AS reporting_path
    FROM sales.staffs AS s
    WHERE s.manager_id IS NULL

    UNION ALL

    -- Recursive member: attach each employee to their manager's hierarchy row.
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.manager_id,
        sh.[level] + 1,
        CAST(CONCAT(sh.reporting_path, ' > ', s.first_name, ' ', s.last_name) AS NVARCHAR(MAX))
    FROM sales.staffs AS s
    INNER JOIN staff_hierarchy AS sh
        ON s.manager_id = sh.staff_id
)
SELECT
    staff_id,
    CONCAT(first_name, ' ', last_name) AS staff_full_name,
    manager_id,
    [level],
    reporting_path
FROM staff_hierarchy
ORDER BY reporting_path
OPTION (MAXRECURSION 0);

--Q15. (a) Using a CTE with a window function, find the top 3 products by 2017 revenue within each category. 
       Show category_name, product_name, total quantity, total revenue and rank.
       (b) Using a recursive CTE that generates months 1 to 12, show the total orders and
       total revenue for every month of 2017, with month number and month name, showing 0 for months with no sales.
WITH product_revenue AS (
    SELECT
        c.category_name,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN production.products AS p
        ON p.product_id = oi.product_id
    INNER JOIN production.categories AS c
        ON c.category_id = p.category_id
    WHERE o.order_date >= '20170101'
      AND o.order_date <  '20180101'
    GROUP BY c.category_name, p.product_id, p.product_name
),
ranked_products AS (
    SELECT
        category_name,
        product_name,
        total_quantity,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category_name
            ORDER BY total_revenue DESC, product_id
        ) AS [rank]
    FROM product_revenue
)
SELECT
    category_name,
    product_name,
    total_quantity,
    total_revenue,
    [rank]
FROM ranked_products
WHERE [rank] <= 3
ORDER BY category_name, [rank], product_name;

-- (b) Monthly order count and revenue for every month of 2017.
WITH months AS (
    SELECT CAST(1 AS INT) AS month_number

    UNION ALL

    SELECT month_number + 1
    FROM months
    WHERE month_number < 12
),
monthly_orders AS (
    SELECT
        MONTH(order_date) AS month_number,
        COUNT(*) AS total_orders
    FROM sales.orders
    WHERE order_date >= '20170101'
      AND order_date <  '20180101'
    GROUP BY MONTH(order_date)
),
monthly_revenue AS (
    SELECT
        MONTH(o.order_date) AS month_number,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_date >= '20170101'
      AND o.order_date <  '20180101'
    GROUP BY MONTH(o.order_date)
)
SELECT
    m.month_number,
    DATENAME(MONTH, DATEFROMPARTS(2017, m.month_number, 1)) AS month_name,
    COALESCE(mo.total_orders, 0) AS total_orders,
    COALESCE(mr.total_revenue, 0) AS total_revenue
FROM months AS m
LEFT JOIN monthly_orders AS mo
    ON mo.month_number = m.month_number
LEFT JOIN monthly_revenue AS mr
    ON mr.month_number = m.month_number
ORDER BY m.month_number
OPTION (MAXRECURSION 12);