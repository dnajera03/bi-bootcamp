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

## Gotchas I've Hit
- **Single quotes** for strings (`'Brazil'`), not double quotes
- **`IS NULL`** has a space — `ISNULL` is non-standard, avoid it
- **`LENGTH`** in MySQL/PostgreSQL/SQLite, **`LEN`** in SQL Server
- **SQLite LIKE is case-insensitive** — most other databases aren't
- **HAVING with a column alias** works in SQLite/MySQL but breaks in PostgreSQL — repeat the aggregate expression instead
- **GROUP BY column in SELECT** — if you group by it, include it in SELECT or your output has no labels
- **End queries with semicolons** — required when running multiple queries in a script
````
````

---

