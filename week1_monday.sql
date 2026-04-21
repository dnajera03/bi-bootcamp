-- 1. Show all customers from Brazil
SELECT *
FROM Customer
WHERE Country = "Brazil";

-- 2. List the first 10 tracks in the database, showing just TrackId, Name, and Milliseconds
SELECT TrackId, Name, Milliseconds
FROM Track
LIMIT 10;

-- 3. Find all tracks longer than 5 minutes (5 minutes = 300,000 milliseconds)
SELECT *
FROM Track
WHERE Milliseconds > 300000;

-- 4. Show all invoices with a total between $5 and $15, sorted by total descending
SELECT *
FROM Invoice
WHERE total BETWEEN 5 AND 15 
ORDER BY total desc;

-- 5. Find all customers whose first name starts with "A"
SELECT *
FROM Customer
WHERE FirstName like 'a%'


-- 7. Show all employees who don't have a ReportsTo value (i.e., the top of the hierarchy)
SELECT *
FROM Employee
WHERE ReportsTo ISNULL
-- 8. Find the 5 most expensive tracks (highest UnitPrice)
SELECT *
From Track
ORDER BY UnitPrice DESC
LIMIT 5 
-- 9. Show all customers from USA, Canada, or Brazil, sorted by country then last name
SELECT *
From Customer
WHERE Country in ('USA', 'Canada', 'Brazil')
ORDER BY Country, LastName
-- 10. Find all tracks whose name contains the word "love" (case-insensitive)
SELECT *
From Track
WHERE Name like '%love%'