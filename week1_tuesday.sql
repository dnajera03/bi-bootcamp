<?xml version="1.0" encoding="UTF-8"?><sqlb_project><db path="/Users/danielnajera/Downloads/Chinook_Sqlite.sqlite" readonly="0" foreign_keys="1" case_sensitive_like="0" temp_store="0" wal_autocheckpoint="1000" synchronous="2"/><attached/><window><main_tabs open="structure browser pragmas query" current="3"/></window><tab_structure><column_width id="0" width="300"/><column_width id="1" width="0"/><column_width id="2" width="100"/><column_width id="3" width="3332"/><column_width id="4" width="0"/><expanded_item id="0" parent="1"/><expanded_item id="1" parent="1"/><expanded_item id="2" parent="1"/><expanded_item id="3" parent="1"/></tab_structure><tab_browse><current_table name="4,5:mainAlbum"/><default_encoding codec=""/><browse_table_settings/></tab_browse><tab_sql><sql name="SQL 1">-- 1. How many customers are in each country? Sort by count descending.
SELECT  Country, count(CustomerId) AS Customer_Count
FROM Customer
GROUP BY Country
ORDER BY Customer_Count DESC;
-- 2. What is the total revenue (sum of invoice totals) across all invoices?
SELECT SUM(Total) AS sum_invoice
FROM Invoice;
-- 3. What is the average invoice total, rounded to 2 decimal places?
SELECT ROUND(AVG(TOTAL) , 2) AS average_invoice
FROM Invoice;
-- 4. How many tracks are in each genre? Show GenreId and the count, sorted by count descending.
SELECT Genreid, count(TrackId) AS tracks_genre 
FROM Track
GROUP BY GenreId
ORDER BY tracks_genre DESC;
-- 5. What is the shortest and longest track (in milliseconds) in each genre?
SELECT GenreId, MIN(milliseconds) AS shortest_track, MAX(milliseconds) AS longest_track
FROM Track
GROUP BY GenreId;
-- 6. Which countries have more than 4 customers? Show country and count.
SELECT Country, COUNT(CustomerId) AS more_than_4
From Customer
GROUP BY Country
HAVING more_than_4 &gt; 4;
-- 7. What is the total revenue per country? Show country and total, sorted by total descending, but only include countries with total revenue over $40.
SELECT BillingCountry, SUM(Total) AS total_revenue_per_country
FROM Invoice
GROUP BY BillingCountry
HAVING total_revenue_per_country &gt; 40
ORDER BY total_revenue_per_country DESC;
-- 8. For each customer, show their CustomerId, the count of invoices they have, and their total lifetime spend. Only show customers who have spent more than $45 in total.
SELECT CustomerId, COUNT(InvoiceId) AS total_invoices, SUM(total) AS total_spent
FROM Invoice
GROUP BY CustomerId
HAVING total_spent &gt; 45;</sql><current_tab id="0"/></tab_sql></sqlb_project>
