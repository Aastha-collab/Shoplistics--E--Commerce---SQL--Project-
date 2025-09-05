#  Shoplistics – E-Commerce SQL Project

### Goal- Analyze customer behavior, sales, payments, and returns in an e-commerce environment using SQL to generate actionable business insights.

---

###  Dataset

* **Size:** 50k+ rows (synthetic but realistic hybrid data)
* **Domains Covered:** Fashion, Electronics, Grocery, Lifestyle
* **Tables:** Customers, Products, Orders, Order\_Items, Payments, Returns
* **Source:** Self-designed dataset to simulate real e-commerce operations

---

### SQL Techniques Used

* Joins (INNER, LEFT, RIGHT)
* Aggregations (SUM, COUNT, AVG, MAX, MIN)
* Subqueries
* Common Table Expressions (CTEs)
* Window Functions (RANK, ROW\_NUMBER, PARTITION BY)
* Business Logic Queries

---

### 💡 Business Insights

* Top 5 Most Purchased Products
* High-value customers (loyalty tiers & spending)
* Product categories driving the most sales
* Churn-risk customers (high returns vs orders)
* Payment method success vs failure rates
* Analysed revenue lost due to Returns

---

### ER Diagram

https://github.com/Aastha-collab/Shoplistics--E--Commerce---SQL--Project-/blob/main/ER%20Diagram.png
ER Diagram.png
---

###  How to Run

1. Import the dataset (`shoplistics_db.xlsx`) into MySQL Workbench.
2. Run the schema and queries from the `.sql` file.
3. Visualize database relationships using the ER diagram.
4. Analyze insights through advanced SQL queries.

---

## Queries + Insights
eg- Coupon Effectiveness

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

---

eg- Monthly Repeat Purchase Rate

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

---

eg- Churn Risk Customers (High Returns)

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
