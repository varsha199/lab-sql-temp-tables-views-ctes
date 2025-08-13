-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
DROP VIEW IF EXISTS rental_info;

CREATE VIEW rental_info AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, a.address, COUNT(r.rental_id) AS rental_count
FROM rental AS r
JOIN customer AS c ON c.customer_id = r.customer_id
JOIN address AS a ON c.address_id = a.address_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, a.address;

SELECT * FROM rental_info;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_paid AS
SELECT ri.customer_id, ri.first_name, ri.last_name, ri.email, ri.address, ri.rental_count, SUM(p.amount) AS total_paid
FROM rental_info AS ri
JOIN rental AS r ON r.customer_id = ri.customer_id
JOIN payment AS p on p.rental_id = r.rental_id
GROUP BY ri.customer_id, ri.first_name, ri.last_name, ri.email, ri.address, ri.rental_count;

SELECT * FROM total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.
WITH customer_summary_report AS (
SELECT ri.customer_id, ri.first_name, ri.last_name, ri.email, ri.address, ri.rental_count, SUM(p.amount) AS total_paid
FROM rental_info AS ri
JOIN rental AS r ON r.customer_id = ri.customer_id
JOIN payment AS p on p.rental_id = r.rental_id
GROUP BY ri.customer_id, ri.first_name, ri.last_name, ri.email, ri.address, ri.rental_count)
SELECT 
    first_name, 
    last_name, 
    email, 
    rental_count, 
    total_paid, 
    total_paid / rental_count AS average_payment_per_rental
FROM customer_summary_report;
