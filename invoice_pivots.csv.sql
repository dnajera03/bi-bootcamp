SELECT 
    i.InvoiceId,
    i.InvoiceDate,
    i.Total,
    c.FirstName,
    c.LastName,
    c.Country,
    c.City,
    e.FirstName || ' ' || e.LastName AS SupportRep
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
JOIN Employee e ON c.SupportRepId = e.EmployeeId;