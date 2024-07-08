
-- List the top 10 orders with the highest sales from the order_breakdown table.
select * from order_breakdown
order by Sales DESC limit 10;

-- Show the number of orders for each product category in the order_breakdown table.
select count(*) as orders, category from order_breakdown
group by category;

-- Find the total profit for each sub-category in the order_breakdown table.
select sum(CAST(REPLACE(Profit, '$', '') AS DECIMAL(10, 2))) as profit, SubCategory from order_breakdown
group by SubCategory;



-- Identify the customer with the highest total sales across all orders.
SELECT ssd.CustomerName, SUM(cast(replace(ob.sales,'$','') as decimal(10,2))) AS total_sales
FROM superstore_data ssd
JOIN order_breakdown ob ON ssd.OrderID = ob.OrderID
GROUP BY ssd.CustomerName
ORDER BY total_sales DESC limit 1;



-- Find the month with the highest average sales in the order_breakdown table.
select month(ssd.ShipDate) as month_name, 
avg(cast(replace(ob.Sales,'$','') as decimal(10,2)))
as avg_sales from
superstore_data ssd join order_breakdown ob
on ssd.OrderID = ob.OrderID 
group by month_name order by avg_sales DESC limit 1;



-- Find out the average quantity ordered by customers whose first name starts with an alphabet 's'?
select avg(ob.Quantity) as avg_quantity
from order_breakdown ob join superstore_data ssd
on ob.OrderID = ssd.OrderID
where left(ssd.CustomerName, 1) = 's';



-- Find out how many new customers were acquired in the year 2014?
SELECT COUNT(*) As NumberOfNewCustomers FROM (
SELECT CustomerName, MIN(Year(OrderDate)) AS FirstOrderDate
from superstore_data
GROUP BY CustomerName
Having year(MIN(OrderDate)) = 2014 ) AS CustWithFirstOrder2014;



-- Calculate the percentage of total profit contributed by each sub-category to the overall profit.
Select SubCategory, SUM(CAST(REPLACE(Profit, '$', '') AS DECIMAL(10, 2)))
 As SubCategoryProfit,
round(SUM(CAST(REPLACE(Profit, '$', '') AS DECIMAL(10, 2)))/(Select SUM(CAST(REPLACE(Profit, '$', '') AS DECIMAL(10, 2)))
FROM order_breakdown),3) * 100 AS PercentageOfTotalContribution
FROM order_breakdown
Group By SubCategory;



-- Find the average sales per customer, considering only customers who have made more than one order.
WITH CustomerAvgSales AS(
SELECT CustomerName, COUNT(DISTINCT ssd.OrderID) As NumberOfOrders,
AVG(cast(replace(Sales,'$','') as decimal(10,2))) AS AvgSales
FROM superstore_data ssd
JOIN order_breakdown ob
ON ssd.OrderID = ob.OrderID 
GROUP BY CustomerName
)
SELECT CustomerName, AvgSales
FROM CustomerAvgSales
WHERE NumberOfOrders > 1;



-- Identify the top-performing subcategory in each category based on total sales. Include the sub-category name, total sales, and a ranking of sub-category within each category.
WITH topsubcategory AS(
SELECT Category, SubCategory, SUM(cast(replace(Sales,'$','') as decimal(10,2))) as TotalSales,
RANK() OVER(PARTITION BY Category ORDER BY SUM(cast(replace(Sales,'$','') as decimal(10,2))) DESC)
 AS SubcategoryRank
FROM order_breakdown
Group By Category, SubCategory
)
SELECT *
FROM topsubcategory
WHERE SubcategoryRank = 1;
