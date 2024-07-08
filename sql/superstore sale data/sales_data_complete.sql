-- --------------------------------------------- Data Cleaning -------------------------------------------------


-- Eastablish a relationship between the tables
alter table superstore_data
modify column OrderID varchar(255) not null;

alter table superstore_data
add constraint pk_orderid primary key (OrderID);

alter table order_breakdown
modify column OrderID varchar(255) not null;

alter table order_breakdown
add constraint fk_orderid foreign key (OrderID) references superstore_data(OrderIRegionD);


-- Spilt the 'City State Country' column into 3 individual columns
alter table superstore_data
add column city varchar(255),
add column state_name varchar(255),
add column country varchar(255);

UPDATE superstore_data
SET 
    city = SUBSTRING_INDEX(SUBSTRING_INDEX(`City State Country`, ',', 1), ',', -1),
    state_name = SUBSTRING_INDEX(SUBSTRING_INDEX(`City State Country`, ',', 2), ',', -1),
    country = SUBSTRING_INDEX(SUBSTRING_INDEX(`City State Country`, ',', 3), ',', -1);
    
alter table superstore_data
drop column `City State Country`;


-- Add a new Category Column using the following mapping as per the first 3 characters in the Product Name Column:
-- TEC- Technology
-- OFS – Office Supplies
-- FUR - Furniture 

alter table order_breakdown
add column category varchar(255);

update order_breakdown
set category = case when left(ProductName,3) = 'TEC' then 'Technology'
					when left(ProductName,3) = 'OFS' then 'Office Supplies'
                    when left(ProductName,3) = 'FUR' then 'Furniture'
				end;
                
                
-- Delete the first 4 characters from the ProductName Column.
UPDATE order_breakdown
SET ProductName = SUBSTRING(ProductName,5,length(ProductName)-4);


-- Remove duplicate rows from order_breakdown table, if all column values are matching

-- (select * from
-- (select *, row_number()
-- over(partition by OrderID, ProductName, Discount, Sales, Profit,
-- Quantity, Category,SubCategory ORDER BY OrderID) as rnk
-- from order_breakdown) as rem
-- where rnk>1;)

delete from order_breakdown 
where order_breakdown.OrderID in (
	select OrderID from
(select *, count(*) as cnt from order_breakdown
group by OrderID, ProductName, Discount, Sales, Profit,
Quantity, Category,SubCategory
having cnt > 1) as rem
);


-- Replace blank with NA in OrderPriority Column in superstore_data table
update superstore_data
set OrderPriority = case when OrderPriority = '' then 'NA' end;

update superstore_data
set OrderPriority = 'Priority'
where OrderPriority is null;


-- -----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------- Data Exploration ------------------------------------------------

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
