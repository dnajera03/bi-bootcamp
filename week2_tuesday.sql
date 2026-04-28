-- 1. Show every invoice with the prior invoice's total for the same customer.
--    Show CustomerId, InvoiceId, InvoiceDate, current Total, and previous_total.
--    First invoice for each customer should show NULL for previous_total.
SELECT c.CustomerId AS customer_id,
i.InvoiceId AS invoice_id,
i.InvoiceDate AS invoice_date,
i.Total AS current_total,
LAG(i.total) OVER (PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS previous_total
FROM Customer c
JOIN Invoice i 
ON c.Customerid = i.CustomerId
ORDER BY c.CustomerId, i.InvoiceDate;

-- 2. For each customer, show each invoice and the difference vs. their previous invoice.
--    Show CustomerId, InvoiceId, InvoiceDate, Total, prev_total, diff_from_prev.
--    The difference can be positive (spent more) or negative (spent less).
WITH invoice_with_lag AS (
    SELECT 
        c.CustomerId,
        i.InvoiceId,
        i.InvoiceDate,
        i.Total AS current_total,
        LAG(i.Total) OVER (PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS previous_total
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
)
SELECT 
    *,
    current_total - previous_total AS diff_from_prev
FROM invoice_with_lag
ORDER BY CustomerId, InvoiceDate;
-- 3. Running total of all revenue across the whole company, ordered chronologically.
--    Show InvoiceDate, daily revenue (SUM per day), running cumulative revenue.
--    Hint: aggregate to one-row-per-day first (CTE), then add the running SUM in the outer query.
WITH daily_revenue AS (
    SELECT 
        InvoiceDate,
        SUM(Total) AS revenue_that_day
    FROM Invoice
    GROUP BY InvoiceDate
)
SELECT 
    InvoiceDate,
    revenue_that_day,
    SUM(revenue_that_day) OVER (ORDER BY InvoiceDate) AS running_revenue
FROM daily_revenue
ORDER BY InvoiceDate;
-- 4. For each customer, running total of their lifetime spend over time.
--    Show CustomerId, InvoiceDate, Total, customer_running_total.
--    The total should restart for each customer.
SELECT c.CustomerId AS customer_id,
i.InvoiceDate AS invoice_date,
i.total AS total,
SUM(i.total) OVER (PARTITION BY c.CustomerId ORDER BY i.InvoiceDate) AS customer_running_total
FROM Customer c
JOIN Invoice i 
ON  c.CustomerId = i.CustomerId
ORDER BY c.CustomerId, i.InvoiceDate;
-- 5. Monthly revenue with month-over-month % change.
--    Show year_month, monthly_revenue, prior_month_revenue, mom_pct_change.
--    This is the proper solution to capstone Q9. ROUND the % to 1 decimal.
WITH monthly_revenue AS (
    SELECT 
        strftime('%Y-%m', InvoiceDate) AS year_month,
        SUM(Total) AS revenue_monthly
    FROM Invoice
    GROUP BY year_month
)
SELECT 
    year_month,
    revenue_monthly,
    LAG(revenue_monthly) OVER (ORDER BY year_month) AS prior_month_revenue,
    ROUND(
        (revenue_monthly - LAG(revenue_monthly) OVER (ORDER BY year_month)) 
        * 100.0 
        / LAG(revenue_monthly) OVER (ORDER BY year_month),
    1) AS mom_pct_change
FROM monthly_revenue
ORDER BY year_month;
-- 6. For each customer's invoice, show the days since their previous invoice.
--    Show CustomerId, InvoiceId, InvoiceDate, prev_invoice_date, days_between.
--    Hint: SQLite's julianday(date1) - julianday(date2) gives a difference in days.
WITH previous_invoice AS(
SELECT c.CustomerId AS customer_id,
i.InvoiceId AS invoice_id,
i.InvoiceDate AS invoice_date,
LAG(i.InvoiceDate) OVER (PARTITION BY c.CustomerId ORDER BY i.InvoiceDate) AS prev_invoice_date
FROM Customer c
JOIN Invoice i 
ON c.CustomerId = i.CustomerId)
SELECT customer_id,
invoice_id,
invoice_date,
prev_invoice_date,
ROUND(julianday(invoice_date) - julianday(prev_invoice_date),0) AS days_between
FROM previous_invoice
ORDER BY customer_id, invoice_date;
-- 7. Show every invoice along with the 3-invoice moving average of the customer's spend.
--    Show CustomerId, InvoiceDate, Total, moving_avg_3.
--    For their first 2 invoices, the moving avg will be the average of fewer rows — that's fine.
SELECT c.CustomerId AS customer_id,
i.InvoiceDate AS invoice_date,
i.total AS total,
AVG(i.total) OVER (
PARTITION BY c.CustomerId ORDER BY i.InvoiceDate
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId;
-- 8. Identify customers whose most recent invoice was their highest-ever spend.
--    Show CustomerId, FirstName, LastName, last_invoice_date, last_invoice_total, max_invoice_total.
--    Filter to only customers where last = max.
--    Hint: this needs a CTE with TWO window functions per row (last invoice's total + max invoice's total).
WITH ranked_invoices AS (
    SELECT 
        c.CustomerId,
        c.FirstName,
        c.LastName,
        i.InvoiceDate,
        i.Total,
        ROW_NUMBER() OVER (PARTITION BY c.CustomerId ORDER BY i.InvoiceDate DESC) AS recency_rank,
        MAX(i.Total) OVER (PARTITION BY c.CustomerId) AS max_invoice_total
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
)
SELECT 
    CustomerId,
    FirstName,
    LastName,
    InvoiceDate AS last_invoice_date,
    Total AS last_invoice_total,
    max_invoice_total
FROM ranked_invoices
WHERE recency_rank = 1
  AND Total = max_invoice_total;