--Exercise 1
WITH customer_tiers AS (

SELECT 
        c.CustomerId,
        CASE 
            WHEN SUM(i.Total) > 40 THEN 'High Value'
            WHEN SUM(i.Total) >= 30 THEN 'Medium Value'
            ELSE 'Low Value' 
        END AS tier
		FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId)
SELECT tier, COUNT(*) AS customer_count
FROM customer_tiers
GROUP BY tier;
--Exercise 2
WITH customer_totals AS(
SELECT
c.Customerid, c.FirstName AS first_name, c.LastName AS last_name, SUM(i.total)  AS lifetime_spendings
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
)
SELECT customerid, first_name, last_name, lifetime_spendings,
lifetime_spendings - (SELECT AVG(lifetime_spendings) FROM customer_totals) AS diff_from_avg
FROM customer_totals
ORDER BY diff_from_avg DESC;
--Exercise 3
WITH 
monthly_revenue AS (
    SELECT 
        strftime('%Y-%m', InvoiceDate) AS year_month,
        SUM(Total) AS revenue
    FROM Invoice
    GROUP BY year_month
),
monthly_with_tier AS (
    SELECT 
        year_month,
        revenue,
        CASE 
            WHEN revenue > 50 THEN 'Strong'
            WHEN revenue >= 30 THEN 'Normal'
            ELSE 'Weak'
        END AS tier
    FROM monthly_revenue
)
SELECT tier, COUNT(*) AS month_count
FROM monthly_with_tier
GROUP BY tier;