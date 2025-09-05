-- Name: Shoplistics – E-commerce Analytics Project
-- Objective: To analyze customer behavior, sales, product performance and returns using SQL.
-- Data: Synthetic dataset (50K rows) covering Customers, Products, Orders, Payments and Returns.
-- Goal: Extract actionable insights to help an e-commerce company improve revenue, reduce churn and optimize strategies


CREATE DATABASE Shoplistics;
USE Shoplistics;

-- CREATING TABLES 

-- Customers Table
CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Gender VARCHAR(10),
    AGE INT,
    City VARCHAR(100),
    Country VARCHAR(100),
    Income_Level VARCHAR(50),
    Signup_Date DATE,
    Device_Type VARCHAR(20),
    Loyalty_Status INT
);

-- Products Table
CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Category VARCHAR(50),
    Subcategory VARCHAR(50),
    Brand VARCHAR(100),
    Product_Name VARCHAR(50),
    Price DECIMAL(10,2),
    Discount DECIMAL(5,2),
    Stock INT,
    Seller_Rating DECIMAL(3,2)
);

-- Orders Table
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Product_ID INT,
    Quantity INT,
    Order_Date DATE,
    Shipping_Date DATE,
    Region VARCHAR(100),
    Coupon_Applied VARCHAR(50),
    Order_Status VARCHAR(50),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

-- Returns Table
CREATE TABLE Returns (
    Return_ID INT PRIMARY KEY,
    Order_ID INT,
    Product_ID INT,
    Return_Reason VARCHAR(255),
    Refund_Amount DECIMAL(10,2),
    Return_Status DATE,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

-- Payments Table
CREATE TABLE Payments (
    Payment_ID INT PRIMARY KEY,
    Order_ID INT,
    Payment_Method VARCHAR(50),
    Transaction_ID VARCHAR(100),
    Payment_Status VARCHAR(50),
    Payment_Date DATE,
    Refund_Date DATE,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
);

-- DATA LOADED SUCCESSFULLY  
SELECT * FROM customers_new;
SELECT * FROM products_new;
SELECT * FROM orders_new;
SELECT * FROM returns_new;
SELECT * FROM payments_new;

-- Making both the tables equal 

-- Customers and Customers_new
INSERT INTO customers 
(Customer_ID, Name, Gender, Age, City, Country, Income_Level, Signup_Date, Device_Type, Loyalty_Status)
SELECT Customer_ID, Name, Gender, Age, City, Country, Income_Level, Signup_Date, Device_Type, Loyalty_Status
FROM customers_new;

-- Verified
SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Customers_new;

-- Products and Products_new
INSERT INTO Products
(Product_ID, Category, Subcategory, Brand, Product_Name, Price, Discount, Stock, Seller_Rating)
SELECT Product_ID, Category, Subcategory, Brand, Product_Name, Price, Discount, Stock, Seller_Rating
FROM Products_new;

-- Verified
SELECT COUNT(*) FROM Products;
SELECT COUNT(*) FROM Products_new;

-- Orders and Orders_new 
INSERT INTO 
Orders(Order_ID, Customer_ID, Product_ID, Quantity, Order_Date, Shipping_Date, Region, Coupon_Applied, Order_Status)
SELECT Order_ID, Customer_ID, Product_ID, Quantity, Order_Date, Shipping_Date, Region, Coupon_Applied, Order_Status
FROM Orders_new; 

-- Verified
SELECT COUNT(*) FROM Orders;
SELECT COUNT(*) FROM Orders_new;

-- Returns and Returns_new
INSERT INTO 
Returns(Return_ID, Order_ID, Product_ID, Return_Reason, Refund_Amount, Return_Status)
SELECT Return_ID, Order_ID, Product_ID, Return_Reason, Refund_Amount, Return_Status
FROM Returns_new;

-- Verified
SELECT COUNT(*) FROM Returns;
SELECT COUNT(*) FROM Returns_new;

-- Payments and Payments_new
INSERT INTO 
Payments(Payment_ID, Order_ID, Payment_Method, Transaction_ID, Payment_Status, Payment_Date, Refund_Date)
SELECT Payment_ID, Order_ID, Payment_Method, Transaction_ID, Payment_Status, Payment_Date, NULLIF(Refund_Date, '')
FROM Payments_new;

-- Verified
SELECT COUNT(*) FROM Payments;
SELECT COUNT(*) FROM Payments_new;

-- Shoplistics: SQL Analytics Case Study
-- Customer Overview
-- Goal: Understand who our customers are and their distribution.

-- Q1.Total number of customers
SELECT COUNT(*) AS Total_no_of_customers
FROM Customers;
-- Insight: We have 5000 total customers in our database.

-- Q2.Gender Distribution
SELECT Gender, Count(*)
FROM Customers
GROUP BY Gender;
-- Insight: We have 2492 males and 2508 females. Females > Males

-- Q3.Average Income Distribution
SELECT Income_Level, Count(*) AS Total_count
FROM Customers
GROUP BY Income_Level;
-- Insight: We have total 1689 mediun income level customers, 1659 low income level customers and 1652 high income level customers. So, we have more medium level income customers 

-- Q4. Analysing the Loyalty_status of the customers
SELECT Loyalty_status, Count(*) AS Total_Loyalty_status
FROM customers
GROUP BY Loyalty_status;
-- Insight: Bronze- 1259 customers (new customers or those who shop rarely)
--          Silver- 1254 customers (Regular customers with moderate purchase frequency) 
--          Gold- 1240 customers (High-value customers who purchase frequently and spend more) 
--          Platinum- 1247 customers (elite customers, highest spenders and most loyal)

-- Goal: Identify best-selling products, categories, and pricing patterns.
-- Q5.Total products available
SELECT COUNT(*) AS Total_products
FROM Products;
-- Insight: We have 1200 products available.

-- Q6.Top 5 Most Purchased Products
SELECT p.Product_Name, SUM(o.Quantity) AS Total_Sold
FROM Orders o
JOIN Products p 
ON o.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY Total_Sold DESC
LIMIT 5;
-- Insight: Samsung Laptop is the most purchased Product i.e. 3235 customers 

-- Q7.Revenue by Category 
SELECT p.Category, sum(o.quantity * p.price) AS Total_revenue
FROM Orders o 
JOIN Products p 
ON o.Product_ID = p.Product_ID
WHERE Order_Status = "DELIVERED"
GROUP BY Category
ORDER BY Total_revenue DESC;
-- Insight:Grocery - 843759254.83
--         Fahion - 842448225.37
--         Electronics - 837515288.03
-- Grocery category has the highest revenue. 

-- Goal: Track revenue, successful orders and trends.

-- Q8.Total successful orders
SELECT Count(*) AS Successful_orders
FROM Orders
WHERE Order_status = "Delivered";
-- Insights : Out of 50,000 orders, 16660 orders delievered successfully  

-- Q9.Monthly Revenue Trend 
SELECT DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month,
       SUM(o.Quantity * p.Price) AS Monthly_Revenue
FROM Orders o
JOIN Products p 
ON o.Product_ID = p.Product_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY Month
ORDER BY Month;
-- Insights: Maximum monthly revenue is on 2023-08   

-- Q10.Top 5 Cities by Revenue 
SELECT c.City, SUM(o.Quantity * p.price) AS Revenue
FROM Customers c 
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
JOIN products p 
ON o.Product_ID = p.Product_ID   
WHERE o.Order_Status = "Delivered"
GROUP BY c.City
ORDER BY Revenue DESC
LIMIT 5;
-- Insights: North James is the most profitable location.

-- Goal: Analyze refunds, delivery and payment methods

-- Q11.Return Rate by Category 
SELECT p.Category, COUNT(r.Return_ID) * 100.0 / COUNT(o.Order_ID) AS Return_Rate_Percent
FROM Orders o
JOIN Products p 
ON o.Product_ID = p.Product_ID
LEFT JOIN Returns r 
ON o.Order_ID = r.Order_ID
GROUP BY p.Category
ORDER BY p.Category DESC;
-- Insights: Grocery has higher return rate means grocery has higher dissatisfaction.

-- Q12.Revenue Lost due to Returns 
SELECT sum(r.Refund_Amount) AS Revenue_Lost
FROM Returns r 
JOIN Orders o
ON r.Order_ID = o.Order_ID
WHERE r.Return_Status = "Approved";
-- Insights: No revenue Lost due to Returns 

-- Q13.Most Used Payment Method 
SELECT Payment_Method, COUNT(*) AS Usage_count 
FROM Payments
GROUP BY Payment_Method
ORDER BY Usage_count DESC; 
-- Insights: Credit Card is the mostly used payment method

-- Goal: Find high-value customers & prevent churn

-- Q14.Customer Lifetime Value (CLV) – Top 10 Customers
SELECT c.Customer_ID, c.name, sum(o.quantity * p.price) AS Lifetime_Value
FROM Customers c 
JOIN Orders o 
ON c.customer_ID = o.Customer_ID
JOIN Products p 
ON o.Product_ID = p.product_ID
WHERE o.order_status = "Delivered"
GROUP BY c.Customer_ID, c.name
ORDER BY Lifetime_Value DESC 
LIMIT 10;
-- Insights:Helps in identifying VIP customers for loyalty programs. 

-- Q15.Repeat Customers
SELECT c.customer_ID, c.name, count(o.order_Id) AS Total_orders
FROM customers c 
JOIN Orders o 
ON c.customer_ID = o.customer_ID 
GROUP BY c.customer_ID, c.name 
HAVING count(o.order_Id) > 1
ORDER BY Total_orders DESC;
-- INSIGHT: It measures customer retention.

-- Q16.Churn Risk Customers (High Returns)
SELECT c.Customer_ID, c.Name,
       COUNT(o.Order_ID) AS Total_Orders,
       COUNT(r.Return_ID) AS Total_Returns
FROM Customers c
JOIN Orders o 
ON c.Customer_ID = o.Customer_ID
LEFT JOIN Returns r 
ON o.Order_ID = r.Order_ID
GROUP BY c.Customer_ID, c.Name
HAVING COUNT(r.Return_ID) > COUNT(o.Order_ID)/2;
-- INSIGHT: Dale Williams (100%) → Every order was returned → extremely high churn risk.
--          Michael Cole (75%) & Randy Rose (60%) → More than half of items returned → dissatisfied, likely to churn.
--          Michael Reed & James Bailey (~55–57%) → Still risky, since majority of purchases are returned.

-- Q17. Monthly Repeat Purchase Rate
SELECT 
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month,
    COUNT(DISTINCT o.Customer_ID) AS Active_Customers,
    COUNT(DISTINCT CASE 
                      WHEN o.Customer_ID IN (
                          SELECT Customer_ID 
                          FROM Orders 
                          GROUP BY Customer_ID 
                          HAVING COUNT(DISTINCT DATE_FORMAT(Order_Date, '%Y-%m')) > 1
                      ) 
                      THEN o.Customer_ID END) AS Repeat_Customers
FROM Orders o
GROUP BY DATE_FORMAT(o.Order_Date, '%Y-%m')
ORDER BY Month;
-- Insight: Shows no. of customers buy again within months.
 
-- Q18.Coupon Effectiveness 
SELECT 
    o.Coupon_Applied,
    COUNT(o.Order_ID) AS Orders,
    SUM(o.Quantity * p.Price) AS Revenue
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY o.Coupon_Applied;
-- Insight:Coupon applied on 8161 orders and not applied on 8499 orders which shows slightly more orders happen without a coupon.
--         Higher revenue comes without coupons and coupons did not increase overall sales or revenue.  
