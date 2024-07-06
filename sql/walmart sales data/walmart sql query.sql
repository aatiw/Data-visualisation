CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);



-- ---------------------------------------------------------------------------------------------------
-- ---------------------------------Feature Engineering-----------------------------------------------

-- ---------------------------------Time of day-------------------------------------------------------
select 
		time, (
        CASE
			When `time` between "00:00:00" and "12:00:00" then "Morning"
            When `time` between "12:00:01" and "16:00:00" then "Evening"
            Else "Night"
		END
		) as time_of_date
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = (
		CASE
			When `time` between "00:00:00" and "12:00:00" then "Morning"
            When `time` between "12:00:01" and "16:00:00" then "Evening"
            Else "Night"
		END
);

-- ----------------------------------------------------------------------------------------------------

-- ------------------------------------Day name--------------------------------------------------------
select date,
DAYNAME(date) from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(date);

-- ----------------------------------------------------------------------------------------------------

-- ------------------------------------Month name--------------------------------------------------------

select date,
monthname(date) from sales;

alter table sales add column month_name varchar(10);

update sales
set month_name = monthname(date);

-- ----------------------------------------------------------------------------------------------------

-- -----------------------------------------   Generic   ----------------------------------------------

-- How many unique cities does the data have?
select 
	distinct city
from sales;

-- In which city is each branch?
select 
	distinct city,
    branch
from sales;

-- ---------------------------------------------------------------------------------------------------
-- --------------------------------------------Product------------------------------------------------
-- ---------------------------------------------------------------------------------------------------

-- How many unique product lines does the data have?
select count(distinct product_line) from sales;


-- What is the most common payment method?
select payment, count(payment) as time_used from sales
group by payment
order by time_used DESC limit 1;


-- What is the most selling product line?
select product_line, sum(quantity) as sold_amt from sales
group by product_line
order by sold_amt DESC;


-- What is the total revenue by month?
select month_name, sum(total) as revenue from sales
group by month_name; 


-- What month had the largest COGS(cost of goods sold)?
select month_name, sum(cogs) as cogs from sales
group by month_name
order by cogs DESC;


-- What product line had the largest revenue? 
select product_line, sum(total) as revenue from sales
group by product_line
order by revenue DESC;


-- What is the city with the largest revenue?
select city, sum(total) as revenue from sales
group by city
order by revenue DESC;


-- What product line had the largest VAT?
select product_line, avg(tax_pct) as VAT from sales
group by product_line
order by VAT DESC;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select product_line,
		Case
			when avg(quantity) > (select avg(quantity) from sales) then "Good"
		else "Bad"
	End as remark
from sales
group by product_line;


-- Which branch sold more products than average product sold?
select branch, avg(quantity), over_avg from sales
group by branch
having avg(quantity)>(select avg(quantity) as over_avg from sales);


-- What is the most common product line by gender?
select product_line,gender,sum(quantity) as sold_amt from sales
group by gender, product_line
order by sold_amt DESC;
-- select product_line, sum(quantity),gender from sales
-- where gender = "Male" 
-- group by product_line;


-- What is the average rating of each product line?
select product_line, avg(rating) as average_rating from sales
group by product_line
order by average_rating;



-- ---------------------------------------------------------------------------------------------
-- ----------------------------------------Sales------------------------------------------------
-- ---------------------------------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday
select time_of_day, count(quantity) as total_sale from sales
group by time_of_day;


-- Which of the customer types brings the most revenue?
select customer_type, sum(total) as revenue from sales
group by customer_type 
order by revenue DESC limit 1;


-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, avg(tax_pct) as VAT from sales
group by city
order by VAT DESC;


-- Which customer type pays the most in VAT?
select customer_type, avg(tax_pct) as VAT from sales
group by customer_type 
order by VAT DESC limit 1;


-- ----------------------------------------------------------------------------------------
-- ------------------------------------Customer--------------------------------------------
-- ----------------------------------------------------------------------------------------

-- What is the most common customer type?
select customer_type,count(customer_type) as count from sales
group by customer_type
order by count DESC;


-- Which customer type buys the most?
select customer_type, sum(quantity) as amt from sales
group by customer_type
order by amt DESC;


-- What is the gender of most of the customers?
select gender, count(gender) as count from sales
group by gender
order by count DESC limit 1;


-- What is the gender distribution per branch?
select branch, gender, count(gender) from sales
group by branch, gender
order by branch;


-- Which time of the day do customers give most ratings?
select time_of_day, avg(rating) as avg_rating from sales
group by time_of_day
order by avg_rating DESC;


-- Which time of the day do customers give most ratings per branch?
select branch, time_of_day, avg_rating from
(select branch, time_of_day, avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) DESC) rnk
from sales
group by branch, time_of_day) a
where rnk = "1";


-- Which day of the week has the best avg ratings?
select day_name, avg(rating) as avg_rating from sales
group by day_name
order by avg_rating DESC;


-- Which day of the week has the best average ratings per branch?
select branch, day_name, avg_rating from 
(select branch, day_name, avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) DESC) as rnk
from sales
group by branch, day_name) as a
where 
 rnk = "1";





