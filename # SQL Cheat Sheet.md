# SQL Cheat Sheet
Personal reference — built during BI bootcamp, Week 1

## Clause Order (MEMORIZE)
`SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT`

## Basic SELECT
````sql
SELECT col1, col2
FROM table
WHERE condition
ORDER BY col1 DESC
LIMIT 10;
````

## Filtering — WHERE patterns
````sql
-- Equality
WHERE Country = 'USA'

-- Comparison
WHERE Total > 100

-- Multiple values
WHERE Country IN ('USA', 'Canada', 'Brazil')

-- Range
WHERE Total BETWEEN 5 AND 15

-- Pattern match (% = any chars, _ = single char)
WHERE Name LIKE '%love%'

-- Null checks
WHERE ReportsTo IS NULL
WHERE ReportsTo IS NOT NULL

-- Combining
WHERE Country = 'USA' AND LastName LIKE 'S%'
````

## Aggregation
````sql
SELECT Country, COUNT(*) AS customer_count, SUM(Total) AS revenue
FROM Invoice
WHERE InvoiceDate >= '2020-01-01'   -- filters rows BEFORE grouping
GROUP BY Country
HAVING SUM(Total) > 100              -- filters groups AFTER grouping
ORDER BY revenue DESC;
````

**Aggregate functions:** `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
**Useful modifier:** `ROUND(AVG(col), 2)` for 2 decimal places

## WHERE vs HAVING — the rule
- WHERE filters **rows BEFORE** grouping
- HAVING filters **groups AFTER** grouping
- If the filter uses an aggregate → **HAVING**
- If not → **WHERE**

## String Functions
- `LENGTH(col)` — character count (SQL Server uses `LEN`)
- `UPPER(col)`, `LOWER(col)` — case conversion
- `LIKE '%x%'` — contains x

## INNER JOIN: only rows that match in both tables
- SELECT c.FirstName, e.FirstName
- FROM Customer c
- INNER JOIN Employee e ON c.SupportRepId = e.EmployeeId;
- (JOIN alone defaults to INNER)

## LEFT JOIN: all rows from left table, NULLs where right has no match
SELECT e.FirstName, COUNT(c.CustomerId) AS customer_count
FROM Employee e
LEFT JOIN Customer c ON e.EmployeeId = c.SupportRepId
GROUP BY e.EmployeeId;
-- Use LEFT JOIN when you want to preserve "zeros" or "no matches"


## Track → Album → Artist (3-table join)
SELECT t.Name, a.Title, art.Name
FROM Track t
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist art ON a.ArtistId = art.ArtistId;

## Aliases
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId

## Clause Order
SELECT → FROM → JOIN → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT


## JOINS + Aggregation Patterns 
SELECT c.FirstName, c.LastName, SUM(i.Total) AS total_spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY total_spent DESC
LIMIT 10;


## STRINGS

## Concatenate
FirstName || ' ' || LastName

## Length
LENGTH(column)

## Case
UPPER(column), LOWER(column)

## DATES

## Extract Year
strftime('%Y', InvoiceDate)

## Extract Month
strftime('%m', InvoiceDate)

## Year + Month Together
strftime('%Y-%m', InvoiceDate)

## Day of Week:
strftime('%w', InvoiceDate) → 0 (Sun) through 6 (Sat)

## CASE Templete
CASE
    WHEN condition1 THEN 'result1'
    WHEN condition2 THEN 'result2'
    ELSE 'default_result'
END

## ROUNDING
ROUND(value, 0) for nearest whole number

ROUND(Milliseconds / 1000.0, 0) — note the .0 to force decimal division




## Gotchas I've Hit
- **Single quotes** for strings (`'Brazil'`), not double quotes
- **`IS NULL`** has a space — `ISNULL` is non-standard, avoid it
- **`LENGTH`** in MySQL/PostgreSQL/SQLite, **`LEN`** in SQL Server
- **SQLite LIKE is case-insensitive** — most other databases aren't
- **HAVING with a column alias** works in SQLite/MySQL but breaks in PostgreSQL — repeat the aggregate expression instead
- **GROUP BY column in SELECT** — if you group by it, include it in SELECT or your output has no labels
- **End queries with semicolons** — required when running multiple queries in a script
IDs match IDs. ON clauses join foreign_key_id = primary_key_id. Never name to name.

Grain = what one row represents. Always GROUP BY the column that defines your desired grain (usually the ID of the thing you want one row per).

GROUP BY the ID, not the name. Two people with the same name would merge into one row otherwise.
LEFT JOIN + COUNT gotcha: Use COUNT(column_from_right_table) not COUNT(*). COUNT(*) would incorrectly show 1 for zero-match rows; COUNT(column) correctly shows 0.

LEFT JOIN + GROUP BY gotcha: Group by columns from the LEFT table, not the right — otherwise the "no match" rows collapse into NULL and you lose the zero-count signal.

Don't default to LEFT JOIN "just in case." Use INNER when you only care about matched rows. Join type signals intent.

Reserved words: avoid naming columns match, order, user, group, etc.

Clause order matters. JOIN has to come right after FROM, before GROUP BY. Errors about "syntax near LEFT" or similar usually mean you put JOIN in the wrong place.
````
````

---

