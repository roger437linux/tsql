-- 3. Exercícios

-- Nível 1 — Aquecimento

-- Q1. Abra uma transação e mude o telefone do cliente 10 para '19981112222'. 
--     Confira com um SELECT, desfaça com ROLLBACK e confira de novo.

BEGIN TRAN
SELECT @@TRANCOUNT;

SELECT * FROM Clientes WHERE IdCliente = 10;

UPDATE Clientes set Telefone = '19981112222'
WHERE IdCliente = 10;

SELECT * FROM Clientes WHERE IdCliente = 10;

ROLLBACK;


-- Q2. Mostre o valor de @@TRANCOUNT em três momentos: antes do BEGIN TRAN, 
--     logo depois dele e depois do ROLLBACK.

SELECT @@TRANCOUNT;
BEGIN TRAN
SELECT @@TRANCOUNT;

UPDATE Clientes set Telefone = '99999-9999'
WHERE IdCliente = 10;

ROLLBACK;
SELECT @@TRANCOUNT;


-- Q3. Dentro de uma transação, apague o cliente 20. Depois tente apagar o cliente 1. 
--     O que aconteceu em cada caso, e por quê? Termine com ROLLBACK.

-- R: Houve a restrição referencial "FK_Locacoes_Clientes", pois na tabela Locacoes há registro com IdCliente = 1

BEGIN TRAN
SELECT @@TRANCOUNT;

DELETE FROM Clientes WHERE IdCliente = 20;
DELETE FROM Clientes WHERE IdCliente = 1;

ROLLBACK;


-- Q4. Seu Ricardo quer apagar as locações canceladas. Antes de apagar, descubra com um SELECT quantas são. 
--     Depois apague dentro de uma transação, mostre @@ROWCOUNT logo em seguida e termine com ROLLBACK.

BEGIN TRAN

SELECT COUNT(*) FROM Locacoes WHERE Status = 'Cancelada';
-- R: 12

DELETE FROM Locacoes WHERE Status = 'Cancelada';
SELECT @@ROWCOUNT;

ROLLBACK;


-- Nível 2 — Regras do negócio

-- Q5. Registre a devolução da locação 143 (Onix Plus, veículo 7) em 23/10/2026, com 19.480 km, numa transação: 
--     finalize a locação, libere o veículo e registre o pagamento do que falta, em Pix. Confira e dê COMMIT.

BEGIN TRAN
SELECT @@TRANCOUNT;

UPDATE Locacoes SET DataDevolucao = '2026-10-23', KmDevolucao = 19480, Status = 'Finalizada'
WHERE IdLocacao = 143;

DECLARE @Id INT = 143;
UPDATE p SET p.FormaPagamento = 'Pix',
p.Valor = (DATEDIFF(DAY, l.DataRetirada, l.DataDevolucao) * l.ValorDiaria) - p.Valor
FROM Locacoes l
INNER JOIN Pagamentos p
ON l.IdLocacao = p.IdLocacao
WHERE l.IdLocacao = @Id;

--SELECT * FROM Pagamentos WHERE IdLocacao = 143;

COMMIT;
GO


-- Q6. Seu Ricardo quer reajustar em 10% só a diária da categoria SUV. 
-- Faça o UPDATE numa transação, confira quantas linhas mudaram e o novo valor, 
-- e confirme só se estiver tudo certo.

BEGIN TRAN
SELECT @@TRANCOUNT;

-- Atualizar diária SUV
DECLARE @IdCategoriaSUV INT = (select IdCategoria from Categorias where NomeCategoria = 'SUV');
UPDATE l set l.ValorDiaria = l.ValorDiaria + (l.ValorDiaria * .10)
FROM Locacoes l
INNER JOIN Veiculos v
ON v.IdVeiculo = l.IdVeiculo
WHERE v.IdCategoria = @IdCategoriaSUV;

SELECT @@ROWCOUNT;

-- Consultar diária SUV
DECLARE @IdCategoriaSUVi INT = (select IdCategoria from Categorias where NomeCategoria = 'SUV');
SELECT Locacoes.ValorDiaria, Veiculos.IdCategoria
FROM Locacoes
INNER JOIN Veiculos
ON Veiculos.IdVeiculo = Locacoes.IdVeiculo
WHERE Veiculos.IdCategoria = @IdCategoriaSUVi;

COMMIT


-- Q7. Compare DELETE e TRUNCATE na tabela Pagamentos. Rode o script do banco antes. 
-- Numa transação: apague todos os pagamentos com DELETE, insira um pagamento novo 
-- para a locação 1 e veja o IdPagamento que ele recebeu; ROLLBACK. 
-- Repita com TRUNCATE TABLE. Por fim, tente TRUNCATE TABLE Locacoes.

BEGIN TRAN
SELECT @@TRANCOUNT;

SELECT * FROM Pagamentos;
SELECT @@ROWCOUNT;

-- Delete
DELETE FROM Pagamentos;

INSERT INTO Pagamentos (IdLocacao, DataPagamento, Valor, FormaPagamento) 
VALUES (1, GETDATE(), 500.00, 'Pix');

-- Truncate
TRUNCATE TABLE Pagamentos;

-- Impossibilitado por restrição de chave estrangeira
TRUNCATE TABLE Locacoes;

ROLLBACK


--  Nível 3 — Desafio

-- Q8. Dentro de uma transação, apague as manutenções preventivas mostrando, 
--     com OUTPUT, o id, o veículo e a descrição de cada uma que saiu. Termine com ROLLBACK.

BEGIN TRANSACTION
SELECT @@TRANCOUNT;

SELECT * FROM Manutencoes WHERE Tipo = 'Preventiva';

DELETE FROM Manutencoes 
OUTPUT
	DELETED.IdManutencao,
	DELETED.IdVeiculo,
	DELETED.Descricao
WHERE Tipo = 'Preventiva';

ROLLBACK


-- Q9. Repita a devolução da locação 144 do exemplo, mas com um erro proposital: 
-- pagamento de valor 0, que a regra CK_Pagamentos_Valor não aceita. 
-- Rode tudo de uma vez (do BEGIN TRAN ao COMMIT) duas vezes: primeiro sem SET XACT_ABORT ON, 
-- depois com ele. Rode o script do banco entre as duas tentativas. O que ficou gravado em cada caso?

-- R: Nos dois casos nada foi gravado

BEGIN TRANSACTION
SELECT @@TRANCOUNT;
--SET XACT_ABORT ON

DECLARE @Id INT = 143;
UPDATE p SET p.FormaPagamento = 'Pix',
p.Valor = ((DATEDIFF(DAY, l.DataRetirada, l.DataDevolucao) * l.ValorDiaria) - p.Valor) * 0
FROM Locacoes l
INNER JOIN Pagamentos p
ON l.IdLocacao = p.IdLocacao
WHERE l.IdLocacao = @Id;

--SELECT * FROM Pagamentos WHERE IdLocacao = 143;

COMMIT;


-- Q10. Exclusão lógica. Numa transação, acrescente à tabela Clientes a coluna Ativo (BIT, obrigatória, padrão 1). 
-- Depois marque como inativos (Ativo = 0) os clientes cuja última retirada foi há mais de 30 dias de @Hoje (03/11/2026). 
-- Mostre quem ficou inativo e dê ROLLBACK.

BEGIN TRANSACTION;
SELECT @@TRANCOUNT;

SELECT TOP(3) * FROM Clientes;

-- 1. Nova coluna
ALTER TABLE Clientes ADD Ativo BIT NOT NULL DEFAULT (1);

-- 2. Data de hoje
DECLARE @Hoje DATE = GETDATE();

-- 3. Identificar a última retirada de cada cliente
;WITH UltimaRetirada AS (
    SELECT
        IdCliente,
        MAX(DataRetirada) AS DataUltimaRetirada
    FROM Locacoes
    GROUP BY IdCliente
)

-- 4. Marcar como inativos os clientes
-- cuja última retirada ocorreu há mais de 30 dias
UPDATE c
SET Ativo = 0
OUTPUT
    INSERTED.IdCliente,
    INSERTED.Nome,
    INSERTED.Ativo
FROM Clientes c
INNER JOIN UltimaRetirada u
    ON c.IdCliente = u.IdCliente
WHERE u.DataUltimaRetirada < DATEADD(DAY, -30, @Hoje)
  AND c.Ativo = 1;


ROLLBACK;
