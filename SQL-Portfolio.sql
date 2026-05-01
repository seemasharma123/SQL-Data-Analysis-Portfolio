\CREATE DATABASE Portfolio;


CREATE TABLE orders (
  ordernum VARCHAR(20),
  order_date DATE,
  customer_id INTEGER,
  product varchar(250),
  unit_price float,
  quantity INTEGER,
  total float,
  year INTEGER
);

DROP TABLE orders;


CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state CHAR(2) NOT NULL,
    zip VARCHAR(10) NOT NULL,
    mail_list BOOLEAN NOT NULL DEFAULT FALSE
);


CREATE TABLE regions (
    state CHAR(2) PRIMARY KEY,
    state_name VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL
);





-- =============================================================================
-- SECTION 1 : BASIC QUERIES  –  Data Exploration & Filtering
-- =============================================================================

-- Q1. View all records from each table

SELECT * FROM customers LIMIT 10;
SELECT * FROM orders    LIMIT 10;
SELECT * FROM regions   LIMIT 10;


-- Q2. How many customers, orders, and regions exist in the dataset?

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_orders    FROM orders;
SELECT COUNT(*) AS total_regions   FROM regions;


-- Q3. What are all the distinct products available?

SELECT DISTINCT product
FROM   orders
ORDER  BY product;


-- Q4. What are all the distinct regions?

SELECT DISTINCT region
FROM   regions
ORDER  BY region;


-- Q5. Show all orders placed in January 2025.

SELECT *
FROM   orders
WHERE  order_date BETWEEN '2025-01-01' AND '2025-01-31'
ORDER  BY order_date;


-- Q6. Which customers have opted in to the mailing list?

SELECT customer_id, name, city, state
FROM   customers
WHERE  mail_list = TRUE
ORDER  BY name;


-- Q7. List all orders where the total amount is greater than $100.

SELECT ordernum, order_date, customer_id, product, total
FROM   orders
WHERE  total > 100
ORDER  BY total DESC;


-- Q8. Find all customers located in New York (NY) or California (CA).

SELECT customer_id, name, city, state
FROM   customers
WHERE  state IN ('NY', 'CA')
ORDER  BY state, name;


-- Q9. Show all orders for the product 'Healing Bracelet'.

SELECT ordernum, order_date, customer_id, quantity, total
FROM   orders
WHERE  product = 'Healing Bracelet'
ORDER  BY order_date;


-- Q10. List customers whose name starts with the letter 'J'.

SELECT customer_id, name, city, state
FROM   customers
WHERE  name ILIKE 'J%'
ORDER  BY name;

ALTER TABLE orders
  ALTER COLUMN total      TYPE NUMERIC(10,2) USING total::numeric,
  ALTER COLUMN unit_price TYPE NUMERIC(10,2) USING unit_price::numeric,
  ALTER COLUMN discount   TYPE NUMERIC(10,2) USING discount::numeric;


-- =============================================================================
-- SECTION 2 : AGGREGATE FUNCTIONS  –  Summary & KPIs
-- =============================================================================

-- Q11. What is the total revenue generated across all orders?

SELECT ROUND(SUM(total), 2)       AS total_revenue,
       ROUND(AVG(total), 2)       AS avg_order_value,
       ROUND(MIN(total), 2)       AS min_order_value,
       ROUND(MAX(total), 2)       AS max_order_value
FROM   orders;


-- Q12. What is the total revenue, total discount given, and total
--      quantity sold per product?

SELECT product,
       COUNT(*)                        AS total_orders,
       SUM(quantity)                   AS total_units_sold,
       ROUND(SUM(total), 2)            AS total_revenue,
       ROUND(SUM(discount), 2)         AS total_discount,
       ROUND(AVG(unit_price), 2)       AS avg_unit_price
FROM   orders
GROUP  BY product
ORDER  BY total_revenue DESC;


-- Q13. How many orders were placed each year?

SELECT year,
       COUNT(DISTINCT ordernum)   AS total_orders,
       SUM(quantity)              AS total_units_sold,
       ROUND(SUM(total), 2)       AS total_revenue
FROM   orders
GROUP  BY year
ORDER  BY year;


-- Q14. Which state has the most customers?

SELECT   c.state,
         r.state_name,
         COUNT(c.customer_id) AS customer_count
FROM     customers c
JOIN     regions   r ON c.state = r.state
GROUP BY c.state, r.state_name
ORDER BY customer_count DESC
LIMIT    10;


-- Q15. What is the total revenue per region?

SELECT   r.region,
         ROUND(SUM(o.total), 2)     AS total_revenue,
         COUNT(DISTINCT o.ordernum) AS total_orders,
         COUNT(DISTINCT o.customer_id) AS unique_customers
FROM     orders   o
JOIN     customers c ON o.customer_id = c.customer_id
JOIN     regions   r ON c.state       = r.state
GROUP BY r.region
ORDER BY total_revenue DESC;

ALTER TABLE orders
  ALTER COLUMN order_date TYPE DATE USING order_date::date;

SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'orders';
 


-- Q16. What is the monthly revenue trend for each year?

SELECT year,
       EXTRACT(MONTH FROM order_date) AS month,
       TO_CHAR(order_date, 'Month')   AS month_name,
       ROUND(SUM(total), 2)           AS monthly_revenue
FROM   orders
GROUP  BY year, EXTRACT(MONTH FROM order_date), TO_CHAR(order_date, 'Month')
ORDER  BY year, month;


-- Q17. How many customers have placed more than one order?

SELECT   customer_id,
         COUNT(DISTINCT ordernum) AS order_count
FROM     orders
GROUP BY customer_id
HAVING   COUNT(DISTINCT ordernum) > 1
ORDER BY order_count DESC;


-- Q18. What percentage of customers are on the mailing list?

SELECT COUNT(*)                                               AS total_customers,
       SUM(CASE WHEN mail_list = TRUE THEN 1 ELSE 0 END)     AS subscribed,
       ROUND(
           SUM(CASE WHEN mail_list = TRUE THEN 1 ELSE 0 END)
           * 100.0 / COUNT(*), 2
       )                                                      AS subscription_pct
FROM   customers;


-- =============================================================================
-- SECTION 3 : JOINS  –  Combining Tables
-- =============================================================================

-- Q19. Show each order with the customer's full name, city, and region.

SELECT o.ordernum,
       o.order_date,
       c.name           AS customer_name,
       c.city,
       c.state,
       r.region,
       o.product,
       o.quantity,
       o.total
FROM   orders    o
JOIN   customers c ON o.customer_id = c.customer_id
JOIN   regions   r ON c.state       = r.state
ORDER  BY o.order_date;


-- Q20. List all customers who have NEVER placed an order  (LEFT JOIN).

SELECT c.customer_id,
       c.name,
       c.city,
       c.state
FROM   customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE  o.ordernum IS NULL
ORDER  BY c.name;


-- Q21. Which states have no customers registered?  (LEFT JOIN on regions)

SELECT r.state,
       r.state_name,
       r.region
FROM   regions   r
LEFT JOIN customers c ON r.state = c.state
WHERE  c.customer_id IS NULL
ORDER  BY r.region, r.state_name;


-- Q22. Show each customer's total spend and number of orders placed.

SELECT c.customer_id,
       c.name,
       c.city,
       c.state,
       COUNT(DISTINCT o.ordernum)  AS orders_placed,
       SUM(o.quantity)             AS units_bought,
       ROUND(SUM(o.total), 2)      AS total_spent
FROM   customers c
JOIN   orders    o ON c.customer_id = o.customer_id
GROUP  BY c.customer_id, c.name, c.city, c.state
ORDER  BY total_spent DESC;


-- Q23. Find the top 3 best-selling products in each region.

SELECT region, product, total_revenue
FROM (
    SELECT r.region,
           o.product,
           ROUND(SUM(o.total), 2)                              AS total_revenue,
           RANK() OVER (PARTITION BY r.region ORDER BY SUM(o.total) DESC) AS rnk
    FROM   orders    o
    JOIN   customers c ON o.customer_id = c.customer_id
    JOIN   regions   r ON c.state       = r.state
    GROUP  BY r.region, o.product
) ranked
WHERE rnk <= 3
ORDER BY region, rnk;


-- =============================================================================
-- SECTION 4 : SUBQUERIES  –  Nested Logic
-- =============================================================================

-- Q24. Find customers whose total spend is above the average spend
--      of all customers.

SELECT customer_id,
       name,
       city,
       state,
       total_spent
FROM (
    SELECT c.customer_id,
           c.name,
           c.city,
           c.state,
           ROUND(SUM(o.total), 2) AS total_spent
    FROM   customers c
    JOIN   orders    o ON c.customer_id = o.customer_id
    GROUP  BY c.customer_id, c.name, c.city, c.state
) customer_totals
WHERE total_spent > (
    SELECT AVG(sub.total_spent)
    FROM (
        SELECT customer_id, SUM(total) AS total_spent
        FROM   orders
        GROUP  BY customer_id
    ) sub
)
ORDER BY total_spent DESC;


-- Q25. Which products generated revenue above the average product revenue?

SELECT product,
       ROUND(SUM(total), 2) AS product_revenue
FROM   orders
GROUP  BY product
HAVING SUM(total) > (
    SELECT AVG(prod_total)
    FROM (
        SELECT SUM(total) AS prod_total
        FROM   orders
        GROUP  BY product
    ) avg_sub
)
ORDER BY product_revenue DESC;


-- Q26. Find the most recent order date for each customer
--      using a correlated subquery.

SELECT c.customer_id,
       c.name,
       (
           SELECT MAX(o.order_date)
           FROM   orders o
           WHERE  o.customer_id = c.customer_id
       ) AS last_order_date
FROM   customers c
ORDER  BY last_order_date DESC NULLS LAST;


-- Q27. Which customers placed orders in ALL three years (2025, 2026, 2027)?

SELECT customer_id
FROM   orders
GROUP  BY customer_id
HAVING COUNT(DISTINCT year) = 3;


-- =============================================================================
-- SECTION 5 : CASE WHEN  –  Conditional Logic & Segmentation
-- =============================================================================

-- Q28. Classify customers into spending tiers based on total spend.

SELECT c.customer_id,
       c.name,
       ROUND(SUM(o.total), 2) AS total_spent,
       CASE
           WHEN SUM(o.total) >= 500  THEN 'High Value'
           WHEN SUM(o.total) >= 200  THEN 'Mid Value'
           WHEN SUM(o.total) >= 50   THEN 'Low Value'
           ELSE                           'Occasional'
       END AS customer_segment
FROM   customers c
JOIN   orders    o ON c.customer_id = o.customer_id
GROUP  BY c.customer_id, c.name
ORDER  BY total_spent DESC;


-- Q29. For each order line, flag whether a discount was applied
--      and classify its size.

SELECT ordernum,
       product,
       total,
       discount,
       CASE
           WHEN discount = 0             THEN 'No Discount'
           WHEN discount < 2             THEN 'Small  (<$2)'
           WHEN discount BETWEEN 2 AND 5 THEN 'Medium ($2–$5)'
           ELSE                               'Large  (>$5)'
       END AS discount_category
FROM   orders
ORDER  BY discount DESC;


-- Q30. Create a year-over-year revenue pivot (wide format) per product.

SELECT product,
       ROUND(SUM(CASE WHEN year = 2025 THEN total ELSE 0 END), 2) AS revenue_2025,
       ROUND(SUM(CASE WHEN year = 2026 THEN total ELSE 0 END), 2) AS revenue_2026,
       ROUND(SUM(CASE WHEN year = 2027 THEN total ELSE 0 END), 2) AS revenue_2027,
       ROUND(SUM(total), 2)                                        AS grand_total
FROM   orders
GROUP  BY product
ORDER  BY grand_total DESC;


-- =============================================================================
-- SECTION 6 : WINDOW FUNCTIONS  –  Ranking & Running Totals
-- =============================================================================

-- Q31. Rank customers by total spend using RANK, DENSE_RANK, and ROW_NUMBER.

SELECT c.customer_id,
       c.name,
       ROUND(SUM(o.total), 2)                                         AS total_spent,
       RANK()       OVER (ORDER BY SUM(o.total) DESC)                 AS rank_num,
       DENSE_RANK() OVER (ORDER BY SUM(o.total) DESC)                 AS dense_rank_num,
       ROW_NUMBER() OVER (ORDER BY SUM(o.total) DESC)                 AS row_num
FROM   customers c
JOIN   orders    o ON c.customer_id = o.customer_id
GROUP  BY c.customer_id, c.name
ORDER  BY total_spent DESC;


-- Q32. Calculate the running total of revenue ordered by date.

SELECT order_date,
       ROUND(SUM(total), 2)                                           AS daily_revenue,
       ROUND(SUM(SUM(total)) OVER (ORDER BY order_date ROWS BETWEEN
             UNBOUNDED PRECEDING AND CURRENT ROW), 2)                 AS running_total
FROM   orders
GROUP  BY order_date
ORDER  BY order_date;


-- Q33. For each customer, show each order's total and the cumulative
--      spend up to that order.

SELECT c.name,
       o.ordernum,
       o.order_date,
       ROUND(SUM(o.total) OVER (
           PARTITION BY o.customer_id
           ORDER BY o.order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ), 2)   AS cumulative_spend
FROM   orders    o
JOIN   customers c ON o.customer_id = c.customer_id
ORDER  BY c.name, o.order_date;


-- Q34. Show each product's monthly revenue and its percentage share of
--      that month's total revenue.

SELECT year,
       EXTRACT(MONTH FROM order_date)                      AS month,
       product,
       ROUND(SUM(total), 2)                                AS product_revenue,
       ROUND(
           SUM(total) * 100.0
           / SUM(SUM(total)) OVER (
               PARTITION BY year, EXTRACT(MONTH FROM order_date)
           ), 2
       )                                                   AS pct_of_monthly_revenue
FROM   orders
GROUP  BY year, EXTRACT(MONTH FROM order_date), product
ORDER  BY year, month, pct_of_monthly_revenue DESC;


-- Q35. Find the top customer by revenue in each region.

SELECT region, customer_name, total_spent
FROM (
    SELECT r.region,
           c.name                                                       AS customer_name,
           ROUND(SUM(o.total), 2)                                       AS total_spent,
           RANK() OVER (PARTITION BY r.region ORDER BY SUM(o.total) DESC) AS rnk
    FROM   orders    o
    JOIN   customers c ON o.customer_id = c.customer_id
    JOIN   regions   r ON c.state       = r.state
    GROUP  BY r.region, c.customer_id, c.name
) ranked
WHERE rnk = 1
ORDER BY region;


-- Q36. Calculate month-over-month (MoM) revenue change using LAG().

SELECT year,
       month,
       monthly_revenue,
       LAG(monthly_revenue) OVER (ORDER BY year, month)                 AS prev_month_revenue,
       ROUND(monthly_revenue
             - LAG(monthly_revenue) OVER (ORDER BY year, month), 2)    AS mom_change,
       ROUND(
           (monthly_revenue
            - LAG(monthly_revenue) OVER (ORDER BY year, month))
           * 100.0
           / NULLIF(LAG(monthly_revenue) OVER (ORDER BY year, month), 0)
       , 2)                                                              AS mom_pct_change
FROM (
    SELECT year,
           EXTRACT(MONTH FROM order_date)   AS month,
           ROUND(SUM(total), 2)             AS monthly_revenue
    FROM   orders
    GROUP  BY year, EXTRACT(MONTH FROM order_date)
) monthly
ORDER BY year, month;


-- =============================================================================
-- SECTION 7 : CTEs (Common Table Expressions)  –  Readable, Reusable Logic
-- =============================================================================

-- Q37. Use a CTE to find the top 5 customers by total revenue,
--      then show their region and mailing list status.

WITH customer_revenue AS (
    SELECT o.customer_id,
           c.name,
           c.state,
           c.mail_list,
           ROUND(SUM(o.total), 2) AS total_spent
    FROM   orders    o
    JOIN   customers c ON o.customer_id = c.customer_id
    GROUP  BY o.customer_id, c.name, c.state, c.mail_list
)
SELECT cr.customer_id,
       cr.name,
       cr.state,
       r.region,
       cr.mail_list,
       cr.total_spent
FROM   customer_revenue cr
JOIN   regions r ON cr.state = r.state
ORDER  BY cr.total_spent DESC
LIMIT  5;


-- Q38. Use a CTE to calculate YoY (Year-over-Year) revenue growth
--      per product.

WITH yearly_revenue AS (
    SELECT product,
           year,
           ROUND(SUM(total), 2) AS revenue
    FROM   orders
    GROUP  BY product, year
)
SELECT curr.product,
       curr.year                                                         AS current_year,
       curr.revenue                                                      AS current_revenue,
       prev.revenue                                                      AS prev_revenue,
       ROUND(curr.revenue - prev.revenue, 2)                            AS yoy_change,
       ROUND(
           (curr.revenue - prev.revenue) * 100.0
           / NULLIF(prev.revenue, 0)
       , 2)                                                              AS yoy_pct_change
FROM   yearly_revenue curr
LEFT JOIN yearly_revenue prev
       ON curr.product = prev.product
      AND curr.year    = prev.year + 1
ORDER  BY curr.product, curr.year;


-- Q39. Use multiple CTEs to build a customer RFM-style summary
--      (Recency, Frequency, Monetary).

WITH rfm_base AS (
    SELECT customer_id,
           MAX(order_date)                   AS last_order_date,
           COUNT(DISTINCT ordernum)          AS frequency,
           ROUND(SUM(total), 2)              AS monetary
    FROM   orders
    GROUP  BY customer_id
),
rfm_scored AS (
    SELECT customer_id,
           last_order_date,
           CURRENT_DATE - last_order_date        AS days_since_last_order,
           frequency,
           monetary,
           NTILE(3) OVER (ORDER BY last_order_date DESC) AS recency_score,
           NTILE(3) OVER (ORDER BY frequency    ASC)     AS frequency_score,
           NTILE(3) OVER (ORDER BY monetary     ASC)     AS monetary_score
    FROM   rfm_base
)
SELECT rs.customer_id,
       c.name,
       rs.days_since_last_order,
       rs.frequency,
       rs.monetary,
       rs.recency_score,
       rs.frequency_score,
       rs.monetary_score,
       (rs.recency_score + rs.frequency_score + rs.monetary_score) AS rfm_total_score
FROM   rfm_scored rs
JOIN   customers  c ON rs.customer_id = c.customer_id
ORDER  BY rfm_total_score DESC;


-- Q40. Identify repeat customers vs one-time buyers using a CTE,
--      then summarise revenue contribution of each group.

WITH order_counts AS (
    SELECT customer_id,
           COUNT(DISTINCT ordernum) AS order_count
    FROM   orders
    GROUP  BY customer_id
),
customer_type AS (
    SELECT customer_id,
           CASE WHEN order_count = 1 THEN 'One-Time Buyer'
                ELSE 'Repeat Customer'
           END AS buyer_type
    FROM   order_counts
)
SELECT ct.buyer_type,
       COUNT(DISTINCT o.customer_id)   AS customer_count,
       ROUND(SUM(o.total), 2)          AS total_revenue,
       ROUND(AVG(o.total), 2)          AS avg_order_value
FROM   orders       o
JOIN   customer_type ct ON o.customer_id = ct.customer_id
GROUP  BY ct.buyer_type
ORDER  BY total_revenue DESC;


-- =============================================================================
-- SECTION 8 : ADVANCED ANALYSIS  –  Business Insights
-- =============================================================================

-- Q41. which pairs of products are most often
--      ordered together in the same order number?

SELECT a.product    AS product_1,
       b.product    AS product_2,
       COUNT(*)     AS times_ordered_together
FROM   orders a
JOIN   orders b
       ON  a.ordernum = b.ordernum
       AND a.product  < b.product       -- avoids duplicates & self-pairs
GROUP  BY a.product, b.product
ORDER  BY times_ordered_together DESC;


-- Q42. For each customer, calculate the average number of days
--      between consecutive orders (purchase cadence).

WITH ordered_dates AS (
    SELECT customer_id,
           order_date,
           LAG(order_date) OVER (
               PARTITION BY customer_id ORDER BY order_date
           )                           AS prev_order_date
    FROM (
        SELECT DISTINCT customer_id, order_date FROM orders
    ) distinct_orders
)
SELECT customer_id,
       ROUND(AVG(order_date - prev_order_date), 1) AS avg_days_between_orders
FROM   ordered_dates
WHERE  prev_order_date IS NOT NULL
GROUP  BY customer_id
ORDER  BY avg_days_between_orders;


-- Q43. Cohort analysis: group customers by the year of their first order
--      and see how much they spent in each subsequent year.

WITH first_order AS (
    SELECT customer_id,
           MIN(year) AS cohort_year
    FROM   orders
    GROUP  BY customer_id
),
cohort_revenue AS (
    SELECT fo.cohort_year,
           o.year                                          AS order_year,
           o.year - fo.cohort_year                        AS years_since_first,
           ROUND(SUM(o.total), 2)                         AS revenue
    FROM   orders o
    JOIN   first_order fo ON o.customer_id = fo.customer_id
    GROUP  BY fo.cohort_year, o.year
)
SELECT cohort_year,
       years_since_first,
       order_year,
       revenue
FROM   cohort_revenue
ORDER  BY cohort_year, years_since_first;


-- Q44. Which products are declining in revenue year-over-year?
--      (revenue in current year < revenue in previous year)

WITH yearly AS (
    SELECT product,
           year,
           ROUND(SUM(total), 2) AS revenue
    FROM   orders
    GROUP  BY product, year
)
SELECT curr.product,
       curr.year,
       curr.revenue        AS current_year_revenue,
       prev.revenue        AS prev_year_revenue,
       ROUND(curr.revenue - prev.revenue, 2) AS change
FROM   yearly curr
JOIN   yearly prev
       ON  curr.product = prev.product
       AND curr.year    = prev.year + 1
WHERE  curr.revenue < prev.revenue
ORDER  BY change ASC;


-- Q45. What is the discount impact? Compare average order value
--      with and without a discount applied, per product.

SELECT product,
       ROUND(AVG(CASE WHEN discount > 0 THEN total END), 2)  AS avg_total_with_discount,
       ROUND(AVG(CASE WHEN discount = 0 THEN total END), 2)  AS avg_total_no_discount,
       ROUND(
           AVG(CASE WHEN discount > 0 THEN total END)
           - AVG(CASE WHEN discount = 0 THEN total END)
       , 2)                                                   AS discount_impact
FROM   orders
GROUP  BY product
ORDER  BY discount_impact;


-- Q46. Revenue concentration: what share of total revenue comes
--      from the top 20% of customers? (Pareto / 80-20 check)

WITH customer_totals AS (
    SELECT customer_id,
           ROUND(SUM(total), 2) AS total_spent
    FROM   orders
    GROUP  BY customer_id
),
ranked AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY total_spent DESC) AS quintile
    FROM   customer_totals
)
SELECT quintile,
       COUNT(*)                    AS customer_count,
       ROUND(SUM(total_spent), 2)  AS quintile_revenue,
       ROUND(
           SUM(total_spent) * 100.0
           / SUM(SUM(total_spent)) OVER ()
       , 2)                        AS pct_of_total_revenue
FROM   ranked
GROUP  BY quintile
ORDER  BY quintile;


-- Q47. Moving 3-month average revenue (smoothed trend).

SELECT year,
       month,
       monthly_revenue,
       ROUND(
           AVG(monthly_revenue) OVER (
               ORDER BY year, month
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           )
       , 2) AS moving_avg_3m
FROM (
    SELECT year,
           EXTRACT(MONTH FROM order_date)   AS month,
           ROUND(SUM(total), 2)             AS monthly_revenue
    FROM   orders
    GROUP  BY year, EXTRACT(MONTH FROM order_date)
) m
ORDER BY year, month;


-- Q48. Full customer 360 view: one row per customer with all key metrics.

WITH stats AS (
    SELECT o.customer_id,
           COUNT(DISTINCT o.ordernum)                    AS total_orders,
           SUM(o.quantity)                               AS total_units,
           ROUND(SUM(o.total), 2)                        AS total_spent,
           ROUND(AVG(o.total), 2)                        AS avg_order_value,
           ROUND(SUM(o.discount), 2)                     AS total_discount_received,
           MIN(o.order_date)                             AS first_order_date,
           MAX(o.order_date)                             AS last_order_date,
           CURRENT_DATE - MAX(o.order_date)              AS days_since_last_order
    FROM   orders o
    GROUP  BY o.customer_id
)
SELECT c.customer_id,
       c.name,
       c.city,
       c.state,
       r.region,
       c.mail_list,
       s.total_orders,
       s.total_units,
       s.total_spent,
       s.avg_order_value,
       s.total_discount_received,
       s.first_order_date,
       s.last_order_date,
       s.days_since_last_order,
       CASE
           WHEN s.total_spent >= 500 THEN 'High Value'
           WHEN s.total_spent >= 200 THEN 'Mid Value'
           WHEN s.total_spent >= 50  THEN 'Low Value'
           ELSE 'Occasional'
       END                                               AS customer_segment
FROM   customers c
JOIN   stats     s ON c.customer_id = s.customer_id
JOIN   regions   r ON c.state       = r.state
ORDER  BY s.total_spent DESC;

