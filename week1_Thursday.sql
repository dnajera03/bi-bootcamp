-- 1. Show each customer's full name (FirstName + LastName combined into one column), along with their Country. Use concatenation.
SELECT c.FirstName || ' ' || c.LastName AS full_name, c.Country
FROM Customer c;
-- 2. Show each employee's full name in all uppercase, along with the total length (character count) of their full name.
SELECT UPPER(e.FirstName || ' ' || e.LastName) AS full_name_upper, LENGTH(e.FirstName || ' ' || e.LastName) AS name_length
FROM Employee e;
-- 3. Show all tracks along with their length in seconds (not milliseconds) — rounded to the nearest whole second.
SELECT t.Name AS track_name, ROUND(t.Milliseconds/1000.0) AS track_length
FROM Track t;
-- 4. Show all invoices from the year 2010. Include InvoiceId, InvoiceDate, and Total.
SELECT i.InvoiceId AS invoice_id, i.InvoiceDate AS invoice_date, i.total AS invoice_total
FROM Invoice i
WHERE i.InvoiceDate >= '2022-01-01'
AND i.InvoiceDate < '2023-01-01';
-- 5. Show monthly revenue: for each year-month combination, show the total revenue. Sort chronologically.
SELECT strftime('%Y-%m', i.InvoiceDate) AS year_month, SUM(i.Total) AS monthly_revenue
FROM Invoice i 
GROUP BY year_month
ORDER BY year_month;
-- 6. For each customer, show their FirstName, LastName, and a "tier" based on their total lifetime spend:
--    - "High Value" if total > $40
--    - "Medium Value" if total between $30 and $40
--    - "Low Value" if total < $30
--    Sort by total spend descending.
SELECT c.FirstName AS first_name, c.LastName AS last_name, SUM(i.total) AS total_spent,
CASE WHEN SUM(i.total) > 40 THEN 'High Value'
WHEN SUM(i.total) >= 30 THEN 'Medium Value'
ELSE  'Low Value' END AS tier
FROM Customer c
JOIN Invoice i
ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId
ORDER BY total_spent DESC;
-- 7. Show the count of customers in each tier from query 6. (Think: how do you count things that match a condition?)
SELECT 
    tier,
    COUNT(*) AS customer_count
FROM (

    SELECT 
        c.CustomerId,
        CASE 
            WHEN SUM(i.Total) > 40 THEN 'High Value'
            WHEN SUM(i.Total) >= 30 THEN 'Medium Value'
            ELSE 'Low Value' 
        END AS tier
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
)
GROUP BY tier;

-- 8. For each invoice, show the InvoiceId, the total, and a flag:
--    - "Weekend" if the invoice was on a Saturday or Sunday
--    - "Weekday" otherwise
--    Hint: in SQLite, strftime('%w', date) returns 0 for Sunday through 6 for Saturday.
SELECT i.InvoiceId AS invoice_id, i.total AS invoice_total, 
CASE WHEN strftime('%w', i.InvoiceDate) IN  ('0', '6') THEN 'Weekend'
ELSE 'Weekday' 
END AS flag
From Invoice i;