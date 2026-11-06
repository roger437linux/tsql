-- T1
-- Monte a lista dos tutores com o cadastro padronizado: id, nome sem espaços sobrando e em maiúsculas, 
-- telefone só com os números, telefone no formato (19) 99812-3344 e e-mail em minúsculas


SELECT * FROM Tutores;


WITH tutores_cte AS (
	SELECT Tutores.IdTutor AS id,
	UPPER(TRIM(Tutores.Nome)) AS tutor,
	TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Tutores.Telefone, '(', ''), ')', ''), '-', ''), ' ', '')) AS telefone,
	LOWER(TRIM(Tutores.Email)) AS email
	FROM Tutores
)
SELECT id, tutor, telefone,
STUFF(STUFF(STUFF(telefone, 1, 0, '('), 4, 0, ')  '), 12, 0, '-') AS telefone_formatado,
email
FROM tutores_cte;


-- T2
-- Crie a variável @IdPet e gere uma única coluna Ficha com o nome do pet, a espécie, 
-- a raça (ou SRD quando não houver), o nome do tutor padronizado e o telefone formatado, 
-- separados por |. É a variável que torna a consulta reutilizável: muda o número, roda de novo, e a ficha é de outro pet. 


DECLARE @IdPet INT = 1;
WITH tutores_cte AS (
	SELECT Tutores.IdTutor AS id,
	UPPER(TRIM(Tutores.Nome)) AS tutor,
	TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Tutores.Telefone, '(', ''), ')', ''), '-', ''), ' ', '')) AS fone	
	FROM Tutores
)
SELECT TRIM(p.Nome) AS Nome, TRIM(p.Especie) AS Especie,
CASE
	WHEN p.Raca IS NULL THEN 'SRD'
	ELSE TRIM(p.Raca)
END AS Raca,
tutor,
STUFF(STUFF(STUFF(t.fone, 1, 0, '('), 4, 0, ')  '), 12, 0, '-') AS telefone
FROM Pets p
INNER JOIN tutores_cte t
ON p.IdTutor = t.id
WHERE p.IdPet = @IdPet;



/*

DECLARE @IdLocacao INT = 144;
SELECT
CONCAT(
		'Locação ', Locacoes.IdLocacao, 
		' | Cliente: ', Clientes.Nome, 
		' | Veículo: ', Veiculos.Marca, 
		' ', Veiculos.Modelo, 
		' (', STUFF(Veiculos.Placa, 4, 0, '-'), ')', 
		' | Retirada: ', CONVERT(VARCHAR(10), Locacoes.DataRetirada, 103), 
		' | Diária: R$ ', REPLACE(Locacoes.ValorDiaria, '.', ',')
) AS Comprovante
FROM Clientes
INNER JOIN Locacoes
ON Clientes.IdCliente = Locacoes.IdCliente
INNER JOIN Veiculos
ON Veiculos.IdVeiculo = Locacoes.IdVeiculo
WHERE Locacoes.IdLocacao = @IdLocacao;


*/




















DECLARE @Hoje DATE = '2026-10-30';

-- 1. Eu consigo falar com os meus clientes?

-- Qtde de tutores
select count(*) from Tutores;


-- Apenas sem telefone
select count(*) from Tutores 
where Telefone is null and Email is not null;


-- Apenas sem email
select count(*) from Tutores 
where Telefone is not null and Email is null;

select * from Tutores 
where Telefone is not null and Email is null;


-- Sem telefone e email
select count(*) from Tutores 
where Telefone is null and Email is null;


-- O que eu recomendo: [ação concreta: quem faz, o quê e quando para a recepção completar os cadastros faltantes durante o atendimento].

-- O que eu recomendo: Durante cada atendimento, que a recepção atualize os dados de cada tutor.























