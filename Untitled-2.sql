GO

SELECT * FROM Customer;
SELECT * FROM Subscription;
SELECT * FROM SubscriptionItem;
SELECT * FROM Invoice;
SELECT * FROM InvoiceItem;
SELECT * FROM InvoiceAudit;
GO

SELECT dbo.fn_CalculateSubscriptionTotal(2) AS ValorTotal_Assinatura_2;
GO

SELECT * FROM dbo.fn_GetSubscriptionMonthlySummary(202602);
GO
EXEC dbo.pc_GenerateInvoice @SubscriptionId = 5, @ReferenceMonth = 202602;
GO

SELECT * FROM dbo.vw_InvoiceSummary;
GO

SELECT * FROM InvoiceAudit;
GO