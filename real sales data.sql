-- Querying this Database Using SQL to answer 17 Questions which is divivded into 3 sections.
-- Basic SQL
-- SQL JOINS
-- Advanced SQL

USE `s1-sales-database`;

-- Basic SQL
-- Question 1: How many Customers do not have dob information Available?

SELECT 
    COUNT(*) AS CustomerWithoutDOB
FROM
    customer
WHERE
    dob IS NULL OR dob = '';

-- Question 2: How many customers are there in each pincode and gender combination?

SELECT 
    primary_pincode, gender, COUNT(*) AS NumberOfCustomer
FROM
    customer
GROUP BY primary_pincode , gender;

-- Question 3: Print product name and mrp for products which have more than 50000 MRP?

SELECT 
    product_name, mrp
FROM
    products
WHERE
    mrp > 50000;

-- Question 4: How many delivery personal are there in each pincode?

SELECT 
    delivery_pincode, COUNT(*) AS NUmberOfdeliveryperson
FROM
    orders
GROUP BY delivery_pincode;

/*
Question 5: For each Pin code, print the count of orders, sum of total amount paid, average amount
paid, maximum amount paid, minimum amount paid for the transactions which were
paid by 'cash'. Take only 'buy' order types
*/

SELECT 
    delivery_pincode,
    COUNT(*) AS Ordercount,
    SUM(total_amount_paid) AS TotalAmountPaid,
    AVG(total_amount_paid) AS AverageAmountPaid,
    MAX(total_amount_paid) AS MaximumAmountPaid,
    MIN(total_amount_paid) AS MinimumAmountPaid
FROM
    orders
WHERE
    payment_type = 'cash'
        AND order_type = 'buy'
GROUP BY delivery_pincode;

/*
Question 6: For each delivery_person_id, print the count of orders and total amount paid for
product_id = 12350 or 12348 and total units > 8. Sort the output by total amount paid in
descending order. Take only 'buy' order types
*/

SELECT 
    delivery_person_id,
    COUNT(*) AS order_id,
    SUM(total_amount_paid) AS TotalAmountPaid
FROM
    orders
WHERE
    order_type = 'buy'
        AND (product_id = 12350 OR product_id = 12348)
        AND tot_units > 8
GROUP BY delivery_person_id;

/*
 Question 7:  Print the Full names (first name plus last name) for customers that have email on 
"gmail.com
*/

SELECT 
    CONCAT(first_name, ' ', last_name) AS Full_name
FROM
    customer
WHERE
    email LIKE '%@gmail.com%';

/*
Question 8: Which pincode has average amount paid more than 150,000? Take only 'buy' order 
types
*/

SELECT 
    delivery_pincode,
    AVG(total_amount_paid) AS average_amount_paid
FROM
    orders
WHERE
    order_type = 'Buy'
GROUP BY delivery_pincode
HAVING average_amount_paid > 150000;

/*
Question 9: Create following columns from order_dim data -
 order_date
 Order day
 Order month
 Order year 
 */
 SELECT 
    order_date,
    DATE(STR_TO_DATE(order_date, '%m-%d-%Y')) AS valid_date,
    MONTH(STR_TO_DATE(order_date, '%m-%d-%y')) AS order_month,
    DAY(STR_TO_DATE(order_date, '%m-%d-%y')) AS order_day,
    YEAR(STR_TO_DATE(order_date, '%m-%d-%y')) AS order_year
FROM
    orders
WHERE
    STR_TO_DATE(order_date, '%m-%d-%y') IS NOT NULL;
 
/*
Question 10: How many total orders were there in each month and how many of them were 
returned? Add a column for return rate too.
return rate = (100.0 * total return orders) / total buy orders
Hint: You will need to combine SUM() with CASE WHEN
*/

SELECT 
    MONTH(STR_TO_DATE(order_date, '%m-%d-%y')) AS order_month,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN order_type = 'returned' THEN 1
        ELSE 0
    END) AS returned_orders,
    (100.0 * SUM(CASE
        WHEN order_type = 'returned' THEN 1
        ELSE 0
    END)) / COUNT(*) AS returned_rate
FROM
    orders
WHERE
    MONTH(STR_TO_DATE(order_date, '%m-%d-%y')) IS NOT NULL
GROUP BY order_month
ORDER BY order_month;



-- SQL joins
/*
Question 11: How many units have been sold by each brand? Also get total returned units for each 
brand.
*/

SELECT 
    p.product_id,
    p.brand,
    SUM(o.tot_units) AS total_unit_sold,
    SUM(CASE
        WHEN o.order_type = 'returned' THEN 1
        ELSE 0
    END) AS total_returned_units
FROM
    products p
        JOIN
    orders o ON p.product_id = o.product_id
GROUP BY p.product_id , p.brand
ORDER BY p.brand;

-- Question 12: How many distinct customers and delivery boys are there in each state?

SELECT 
    i.pincode,
    i.state,
    COUNT(DISTINCT c.cust_id) AS distinct_customer,
    COUNT(DISTINCT d.delivery_person_id) AS distinct_delivery_boys
FROM
    pincode i
        JOIN
    customer c ON i.pincode = c.primary_pincode
        JOIN
    delivery_person d ON c.primary_pincode = d.pincode
GROUP BY i.pincode , i.state
ORDER BY i.state;

/*
Question 13: For every customer, print how many total units were ordered, how many units were 
ordered from their primary_pincode and how many were ordered not from the 
primary_pincode. Also calulate the percentage of total units which were ordered from 
primary_pincode(remember to multiply the numerator by 100.0). Sort by the 
percentage column in descending order.
*/

SELECT 
    o.cust_id,
    SUM(o.tot_units) AS total_unit_ordered,
    SUM(CASE
        WHEN o.delivery_pincode = c.primary_pincode THEN 1
        ELSE 0
    END) AS units_ordered_from_pincode,
    SUM(CASE
        WHEN o.delivery_pincode <> c.primary_pincode THEN 1
        ELSE 0
    END) AS units_ordered_not_from_pincode,
    (100.0 * SUM(CASE
        WHEN o.delivery_pincode = c.primary_pincode THEN 1
        ELSE 0
    END)) / SUM(tot_units) AS percentage_from_pincode
FROM
    orders o
        JOIN
    customer c ON o.cust_id = c.cust_id
GROUP BY o.cust_id
ORDER BY percentage_from_pincode DESC;

/*
Question 14: For each product name, print the sum of number of units, total amount paid, total 
displayed selling price, total mrp of these units, and finally the net discount from selling 
price.
(i.e. 100.0 - 100.0 * total amount paid / total displayed selling price) &
the net discount from mrp (i.e. 100.0 - 100.0 * total amount paid / total mrp)
*/

SELECT 
    p.product_id,
    p.product_name,
    SUM(o.tot_units) AS total_units,
    SUM(o.total_amount_paid) AS total_amount_paid,
    SUM(o.displayed_selling_price_per_unit) AS total_displayed_selling_price,
    SUM(p.mrp) AS total_mrp,
    100.0 - 100.0 * SUM(o.total_amount_paid) / SUM(o.displayed_selling_price_per_unit * o.tot_units) AS net_discount_from_selling_price,
    100.0 - 100.0 * SUM(o.total_amount_paid) / SUM(p.mrp * o.tot_units) AS net_discount_from_mrp
FROM
    products p
        JOIN
    orders o ON p.product_id = o.product_id
GROUP BY p.product_name , p.product_id
ORDER BY product_name;


-- Advanced SQL

/*
Question 15: For every order_id (exclude returns), get the product name and calculate the discount 
percentage from selling price. Sort by highest discount and print only those rows where 
discount percentage was above 10.10%
*/

SELECT 
    o.order_id,
    p.product_name,
    ((p.mrp - o.displayed_selling_price_per_unit) / p.mrp) * 100 AS discount_percentage
FROM
    orders o
        JOIN
    products p ON o.product_id = p.product_id
WHERE
    o.order_type <> 'returned'
        AND ((p.mrp - o.displayed_selling_price_per_unit) / p.mrp) * 100 > 10.10
ORDER BY discount_percentage DESC;

/*
Question 16: Using the per unit procurement cost in product_dim, find which product category has 
made the most profit in both absolute amount and percentage
Absolute Profit = Total Amt Sold - Total Procurement Cost
Percentage Profit = 100.0 * Total Amt Sold / Total Procurement Cost - 100.0 
*/

SELECT 
    P.category,
    SUM(o.total_amount_paid) - SUM(p.procurement_cost_per_unit) AS Absolute_profit,
    100.0 * SUM(o.total_amount_paid) / SUM(p.procurement_cost_per_unit) - 100.0 AS percentage_profit
FROM
    products p
        JOIN
    orders o ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY Absolute_profit DESC;





