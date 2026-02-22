GO

-- ============================================================
-- Somar o valor de todos os itens de uma assinatura.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_CalculateSubscriptionTotal
(
    @SubscriptionId INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    -- Soma o (Preço * Quantidade) de todos os itens daquela assinatura
    SELECT @Total = SUM(MonthlyPrice * Quantity)
    FROM SubscriptionItem
    WHERE SubscriptionId = @SubscriptionId;

    -- Se não encontrar nada, retorna 0 em vez de NULL
    RETURN ISNULL(@Total, 0);
END;
GO

-- ============================================================
-- Retorna o relatório detalhado de assinaturas.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_GetSubscriptionMonthlySummary
(
    @ReferenceMonth INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.CustomerId,
        c.Name AS CustomerName,
        s.SubscriptionId,
        @ReferenceMonth AS ReferenceMonth,
        COUNT(si.SubscriptionItemId) AS ItemCount,
        SUM(si.MonthlyPrice * si.Quantity) AS MonthlyTotal,
        s.Status AS SubscriptionStatus
    FROM Customer c  -- with (nolock) 
    INNER JOIN Subscription s ON s.CustomerId = c.CustomerId 
    INNER JOIN SubscriptionItem si ON si.SubscriptionId = s.SubscriptionId
    GROUP BY c.CustomerId, c.Name, s.SubscriptionId, s.Status
);
GO