-- ============================================================
-- Week 1 Capstone: 15 Analytical Queries on Chinook Database
-- ============================================================
-- 1. Top 10 best-selling tracks of all time (by quantity sold).
--    Show track name, artist name, and total quantity sold.
SELECT t.Name AS track_name, art.Name AS artist_name, SUM(il.Quantity) AS total_quantity_sold
FROM Track t
JOIN Album a
ON t.AlbumId = a.AlbumId
JOIN Artist art
ON art.ArtistId = a.ArtistId
JOIN InvoiceLine il
ON il.TrackId = t.TrackId
GROUP BY t.TrackId, t.Name, art.Name
ORDER BY SUM(il.Quantity) DESC
LIMIT 10;
-- 2. Top 5 customers by lifetime revenue.
--    Show first name, last name, country, and total spent.
SELECT c.FirstName, c.LastName, c.Country, SUM(i.total) AS total_spent
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY SUM(i.total) DESC
LIMIT 5;
-- 3. Monthly revenue for the last 2 years of data.
--    Show year-month and total revenue, sorted chronologically.
SELECT strftime('%Y-%m', i.InvoiceDate) AS year_month, SUM(i.total) AS total_revenue 
FROM Invoice i 
WHERE i.InvoiceDate >= '2024-01-01'
GROUP BY year_month
ORDER BY year_month;
-- 4. Revenue by country, with a rank column.
--    Show country, total revenue, and rank (1 = highest revenue).
--    Hint: you can ORDER BY and use ROW_NUMBER() — or simpler, just ORDER BY 
--    and let the user see the rank by row order. Use row order for now.
SELECT 
    BillingCountry AS country,
    SUM(Total) AS total_revenue, 
	row_number() OVER (ORDER BY SUM(Total) DESC) AS rank
FROM Invoice
GROUP BY BillingCountry
ORDER BY rank;
-- 5. Customers who haven't purchased in the last 12 months.
--    Show first name, last name, country, and date of their last purchase.
--    Use the max invoice date in the database as "today."
WITH customer_last_purchease AS(
SELECT c.CustomerId, c.FirstName,c.LastName,c.Country,MAX(i.InvoiceDate) AS last_purchease
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId)
SELECT *
FROM customer_last_purchease 
WHERE last_purchease < date(
(SELECT MAX(InvoiceDate) FROM Invoice),
'-12 months'
);
-- 6. Employees ranked by the total revenue of customers they support.
--    Show employee full name, count of customers supported, and their total revenue.
SELECT e.FirstName|| ' ' || e.LastName AS full_name,  COUNT(c.SupportRepId) AS total_customers_supported, ROUND(SUM(i.total) ,2) AS total_revenue 
FROM Employee e
JOIN Customer c
ON c.SupportRepId = e.EmployeeId
JOIN Invoice i 
ON i.CustomerId = c.CustomerId
GROUP BY e.FirstName, e.LastName
ORDER BY SUM(i.total) DESC;

-- 7. Average invoice amount per country, compared to the overall average.
--    Show country, country_avg, overall_avg, and the difference.
--    Use a scalar subquery or CTE for the overall average.
WITH Country_Average AS (
SELECT i.BillingCountry AS Country, ROUND(AVG(i.Total),2) AS country_average
FROM Invoice i
GROUP BY i.BillingCountry)
SELECT ca.Country, ca.country_average, (SELECT ROUND (AVG(Total),2) FROM Invoice) AS overall_average,
ROUND(
ca.country_average - (SELECT AVG(Total) FROM Invoice),
2
) AS diff_from_average
FROM Country_Average ca
ORDER BY diff_from_average DESC;
-- 8. Genres whose average track length exceeds the database-wide average track length.
--    Show genre name, avg track length in that genre, and the DB-wide avg for reference.
WITH Genre_Average AS (
SELECT g.Name AS genre_name, ROUND(AVG(t.milliseconds),2) AS average_track_length 
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
GROUP BY g.Name)
SELECT 
ga.genre_name, ga.average_track_length,
(SELECT ROUND(AVG(Milliseconds),2) FROM Track t) AS overall_track_length
FROM Genre_Average AS ga 
WHERE ga.average_track_length > (SELECT AVG(Milliseconds) FROM Track)
ORDER BY ga.average_track_length DESC;
-- 9. Month-over-month revenue growth (percentage).
--    Show year-month, revenue, and % change vs. the prior month.
--    Hint: you don't know LAG yet. Use a self-join or CTE comparing two copies of monthly revenue.
WITH month_by_month AS(
SELECT strftime('%Y-%m', i.InvoiceDate) AS year_month, SUM(i.total) AS revenue
FROM Invoice i 
GROUP BY year_month)
SELECT mm.year_month, mm.revenue,
ROUND((mm.revenue - prev.revenue) * 100.0 / prev.revenue, 2
) AS percent_change 
FROM month_by_month mm 
LEFT JOIN month_by_month prev 
ON prev.year_month = strftime('%Y-%m', date(mm.year_month || '-01', '+1 month')
)
ORDER BY mm.year_month;
-- 10. Top 3 genres in each country by sales revenue.
--     Show country, genre name, revenue. 
--     Note: doing "top N per group" cleanly requires window functions (week 2).
--     For now, just show revenue per country and genre — sorted by country, then revenue desc.
SELECT c.Country AS Country, g.Name as genre_name, SUM(il.UnitPrice * il.Quantity) AS sales_revenue
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il
ON il.InvoiceId = i.InvoiceId
JOIN Track t 
ON il.TrackId = t.TrackId
JOIN Genre g
ON t.GenreId = g.GenreId
GROUP BY c.Country, g.Name
ORDER BY c.Country, sales_revenue DESC;
-- 11. Customer segmentation: label each as High/Medium/Low value.
--     Show first name, last name, total spent, tier.
--     Use your Thursday thresholds (>$40 high, >=$30 medium, else low).
SELECT c.FirstName AS first_name, c.LastName AS last_name, SUM(i.total) AS total_spent,
CASE 
WHEN SUM(i.total) > 40 THEN 'high'
WHEN SUM(i.total) >= 30 THEN 'medium'
ELSE 'low'  END AS tier 
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;
-- 12. First and most recent purchase date for each customer.
--     Show first name, last name, first_purchase, last_purchase, days_as_customer.
SELECT c.FirstName AS first_name, c.LastName AS last_name, MIN(i.InvoiceDate) AS first_purchease, MAX(i.invoiceDate) AS last_purchease, MAX(i.InvoiceDate) - MIN(i.InvoiceDate) AS days_as_customer
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;
-- 13. Artists whose tracks appear in more than 5 different playlists.
--     Show artist name and the distinct count of playlists their tracks appear in.
SELECT art.Name AS artist_name, COUNT(DISTINCT pt.PlaylistId) AS different_playlists 
FROM Artist art
JOIN ALBUM a
ON a.ArtistId = art.ArtistId
JOIN Track t
ON t.AlbumId = a.AlbumId
JOIN PlaylistTrack pt
ON pt.TrackId = t.TrackId
GROUP BY art.Name;
-- 14. Revenue by customer in the year following their first purchase.
--     Show customer name, first_purchase_date, and revenue in the 12 months after that.
--     Hint: use a CTE to compute first_purchase per customer, join back to invoices,
--     filter to invoices within 365 days.
WITH first_purchase AS (
    SELECT 
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS full_name,
        MIN(i.InvoiceDate) AS first_purchase_date
    FROM Customer c
    JOIN Invoice i 
        ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
)

SELECT 
    fp.full_name,
    fp.first_purchase_date,
    SUM(i.Total) AS revenue_first_12_months
FROM first_purchase fp
JOIN Invoice i 
    ON fp.CustomerId = i.CustomerId
WHERE julianday(i.InvoiceDate) - julianday(fp.first_purchase_date) <= 365
GROUP BY fp.CustomerId, fp.full_name, fp.first_purchase_date
ORDER BY revenue_first_12_months DESC;
-- 15. Churn risk report: customers whose last purchase was > 6 months ago 
--     AND whose total lifetime spend is > $40.
--     Show first name, last name, country, last_purchase, total_spent.
SELECT 
    c.FirstName AS first_name,
    c.LastName AS last_name,
    c.Country,
    MAX(i.InvoiceDate) AS last_purchase,
    SUM(i.Total) AS total_spent
FROM Customer c
JOIN Invoice i 
    ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
HAVING 
    SUM(i.Total) > 40
    AND julianday('now') - julianday(MAX(i.InvoiceDate)) > 180;