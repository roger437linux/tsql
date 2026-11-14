-- PARTE 1

-- P1. vw_ContatoTutor: id do tutor, nome padronizado, telefone só com os números, 
-- telefone no formato (19) 99812-3344, e-mail em minúsculas e bairro. Sem o CPF.

CREATE OR ALTER VIEW vw_ContatoTutor AS
WITH tutores_cte AS (
	SELECT Tutores.IdTutor AS id,
	UPPER(TRIM(Tutores.Nome)) AS tutor,
	TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Tutores.Telefone, '(', ''), ')', ''), '-', ''), ' ', '')) AS telefone,
	LOWER(TRIM(Tutores.Email)) AS email,
	LOWER(TRIM(Tutores.Bairro)) AS bairro
	FROM Tutores
)
SELECT id, tutor, telefone,
STUFF(STUFF(STUFF(telefone, 1, 0, '('), 4, 0, ')  '), 12, 0, '-') AS telefone_formatado,
email
FROM tutores_cte;
GO

SELECT * FROM vw_ContatoTutor;


-- P2. vw_VacinasPendentes: pet, vacina, vencimento, situação (Vencida ou Vence em 30 dias), 
-- nome do tutor e um contato: -- o telefone formatado ou, se não houver, o e-mail. 
-- Dentro da view, calcule o vencimento numa CTE, e pegue o contato da vw_ContatoTutor.

CREATE OR ALTER VIEW vw_VacinasPendentes AS
WITH vacinas_cte AS (
	SELECT
		TRIM(p.Nome) AS Nome_pet,
		s.NomeServico, s.ValidadeDias,		
		CAST(DATEADD(DAY, s.ValidadeDias, a.DataAtendimento) AS DATE) AS DataVencimento,
		UPPER(TRIM(t.Nome)) AS Nome_tutor,
		TRIM(REPLACE(REPLACE(REPLACE(REPLACE(t.Telefone, '(', ''), ')', ''), '-', ''), ' ', '')) AS Telefone, 
		t.Email
	FROM Servicos s
	INNER JOIN ItensAtendimento i
		ON s.IdServico = i.IdServico
	INNER JOIN Atendimentos a
		ON a.IdAtendimento = i.IdAtendimento
	INNER JOIN Pets p
		ON p.IdPet = a.IdPet
	INNER JOIN Tutores AS t
		ON t.IdTutor = p.IdTutor
	WHERE s.Categoria = 'Vacina' AND a.Status = 'Realizado'
)
select Nome_pet, NomeServico, ValidadeDias, DataVencimento, 
DATEDIFF(day, GETDATE(), DataVencimento) AS DiasParaVencer,
CASE
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) > 30 THEN 'Em dia'
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) = 30 THEN 'Vence em 30 dias'
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) BETWEEN 0 AND 29 THEN 'Menos de 30 dias'
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) < 0 THEN 'Vencida'
END AS SituacaoValidadeVacina, 
Nome_tutor,
CASE
	WHEN Telefone IS NOT NULL THEN Telefone
	WHEN Email IS NOT NULL THEN Email
	ELSE 'SEM CONTATO'
END AS Contato
from vacinas_cte;
GO

SELECT * FROM vw_VacinasPendentes;


-- P3. vw_Agenda: data, pet, espécie, tutor, contato e veterinário (Estética quando não houver), 
-- só dos atendimentos agendados. Use a vw_ContatoTutor.

create or alter view vw_Agenda as
select Atendimentos.DataAtendimento, 
Pets.Nome AS Nome_pet, Pets.Especie, 
vw_ContatoTutor.tutor, 
Veterinarios.Nome,
CASE
	WHEN Tutores.Telefone IS NOT NULL THEN Tutores.Telefone
	WHEN Tutores.Email IS NOT NULL THEN Tutores.Email
	ELSE 'SEM CONTATO'
END AS Contato
from Atendimentos
inner join Pets
on Pets.IdPet = Atendimentos.IdAtendimento
inner join vw_ContatoTutor
on Pets.IdTutor = vw_ContatoTutor.id
inner join Veterinarios
on Atendimentos.IdVeterinario = Veterinarios.IdVeterinario
inner join Tutores
on Tutores.IdTutor = Pets.IdTutor
where Status = 'Agendado';
go


select * from vw_Agenda;
