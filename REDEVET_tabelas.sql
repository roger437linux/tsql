-- Índices


/* =====================================================================
   REDEVET  |  tabela VacinasRede no banco BichoFeliz  |  SQL Server (SSMS)
   Sprint 4, Aula 2: 300 mil aplicações de vacina de 12 clínicas parceiras
   ---------------------------------------------------------------------
   Rode DEPOIS do script do BichoFeliz. Pode rodar de novo sem erro:
   apaga e recria a tabela. Leva alguns segundos.
   ===================================================================== */

USE BichoFeliz;
GO

-- As views indexadas da aula ficam presas à tabela (SCHEMABINDING): apague antes
DROP VIEW IF EXISTS dbo.vw_VacinasPorAno;
DROP VIEW IF EXISTS dbo.vw_AplicacoesPorClinica;
DROP TABLE IF EXISTS dbo.VacinasRede;
GO

CREATE TABLE dbo.VacinasRede (
    IdAplicacao    INT IDENTITY(1,1) CONSTRAINT PK_VacinasRede PRIMARY KEY,  -- índice clusterizado
    CPFTutor       CHAR(11)     NOT NULL,
    NomePet        VARCHAR(50)  NOT NULL,
    Especie        VARCHAR(10)  NOT NULL,
    Vacina         VARCHAR(50)  NOT NULL,
    DataAplicacao  DATE         NOT NULL,
    Clinica        VARCHAR(60)  NOT NULL,
    Cidade         VARCHAR(40)  NOT NULL
);
GO

/* 1. As aplicações das clínicas parceiras: 75 mil pets, 4 visitas cada, uma por ano */
WITH Numeros AS (
    SELECT TOP (300000) CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS INT) - 1 AS n
    FROM sys.all_columns a
    CROSS JOIN sys.all_columns b
),
Base AS (
    SELECT n,
           n % 75000                    AS t,   -- o pet (e o tutor)
           n / 75000                    AS j,   -- a visita: 0, 1, 2 ou 3
           (n % 75000 * 7 + n / 75000) % 12 AS c  -- a clínica
    FROM Numeros
)
INSERT INTO dbo.VacinasRede (CPFTutor, NomePet, Especie, Vacina, DataAplicacao, Clinica, Cidade)
SELECT
    CAST(10000000000 + CAST(t AS BIGINT) * 7919 AS CHAR(11)),
    CHOOSE(t % 20 + 1, 'Bidu', 'Mel', 'Thor', 'Luna', 'Nina', 'Bob', 'Lola', 'Max', 'Pipoca', 'Fred',
                       'Amora', 'Toby', 'Belinha', 'Simba', 'Mia', 'Rex', 'Nala', 'Zeus', 'Pandora', 'Chico'),
    CASE WHEN t % 3 = 0 THEN 'Gato' ELSE 'Cão' END,
    CASE WHEN (t + j) % 2 = 1 THEN 'Vacina antirrábica'
         WHEN t % 3 = 0       THEN 'Vacina V4 felina'
         ELSE 'Vacina V10' END,
    DATEADD(DAY, (t * 37) % 365 + j * 365, CAST('2022-10-01' AS DATE)),
    CHOOSE(c + 1, 'Amigo Fiel', 'Pata Amiga', 'VetCare Cambuí', 'Clínica São Francisco', 'Patas & Cia',
                  'Vida Animal', 'Bem-Estar Pet', 'Hospital Vet Taquaral', 'Cão & Gato', 'PetSaúde',
                  'Arca de Noé', 'Clínica Barão'),
    CASE WHEN c < 8  THEN 'Campinas'
         WHEN c = 8  THEN 'Valinhos'
         WHEN c = 9  THEN 'Sumaré'
         WHEN c = 10 THEN 'Hortolândia'
         ELSE 'Paulínia' END
FROM Base
ORDER BY n;

/* 2. Pets da Bicho Feliz que também foram vacinados em clínicas da rede */
INSERT INTO dbo.VacinasRede (CPFTutor, NomePet, Especie, Vacina, DataAplicacao, Clinica, Cidade) VALUES
    ('62048193705', 'Luna',    'Gato', 'Vacina V4 felina',   '2026-03-10', 'Pata Amiga',  'Campinas'),
    ('62048193705', 'Luna',    'Gato', 'Vacina antirrábica', '2026-03-10', 'Pata Amiga',  'Campinas'),
    ('16482537149', 'Mel',     'Cão',  'Vacina V10',         '2025-08-22', 'Vida Animal', 'Campinas'),
    ('16482537149', 'Mel',     'Cão',  'Vacina antirrábica', '2025-08-22', 'Vida Animal', 'Campinas'),
    ('27593648250', 'Frajola', 'Gato', 'Vacina V4 felina',   '2024-05-15', 'Cão & Gato',  'Campinas'),
    ('71937082694', 'Toddy',   'Cão',  'Vacina V10',         '2026-09-05', 'Amigo Fiel',  'Campinas'),
    ('71937082694', 'Toddy',   'Cão',  'Vacina antirrábica', '2026-09-05', 'Amigo Fiel',  'Campinas'),
    ('40326718502', 'Thor',    'Cão',  'Vacina V10',         '2026-10-05', 'PetSaúde',    'Campinas'),
    ('40326718502', 'Thor',    'Cão',  'Vacina antirrábica', '2026-10-05', 'PetSaúde',    'Campinas');
GO

/* 3. Conferência: 300009 aplicações */
SELECT COUNT(*) AS Aplicacoes FROM dbo.VacinasRede;