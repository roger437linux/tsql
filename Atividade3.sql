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

SELECT * FROM Locacoes WHERE IdLocacao = 143;


ROLLBACK;