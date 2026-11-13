
--Crie a view vw_Pets com o id, o nome e a espécie do pet, a raça (SRD quando não houver), 
--o nome do tutor padronizado (sem espaços sobrando e em maiúsculas) e o bairro. 
--Depois, use a view para contar quantos pets há em cada bairro.

-- VIEW
CREATE OR ALTER VIEW vw_tutor_pet AS
SELECT Pets.IdPet, Pets.Nome AS Nome_pet, Pets.Especie,
CASE
	WHEN Pets.Raca IS NULL THEN 'SRD'
	ELSE Pets.Raca
END AS Raca,
ISNULL(Pets.Raca, 'SRD') AS Raca_f2,
UPPER(TRIM(Tutores.Nome)) Nome_tutor, Tutores.Bairro
FROM Pets
INNER JOIN Tutores
ON Tutores.IdTutor = Pets.IdTutor;
GO

-- CONSULTAS
SELECT * FROM vw_tutor_pet;

SELECT bairro, count(Nome_pet) qtde_pet
FROM vw_tutor_pet
GROUP BY Bairro
ORDER BY qtde_pet DESC;

-- Obter a query que gerou a view
EXEC sp_helptext vw_tutor_pet;


-- ------------------------------


-- SUBQUERY

--Quais veterinários não fizeram nenhum atendimento em setembro de 2026? 
--Resolva duas vezes: com NOT IN e com NOT EXISTS. Os resultados são iguais?


-- Utilizando NOT IN
SELECT
    V.IdVeterinario,
    V.Nome,
    V.Especialidade
FROM VETERINARIOS V
WHERE V.IdVeterinario NOT IN (
    SELECT A.IdVeterinario
    FROM ATENDIMENTOS A
    WHERE A.DataAtendimento >= '20260901'
      AND A.DataAtendimento < '20261001'
      AND A.IdVeterinario IS NOT NULL
);


-- Utilizando NOT EXISTS
SELECT
    V.IdVeterinario,
    V.Nome,
    V.Especialidade
FROM VETERINARIOS V
WHERE NOT EXISTS (
    SELECT 1
    FROM ATENDIMENTOS A
    WHERE A.IdVeterinario = V.IdVeterinario
      AND A.DataAtendimento >= '20260901'
      AND A.DataAtendimento < '20261001'
);


--Quais atendimentos realizados custaram mais que a média dos atendimentos realizados? 
--Mostre o id, a data e o total, do maior para o menor. 
--Não use a view da Q2: calcule o total de cada atendimento numa subconsulta no FROM.

SELECT
    AtendimentoId,
    DataAtendimento,
    TotalAtendimento
FROM (
    -- Calcula o total de cada atendimento
    SELECT
        A.IdAtendimento AS AtendimentoId,
        A.DataAtendimento,
        SUM(IA.Quantidade * IA.PrecoCobrado) AS TotalAtendimento
    FROM ATENDIMENTOS A
    INNER JOIN ITENSATENDIMENTO IA
        ON A.IdAtendimento = IA.IdAtendimento
    WHERE A.Status = 'Realizado'
    GROUP BY
        A.IdAtendimento,
        A.DataAtendimento
) AS Faturamento

WHERE TotalAtendimento > (
    -- Calcula a média dos atendimentos realizados
    SELECT AVG(Total)
    FROM (
        SELECT
            SUM(IA.Quantidade * IA.PrecoCobrado) AS Total
        FROM ATENDIMENTOS A
        INNER JOIN ITENSATENDIMENTO IA
            ON A.IdAtendimento = IA.IdAtendimento
        WHERE A.Status = 'Realizado'
        GROUP BY A.IdAtendimento
    ) AS MediaAtendimentos
)

ORDER BY TotalAtendimento DESC;

