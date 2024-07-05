select * from pizza_sales_data;


-- What is the total revenue
select sum(total_price) from pizza_sales_data;


-- What is the average order value per user?
select round(sum(total_price)/count(distinct order_id), 2) 
as average_order_value from pizza_sales_data;


-- How many pizzas were sold?
select sum(quantity) as quantity from pizza_sales_data;


-- How many order were placed per user?
select round(sum(quantity)/count(distinct order_id), 2) 
as average_order_quantity from pizza_sales_data;


-- Pizza sales with week days
select dayname(str_to_date(order_date, '%Y-%m-%d')) as dayt,
sum(quantity) as orders from pizza_sales_data
group by dayt
order by orders DESC;

-- trend with day hour
select hour(str_to_date(order_time, '%H:%i:%s')) as hourt,
sum(quantity) as orders from pizza_sales_data
group by hourt
order by hourt;


-- % of pizza sale per category
select pizza_category, sum(quantity) as counts, round(sum(total_price),2) as revenue,
round(sum(total_price)/(select sum(total_price) from pizza_sales_data),4)*100
as per_cent_total
from pizza_sales_data
group by pizza_category
order by per_cent_total DESC;


-- Average price of each pizza category
select pizza_category, round(avg(total_price),2) as avg_price
from pizza_sales_data
group by pizza_category
order by avg_price DESC;


-- % sales by pizza size
select pizza_size, sum(total_price) as revenue, 
round(sum(quantity)/(select sum(quantity) from pizza_sales_data),4)*100 
as per_cent_total from pizza_sales_data
group by pizza_size
order by per_cent_total DESC;


-- Total pizza sold per category
select pizza_category, sum(quantity) as counts
from pizza_sales_data
group by pizza_category
order by counts DESC;


-- Top 5 best seller pizzas by total pizzas sold
select pizza_name, sum(quantity) as amt_sold, 
sum(total_price) as revenue, avg(total_price) as avg_price
from pizza_sales_data
group by pizza_name
order by amt_sold DESC limit 5;


-- Least 5 sold pizzas by total pizzas sold
select pizza_name, sum(quantity) as amt_sold, 
sum(total_price) as revenue, avg(total_price) as avg_price
from pizza_sales_data
group by pizza_name
order by amt_sold ASC limit 5;


-- Pizza sales with months
select monthname(str_to_date(order_date, '%Y-%m-%d'))as month_name,
sum(quantity) as orders from pizza_sales_data group by month_name;





