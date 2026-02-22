-- ============================================================
-- RANKING DE FATURAMENTO POR CLIENTE 
-- ============================================================
WITH FaturamentoPorCliente AS (
    SELECT 
        c.CustomerId,
        c.Name AS CustomerName,
        SUM(i.TotalAmount) AS TotalFaturado
    FROM Invoice i
    INNER JOIN Subscription s ON s.SubscriptionId = i.SubscriptionId
    INNER JOIN Customer c ON c.CustomerId = s.CustomerId
    WHERE i.CreatedAt >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY c.CustomerId, c.Name
)
SELECT TOP 3
    CustomerName,
    TotalFaturado,
    RANK() OVER (ORDER BY TotalFaturado DESC) AS PosicaoRanking
FROM FaturamentoPorCliente
ORDER BY TotalFaturado DESC;


-- ============================================================
-- QUERY 01: Faturamento Acumulado Mês a Mês por Cliente
-- Ver a evolução do faturamento de cada cliente
--           ao longo do tempo, acumulando mês a mês.
-- ============================================================
SELECT
    c.Name AS CustomerName,
    i.ReferenceMonth,
    i.TotalAmount AS MonthlyAmount,
    SUM(i.TotalAmount) OVER (
        PARTITION BY c.CustomerId
        ORDER BY i.ReferenceMonth
    ) AS RunningTotal
FROM Invoice AS i
INNER JOIN Subscription  AS s  ON s.SubscriptionId = i.SubscriptionId
INNER JOIN Customer      AS c  ON c.CustomerId     = s.CustomerId
ORDER BY
    c.Name,
    i.ReferenceMonth;


    -- ============================================================
--  Detecção de Assinaturas Inativas
--  Encontrar assinaturas Active que não geraram fatura nos últimos 3 meses 
-- ============================================================
SELECT
    s.SubscriptionId,
    c.Name                          AS CustomerName,
    c.Email                         AS CustomerEmail,
    s.Status                        AS SubscriptionStatus,
    s.StartDate,
    MAX(i.ReferenceMonth)           AS LastInvoiceMonth
FROM Subscription       AS s
INNER JOIN Customer     AS c  ON c.CustomerId    = s.CustomerId
LEFT JOIN Invoice       AS i  ON i.SubscriptionId = s.SubscriptionId
WHERE
    s.Status = 'Active'
GROUP BY
    s.SubscriptionId,
    c.Name,
    c.Email,
    s.Status,
    s.StartDate
HAVING -- where do GROUP BY tem acesso nas funçoes de agregação (executa depois do where e group by)
    MAX(i.ReferenceMonth) < FORMAT(DATEADD(MONTH, -3, GETDATE()), 'yyyyMM')
    OR MAX(i.ReferenceMonth) IS NULL;


    -- ============================================================
-- Última Fatura por Assinatura
--  Para cada cliente e assinatura, retornar apenas a fatura mais recente.
-- ============================================================
SELECT
    c.CustomerId,
    c.Name                      AS CustomerName,
    c.Email                     AS CustomerEmail,
    s.SubscriptionId,
    s.Status                    AS SubscriptionStatus,
    uf.InvoiceId                AS LastInvoiceId,
    uf.ReferenceMonth           AS LastReferenceMonth,
    uf.TotalAmount              AS LastInvoiceAmount,
    uf.CreatedAt                AS LastInvoiceDate
FROM Customer           AS c
INNER JOIN Subscription AS s   ON s.CustomerId = c.CustomerId
CROSS APPLY (
    SELECT TOP 1
        i.InvoiceId,
        i.ReferenceMonth,
        i.TotalAmount,
        i.CreatedAt
    FROM Invoice AS i
    WHERE i.SubscriptionId = s.SubscriptionId
    ORDER BY i.ReferenceMonth DESC
)  AS uf
ORDER BY
    c.Name,
    s.SubscriptionId;


    -- ============================================================
-- Anti-Join – Assinaturas Problemáticas
--  1: Assinaturas sem nenhum item cadastrado.
--  2: Assinaturas com itens mas sem nenhuma fatura.
-- ============================================================

-- ----------------------------------------------------------
-- PARTE 1: Assinaturas SEM itens
-- ----------------------------------------------------------
SELECT
    s.SubscriptionId,
    c.Name                  AS CustomerName,
    c.Email                 AS CustomerEmail,
    s.Status                AS SubscriptionStatus,
    s.StartDate,
    'Sem Itens'             AS Problema
FROM Subscription       AS s
INNER JOIN Customer     AS c  ON c.CustomerId = s.CustomerId
WHERE NOT EXISTS (
    SELECT 1
    FROM SubscriptionItem   AS si
    WHERE si.SubscriptionId = s.SubscriptionId
)

UNION ALL

-- ----------------------------------------------------------
-- PARTE 2: Assinaturas COM itens mas SEM faturas
-- ----------------------------------------------------------
SELECT
    s.SubscriptionId,
    c.Name                  AS CustomerName,
    c.Email                 AS CustomerEmail,
    s.Status                AS SubscriptionStatus,
    s.StartDate,
    'Com Itens, Sem Fatura' AS Problema
FROM Subscription       AS s
INNER JOIN Customer     AS c  ON c.CustomerId = s.CustomerId
WHERE EXISTS (
    SELECT 1
    FROM SubscriptionItem   AS si
    WHERE si.SubscriptionId = s.SubscriptionId
)
AND NOT EXISTS (
    SELECT 1
    FROM Invoice            AS i
    WHERE i.SubscriptionId  = s.SubscriptionId
)
ORDER BY
    Problema,
    CustomerName;