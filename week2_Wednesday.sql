-- 1. Find customers whose total lifetime spend is above the average customer's lifetime spend.
--    Show CustomerId, FirstName, LastName, total_spent.
--    Use a subquery in the HAVING clause for the average.
SELECT c.CustomerId AS customer_id,
c.FirstName AS first_name,
c.LastName AS last_name, 
SUM(i.total) AS total_spent 
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
HAVING SUM(i.total) > (
SELECT AVG(customer_total)
FROM (
	SELECT SUM(TOTAL) AS customer_total
	FROM Invoice i
	GROUP BY CustomerId
	)
	)
ORDER BY total_spent DESC;
-- 2. Find tracks that are longer than the average track in their genre.
--    Show track name, genre name, milliseconds, and the genre's average length.
--    Use a correlated subquery in the WHERE clause (the inner query references the outer).
SELECT t.Name AS track_name,
g.Name AS genre_name,
t.Milliseconds,
AVG(t.milliseconds) OVER (PARTITION BY t.Genreid) AS genre_avg_length
FROM Track t 
JOIN Genre g 
ON t.GenreId = g.GenreId
WHERE t.Milliseconds > (
SELECT AVG(t2.Milliseconds)
FROM Track t2
WHERE t2.GenreId = t.GenreId
)
ORDER BY t.GenreId, t.Milliseconds DESC;
-- 3. Show all customers who have NEVER purchased a track from the "Rock" genre.
--    Show CustomerId, FirstName, LastName.
--    Use NOT EXISTS (preferred) or NOT IN (with the NULL gotcha — note which you used).
SELECT c.CustomerId,
c.FirstName,
c.LastName
FROM Customer c
WHERE NOT EXISTS ( 
SELECT 1
FROM Invoice i
JOIN InvoiceLine il
ON il.InvoiceId = i.InvoiceId
JOIN Track t 
ON il.TrackId = t.TrackId
JOIN Genre g
ON g.GenreId = t.GenreId
WHERE  g.Name = 'Rock'
AND i.CustomerId = c.CustomerId);
-- 4. Combine two lists into one: top 5 customers by lifetime spend AND bottom 5 customers by lifetime spend.
--    Show FirstName, LastName, total_spent, and a 'segment' column labeled either 'TOP_5' or 'BOTTOM_5'.
--    Use UNION ALL.
SELECT * FROM (
SELECT c.FirstName,
c.LastName,
SUM(i.total) AS total_spent,
'Top_5' AS segment
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY total_spent DESC
LIMIT 5
)
UNION ALL
SELECT * FROM (
SELECT c.FirstName,
c.LastName,
SUM(i.total) AS total_spent,
'Bottom_5' AS segment
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY total_spent
LIMIT 5);
-- 5. Find genres that exist in BOTH the Rock playlist AND the Heavy Metal Classic playlist.
--    Show genre names. Use INTERSECT.
--    Hint: write two SELECT statements (one per playlist) and INTERSECT them.
SELECT g.Name
FROM Playlist p
JOIN PlaylistTrack pt
ON p.PlaylistId = pt.PlaylistId
JOIN Track t
ON t.TrackId = pt.TrackId
JOIN Genre g 
ON g.GenreId = t.GenreId
WHERE p.Name = ''

INTERSECT

SELECT g.Name
FROM Playlist p
JOIN PlaylistTrack pt
ON p.PlaylistId = pt.PlaylistId
JOIN Track t
ON t.TrackId = pt.TrackId
JOIN Genre g 
ON g.GenreId = t.GenreId
WHERE p.Name = 'Heavy Metal Classic';
-- 6. Rewrite this CTE-based query using only subqueries (no WITH clause):
--    "For each country, show its total revenue and how that compares to the overall average revenue per country."
--    Try to write it using FROM-clause subqueries to feel the difference vs. CTEs.
SELECT country,
total_revenue,
(SELECT  AVG(total_revenue) FROM (
SELECT SUM(total) AS total_revenue 
FROM Invoice 
GROUP BY BillingCountry
)) AS overall_avg_per_country,
total_revenue - (SELECT AVG(total_revenue) FROM (
SELECT SUM(Total) AS total_revenue
FROM Invoice 
GROUP BY BillingCountry
)) AS diff_from_avg
FROM (
SELECT BillingCountry AS country,
SUM(total) AS total_revenue
FROM Invoice 
GROUP BY BillingCountry
) country_totals
ORDER BY total_revenue DESC;