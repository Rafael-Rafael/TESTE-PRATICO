
-- ============================================================
-- Exibir um resumo das faturas com nomes de clientes.
-- ============================================================
CREATE OR ALTER VIEW dbo.vw_InvoiceSummary
AS
SELECT 
    i.InvoiceId,
    c.Name AS CustomerName,
    s.SubscriptionId,
    i.ReferenceMonth,
    i.TotalAmount,
    i.CreatedAt AS InvoiceDate,
    s.Status AS SubscriptionStatus
FROM Invoice i
INNER JOIN Subscription s ON s.SubscriptionId = i.SubscriptionId
INNER JOIN Customer c ON c.CustomerId = s.CustomerId;
