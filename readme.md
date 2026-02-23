os scripts devem ser executados na ordem numérica prefixada nos arquivos. Utilize o Visual Studio Code com a extensão mssql.

1. **01-ddl.sql**: Criação do banco de dados `TesteSQL`, tabelas, chaves primárias/estrangeiras e índices.
2. **02-dml.sql**: Inserção de dados iniciais para teste (Clientes, Assinaturas e Itens).
3. **03-functions.sql**: Criação de funções escalares e tabulares.
4. **04-procedures.sql**: Criação da Procedure de geração de faturas com controle transacional.
5. **05-views.sql**: Criação da View analítica de resumo de faturamento.
6. **06-triggers.sql**: Implementação do gatilho de auditoria automática.
7. **07-queries.sql**: Consultas avançadas (Ranking, Acumulado, Anti-Join e Apply).

---

## 📋 Premissas Adotadas

*   **Idempotência**: Todos os scripts foram desenvolvidos para serem executados múltiplas vezes sem gerar erros (uso de `CREATE OR ALTER` e verificações de existência).
*   **Integridade**: O faturamento é baseado em assinaturas com status `Active`.
*   **Moeda**: Valores monetários utilizam o tipo `DECIMAL(18,2)` para garantir precisão decimal, evitando arredondamentos incorretos comuns ao tipo `FLOAT`.

---

## 🛠 Decisões Técnicas

*   **Stored Procedure com Transação**: A geração de faturas utiliza `BEGIN TRANSACTION` e `TRY...CATCH` com `ROLLBACK` para garantir que, em caso de erro, nenhum dado parcial seja gravado (Atomicidade).
*   **Inline Table-Valued Functions (ITVF)**: Utilizado funções Inline em vez de Multistatement para melhor performance.
*   **Window Functions**: Utilização de `RANK()` e `SUM() OVER` para cálculos analíticos, mantendo a granularidade dos dados sem a necessidade de subqueries lentas.
*   **Anti-Joins com NOT EXISTS**: Preferência pelo uso de `NOT EXISTS` em vez de `NOT IN` para garantir segurança contra valores `NULL` e melhor performance em grandes volumes de dados.
*   **Índices Não-Clusterizados**: Criados em colunas de busca frequente (como `ReferenceMonth` e `Status`) para otimizar a velocidade das consultas de relatório.

---

## 📈 Possíveis Melhorias

1.  **Particionamento de Tabelas**: Para volumes massivos de dados, a tabela `Invoice` poderia ser particionada por ano/mês.
2.  **Soft Delete**: Implementar uma coluna `IsDeleted` em vez de excluir registros fisicamente, mantendo o histórico completo.
3.  **Log de Erros**: Criar uma tabela específica para logar erros capturados no `CATCH` das Procedures, facilitando o debug em produção.
4.  **Automação**: Configurar um SQL Server Agent Job para executar a `sp_GenerateInvoice` automaticamente no primeiro dia de cada mês.