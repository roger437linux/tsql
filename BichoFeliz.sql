/*
	Capítulo 1 · Antes do primeiro lembrete
*/

-- T1
-- Monte a lista dos tutores com o cadastro padronizado: id, nome sem espaços sobrando e em maiúsculas, 
-- telefone só com os números, telefone no formato (19) 99812-3344 e e-mail em minúsculas

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


DECLARE @IdPet INT = 13;
WITH tutores_cte AS (
	SELECT Tutores.IdTutor AS id,
	UPPER(TRIM(Tutores.Nome)) AS tutor,
	TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Tutores.Telefone, '(', ''), ')', ''), '-', ''), ' ', '')) AS fone	
	FROM Tutores
)
SELECT
CONCAT(
	TRIM(p.Nome), ' | ',
	TRIM(p.Especie), ' | ',
	CASE
		WHEN p.Raca IS NULL THEN 'SRD'
		ELSE TRIM(p.Raca)
	END, ' | ',
	tutor, ' | ',
	STUFF(STUFF(STUFF(t.fone, 1, 0, '('), 4, 0, ')  '), 12, 0, '-')
) AS Ficha
FROM Pets p
INNER JOIN tutores_cte t
ON p.IdTutor = t.id
WHERE p.IdPet = @IdPet;


/*
	Capítulo 2 · O que as datas contam
*/


-- T3
-- Liste os pets com nome, espécie, raça (SRD quando NULL), idade em anos completos em @Hoje e faixa etária: 
-- Filhote (menos de 1 ano), Adulto (de 1 a 7) e Idoso (8 ou mais). 
-- Pet sem data de nascimento fica com a faixa Idade desconhecida

DECLARE @Hoje DATE = GETDATE();
WITH pets_cte AS (
	SELECT 
		Nome, Especie, 
		CASE
			WHEN Raca IS NULL THEN 'SRD'
			ELSE Raca
		END AS Raca,
		DATEDIFF(YEAR, Pets.DataNascimento, @Hoje) - 
    CASE 
        WHEN DATEADD(year, DATEDIFF(year, '2025-11-10', GETDATE()), '2025-11-10') > GETDATE() 
        THEN 1 
        ELSE 0 
    END AS Idade
	FROM Pets
)
SELECT Nome, Especie, Raca, Idade,
CASE
	WHEN Idade < 1 THEN 'Filhote'
	WHEN Idade BETWEEN 1 AND 7 THEN 'Adulto'
	WHEN Idade >= 8 THEN 'Idoso'
	ELSE 'Desconhecida'
END AS FaixaEtaria
FROM pets_cte;


-- T4
-- Em uma única linha, mostre quantos atendimentos foram realizados, cancelados, com falta e agendados.

DECLARE @Atendimentos INT = (SELECT count(*) FROM Atendimentos WHERE Status = 'Agendado');
DECLARE @Realizados INT = (SELECT count(*) FROM Atendimentos WHERE Status = 'Realizado');
DECLARE @Cancelados INT = (SELECT count(*) FROM Atendimentos WHERE Status = 'Cancelado');
DECLARE @Faltou INT = (SELECT count(*) FROM Atendimentos WHERE Status = 'Faltou');
SELECT 
CONCAT (
	'Agendados: ', @Atendimentos, ' | ',
	'Realizados: ', @Realizados,  ' | ',
	'Cancelados: ', @Cancelados,  ' | ',
	'Faltaram: ', @Faltou
);


-- T5
-- O “de verdade” é a parte importante: releia a regra de faturamento antes de começar. 
-- Mostre o faturamento de cada mês: ano, mês, quantidade de atendimentos 
-- realizados e faturamento, em ordem cronológica

-- Faturamento = Quantidade × PrecoCobrado, da tabela ItensAtendimento, só de atendimentos com Status = 'Realizado'

WITH atendimento_cte AS (
	select a.DataAtendimento,
		YEAR(a.DataAtendimento) AS Ano, 
		MONTH(a.DataAtendimento) AS Mes,
		i.Quantidade, i.PrecoCobrado,
		(i.Quantidade * i.PrecoCobrado) AS faturamento_atend,
		a.Status
	from ItensAtendimento i
	INNER JOIN Atendimentos a
	ON a.IdAtendimento = i.IdAtendimento
	WHERE a.Status = 'Realizado'
)
select Ano, Mes, 
SUM(faturamento_atend) AS Faturamento,
COUNT(*) AS Qtde_atendimento
from atendimento_cte
GROUP BY Mes, Ano
ORDER BY Ano ASC, Mes ASC;


-- T6
-- Para cada pet e cada vacina que ele já tomou, mostre a data da última aplicação, 
-- a data de vencimento e a situação: Vencida, Vence em 30 dias ou Em dia. 
-- Antes de conferir o resultado, pergunte-se: um pet que tinha vacina marcada e faltou tomou a vacina?

-- SELECT CAST(DATEADD(day, 366, '2000-01-01') AS DATE) AS NovaData;

WITH vacinas_cte AS (
	SELECT
		p.Nome, p.Especie,
		s.NomeServico, s.Categoria, s.ValidadeDias,
		a.DataAtendimento AS DataAplicacao,
		CAST(DATEADD(DAY, s.ValidadeDias, a.DataAtendimento) AS DATE) AS DataVencimento
	FROM Servicos s
	INNER JOIN ItensAtendimento i
		ON s.IdServico = i.IdServico
	INNER JOIN Atendimentos a
		ON a.IdAtendimento = i.IdAtendimento
	INNER JOIN Pets p
		ON p.IdPet = a.IdPet
	WHERE s.Categoria = 'Vacina' AND a.Status = 'Realizado'
)
select Nome, Especie, NomeServico, Categoria, ValidadeDias, DataAplicacao, DataVencimento,
DATEDIFF(day, GETDATE(), DataVencimento) AS DiasParaVencer,
CASE
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) > 30 THEN 'Em dia'
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) = 30 THEN 'Vence em 30 dias'
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) BETWEEN 0 AND 29 THEN 'Menos de 30 dias'
	WHEN DATEDIFF(day, GETDATE(), DataVencimento) < 0 THEN 'Vencida'
END AS SituacaoValidadeVacina
from vacinas_cte;


-- T7
-- Quais pets nunca tomaram nenhuma vacina na clínica? 
-- Use EXCEPT e mostre o nome deles.

WITH PetsSemVacina AS (
    SELECT IdPet, Nome FROM PETS
    EXCEPT
    SELECT P.IdPet, P.Nome
    FROM PETS P
    INNER JOIN ATENDIMENTOS A
        ON P.IdPet = A.IdPet
    INNER JOIN ITENSATENDIMENTO IA
        ON A.IdAtendimento = IA.IdAtendimento
    INNER JOIN SERVICOS S
        ON IA.IdServico = S.IdServico
    WHERE S.Categoria = 'Vacina'
)
SELECT Nome FROM PetsSemVacina;


-- T8
-- Quais tutores tiveram atendimento realizado em setembro de 2026 e 
-- não voltaram em outubro? E quantos vieram nos dois meses?

-- Setembro, más não outubro

WITH TutoresSetembro AS (
    SELECT DISTINCT T.IdTutor, T.Nome
    FROM TUTORES T
    INNER JOIN PETS P
        ON T.IdTutor = P.IdTutor
    INNER JOIN ATENDIMENTOS A
        ON P.IdPet = A.IdPet
    WHERE A.DataAtendimento >= '20260901'
      AND A.DataAtendimento <  '20261001'
),
TutoresOutubro AS (
    SELECT DISTINCT T.IdTutor, T.Nome
    FROM TUTORES T
    INNER JOIN PETS P
        ON T.IdTutor = P.IdTutor
    INNER JOIN ATENDIMENTOS A
        ON P.IdPet = A.IdPet
    WHERE A.DataAtendimento >= '20261001'
      AND A.DataAtendimento <  '20261101'
)
SELECT IdTutor, Nome
FROM TutoresSetembro
EXCEPT
SELECT IdTutor, Nome
FROM TutoresOutubro;

-- Vieram nos dois meses

WITH TutoresSetembro AS (
    SELECT DISTINCT T.IdTutor, T.Nome
    FROM TUTORES T
    INNER JOIN PETS P
        ON T.IdTutor = P.IdTutor
    INNER JOIN ATENDIMENTOS A
        ON P.IdPet = A.IdPet
    WHERE A.DataAtendimento >= '20260901'
      AND A.DataAtendimento <  '20261001'
),
TutoresOutubro AS (
    SELECT DISTINCT T.IdTutor, T.Nome
    FROM TUTORES T
    INNER JOIN PETS P
        ON T.IdTutor = P.IdTutor
    INNER JOIN ATENDIMENTOS A
        ON P.IdPet = A.IdPet
    WHERE A.DataAtendimento >= '20261001'
      AND A.DataAtendimento <  '20261101'
)
SELECT
    COUNT(*) AS QuantidadeTutoresNosDoisMeses
FROM (
    SELECT IdTutor, Nome
    FROM TutoresSetembro

    INTERSECT

    SELECT IdTutor, Nome
    FROM TutoresOutubro
) AS TutoresEmAmbos;


-- T9
-- Algum serviço do catálogo nunca foi vendido? 
-- Se tiver, ele é candidato a sair da tabela de preços. 

SELECT
    IdServico,
    NomeServico,
    Categoria,
    Preco
FROM SERVICOS

EXCEPT

SELECT
    S.IdServico,
    S.NomeServico,
    S.Categoria,
    S.Preco
FROM SERVICOS S
INNER JOIN ITENSATENDIMENTO IA
    ON S.IdServico = IA.IdServico;



-- T10
-- São duas perguntas sobre o mesmo cálculo. Primeiro, guarde numa tabela temporária #FaturamentoVet o nome do veterinário 
-- e o faturamento de cada um em 2026; banho e tosa aparecem como Estética (sem veterinário). 
-- Depois, guarde o total numa variável e mostre cada linha com o percentual do total, do maior para o menor.

-- Tabela temporária #FaturamentoVet

DROP TABLE IF EXISTS #FaturamentoVet;
SELECT
    CASE
        WHEN S.Categoria = 'Estética' THEN 'Estética'
        ELSE COALESCE(V.Nome, 'Sem veterinário')
    END AS NomeVeterinario,
    SUM(IA.Quantidade * IA.PrecoCobrado) AS Faturamento
INTO #FaturamentoVet
FROM ATENDIMENTOS A
INNER JOIN ITENSATENDIMENTO IA
    ON A.IdAtendimento = IA.IdAtendimento
INNER JOIN SERVICOS S
    ON IA.IdServico = S.IdServico
LEFT JOIN VETERINARIOS V
    ON A.IdVeterinario = V.IdVeterinario
WHERE A.DataAtendimento >= '20260101'
  AND A.DataAtendimento < '20270101'
GROUP BY
    CASE
        WHEN S.Categoria = 'Estética' THEN 'Estética'
        ELSE COALESCE(V.Nome, 'Sem veterinário')
    END;


-- Calcular os percentuais
DECLARE @FaturamentoTotal DECIMAL(18,2);
SELECT @FaturamentoTotal = SUM(Faturamento)
FROM #FaturamentoVet;

SELECT NomeVeterinario, Faturamento,
CAST(
    Faturamento * 100.0 /
    NULLIF(@FaturamentoTotal, 0)
    AS DECIMAL(6,2)
) AS Percentual
FROM #FaturamentoVet
ORDER BY Faturamento DESC;



-- T11
-- Registre o atendimento de hoje da Mia (pet 2) com o Dr. Lucas (veterinário 4) e os três itens numa transação, 
-- com o preço atual de cada serviço. Confira o total e, como é um ensaio, termine com ROLLBACK. 
-- Repare que o preço é copiado para ItensAtendimento.PrecoCobrado: por que guardar o preço de novo, 
-- se ele já está em Servicos? Lembre do reajuste de setembro.


-- Serviços que serão incluídos no atendimento
DECLARE @Itens TABLE (
    NomeServico VARCHAR(100),
    Quantidade INT
);

INSERT INTO @Itens (NomeServico, Quantidade)
VALUES
    ('Banho', 1),
    ('Tosa', 1),
    ('Corte de unha', 1);

-- Variáveis de controle
DECLARE @IdAtendimento INT;
DECLARE @QuantidadeInserida INT;

BEGIN TRY

    BEGIN TRANSACTION;

    -- 1. Registrar o atendimento
    INSERT INTO ATENDIMENTOS (
        IdPet,
        IdVeterinario,
        DataAtendimento,
        Status,
        Observacao
    )
    VALUES (
        2,
        4,
        '20261106',
        'Realizado',
        'Ensaio de transacao'
    );

    -- Recuperar o ID gerado automaticamente
    SET @IdAtendimento = SCOPE_IDENTITY();


    -- 2. Inserir os três serviços com os preços atuais
    INSERT INTO ITENSATENDIMENTO (
        IdAtendimento,
        IdServico,
        Quantidade,
        PrecoCobrado
    )
    SELECT
        @IdAtendimento,
        S.IdServico,
        I.Quantidade,
        S.Preco
    FROM @Itens I
    INNER JOIN SERVICOS S
        ON I.NomeServico = S.NomeServico;


    -- 3. Conferir se os três itens foram encontrados
    SET @QuantidadeInserida = @@ROWCOUNT;

    IF @QuantidadeInserida <> (SELECT COUNT(*) FROM @Itens)
        THROW 50001, 'Nem todos os servicos foram encontrados no catalogo.', 1;


    -- 4. Consultar os itens do atendimento
    SELECT
        A.IdAtendimento,
        S.NomeServico,
        IA.Quantidade,
        IA.PrecoCobrado,
        IA.Quantidade * IA.PrecoCobrado AS Subtotal
    FROM ATENDIMENTOS A
    INNER JOIN ITENSATENDIMENTO IA
        ON A.IdAtendimento = IA.IdAtendimento
    INNER JOIN SERVICOS S
        ON IA.IdServico = S.IdServico
    WHERE A.IdAtendimento = @IdAtendimento;


    -- 5. Conferir o faturamento total
    SELECT
        @IdAtendimento AS IdAtendimento,
        SUM(IA.Quantidade * IA.PrecoCobrado) AS TotalAtendimento
    FROM ITENSATENDIMENTO IA
    WHERE IA.IdAtendimento = @IdAtendimento;


    -- 6. Desfazer todas as operações
    ROLLBACK TRANSACTION;

    PRINT 'Ensaio concluido: transacao revertida com sucesso.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;


-- T12
-- Numa transação, mude para Cancelado o status dos agendamentos futuros dos pets dela, 
-- mostre quantas linhas mudaram e confirme. Dessa vez não é ensaio: 
-- termina com COMMIT, e a mudança fica no banco. No arquivo:

DECLARE @IdTutor INT = 1; -- Substituir pelo ID da tutora
DECLARE @LinhasAlteradas INT;
BEGIN TRY
    BEGIN TRANSACTION;
    -- Cancelar agendamentos futuros de todos os pets da tutora
    UPDATE A
    SET A.Status = 'Cancelado'
    FROM ATENDIMENTOS A
    INNER JOIN PETS P
        ON A.IdPet = P.IdPet
    WHERE P.IdTutor = @IdTutor
      AND A.DataAtendimento > CAST(GETDATE() AS DATE)
      AND A.Status = 'Agendado';
    -- Guardar quantidade de registros alterados
    SET @LinhasAlteradas = @@ROWCOUNT;
    -- Mostrar quantidade de alterações
    SELECT
        @IdTutor AS IdTutor,
        @LinhasAlteradas AS AgendamentosCancelados;
    -- Confirmar definitivamente as alterações
    COMMIT TRANSACTION;
    PRINT 'Transacao confirmada com sucesso!';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;


-- T13
-- Numa transação, apague o pet e o cadastro da Yasmin, mostrando com OUTPUT o que saiu. 
-- Depois, na mesma transação, tente apagar o Roberto (tutor 2). 
-- Explique num comentário por que um sai e o outro não, e termine com ROLLBACK.



-- R: Yasmin foi excluída porque seus pets foram apagados primeiro; 
--    Roberto não foi excluído porque ainda possui pets vinculados a ele pela chave estrangeira.


BEGIN TRY

    BEGIN TRANSACTION;

    -- 1. Excluir os pets da tutora Yasmin
    -- OUTPUT DELETED mostra os registros removidos.

    DELETE P
    OUTPUT
        DELETED.IdPet,
        DELETED.IdTutor,
        DELETED.Nome,
        DELETED.Especie
    FROM PETS P
    INNER JOIN TUTORES T
        ON P.IdTutor = T.IdTutor
    WHERE T.Nome = 'Yasmin';


    -- 2. Excluir o cadastro da tutora Yasmin

    DELETE FROM TUTORES
    OUTPUT
        DELETED.IdTutor,
        DELETED.Nome,
        DELETED.CPF,
        DELETED.Telefone
    WHERE Nome = 'Yasmin';


    -- 3. Tentar excluir Roberto (tutor 2)

    BEGIN TRY

        DELETE FROM TUTORES
        OUTPUT
            DELETED.IdTutor,
            DELETED.Nome,
            DELETED.CPF
        WHERE IdTutor = 2;

        PRINT 'Roberto excluido com sucesso.';

    END TRY

    BEGIN CATCH

        PRINT 'Nao foi possivel excluir Roberto.';
        PRINT ERROR_MESSAGE();

        -- A exclusão é impedida se Roberto ainda possuir pets
        -- referenciando seu IdTutor pela FK de PETS.
        -- A restrição protege a integridade referencial.

    END CATCH;


    -- 4. Desfazer todas as operações do ensaio

    ROLLBACK TRANSACTION;

    PRINT 'Transacao revertida. Nenhuma exclusao foi permanente.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;