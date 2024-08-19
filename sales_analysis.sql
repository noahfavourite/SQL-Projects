 select *
from noah7.dbo.sales;

-- showing deals that has been closed each month in 2024 --
with a1 as (select Industry, Product, Deal_Value, Month(Actual_close_date) as month, Year(Actual_close_date) as year
from noah7.dbo.sales
where Actual_close_date is not null)
	select Industry, Product, Deal_Value, month, year,
	count(month) over(partition by month order by month) as no_of_deals
	from a1
	where year = '2024' ;
	  
-- showing average deal value for deals acquired in each quarter of 2024 --
with b1 as (select datepart(quarter,Actual_close_date) as quarter, Deal_value
from noah7.dbo.sales
where Actual_close_date is not null)
	select quarter, avg(Deal_value) as average_deal_value
	from b1
	group by quarter;

-- showing total number of deals for each status --
select Status, count(deal_value) as no_of_deal_value
from noah7.dbo.sales
group by Status
order by no_of_deal_value desc;

-- showing deals with a probability greater than 70% --
select Industry, Owner, Probability, Product
from noah7.dbo.sales
where probability > 70
order by Probability desc;

-- showing the country with the highest deal value --
select top 1 Country, SUM(Deal_Value) AS countrys_deal_vale 
from noah7.dbo.sales
group by Country 
order by countrys_deal_vale  desc;

-- showing average deal value for each industry --
select Industry, avg(Deal_Value) AS avg_deal_vale 
from noah7.dbo.sales
group by Industry
order by avg_deal_vale  desc;

-- which product has the average probability of closing --
select Product, avg(Probability) AS avg_probability
from noah7.dbo.sales
group by Product
order by avg_probability  desc;

-- showing owner with the highest deal value --
select top 1 Owner, sum(Deal_Value) AS total_deal_value
from noah7.dbo.sales
group by Owner
order by total_deal_value desc;

-- showing average deal value for each owner --
select Owner, avg(Deal_Value) AS avg_deal_value
from noah7.dbo.sales
group by Owner
order by avg_deal_value  desc;

--  showing distribution of deal value across different stage --
select Stage, sum(Deal_Value) AS total_deal_value
from noah7.dbo.sales
WHERE Stage IS NOT NULL
group by Stage
order by total_deal_value desc;

-- showing total number of deals for each status --
select Status, count(Deal_Value) AS total_deals
from noah7.dbo.sales
WHERE Status IS NOT NULL
group by Status
order by total_deals desc;

-- showing which industry has the highest and lowest average deal value -- 
with c1 as 
	(select Industry, avg(Deal_Value) as average_age
from noah7.dbo.sales
group by Industry)
	select distinct 
	concat(first_value(Industry) over(order by average_age), ' - ',
	first_value(average_age) over(order by average_age)) as lowset_average_deal_value,
	concat(first_value(Industry) over(order by average_age desc), ' - ',
	first_value(average_age) over(order by average_age desc)) as highest_average_deal_value
	from c1;

-- showing country with the highest average deal value --
select top 1 Country, avg(deal_value) as average_deal_value
from noah7.dbo.sales
group by Country
order by Country desc;

-- showing average deal value for each status sequence --
select Stage_sequence, avg(deal_value) as average_deal_value
from noah7.dbo.sales
where Stage_sequence is not null
group by Stage_sequence
order by Stage_sequence;

-- showing average probability of closing for each stage --
select Stage, avg(Probability) as average_probability_of_closing
from noah7.dbo.sales
where Stage is not null
group by Stage
order by average_probability_of_closing desc;

-- showing deals with deal values above 1,000 --
select Industry, Owner, Probability, Product
from noah7.dbo.sales
where deal_value > '1000'
order by Probability desc;

 -- showing owner with the highest probability of closing --
select top 1 Owner, avg(Probability) as average_probability_of_closing
from noah7.dbo.sales
group by owner 
order by average_probability_of_closing desc;

-- showing total deal value for each product in each country --
select Country, Product, sum(Deal_Value) as total_deal_value
from noah7.dbo.sales
group by Country, Product
order by country;
 
 -- showing average probaility of closing for each organiztion size --
select Organization_size, avg(Probability) as average_probability
from noah7.dbo.sales
group by Organization_size
order by average_probability desc;

-- showing industries with the highest total deal values --
select top 8 Industry, sum(Deal_value) as total_deal_value
from noah7.dbo.sales
group by Industry
order by total_deal_value desc;
