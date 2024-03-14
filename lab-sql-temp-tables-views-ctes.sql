use sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

create view rental_summary_per_customer as 
select customer_id, last_name, email, count(1) as total_rentals -- total number of rentals 
from customer
inner join	payment
    using (customer_id)
group by customer_id, last_name, email;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_payment_summary (
select customer_id, last_name, sum(amount) as total_paid 
from customer
inner join	payment
    using (customer_id)
group by customer_id, last_name); --  customer_id, 

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

CREATE TEMPORARY TABLE customer_summary_report (
select customer_id, rental_summary_per_customer.last_name, email, total_rentals, total_paid from total_payment_summary
full join rental_summary_per_customer
using (customer_id));

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

with cte_customer_summary as (
 select  customer_id
 , last_name
 , email
 ,total_rentals
 , total_paid 
 , round(avg(total_paid/total_rentals), 2) as average_payment_per_rental
 from customer_summary_report
 group by customer_id
 , last_name
 , email
 ,total_rentals
 , total_paid 
 )
 select * from cte_customer_summary ;