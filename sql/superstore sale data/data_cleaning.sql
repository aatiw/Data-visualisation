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


-- Replace blank with NA in OrderPriority Column in OrdersList table
update superstore_data
set OrderPriority = case when OrderPriority = '' then 'NA' end;
