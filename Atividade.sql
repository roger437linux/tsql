-- 4. Exercícios

-- Nível 1 — Aquecimento

-- Q1. Declare @NomeLoja com o valor 'Locadora Veloz' e @Hoje com a data 23/10/2026. 
--     Mostre as duas num SELECT, com a data no formato brasileiro.

DECLARE @NomeLoja VARCHAR(100) = 'Locadora Veloz';
DECLARE @Hoje DATE = '2026/10/23';

SELECT 
@NomeLoja AS 'Nome Loja',
CONVERT(VARCHAR(10), @Hoje, 103) AS 'Data';


-- Q2. Liste o nome de todos os clientes padronizado: sem espaços sobrando e em maiúsculas.

SELECT 
UPPER(TRIM(TRIM(Nome )) AS 'Nome cliente'
FROM Clientes;


-- Q3. O balcão quer as placas com hífen, no formato RVA-1B23. Liste a placa formatada, 
--     a marca e o modelo de todos os veículos.

SELECT Marca, Modelo,
STUFF(Placa, 4, 0, '-') AS Placa
FROM Veiculos;


-- Q4. Crie a variável @Cidade e liste o nome e o telefone dos clientes dessa cidade. 
--     Teste com 'Valinhos' e depois com 'Campinas'.


DECLARE @Cidade VARCHAR(100) = 'Valinhos';
SELECT TRIM(Nome), 
STUFF(STUFF(TRIM(Telefone), 3, 0, ' '), 9, 0, '-'), 
TRIM(Cidade)
FROM Clientes
WHERE Cidade = @Cidade;

SET @Cidade = 'Campinas'
SELECT TRIM(Nome), 
STUFF(STUFF(TRIM(Telefone), 3, 0, ' '), 9, 0, '-'), 
TRIM(Cidade)
FROM Clientes
WHERE Cidade = @Cidade;


-- Nível 2 — Formatando

-- Q5. Mostre o nome e o CPF formatado de todos os clientes, no padrão 529.982.247-25.

SELECT 
TRIM(Nome),
STUFF(STUFF(STUFF(CPF, 4, 0, '.'), 8, 0, '.'), 12, 0, '-')
FROM Clientes;


-- Q6. Monte a frase de contato Nome - e-mail de duas formas, lado a lado: com + e com CONCAT. 
--     Quantas linhas ficam NULL na versão com +? Por quê?

-- R: Ao concatenar com '+' ficam três linhas NULL pois nessa forma, havendo algum campo NULL a resultante também é NULL.


SELECT 
CONCAT(UPPER(TRIM(Nome)), ' - ', LOWER(TRIM(Email)))
FROM Clientes;

SELECT 
UPPER(TRIM(Nome)) + ' - ' + LOWER(TRIM(Email))
FROM Clientes;


-- Q7. Guarde numa variável quantos veículos estão disponíveis e escreva na aba Messages a frase: 
--     Temos 8 carros disponíveis hoje.

DECLARE @QtdeVeiculosDisp INT = (SELECT COUNT(*) FROM Veiculos);
PRINT CONCAT('Temos ', @QtdeVeiculosDisp, ' carros disponíveis hoje.');


-- Nível 3 — Desafio

-- Q8. Seu Ricardo quer saber quais provedores de e-mail os clientes usam. 
--     Mostre o domínio (o que vem depois do @), em minúsculas, e quantos 
--     clientes usam cada um, do mais usado para o menos usado.

WITH clIentes_cte AS (
	SELECT 
	RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) as Domain
	FROM Clientes
)
SELECT LOWER(Domain) AS Domain, COUNT(*) AS Qtde_clientes
FROM clientes_cte
WHERE Domain IS NOT NULL
GROUP BY Domain
ORDER BY Qtde_clientes DESC;


-- Q9. Encontre os clientes com espaços sobrando no começo ou no fim do nome.

SELECT
CASE
	WHEN CHARINDEX(' ', Nome) = 1 THEN TRIM(Nome)
	WHEN CHARINDEX(' ', RIGHT(Nome, 1)) > 0 THEN TRIM(Nome)
	ELSE ''
END AS Cliente
FROM Clientes;


-- Q10. Crie a variável @IdLocacao com o valor 144 e gere uma única coluna Comprovante com o texto:
--      Locação 144 | Cliente: BRUNO CARVALHO | Veículo: Jeep Renegade (RST-8M56) | Retirada: 20/10/2026 | Diária: R$ 240,00

DECLARE @IdLocacao INT = 144;

SELECT Locacoes.IdLocacao, Clientes.Nome, Veiculos.Marca, Veiculos.Modelo, Veiculos.Placa, Locacoes.DataRetirada, Locacoes.ValorDiaria
FROM Clientes
INNER JOIN Locacoes
ON Clientes.IdCliente = Locacoes.IdCliente
INNER JOIN Veiculos
ON Veiculos.IdVeiculo = Locacoes.IdVeiculo
WHERE Locacoes.IdLocacao = @IdLocacao;

