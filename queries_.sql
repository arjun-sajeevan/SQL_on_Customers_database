select * from customers;
select * from employees; 
select * from offices; 
select * from orderdetails; 
select * from orders; 
select * from payments; 
select * from productlines; 
select * from products; 

## 1. Find the customers whose "state" code is not filled and display only their full name and contact number
select CustomerName,phone from customers
where state is null ;

## 2. Find the product names for each of the orders in 'order details ' table 
select distinct od.productcode,p.productname from orderdetails as od
         left join products as p on od.productcode = p.productcode;
         
## 3. Using the "payments " table, find out the total amount spend by each customer ID 
select customernumber,sum(amount) as total_amount_spend from payments
group by customernumber;

## 4. Find out the number of customers from each country 
select country , count(customernumber) as No_of_Customers from customers
group by country ;


## 5. Find out the amount of sales driven by each sales representative 

select e.employeenumber,sum(p.amount) as amount from employees as e 
left join customers as c on c.salesRepEmployeeNumber=e.employeenumber 
left join payments as p on p.customernumber = c.customernumber 
group by employeenumber;


## 6. Find out the total number of quantity ordered per each order
select Ordernumber, sum(quantityordered) as total_no_of_quantity from orderdetails
group by ordernumber;  

## 7. Find out the total number of quantity ordered per each product ID
select productcode, sum(quantityordered) as total_no_of_quantity from orderdetails
group by Productcode;

## 8. Find out the Total number of orders made where the order value is over 7000 INR

select count(*) as Total_no_of_orders from (
select ordernumber,sum(priceeach * quantityordered) from orderdetails 
group by ordernumber 
having sum(priceeach * quantityordered) > 7000) as r;

## 9. List the customer names for those who their names are starting with "A"

select CustomerName from customers
where customername like 'a%';

## 10. Find the Difference between the order date and the shipped date 
select ordernumber , orderdate, shippeddate ,datediff(shippeddate,orderdate) as difference_of_date 
from orders; 

## 11. Find out the profit for each product on the basis on buy price and sell price and 
#      find the overall profit for all the inventory in stock 

select Productcode,productname, sum(profit) as profit from (
select p.productcode,productname, buyprice ,sell_price ,(sell_price - buyprice)as profit
from products as p 
right join
     (select productcode ,priceeach as sell_price from orderdetails
      ) as od on od.productcode = p.productcode) as m
      group by productcode;
      

select sum(profit) as overall_profit from       
(select p.productcode ,(quantityordered*priceeach-quantityordered*buyprice)as profit 
	      from products as p right join (select * from orderdetails
         ) as od on od.productcode = p.productcode) as r;


## 12. Find the profit for each product line and also see the inventory in stock 
select Productline , sum(profit) as Profit from 
(select productcode,productline,sum(profit)as profit from 
( select p.productcode ,p.productline ,(quantityordered*priceeach-quantityordered*buyprice)as profit 
          from products as p right join (select * from orderdetails
         ) as od on od.productcode = p.productcode) as r
group by productcode) as m group by productline ; 




## 13. Create a view that maps the customers and their payments, ignore fields that has greater than 30% null values in it .
create table customer_payment as select p.customerNumber,customername,contactlastname,contactfirstname,phone,addressline1,
 city,state,postalcode,country,salesrepemployeenumber,creditlimit,checknumber,paymentdate,amount 
 from payments as p left join customers as c on p.customernumber = c.customernumber;

SELECT 100.0 * SUM(CASE WHEN customernumber IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS customernumber_Percent,
100.0 * SUM(CASE WHEN customername IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS customername_Percent,
100.0 * SUM(CASE WHEN contactlastname IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS contactlastname_Percent,
100.0 * SUM(CASE WHEN contactfirstname IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS contactfirstname_Percent,
100.0 * SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS phone_Percent,
100.0 * SUM(CASE WHEN addressline1 IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS addressline1_Percent,
100.0 * SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS city_Percent,
100.0 * SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS state_Percent,
100.0 * SUM(CASE WHEN postalcode IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS postalcode_Percent,
100.0 * SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS country_Percent,
100.0 * SUM(CASE WHEN salesrepemployeenumber IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS salesrepemployeenumber_Percent,
100.0 * SUM(CASE WHEN creditlimit IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS creditlimit_Percent,
100.0 * SUM(CASE WHEN checknumber IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS checknumber_Percent,
100.0 * SUM(CASE WHEN paymentdate IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS paymentdate_Percent,
100.0 * SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS amount_Percent
FROM customer_payment;

### result by removing columns that has more than 30% null values 
	create view new_view as 
    select p.customerNumber,customername,contactlastname,contactfirstname,phone,addressline1,
	city,postalcode,country,salesrepemployeenumber,creditlimit,checknumber,paymentdate,amount 
	from payments as p left join customers as c on p.customernumber = c.customernumber;

select * from new_view;


## 14. Check if the overall purchase value has exceeded the credit limit set for them 

select p.customernumber,sum(amount) as purchase_value ,Customername,creditlimit ,(sum(amount)-creditlimit) as exceded_creditlimit
     from payments as p left join customers as c on p.customernumber = c.customernumber
group by customernumber ;



## 15. Find the top performing sales agent, revenue generated and total number of customers for each of them individually


select employeenumber, employeename,count(customernumber) no_of_customers ,sum(amount) revenue from (
select employeenumber, concat(firstname,lastname) as employeeName,c.customernumber,p.amount   
       from employees as e left join customers as c on e.employeenumber = c.salesRepEmployeeNumber
       left join payments as p on p.customernumber = c.customernumber) as r 
group by employeenumber
order by revenue desc
