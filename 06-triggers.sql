
-- ============================================================
-- Gravar automaticamente na tabela de auditoria 
-- sempre que uma nova fatura for inserida.
-- ============================================================
CREATE OR ALTER TRIGGER dbo.trg_Invoice_Audit
ON dbo.Invoice
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- O SQL Server usa a tabela especial 'inserted' para 
    -- mostrar o que acabou de ser gravado na tabela principal.
    INSERT INTO InvoiceAudit (InvoiceId, TotalAmount, OperationDate, UserName)
    SELECT 
        i.InvoiceId, 
        i.TotalAmount, 
        GETDATE(), 
        SUSER_SNAME() -- Pega o nome do usuário que está logado no SQL
    FROM inserted i;
END;
