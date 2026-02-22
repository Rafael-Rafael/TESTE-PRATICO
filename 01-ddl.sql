-- 1. Tabela de Clientes
CREATE TABLE Customer (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 2. Tabela de Assinaturas
CREATE TABLE Subscription (
    SubscriptionId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status VARCHAR(20) CHECK (Status IN ('Active', 'Canceled', 'Suspended')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Subscription_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

-- 3. Itens da Assinatura
CREATE TABLE SubscriptionItem (
    SubscriptionItemId INT IDENTITY(1,1) PRIMARY KEY,
    SubscriptionId INT NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    MonthlyPrice DECIMAL(18,2) NOT NULL CHECK (MonthlyPrice >= 0),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    CONSTRAINT FK_SubItem_Subscription FOREIGN KEY (SubscriptionId) REFERENCES Subscription(SubscriptionId)
);

-- 4. Faturas
CREATE TABLE Invoice (
    InvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    SubscriptionId INT NOT NULL,
    ReferenceMonth INT NOT NULL, -- Formato YYYYMM
    TotalAmount DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Invoice_Subscription FOREIGN KEY (SubscriptionId) REFERENCES Subscription(SubscriptionId),
    CONSTRAINT UQ_Invoice_Sub_Month UNIQUE (SubscriptionId, ReferenceMonth)
);

-- 5. Itens da Fatura
CREATE TABLE InvoiceItem (
    InvoiceItemId INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceId INT NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_InvItem_Invoice FOREIGN KEY (InvoiceId) REFERENCES Invoice(InvoiceId)
);

-- 6. Tabela de Auditoria
CREATE TABLE InvoiceAudit (
    AuditId INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceId INT,
    OperationDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18,2),
    UserName VARCHAR(100)
);

-- Índice para Performance
CREATE NONCLUSTERED INDEX IX_Subscription_Status_CustomerId 
ON Subscription (Status, CustomerId);