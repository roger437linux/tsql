SELECT FormaPagamento
From Pagamentos;


-- Selecionar valores únicos e formas de pagamento

select distinct FormaPagamento
from pagamentos;



SELECT COUNT(DISTINCT Cidade) as QTD_Cidades
FROM Clientes;



-- Outra possibilidade

SELECT Email
from Clientes; -- 20



Select count(Email)
from clientes -- 17



SELECT DISTINCT(Email)
FROM Clientes; -- 18



-- Combinando valores de resultados de query (UNION)
-- Carros que estão alugados (na rua)

SELECT idVeiculo FROM Locacoes WHERE Status = 'Em Andamento'

--union -- Carros que estão na rua ou já foram para oficina ?

--union all -- carros que estão na rua e carros que estão na oficina ou que já foram para oficina

--intersect -- Carros na rua e já foram na oficina

except -- somente os carros que estão na rua que nunca foram pra oficina

SELECT idVeiculo FROM Manutencoes; -- carros que já passaram por manutenção



-- exemplo 1. extrato do caixa de agosto

SELECT
DataPagamento as Data,
FormaPagamento as Descricao,
'Entrada' as TipoMovimentacao,
Valor
FROM Pagamentos
WHERE DataPagamento >= '2026-08-01' AND DataPagamento < '2026-09-01'
UNION ALL
SELECT
DataSaida,
Descricao,
'Saida' as TipoMovimentacao,
Custo
FROM Manutencoes
WHERE Custo IS NOT NULL AND DataSaida >= '2026-08-01' AND DataSaida < '2026-09-01'


-- Quais carros estão no pátio de locação ??
-- combinações (union, union all, intersect, except)

select Veiculos.IdVeiculo from Veiculos
except
(
	select Locacoes.IdVeiculo from Locacoes where status = 'Em Andamento'
	union
	select Manutencoes.IdVeiculo from Manutencoes where DataSaida is null
)


-- Quem alugou todo mês?

-- Versão teste
select  distinct IdCliente, month(DataRetirada) as mes from Locacoes;


-- Versão final
select IdCliente from Locacoes
where month(DataRetirada) = 7
intersect
select IdCliente from Locacoes
where month(DataRetirada) = 8
intersect
select IdCliente from Locacoes
where month(DataRetirada) = 9
intersect
select IdCliente from Locacoes
where month(DataRetirada) = 10


-- Versão final
select Locacoes.IdCliente, trim(Clientes.Nome) as cliente from Locacoes
inner join Clientes
on Clientes.IdCliente = Locacoes.IdCliente
where month(DataRetirada) = 7
intersect
select Locacoes.IdCliente, trim(Clientes.Nome) from Locacoes
inner join Clientes
on Clientes.IdCliente = Locacoes.IdCliente
where month(DataRetirada) = 8
intersect
select Locacoes.IdCliente, trim(Clientes.Nome) from Locacoes
inner join Clientes
on Clientes.IdCliente = Locacoes.IdCliente
where month(DataRetirada) = 9
intersect
select Locacoes.IdCliente, trim(Clientes.Nome) from Locacoes
inner join Clientes
on Clientes.IdCliente = Locacoes.IdCliente
where month(DataRetirada) = 10


-- ----- TABELA TEMPORÁRIA -------

-- Primeira  forma

DROP TABLE IF EXISTS #Frota

SELECT IdVeiculo , COUNT(*) AS locacoes,
SUM(DATEDIFF(DAY, DataRetirada, DataDevolucao)) AS dias_rua
INTO #Frota
FROM Locacoes
WHERE STATUS = 'Finalizada'
GROUP BY IdVeiculo;


SELECT * FROM #Frota;



-- --------------------------------


drop table if exists #Teste
select Clientes.Nome, Clientes.Email
into #Teste
from Clientes;

select * from #Teste;