# SQL Retail Sales Project

## Project Overview

**Project Title**: Retail Sales Data Analysis & Insight 
**Database**: `retailsales`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data in order to provide clear insight & recommendations to the client's key business problems. The project involves setting up a retail sales database, cleaning the data, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. 

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

-- **Database Setup and Table Creation**
```sql
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
```
-- **Data Cleaning**
```sql
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
```

-- **Data exploration**
-- **Key KPIs:**
```sql
-- **Number of Sales**
SELECT COUNT(*) as total_sale FROM retailsales;

-- **Number of Customers**
SELECT COUNT(DISTINCT customer_id) as total_sale from retailsales;

-- **Number of Categories**
SELECT DISTINCT category FROM retailsales;
```

-- **Analysis of Data in order to Provide Key Business Insights:**

-- **Sales/Revenue and Product Category Insight**
```sql
-- **Total Sales/Total Revenue**
SELECT SUM(quantiy * price_per_unit) AS total_sales
FROM retailsales;

-- **Total Sales/Revenue by Each Category**
SELECT category, SUM(quantiy * price_per_unit) AS total_sales,
COUNT(*) as total_orders
FROM retailsales
GROUP BY category;

-- **Total sales and Total Transactions when product_Category is "Clothing" and quantity sold is more than 5 in the month of Nov -2022**
SELECT * FROM 
    retailsales
WHERE 
    category = 'Clothing'
    AND quantiy > 1
    AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
    
-- **Top Selling Products**
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

-- **Total sales are greater than 1000**
SELECT * FROM retailsales
WHERE total_sale > 1000;
```


-- **Sales Trend And Shift Hour Analysis**
```sql
-- **Average Selling for Each Month & The Best Selling Month in each year by Product Category**

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
    
-- **Create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):**
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS number_of_orders
FROM retailsales
GROUP BY shift;
```



 -- **Customer Demographics & Purchasing Behaviour Insight**
 ```sql
-- **How does purchasing behavior vary across different age groups or genders?**
SELECT gender, age, category, SUM(quantiy * price_per_unit) AS total_spent
FROM retailsales
GROUP BY gender, age, category
ORDER BY total_spent DESC;

-- **Average age of customers who purchased from the beauty categoory**
SELECT 
	AVG(age)
FROM retailsales
WHERE category = 'Beauty';

-- **TOP 10 customers based on highest sales and products**
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

-- **Total number of Transaction made by each gender in each category**
SELECT 
category,
gender,
COUNT(*) as total_transactions
FROM retailsales
GROUP BY
category, gender
ORDER BY 1;

--**Number of Unique Customers who purchased products from each category**
SELECT 
category,
COUNT(DISTINCT customer_id) as unique_customer
FROM retailsales
GROUP BY category;

-- **Customer spending segmentation**
SELECT customer_id, SUM(quantiy * price_per_unit) AS total_spent
FROM retailsales
GROUP BY customer_id
ORDER BY total_spent DESC;

-- **Total number of customers' spending category classification by each category of products.(For example: total_spent<5000, 'frugal customer', total_spent between 5000 and 15000, ;medium-spent_range customer and total_spent>15000 is high-spent_range customer)**
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

-- **Number of Transactions each customer make, and what is their average spend per transaction**
SELECT customer_id, 
       COUNT(transactions_id) AS total_transactions, 
       ROUND(AVG(total_sale), 2) AS avg_spend_per_transaction
FROM retailsales
GROUP BY customer_id
ORDER BY total_transactions DESC;
```


-- **Profitability Analysis**
```sql
-- **Profit Margin for each Category**
SELECT category, 
       SUM((price_per_unit - cogs) * quantiy) AS total_profit,
       (SUM((price_per_unit - cogs) * quantiy) / SUM(quantiy * price_per_unit)) * 100 AS profit_margin_percentage
FROM retailsales
GROUP BY category;
```


-- **Cost Analysis**
```sql
-- **Total cost of goods sold (COGS) for each category, and how does it compare to the revenue generated?**
SELECT category, 
       ROUND(SUM(cogs * quantiy), 2) AS total_cogs, 
       ROUND(SUM(quantiy * price_per_unit), 2) AS revenue,
       ROUND(SUM(quantiy * price_per_unit), 2) - ROUND(SUM(cogs * quantiy), 2) AS profit
FROM retailsales
GROUP BY category;
```
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Reports & Findings

- **Revenue/Sales Insight**:
- Total Sales/Revenue by each category of products - Beauty products: Total revenue: 286790	and Total orders 611; Clothing: Total Revenue:	309995	and total orders: 698; Electronics: Total revenue:	311445 and Total orders:	678 which shows that highest ordered product is "Clothing" but Highest revenue making Product is Electronics.
- Several transactions had a total sale amount greater than 1000, indicating premium purchases.

- **Shift Hours & Sales Trends Insight over Time**:
- Monthly analysis shows variations in sales, helping identify peak seasons by each product category over the year. Also, the shift hour analysis shows that during evening shift nuber of order is teh highest - 1062

- **Customer Demographics, Segmetation & Purchasing behavour Insight**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty, electronics. Where by age and gender we find how much which gender has spent on each product, average age of female customers spending on beauty product ( That is age 40), top 10 spenidng customers are identified as well as average_spending of each customers on each product category; lastly, we can classified the total number of customers in 3 categories: "Frugal","Medium"Spent_Range" and "High/Premium_Spent_Range" based on their spending/purchasing habit.

- **Profitability Insight**: The profitability analysis shows that HIghest total profit have been earned by "Clothing" followed by "Electronics" and "Beauty" products. While, "Beauty" has the highest profit_margin (47.9%) followed by "Clothing" (46.2%) and "Electronics" (45.2%).
  
- **Product & Cost Insight**: The Product analysis give the top performing products based on total_sale that is Electronics followed by Clothing & beauty products. However, the Cost analysis shows that Electronics has the highest COGS and Revenue generated followed by Clothing & Beauty. But, Highest profit is made by Clothing followed by Electronics & Beauty products.

## Recommendations 

Based on the insights provided, here are several strategic recommendations for the client:

**1. Product Category Focus**
Electronics: Despite generating the highest revenue, Electronics has a slightly lower profit margin compared to Clothing and Beauty products. The client should consider strategies to optimize the cost of goods sold (COGS) in this category or potentially increase prices slightly to improve the profit margin without affecting demand.
Clothing: This category has the highest number of orders and generates significant profit, indicating strong customer demand. The client should continue to focus on this category, possibly expanding the range or offering more promotions to capitalize on its popularity.
Beauty Products: Although Beauty products have the highest profit margin, the total revenue and number of orders are lower compared to Electronics and Clothing. The client could explore targeted marketing campaigns aimed at increasing sales volume in this category, especially since it already yields high profitability.

**2. Premium Product Strategy**
The presence of several transactions with a total sale amount greater than $1,000 suggests a segment of premium customers. The client should consider developing exclusive, high-end product lines or bundles, particularly in the Electronics and Clothing categories, to cater to these premium customers and increase overall revenue.

**3. Seasonal and Shift-Based Marketing**
Peak Seasons: The monthly sales variations indicate that certain times of the year are more profitable for different categories. The client should plan seasonal promotions and inventory management around these peak periods to maximize sales.
Evening Shifts: The highest number of orders occurs during the evening shift. The client could allocate more resources to customer service, staffing, and marketing efforts during these hours to further boost sales.

**4. Customer Segmentation and Targeting**
Demographics and Segmentation: With clear segmentation of customers into "Frugal," "Medium Spent Range," and "High/Premium Spent Range," the client can tailor marketing efforts to each group. For example, premium customers can be targeted with exclusive offers, while more price-sensitive customers could be offered discounts or loyalty programs.
Gender and Age Targeting: The data reveals specific spending habits by gender and age, such as the average age of female customers spending on beauty products. The client should use this information to create more personalized marketing campaigns, possibly focusing on products that resonate with these demographics.

**5. Profitability Enhancement**
Focus on High-Margin Products: Given that Beauty products have the highest profit margin, the client should consider promotional strategies to increase sales in this category. They could also explore whether certain beauty products could be positioned as luxury items, further enhancing profitability.
Cost Optimization: While Electronics generate the highest revenue, the profit margin is slightly lower. The client could look into cost-saving measures in the supply chain or explore more favorable supplier contracts to increase margins in this category.

**6. Inventory and Supply Chain Management**
Top Performing Products: Since Electronics and Clothing are the top-selling categories, it’s essential to ensure these products are always well-stocked, particularly during peak sales periods.
Cost Analysis: The client should continue to monitor COGS closely, especially in the Electronics category, to ensure profitability is maintained or improved. Regular reviews of supplier contracts and bulk purchasing strategies could help in managing costs effectively.

**7. Enhanced Customer Loyalty Programs**
Top 10 Customers: The client has identified their top 10 spending customers. A personalized loyalty program could be developed to retain these high-value customers and encourage even greater spending, particularly in the most profitable product categories.
By implementing these recommendations, the client can enhance their revenue, improve profit margins, and better target their marketing efforts to drive growth in each product category.


## Conclusion

This project serves for retails sales data clenaing, exploratory analysis, and finding key business-problem anaswers to provide an insight of the dataset to the client for their retail business and recommendations to improve the business. The findings from this project can help drive business decisions by understanding sales patterns, customer segmentation, purchasing behavior, cost analysis, profitability and product performance and take steps accordingly. 
