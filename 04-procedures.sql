CREATE OR ALTER PROCEDURE dbo.pc_GenerateInvoice
(
    @SubscriptionId INT,
    @ReferenceMonth INT
)
AS
BEGIN
    -- 1. Evitar que gere duas faturas para o mesmo mês (Idempotência)
    IF EXISTS (SELECT 1 FROM Invoice WHERE SubscriptionId = @SubscriptionId AND ReferenceMonth = @ReferenceMonth)
    BEGIN
        PRINT 'Fatura já existe para esta assinatura e mês.';
        RETURN;
    END

    -- 2. Início da Transação (Garante que ou grava tudo ou nada)
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @InvoiceId INT;
        DECLARE @Total DECIMAL(18,2);

        -- 3. Calcula o total usando a função que criamos no Passo 3
        SET @Total = dbo.fn_CalculateSubscriptionTotal(@SubscriptionId);

        -- 4. Insere a Fatura Principal
        INSERT INTO Invoice (SubscriptionId, ReferenceMonth, TotalAmount)
        VALUES (@SubscriptionId, @ReferenceMonth, @Total);

        -- Pega o ID da fatura que acabou de ser criada
        SET @InvoiceId = SCOPE_IDENTITY();

        -- 5. Insere os itens da fatura baseados nos itens da assinatura
        INSERT INTO InvoiceItem (InvoiceId, Description, Amount)
        SELECT @InvoiceId, ProductName, (MonthlyPrice * Quantity)
        FROM SubscriptionItem
        WHERE SubscriptionId = @SubscriptionId;

        -- 6. Se chegou aqui sem erro, confirma a gravação
        COMMIT TRANSACTION;
        PRINT 'Fatura gerada com sucesso!';
    END TRY
    BEGIN CATCH
        -- 7. Se deu qualquer erro, desfaz tudo o que foi feito acima
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- 8. Capture os detalhes do erro em variáveis
        DECLARE @ErroNumero INT = ERROR_NUMBER();
        DECLARE @ErroMensagem NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErroLinha INT = ERROR_LINE();
        DECLARE @ErroProcedure NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), 'Ad-hoc Script');

        -- 9. Formate uma mensagem detalhada para o desenvolvedor/log
        DECLARE @MensagemFinal NVARCHAR(4000);
        SET @MensagemFinal = FORMATMESSAGE('Erro %d na linha %d da procedure %s: %s', 
                                           @ErroNumero, @ErroLinha, @ErroProcedure, @ErroMensagem);

        -- 10. Use o THROW para lançar a mensagem personalizada
        -- O número do erro deve ser >= 50000 para mensagens customizadas
        ;THROW 50001, @MensagemFinal, 1;
    END CATCH
END;
