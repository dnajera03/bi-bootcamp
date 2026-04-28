-- 1. Number every customer by their lifetime spend (highest spender = 1).
--    Show CustomerId, FirstName, LastName, total spent, and a row_number column.
SELECT c.CustomerId AS customer_id,
 c.FirstName AS first_name, 
 c.LastName AS last_name,
SUM(i.total) AS total_spent,
ROW_NUMBER() OVER (ORDER BY SUM(i.total) DESC) AS spent_rank
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;
-- 2. Rank tracks within each genre by length (longest = rank 1).
--    Show GenreId, TrackId, Track Name, Milliseconds, and the rank within that genre.
SELECT 
    g.Name AS genre_name,
    t.TrackId,
    t.Name AS track_name,
    t.Milliseconds,
    RANK() OVER (PARTITION BY g.GenreId ORDER BY t.Milliseconds DESC) AS length_rank
FROM Track t
JOIN Genre g ON t.GenreId = g.GenreId;
-- 3. For each customer, number their invoices chronologically (oldest invoice = 1).
--    Show CustomerId, InvoiceId, InvoiceDate, and an invoice_number column.
SELECT c.CustomerId AS customer_id,
i.InvoiceId AS invoice_id,
i.InvoiceDate AS invoice_date,
ROW_NUMBER() OVER (PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS invoice_number
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId;
-- 4. Show every customer's lifetime spend AND the rank of that spend among all customers.
--    Use RANK (not ROW_NUMBER) so customers tied at the same total share a rank.
SELECT c.FirstName || ' ' || c.LastName AS full_name, 
SUM(i.total) AS lifetime_spent,
RANK() OVER (ORDER BY SUM(i.total) DESC) AS rank_spent
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;
-- 5. For each artist, find their longest track. 
--    Show artist name, track name, milliseconds. (Hint: rank tracks per artist by length, then keep rank=1.)
WITH ranked_tracks AS (
    SELECT 
        art.Name AS artist_name,
        t.Name AS track_name,
        t.Milliseconds,
        ROW_NUMBER() OVER (PARTITION BY art.ArtistId ORDER BY t.Milliseconds DESC) AS length_rank
    FROM Artist art
    JOIN Album a ON art.ArtistId = a.ArtistId
    JOIN Track t ON t.AlbumId = a.AlbumId
)
SELECT artist_name, track_name, Milliseconds
FROM ranked_tracks
WHERE length_rank = 1;
-- 6. Top 3 best-selling tracks per genre.
--    Show genre name, track name, total quantity sold. 
--    (This is the proper solution to your capstone Q10.)
WITH track_sales AS (
    SELECT 
        g.Name AS genre_name,
        g.GenreId,
        t.Name AS track_name,
        SUM(il.Quantity) AS quantity_sold
    FROM Genre g
    JOIN Track t ON g.GenreId = t.GenreId
    JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY g.GenreId, t.TrackId
),
ranked AS (
    SELECT 
        genre_name,
        track_name,
        quantity_sold,
        RANK() OVER (PARTITION BY GenreId ORDER BY quantity_sold DESC) AS rank_in_genre
    FROM track_sales
)
SELECT genre_name, track_name, quantity_sold
FROM ranked
WHERE rank_in_genre <= 3
ORDER BY genre_name, rank_in_genre;
-- 7. For each invoice, show what % of that invoice's total revenue came from each line item.
--    Show InvoiceId, TrackId, line total (UnitPrice * Quantity), invoice total, and percent of invoice.
--    (Hint: SUM() OVER PARTITION BY gives you the invoice total alongside each row.)
WITH line_with_invoice_total AS (
    SELECT 
        il.InvoiceId,
        il.TrackId,
        il.UnitPrice * il.Quantity AS line_total,
        SUM(il.UnitPrice * il.Quantity) OVER (PARTITION BY il.InvoiceId) AS invoice_total
    FROM InvoiceLine il
)
SELECT 
    InvoiceId,
    TrackId,
    line_total,
    invoice_total,
    ROUND(line_total * 1.0 / invoice_total, 3) AS percent_of_invoice
FROM line_with_invoice_total
ORDER BY InvoiceId, TrackId;
-- 8. Compare each track's length to its genre's average track length.
--    Show track name, genre name, milliseconds, genre_avg_ms, and the difference.
--    (Hint: AVG() OVER PARTITION BY genre.)
WITH track_length AS (
    SELECT 
        t.Name AS track_name,
        g.Name AS genre_name,
        t.Milliseconds,
        AVG(t.Milliseconds) OVER (PARTITION BY g.GenreId) AS genre_avg_ms
    FROM Track t
    JOIN Genre g ON t.GenreId = g.GenreId
)
SELECT 
    track_name,
    genre_name,
    Milliseconds,
    ROUND(genre_avg_ms) AS genre_avg_ms,
    ROUND(Milliseconds - genre_avg_ms) AS diff_from_genre_avg
FROM track_length
ORDER BY diff_from_genre_avg DESC;