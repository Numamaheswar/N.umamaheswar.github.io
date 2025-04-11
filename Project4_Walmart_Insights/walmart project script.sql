CREATE 	database Walmartdb;
USE Walmartdb;
create table walmart_sales( invoice_id varchar(25) PRIMARY KEY,
branch char(1),
city varchar(25),customer_type varchar( 10),
gender varchar(10),Product_line varchar(50),
unit_price decimal(10,2),quanity int,
tax_5_percent decimal(10,2),total decimal(10,3),
Date DATE, time TIME,payment varchar(20),cogs decimal(10,2), 
gross_market_percentage decimal(10,3), gross_income decimal(10,3),
ratings decimal(10,1),customer_id int
);

select * from walmart_sales;
WITH top_Branch_by_Sales AS (
    SELECT branch, 
           MONTH(date) AS month, 
           SUM(total) AS total_sales,
           LAG(SUM(total)) OVER (PARTITION BY branch ORDER BY MONTH(date)) AS prev_month_sales
    FROM walmart_sales
    GROUP BY branch, MONTH(date)
)
SELECT branch, 
       month, 
       total_sales, 
       (total_sales - prev_month_sales) / prev_month_sales * 100 AS growth_rate
FROM top_Branch_by_Sales;

SELECT branch, product_line, SUM(gross_income) AS total_profit
FROM walmart_sales
GROUP BY branch, product_line
ORDER BY branch, total_profit DESC;

SELECT customer_type, 
       SUM(total) AS total_spent,
       CASE 
           WHEN 
            SUM(total) >= 1000 THEN 'High Spender'
           WHEN SUM(total)>= 500 then 'Medium Spender'
           ELSE 'Low Spender'
       END AS spend_category
FROM walmart_sales
GROUP BY customer_type;
select * from walmart_sales;

SELECT 
    payment, 
    product_line, 
    ROUND(total, 3) AS total, 
    ROUND((SELECT AVG(total) 
           FROM walmart_sales 
           WHERE product_line = s.product_line), 3) AS avg_sales
FROM 
    walmart_sales s
WHERE 
    total > (SELECT AVG(total) * 1.5 
             FROM walmart_sales 
             WHERE product_line = s.product_line) 
    OR 
    total < (SELECT AVG(total) * 0.5 
             FROM walmart_sales 
             WHERE product_line = s.product_line);

SELECT city, payment, COUNT(*) AS usage_count
FROM walmart_sales
GROUP BY city, payment
ORDER BY city, usage_count DESC;

SELECT MONTH(date) AS month, gender, SUM(total) AS total_sales
FROM walmart_sales
GROUP BY month, gender
ORDER BY month;

SELECT customer_type, product_line, COUNT(*) AS purchases
FROM walmart_sales
GROUP BY customer_type, product_line
ORDER BY customer_type, purchases DESC;
	
SELECT customer_id, COUNT(*) AS purchase_count
FROM walmart_sales
WHERE date BETWEEN DATE_SUB(date, INTERVAL 30 DAY) AND date
GROUP BY customer_id
HAVING purchase_count > 1;

SELECT customer_id, SUM(total) AS total_spent
FROM walmart_sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;

SELECT DAYNAME(date) AS day_of_week, SUM(total) AS total_sales
FROM walmart_sales
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

select * from walmart_sales;