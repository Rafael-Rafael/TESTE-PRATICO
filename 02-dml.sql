
-- auto increment
INSERT INTO Customer (Name, Email) VALUES
('João Silva',   'joao.silva@email.com'),
('Maria Souza',  'maria.souza@email.com'),
('Carlos Lima',  'carlos.lima@email.com'),
('Ana Costa',    'ana.costa@email.com'),
('Pedro Rocha',  'pedro.rocha@email.com');

INSERT INTO Subscription (CustomerId, StartDate, Status) VALUES
(1, '2024-01-01', 'Active'),    -- João (Ativo)
(2, '2024-02-01', 'Active'),    -- Maria (Ativa)
(3, '2024-03-01', 'Canceled'),  -- Carlos (Cancelado)
(4, '2024-04-01', 'Suspended'), -- Ana (Suspenso)
(5, '2024-05-01', 'Active');    -- Pedro (Ativo)

INSERT INTO SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity) VALUES
(1, 'Plano Premium', 99.90, 1),
(1, 'Suporte VIP', 20.00, 1),
(1, 'Backup Cloud', 15.00, 2);

INSERT INTO SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity) VALUES
(2, 'Plano Basic', 49.90, 1),
(2, 'Domínio .com', 10.00, 1);

INSERT INTO SubscriptionItem (SubscriptionId, ProductName, MonthlyPrice, Quantity) VALUES
(5, 'Plano Enterprise', 199.90, 1),
(5, 'Segurança Avançada', 50.00, 1);

-- Atualizando a assinatura do Carlos (ID 3) que está cancelada
UPDATE Subscription 
SET EndDate = '2024-12-31' 
WHERE SubscriptionId = 3;

INSERT INTO Customer (Name, Email) VALUES
('Rafael Ribeiro',   'rafael.ribeiro@email.com');

INSERT INTO Subscription (CustomerId, StartDate, Status) VALUES
(1, '2024-01-01', 'Active');    
