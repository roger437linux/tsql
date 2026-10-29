
-- Quantos dias xada carro ficou fora?
-- Quem está atrasado
-- Quanto cobrar?


-- Seu Ricardo que mandar parabéns aos clientes pelo aniversário.
-- 


-- -------------------------------------------------------------


-- Datas no SQL Server

-- Date
-- Datetime
-- Datetime2

DECLARE @Data date = getdate();
print(@Data);
print DAY(@Data);
SELECT DATEDIFF(YEAR, @Data, '2025-10-28');


-- -------------------------------------------------------------




-- FUNÇÕES DE DATA
-- TRATAMENTO DE NULOS (ISNULL/COALESCE)
-- CASE

---quantos dias cada carro ficou fora?
--quem está atrasado?
--quanto cobrar?

--O caixa quer ver as locações por 
--situação (disponível, lugado, manutenção) numa linha só

--Seu Ricardo quer mandar parabéns aos clientes que fazem aniversário

--DECLARE @DataAtual DATE = '2026-10-28';
DECLARE @DataAtual DATE = GETDATE();

-- mostrando fragmentos da data
PRINT MONTH(@DataAtual);
PRINT YEAR(@DataAtual);
PRINT DAY(@DataAtual);

-- somar valores de data

PRINT DATEADD(YEAR, 8, @DataAtual);
--SELECT DATEADD(year, 1, '20170825') as DataAdicionada;

--DATEDIFF(interval, date1, date2)

PRINT DATEDIFF(YEAR, '2026-10-28', '2027-10-28');


--tratativa de erros
--COALESCE(val1, val2, ...., val_n)

print coalesce(NULL, 'Cliente não tem telefone');

--ISNULL(expression, value)
print isnull(NULL, 'não possui valor');


-- -------------------------------------------------------------



select distinct(Locacoes.Status) from Locacoes;

-- Quantos dias cada carro ficou fora?

select 
Locacoes.IdLocacao,
Locacoes.DataRetirada,
Locacoes.DataDevolucao,		-- Ainda alugado
DATEDIFF(day, Locacoes.DataRetirada, Locacoes.DataDevolucao) as dias_fora		-- N/A caso seja null
from Locacoes;


-- Tratar o valor null e retornar a informação do carro

SELECT
Veiculos.Marca, Veiculos.Modelo, Veiculos.Placa,
-- Locacoes.IdLocacao,
Locacoes.DataRetirada,
COALESCE(CONVERT(VARCHAR(20), Locacoes.DataDevolucao, 103),  'ALUGADO') AS DataDevolucao,
COALESCE(CAST(DATEDIFF(DAY, Locacoes.DataRetirada, Locacoes.DataDevolucao) AS varchar(10)), 'Ñ ENTREGUE') AS 'Dias alugado'
FROM Locacoes
INNER JOIN Veiculos
ON Veiculos.IdCategoria = Locacoes.IdVeiculo;



-- Diferença entre data prevista de devolução para a data de devolução

SELECT
Veiculos.Marca, Veiculos.Modelo, Veiculos.Placa,
-- Locacoes.IdLocacao,
Locacoes.DataRetirada,
COALESCE(CONVERT(VARCHAR(20), Locacoes.DataDevolucao, 103),  'ALUGADO') AS DataDevolucao,
COALESCE(CAST(DATEDIFF(DAY, Locacoes.DataRetirada, Locacoes.DataDevolucao) AS varchar(10)), 'Ñ ENTREGUE') AS 'Dias alugado',
COALESCE(CONVERT(VARCHAR(20), Locacoes.DataPrevistaDevolucao, 103),  'ALUGADO') AS DataPrevistaDevolucao,
COALESCE(CONVERT(VARCHAR(20), Locacoes.DataDevolucao, 103),  'ALUGADO') AS DataDevolucao,
coalesce(cast(DATEDIFF(day, Locacoes.DataPrevistaDevolucao, Locacoes.DataDevolucao) as varchar(20)), 'Atraso na entrega') as Dias_alem_prazo
FROM Locacoes
INNER JOIN Veiculos
ON Veiculos.IdCategoria = Locacoes.IdVeiculo
where Locacoes.Status != 'Cancelada';


-- -------------------------------------------------------------

-- CASE

select Modelo, Quilometragem,
case
	when Quilometragem < 35e3 then 'NOVO'
	when Quilometragem < 50e3 then 'SEMINOVO'
	else 'RODADO'
end AS Estado
FROM Veiculos;


select IdLocacao,
case status
	when 'Finalizada' then 'Encerrado'
	when 'Em andamento' then 'Com o cliente'
	when 'Cancelada' then 'Contrato encerrado'
	else 'Não ocorreu locãção'
end as situacao
from Locacoes;