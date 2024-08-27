-- Database setup and Table Creation

CREATE DATABASE retailsales;

-- Create table
CREATE TABLE retailsales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantiy INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

-- Data Cleaning
Select * From retailsales;

-- Taking care of missing values
SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL 
    OR 
    sale_time IS NULL 
    OR 
    customer_id IS NULL 
    OR 
    gender IS NULL 
    OR 
    age IS NULL 
    OR 
    category IS NULL 
    OR 
    quantiy IS NULL 
    OR 
    price_per_unit IS NULL 
    OR 
    cogs IS NULL;

DELETE FROM retailsales
WHERE 
    transactions_id is null
    OR
    sale_date is null
    OR
    sale_time is null
    OR
    gender is null
    OR
    age is null
    OR
    category is null
    OR
    quantiy is null
    OR
    cogs is null
    OR
    total_sale is null;

-- Record Count
Select Count(*) FROM retailsales;

-- Data exploration
-- Key KPIs:

-- Number of Sales
SELECT COUNT(*) as total_sale FROM retailsales;

-- Number of Customers
SELECT COUNT(DISTINCT customer_id) as total_sale from retailsales;

-- Number of Categories
SELECT DISTINCT category FROM retailsales;

-- Analysis of Data in order to Provide Key Business Insights:

-- Sales/Revenue and Product Category Insight

-- Total Sales/Total Revenue
SELECT SUM(quantiy * price_per_unit) AS total_sales
FROM retailsales;

-- Total Sales/Revenue by Each Category
SELECT category, SUM(quantiy * price_per_unit) AS total_sales,
COUNT(*) as total_orders
FROM retailsales
GROUP BY category;

-- Total sales and Total Transactions when product_Category is "Clothing" and quantity sold is more than 5 in the month of Nov -2022
SELECT * FROM 
    retailsales
WHERE 
    category = 'Clothing'
    AND quantiy > 1
    AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
    
-- Top Selling Products
SELECT 
    category,
    SUM(quantiy * price_per_unit) AS total_sales
FROM 
    retailsales
GROUP BY 
    category
ORDER BY 
    total_sales DESC
LIMIT 5;

-- Total sales are greater than 1000
SELECT * FROM retailsales
WHERE total_sale > 1000;



-- Sales Trend And Shift Hour Analysis

-- Average Selling for Each Month & The Best Selling Month in each year by Product Category
-- First, this query calculates the average sales for each month across all years and categories.
SELECT
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    category,
    ROUND(AVG(total_sale), 2) AS average_sales
FROM
    retailsales
GROUP BY
    year, month, category
ORDER BY
    year, month, category;

-- Second, this query identifies the best-selling month for each category within each year.
WITH MonthlySales AS (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        category,
        SUM(total_sale) AS total_sales
    FROM
        retailsales
    GROUP BY
        year, month, category
)
SELECT
    year,
    category,
    month,
    total_sales
FROM
    MonthlySales
WHERE
    (year, category, total_sales) IN (
        SELECT
            year,
            category,
            MAX(total_sales)
        FROM
            MonthlySales
        GROUP BY
            year, category
    )
ORDER BY
    year, category;
    
-- Create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS number_of_orders
FROM retailsales
GROUP BY shift;



 -- Customer Demographics & Purchasing Behaviour Insight
 
-- How does purchasing behavior vary across different age groups or genders?
SELECT gender, age, category, SUM(quantiy * price_per_unit) AS total_spent
FROM retailsales
GROUP BY gender, age, category
ORDER BY total_spent DESC;

-- Average age of customers who purchased from the beauty categoory
SELECT 
	AVG(age)
FROM retailsales
WHERE category = 'Beauty';

-- TOP 10 customers based on highest sales and products
SELECT 
    customer_id,
    category,
    SUM(total_sale) AS total_sales
FROM 
    retailsales
GROUP BY 
    customer_id, category
ORDER BY 
    total_sales DESC
LIMIT 10;

-- Total number of Transaction made by each gender in each category
SELECT 
category,
gender,
COUNT(*) as total_transactions
FROM retailsales
GROUP BY
category, gender
ORDER BY 1;

-- Number of Unique Customers who purchased products from each category
SELECT 
category,
COUNT(DISTINCT customer_id) as unique_customer
FROM retailsales
GROUP BY category;

-- Customer spending segmentation
SELECT customer_id, SUM(quantiy * price_per_unit) AS total_spent
FROM retailsales
GROUP BY customer_id
ORDER BY total_spent DESC;

-- Total number of customers' spending category classification by each category of products.(For example: total_spent<5000, 'frugal customer', total_spent between 5000 and 15000, ;medium-spent_range customer and total_spent>15000 is high-spent_range customer)
SELECT
	category,
    spending_category,
    COUNT(customer_id) AS number_of_customers
FROM (
    SELECT
		category,
        customer_id,
        SUM(quantiy * price_per_unit) AS total_spent,
        CASE
            WHEN SUM(quantiy * price_per_unit) < 5000 THEN 'frugal customer'
            WHEN SUM(quantiy * price_per_unit) BETWEEN 5000 AND 15000 THEN 'medium-spent_range customer'
            ELSE 'high-spent_range customer'
        END AS spending_category
    FROM retailsales
    GROUP BY category, customer_id
) AS categorized_customers
GROUP BY category, spending_category
ORDER BY spending_category;

-- Number of Transactions each customer make, and what is their average spend per transaction
SELECT customer_id, 
       COUNT(transactions_id) AS total_transactions, 
       ROUND(AVG(total_sale), 2) AS avg_spend_per_transaction
FROM retailsales
GROUP BY customer_id
ORDER BY total_transactions DESC;



-- Profitability Analysis

-- Profit Margin for each Category
SELECT category, 
       SUM((price_per_unit - cogs) * quantiy) AS total_profit,
       (SUM((price_per_unit - cogs) * quantiy) / SUM(quantiy * price_per_unit)) * 100 AS profit_margin_percentage
FROM retailsales
GROUP BY category;



-- Cost Analysis

-- Total cost of goods sold (COGS) for each category, and how does it compare to the revenue generated?
SELECT category, 
       ROUND(SUM(cogs * quantiy), 2) AS total_cogs, 
       ROUND(SUM(quantiy * price_per_unit), 2) AS revenue,
       ROUND(SUM(quantiy * price_per_unit), 2) - ROUND(SUM(cogs * quantiy), 2) AS profit
FROM retailsales
GROUP BY category;










    
    



