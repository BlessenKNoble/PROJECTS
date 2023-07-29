select top 1* from DIM_CUSTOMER
select top 1* from DIM_DATE
select top 1* from DIM_LOCATION
select top 1* from DIM_MANUFACTURER
select top 1* from DIM_MODEL
select top 1* from FACT_TRANSACTIONS

--1. List all the states in which we have customers who have bought cellphones from 2005 till today

select distinct State from (
select t1.State, year(t2.Date) as Year, SUM(Quantity) as cnt 
from DIM_LOCATION as t1 
join FACT_TRANSACTIONS as t2
on t1.IDLocation = t2.IDLocation
where year(t2.Date) >= 2005
group by t1.state, year(t2.Date)
) as A

--2. What state in the US is buying the most 'Samsung' cell phones?

select top 1 state, count(*) as cnt from DIM_LOCATION as t1                       --count(*) includes manufacturer name 
join FACT_TRANSACTIONS as t2
on t1.IDLocation=t2.IDLocation
join DIM_MODEL as t3
on t2.IDModel= t3.IDModel
join DIM_MANUFACTURER as t4
on t3.IDManufacturer=t4.IDManufacturer
where Country='US' and Manufacturer_Name='Samsung'
group by State
order by count(*) desc

--3. Show the number of transactions for each model per zip code per state. 
select IDModel,ZipCode,state,count(*) as tot_transactions                        --count(*) gives the total no of rows in the selected table for
from DIM_LOCATION as t1                                                          --the selected field
join FACT_TRANSACTIONS as t2
on t1.IDLocation = t2.IDLocation
group by IDModel,ZipCode,State

--4. Show the cheapest cellphone (Output should contain the price also)

select top 1 Model_Name,min(unit_price) as min_price 
from DIM_MODEL
group by Model_Name
order by min(unit_price) 

--5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 

--Avg price for each model

select top 5 t3.Manufacturer_Name,t1.IDModel, AVG(TotalPrice) as Avg_Price,SUM(Quantity) as tot_Qty
from FACT_TRANSACTIONS as t1
join DIM_MODEL as t2
on t1.IDModel=t2.IDModel
join DIM_MANUFACTURER as t3
on t2.IDManufacturer=t3.IDManufacturer
where manufacturer_name in (select top 5 Manufacturer_Name
                            from FACT_TRANSACTIONS as t1
                            join DIM_MODEL as t2
                            on t1.IDModel=t2.IDModel
                            join DIM_MANUFACTURER as t3
                            on t2.IDManufacturer=t3.IDManufacturer
                            group by Manufacturer_Name
                            order by SUM(TotalPrice)  desc)
group by t1.IDModel, t3. Manufacturer_Name
Order by Avg_Price desc


--6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500

select Customer_Name, AVG(TotalPrice) as Avg_Price from DIM_CUSTOMER as t1
join FACT_TRANSACTIONS as t2
on t1.IDCustomer=t2.IDCustomer
where YEAR(date) > 2009
group by Customer_Name
having AVG(TotalPrice) > 500

--7.List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010

select* from(
select top 5 IDModel
from FACT_TRANSACTIONS
where YEAR(date)= 2008
group by IDModel, YEAR(date)
order by SUM(quantity) desc
) as A
intersect
select*from(
select top 5 IDModel
from FACT_TRANSACTIONS
where YEAR(date)= 2009
group by IDModel, YEAR(date)
order by SUM(quantity) desc) as B

intersect
select*from (
select top 5 IDModel
from FACT_TRANSACTIONS
where YEAR(date)= 2010
group by IDModel, YEAR(date)
order by SUM(quantity) desc) as c

--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

select*from(
select top 1* from(
select top 2 manufacturer_name, YEAR(date) as year, SUM(totalprice) as Sales from FACT_TRANSACTIONS as t1
join DIM_MODEL as t2
on t1.IDModel = t2.IDModel
join DIM_MANUFACTURER as t3
on t2.IDManufacturer=t3.IDManufacturer
where YEAR(date) = 2009
group by Manufacturer_Name,year(date)
order by Sales desc
)as A
order by sales asc
) as C

union

select*from(
select top 1*from(
select top 2 manufacturer_name, YEAR(date) as year, SUM(totalprice) as Sales from FACT_TRANSACTIONS as t1
join DIM_MODEL as t2
on t1.IDModel = t2.IDModel
join DIM_MANUFACTURER as t3
on t2.IDManufacturer=t3.IDManufacturer
where YEAR(date) = 2010
group by Manufacturer_Name,year(date)
order by Sales desc
) as B
order by Sales asc
)as D

--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.

select manufacturer_name from FACT_TRANSACTIONS as t1
join DIM_MODEL as t2
on t1.IDModel = t2.IDModel
join DIM_MANUFACTURER as t3
on t2.IDManufacturer=t3.IDManufacturer
where YEAR(date) = 2010
group by Manufacturer_Name
Except
select manufacturer_name from FACT_TRANSACTIONS as t1
join DIM_MODEL as t2
on t1.IDModel = t2.IDModel
join DIM_MANUFACTURER as t3
on t2.IDManufacturer=t3.IDManufacturer
where YEAR(date) = 2009
group by Manufacturer_Name

--10 Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

--top 10 customer

select *, ((avg_price-lag_price)/lag_price) as percentage_change from(
select *, lag (avg_price,1) over(partition by idcustomer order by year) as lag_price from(
select IDCustomer, year(date) as year, AVG(totalprice)as avg_price, SUM(quantity) as qty from FACT_TRANSACTIONS
where IDCustomer in (select top 10 idcustomer from FACT_TRANSACTIONS
                     group by IDCustomer
                     order by sum(totalprice) desc)
group by IDCustomer, YEAR(date)
) as A
) as B











