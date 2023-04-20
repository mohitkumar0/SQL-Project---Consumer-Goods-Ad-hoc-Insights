# CODEBASICS_SQL_PROJECT_CHALLENGE 
---------------------------------------------------------------------------------------------------------
I create Master table for all ther Query 
-------------------------------------------
CREATE VIEW `master_left_join` AS
    SELECT 
        `f`.`date` AS `date`,
        `f`.`product_code` AS `product_code`,
        `f`.`customer_code` AS `customer_code`,
        `f`.`sold_quantity` AS `sold_quantity`,
        `f`.`fiscal_year` AS `fiscal_year`,
        `d`.`customer` AS `customer`,
        `d`.`platform` AS `platform`,
        `d`.`channel` AS `channel`,
        `d`.`sub_zone` AS `sub_zone`,
        `d`.`region` AS `region`,
        `d`.`market` AS `market`,
        `p`.`division` AS `division`,
        `p`.`segment` AS `segment`,
        `p`.`category` AS `category`,
        `p`.`product` AS `product`,
        `p`.`variant` AS `variant`,
        `g`.`gross_price` AS `gross_price`,
        `m`.`manufacturing_cost` AS `manufacturing_cost`,
        `i`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct`
    FROM
        (((((`gdb023`.`fact_sales_monthly` `f`
        LEFT JOIN `gdb023`.`dim_customer` `d` ON ((`f`.`customer_code` = `d`.`customer_code`)))
        LEFT JOIN `gdb023`.`dim_product` `p` ON ((`f`.`product_code` = `p`.`product_code`)))
        LEFT JOIN `gdb023`.`fact_gross_price` `g` ON (((`f`.`product_code` = `g`.`product_code`)
            AND (`f`.`fiscal_year` = `g`.`fiscal_year`))))
        LEFT JOIN `gdb023`.`fact_manufacturing_cost` `m` ON (((`f`.`product_code` = `m`.`product_code`)
            AND (`f`.`fiscal_year` = `m`.`cost_year`))))
        LEFT JOIN `gdb023`.`fact_pre_invoice_deductions` `i` ON (((`f`.`customer_code` = `i`.`customer_code`)
            AND (`f`.`fiscal_year` = `i`.`fiscal_year`))))
------------------------------------------------------------------------------------------------------------------------           

Q1 Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.

Answer
select market 
from master_left_join
where customer = 'Atliq Exclusive' and  region = 'APAC'
group by market;
.................................--------------------------.-----------------------------

Q2 =What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, unique_products_2020 unique_products_2021 percentage_chg

Anwers
with uni2020 
 as 
(select count(distinct((product_code))) as unique_products_2020 
from master_left_join 
where fiscal_year = 2020 )
,
uni2021 as 
(select count(distinct((product_code))) as unique_products_2021 
from master_left_join
 where fiscal_year = 2021 )

select unique_products_2020 , unique_products_2021 ,

round(((unique_products_2021 - unique_products_2020 ) /unique_products_2020*100),2) as percentage_chg
from uni2020 ,uni2021;

.-.-.-.-.-.-.--.-.-.-.-.--..--.-.-.--.-.-.-.-.--.-.-.-.-.-.-.-.-.-.-.-.--.-.-.--.-.-.-.-.-.-.-.-.-.--.-.--.-.-..--..--
Q3 . Provide a report with all the unique product counts for each segment and
 sort them in descending order of product counts. The final output contains ,fields,segment, product_count

Answer

select segment ,count(distinct(product_code)) as product_count 
from master_left_join
group by segment
order by product_count desc ;
.......................................................................................
q5 :> Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference

answers 4

WITH pre AS (
    SELECT segment, COUNT(DISTINCT product_code) AS product_count_2020
    FROM master_left_join
    WHERE fiscal_year = 2020
    GROUP BY segment
),
p AS (
    SELECT m.segment, p.product_count_2020, COUNT(DISTINCT m.product_code) AS product_count_2021
    FROM master_left_join m
    JOIN pre p ON m.segment = p.segment
    WHERE fiscal_year = 2021
    GROUP BY m.segment, p.product_count_2020
)
SELECT p.segment, p.product_count_2020, p.product_count_2021, p.product_count_2021 - p.product_count_2020 AS difference
FROM p
ORDER BY difference DESC;

----------------------------------------------------------------------------------------------------------------------------------
q5 
 Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields, product_code,product,manufacturing_cost

Answer

 select  distinct product_code ,(product) ,manufacturing_cost   
 from master_left_join
 where manufacturing_cost = (select max(manufacturing_cost)  from master_left_join)
  or  manufacturing_cost = (select min(manufacturing_cost)  from master_left_join)
----------------------------------------------------------------------------------------

q6   Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the  Indian market. 
The final output contains these fields,customer_code,customer,average_discount_percentage

Answer :-
 select customer_code , customer ,avg(pre_invoice_discount_pct)  as 'average_discount_percentage' 
from master_left_join 
where market  = 'india' and fiscal_year = 2021
group by 1,2
having average_discount_percentage > 0.23336274 # avg discount 
order by average_discount_percentage desc  limit 5 ;
............................................................................................................................

q7  Get the complete report of the Gross sales amount for the customer “Atliq
-- Exclusive” for each month. This analysis helps to get an idea of low and
-- high-performing months and take strategic decisions.
-- The final report contains these columns:
-- Month
-- Year
-- Gross sales Amount

answer
select month(date) as 'Month', fiscal_year as 'Year',  sum(sold_quantity*gross_price) as 'gross_sale_amount' 
from master_left_join 
where customer = 'Atliq Exclusive'
group by 1,2
order by 1 ,2;

................................................................................................................................

q8 . In which quarter of 2020, got the maximum total_sold_quantity? The final
-- output contains these fields sorted by the total_sold_quantity,
-- Quarter
-- total_sold_quantity

Answer:- 

with df as(
select date,month(date_add(date,interval 4 month))  as `months` , (sold_quantity), fiscal_year 
from master_left_join)
select case
    when months /3<= 1 then 'Q1'
    when months/3 <=2 and months /3 >1 then 'Q2'
    when months /3 <=3 and months / 3 > 2 then 'Q3'
    when months /3 <= 4 and months / 3 > 3 then 'Q4'
    end Quarters ,
    sum(sold_quantity)  as 'total_sold_quantity' from df 
    where fiscal_year =2020
    group by Quarters
    order  by total_sold_quantity desc

...............................................................................................................................
q9
 -- Which channel helped to bring more gross sales in the fiscal year 2021
-- and the percentage of contribution? The final output contains these fields,
-- channel
-- gross_sales_mln
-- percentage 
 
Answer

with per as
 (
select `channel`, manufacturing_cost ,sold_quantity ,
sum(sold_quantity*manufacturing_cost) as 'gross_sale_amount' 
from master_left_join
where fiscal_year = 2021
group by `channel`) ,

divs
as ( select  sum(sold_quantity*manufacturing_cost) as 'total_sale' from master_left_join
 where fiscal_year = 2021 ) 
 
select  channel , gross_sale_amount ,(gross_sale_amount/ total_sale )*100 as 'percentage'
 from per , divs
order by percentage desc ;

-------------------------------------------------------------------------------------------------------------------------
q.10 
--  Get the Top 3 products in each division that have a high
-- total_sold_quantity in the fiscal_year 2021? The final output contains these
-- fields,
-- division
-- product_code
-- product
-- total_sold_quantity
-- rank_order

select  division, product_code ,product,  total_sold_quantity, rank_order   from
 (
select * ,sum(sold_quantity) as total_sold_quantity ,
dense_rank() over( partition by division order by sum(sold_quantity) desc)  as rank_order
from  master_left_join
where fiscal_year = 2021
group by product_code ) t


where rank_order in(1,2,3)
