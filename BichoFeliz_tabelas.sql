/* =====================================================================
   BANCO BichoFeliz  |  SQL Server (SSMS)
   Clínica Veterinária Bicho Feliz - atendimentos de set/2025 a nov/2026
   Projeto final da Sprint 3
   ---------------------------------------------------------------------
   Como usar: abra este script no SSMS e execute tudo (F5).
   Ele pode ser executado de novo sem erro: apaga e recria as tabelas.
   Antes de rodar de novo, apague as views com SCHEMABINDING que você criou.
   Data de referência do projeto ("hoje"): 30/10/2026.
   ===================================================================== */

IF DB_ID('BichoFeliz') IS NULL
    CREATE DATABASE BichoFeliz;
GO

USE BichoFeliz;
GO

DROP TABLE IF EXISTS ItensAtendimento;
DROP TABLE IF EXISTS Atendimentos;
DROP TABLE IF EXISTS Servicos;
DROP TABLE IF EXISTS Veterinarios;
DROP TABLE IF EXISTS Pets;
DROP TABLE IF EXISTS Tutores;
GO

/* ---------------------------------------------------------------------
   1. CRIAÇÃO DAS TABELAS (DDL)
   --------------------------------------------------------------------- */

CREATE TABLE Tutores (
    IdTutor       INT IDENTITY(1,1) CONSTRAINT PK_Tutores PRIMARY KEY,
    Nome          VARCHAR(100) NOT NULL,     -- digitado na recepção: nem sempre padronizado
    CPF           CHAR(11)     NOT NULL CONSTRAINT UQ_Tutores_CPF UNIQUE,
    Telefone      VARCHAR(20)  NULL,         -- cada atendente digitou de um jeito
    Email         VARCHAR(100) NULL,
    Bairro        VARCHAR(50)  NOT NULL,
    DataCadastro  DATE         NOT NULL CONSTRAINT DF_Tutores_DataCadastro DEFAULT GETDATE()
);

CREATE TABLE Pets (
    IdPet           INT IDENTITY(1,1) CONSTRAINT PK_Pets PRIMARY KEY,
    IdTutor         INT          NOT NULL CONSTRAINT FK_Pets_Tutores REFERENCES Tutores (IdTutor),
    Nome            VARCHAR(50)  NOT NULL,
    Especie         VARCHAR(10)  NOT NULL CONSTRAINT CK_Pets_Especie CHECK (Especie IN ('Cão', 'Gato')),
    Raca            VARCHAR(50)  NULL,       -- NULL = sem raça definida
    Sexo            CHAR(1)      NOT NULL CONSTRAINT CK_Pets_Sexo CHECK (Sexo IN ('M', 'F')),
    DataNascimento  DATE         NULL,       -- NULL = adotado, data desconhecida
    Peso            DECIMAL(5,2) NULL        -- em kg, na última pesagem
);

CREATE TABLE Veterinarios (
    IdVeterinario  INT IDENTITY(1,1) CONSTRAINT PK_Veterinarios PRIMARY KEY,
    Nome           VARCHAR(100) NOT NULL,
    CRMV           VARCHAR(20)  NOT NULL CONSTRAINT UQ_Veterinarios_CRMV UNIQUE,
    Especialidade  VARCHAR(50)  NOT NULL,
    DataAdmissao   DATE         NOT NULL
);

CREATE TABLE Servicos (
    IdServico     INT IDENTITY(1,1) CONSTRAINT PK_Servicos PRIMARY KEY,
    NomeServico   VARCHAR(50)   NOT NULL CONSTRAINT UQ_Servicos_Nome UNIQUE,
    Categoria     VARCHAR(20)   NOT NULL
                  CONSTRAINT CK_Servicos_Categoria CHECK (Categoria IN ('Consulta', 'Vacina', 'Exame', 'Estética', 'Cirurgia')),
    Preco         DECIMAL(10,2) NOT NULL,    -- preço ATUAL (reajustado em 01/09/2026)
    ValidadeDias  INT           NULL         -- só vacinas: dias até a próxima dose
);

CREATE TABLE Atendimentos (
    IdAtendimento    INT IDENTITY(1,1) CONSTRAINT PK_Atendimentos PRIMARY KEY,
    IdPet            INT          NOT NULL CONSTRAINT FK_Atendimentos_Pets REFERENCES Pets (IdPet),
    IdVeterinario    INT          NULL CONSTRAINT FK_Atendimentos_Veterinarios REFERENCES Veterinarios (IdVeterinario),
                                         -- NULL = banho e tosa, sem veterinário
    DataAtendimento  DATE         NOT NULL,
    Status           VARCHAR(20)  NOT NULL
                     CONSTRAINT CK_Atendimentos_Status CHECK (Status IN ('Agendado', 'Realizado', 'Cancelado', 'Faltou')),
    FormaPagamento   VARCHAR(20)  NULL,      -- só para atendimentos realizados
    Observacao       VARCHAR(200) NULL
);

CREATE TABLE ItensAtendimento (
    IdAtendimento  INT           NOT NULL CONSTRAINT FK_Itens_Atendimentos REFERENCES Atendimentos (IdAtendimento),
    IdServico      INT           NOT NULL CONSTRAINT FK_Itens_Servicos REFERENCES Servicos (IdServico),
    Quantidade     INT           NOT NULL CONSTRAINT CK_Itens_Quantidade CHECK (Quantidade > 0),
    PrecoCobrado   DECIMAL(10,2) NOT NULL,   -- preço NO DIA do atendimento
    CONSTRAINT PK_ItensAtendimento PRIMARY KEY (IdAtendimento, IdServico)
);
GO

/* ---------------------------------------------------------------------
   2. CARGA DOS DADOS (DML)
   Os IDs são gerados pelo IDENTITY, na ordem dos INSERTs (1, 2, 3...).
   --------------------------------------------------------------------- */

INSERT INTO Tutores (Nome, CPF, Telefone, Email, Bairro, DataCadastro) VALUES
    ('Mariana Albuquerque', '40326718502', '(19) 99812-3344', 'mariana.alb@gmail.com', 'Cambuí', '2025-09-02'),  -- 1
    ('  Roberto Siqueira', '51947360281', '19998127755', 'roberto.siqueira@outlook.com', 'Taquaral', '2025-09-03'),  -- 2
    ('juliana prates', '62048193705', '19 99734 1290', NULL, 'Barão Geraldo', '2025-09-05'),  -- 3
    ('Carlos Henrique Viana', '73159204816', '(19) 98845-6012', 'CARLOS.VIANA@EMPRESA.COM.BR', 'Cambuí', '2025-09-10'),  -- 4
    ('Fernanda Lopes', '84260315927', NULL, 'fernanda.lopes@gmail.com', 'Guanabara', '2025-09-15'),  -- 5
    ('Gustavo Ramos  ', '95371426038', '19991230045', 'gustavo.ramos@yahoo.com.br', 'Taquaral', '2025-09-20'),  -- 6
    ('Helena Matsuda', '16482537149', '(19) 99621-7788', 'helena.matsuda@gmail.com', 'Barão Geraldo', '2025-10-01'),  -- 7
    ('Igor Batista', '27593648250', '19 98102 3367', 'igor.batista@outlook.com', 'Castelo', '2025-10-08'),  -- 8
    ('Joana D''Arc Moreira', '38604759361', '(19) 99555-1020', 'joana.moreira@gmail.com', 'Cambuí', '2025-10-15'),  -- 9
    ('Kleber Nogueira', '49715860472', NULL, NULL, 'Guanabara', '2025-10-22'),  -- 10
    ('Luana Figueiredo', '50826971583', '19997788123', 'Luana.Figueiredo@Gmail.com', 'Taquaral', '2025-11-03'),  -- 11
    ('Mauro Peixoto', '61937082694', '(19) 98234-5566', 'mauro.peixoto@empresa.com.br', 'Castelo', '2025-11-12'),  -- 12
    ('Nathalia Coutinho', '72048193705', '19 99102 7744', 'nathalia.c@yahoo.com.br', 'Cambuí', '2025-12-01'),  -- 13
    ('Otávio Lemos', '83159204816', '19996541230', 'otavio.lemos@gmail.com', 'Barão Geraldo', '2026-01-10'),  -- 14
    ('patrícia gomes', '94260315927', '(19) 99876-0011', 'patricia.gomes@outlook.com', 'Guanabara', '2026-02-05'),  -- 15
    ('Ricardo Tanaka', '15371426038', '(19) 98321-4455', 'ricardo.tanaka@gmail.com', 'Taquaral', '2026-03-14'),  -- 16
    ('Sílvia Borges', '26482537149', '19 98877 6655', NULL, 'Castelo', '2026-04-20'),  -- 17
    ('Thiago Monteiro', '37593648250', '19993216677', 'thiago.monteiro@gmail.com', 'Cambuí', '2026-05-18'),  -- 18
    ('Úrsula Campos', '48604759361', '(19) 99432-8899', 'ursula.campos@yahoo.com.br', 'Barão Geraldo', '2026-06-22'),  -- 19
    ('Vinícius Assis', '59715860472', '19 99001 2233', 'vinicius.assis@empresa.com.br', 'Guanabara', '2026-08-03'),  -- 20
    ('Wagner Lima', '60826971583', '19992345566', 'wagner.lima@gmail.com', 'Taquaral', '2026-09-28'),  -- 21
    ('Yasmin Duarte', '71937082694', '(19) 98765-4321', 'yasmin.duarte@outlook.com', 'Castelo', '2026-10-20');  -- 22

INSERT INTO Pets (IdTutor, Nome, Especie, Raca, Sexo, DataNascimento, Peso) VALUES
    (1, 'Thor', 'Cão', 'Labrador', 'M', '2019-04-12', 32.50),  -- 1
    (1, 'Mia', 'Gato', 'Siamês', 'F', '2021-08-03', 4.20),  -- 2
    (2, 'Bolinha', 'Cão', 'Poodle', 'M', '2014-02-20', 6.80),  -- 3
    (3, 'Luna', 'Gato', NULL, 'F', NULL, 3.90),  -- 4
    (3, 'Simba', 'Gato', 'Persa', 'M', '2023-11-10', 4.60),  -- 5
    (4, 'Rex', 'Cão', 'Pastor Alemão', 'M', '2017-06-15', 36.00),  -- 6
    (5, 'Pipoca', 'Cão', NULL, 'F', '2022-09-01', 9.40),  -- 7
    (6, 'Nina', 'Cão', 'Shih Tzu', 'F', '2018-12-24', 5.90),  -- 8
    (6, 'Fred', 'Cão', 'Beagle', 'M', '2016-03-30', 13.20),  -- 9
    (7, 'Mel', 'Cão', 'Golden Retriever', 'F', '2020-10-05', 29.10),  -- 10
    (8, 'Frajola', 'Gato', NULL, 'M', NULL, 5.10),  -- 11
    (9, 'Amora', 'Cão', 'Spitz Alemão', 'F', '2025-08-20', 2.30),  -- 12
    (9, 'Tom', 'Gato', NULL, 'M', '2012-07-07', 4.90),  -- 13
    (10, 'Duque', 'Cão', 'Rottweiler', 'M', '2018-01-19', 41.00),  -- 14
    (11, 'Kiara', 'Gato', 'Maine Coon', 'F', '2022-05-27', 6.30),  -- 15
    (12, 'Paçoca', 'Cão', NULL, 'M', NULL, 18.70),  -- 16
    (12, 'Belinha', 'Cão', 'Yorkshire', 'F', '2015-11-02', 3.10),  -- 17
    (13, 'Zeus', 'Cão', 'Bulldog Francês', 'M', '2021-03-08', 12.40),  -- 18
    (14, 'Lola', 'Gato', 'Sphynx', 'F', '2024-06-30', 3.40),  -- 19
    (15, 'Bob', 'Cão', NULL, 'M', '2013-09-12', 22.00),  -- 20
    (15, 'Jade', 'Gato', NULL, 'F', '2025-12-10', 1.80),  -- 21
    (16, 'Max', 'Cão', 'Border Collie', 'M', '2020-02-14', 19.50),  -- 22
    (17, 'Chico', 'Cão', NULL, 'M', NULL, 15.00),  -- 23
    (18, 'Sushi', 'Gato', 'Bengal', 'M', '2023-01-22', 5.50),  -- 24
    (18, 'Pandora', 'Cão', 'Dachshund', 'F', '2019-08-08', 8.20),  -- 25
    (19, 'Nala', 'Gato', NULL, 'F', '2025-11-20', 3.00),  -- 26
    (20, 'Bruce', 'Cão', 'Pit Bull', 'M', '2022-12-01', 27.30),  -- 27
    (20, 'Cacau', 'Cão', 'Lhasa Apso', 'F', '2017-05-21', 7.00),  -- 28
    (21, 'Snow', 'Gato', 'Angorá', 'F', '2020-01-15', 4.00),  -- 29
    (22, 'Toddy', 'Cão', NULL, 'M', '2024-10-10', 10.20);  -- 30

INSERT INTO Veterinarios (Nome, CRMV, Especialidade, DataAdmissao) VALUES
    ('Dra. Helena Duarte', 'CRMV-SP 21450', 'Clínica geral', '2025-09-01'),  -- 1
    ('Dr. Rafael Okada', 'CRMV-SP 30982', 'Cirurgia', '2025-09-01'),  -- 2
    ('Dra. Bianca Prado', 'CRMV-SP 41237', 'Dermatologia', '2026-02-01'),  -- 3
    ('Dr. Lucas Tavares', 'CRMV-SP 52671', 'Clínica geral', '2026-10-01');  -- 4

INSERT INTO Servicos (NomeServico, Categoria, Preco, ValidadeDias) VALUES
    ('Consulta clínica', 'Consulta', 150.00, NULL),  -- 1
    ('Consulta de retorno', 'Consulta', 80.00, NULL),  -- 2
    ('Vacina V10', 'Vacina', 95.00, 365),  -- 3
    ('Vacina antirrábica', 'Vacina', 70.00, 365),  -- 4
    ('Vacina V4 felina', 'Vacina', 110.00, 365),  -- 5
    ('Hemograma', 'Exame', 85.00, NULL),  -- 6
    ('Ultrassom abdominal', 'Exame', 220.00, NULL),  -- 7
    ('Banho', 'Estética', 60.00, NULL),  -- 8
    ('Tosa', 'Estética', 70.00, NULL),  -- 9
    ('Castração', 'Cirurgia', 650.00, NULL),  -- 10
    ('Aplicação de vermífugo', 'Consulta', 45.00, NULL),  -- 11
    ('Fisioterapia', 'Consulta', 120.00, NULL);  -- 12

INSERT INTO Atendimentos (IdPet, IdVeterinario, DataAtendimento, Status, FormaPagamento, Observacao) VALUES
    (2, 1, '2025-09-02', 'Cancelado', NULL, NULL),  -- 1
    (5, 1, '2025-09-08', 'Realizado', 'Cartão de crédito', NULL),  -- 2
    (3, 2, '2025-09-10', 'Realizado', 'Cartão de crédito', NULL),  -- 3
    (6, 2, '2025-09-12', 'Realizado', 'Cartão de débito', NULL),  -- 4
    (1, 1, '2025-09-16', 'Realizado', 'Cartão de crédito', NULL),  -- 5
    (4, 1, '2025-09-20', 'Realizado', 'Cartão de débito', NULL),  -- 6
    (8, 1, '2025-09-23', 'Cancelado', NULL, NULL),  -- 7
    (7, 1, '2025-09-27', 'Realizado', 'Dinheiro', NULL),  -- 8
    (10, NULL, '2025-10-07', 'Realizado', 'Pix', NULL),  -- 9
    (9, 1, '2025-10-08', 'Realizado', 'Pix', NULL),  -- 10
    (11, 1, '2025-10-15', 'Realizado', 'Cartão de crédito', NULL),  -- 11
    (13, 1, '2025-10-21', 'Realizado', 'Pix', NULL),  -- 12
    (2, 1, '2025-10-24', 'Faltou', NULL, NULL),  -- 13
    (12, 1, '2025-10-27', 'Realizado', 'Pix', NULL),  -- 14
    (5, 1, '2025-11-03', 'Realizado', 'Cartão de crédito', NULL),  -- 15
    (6, NULL, '2025-11-03', 'Realizado', 'Cartão de débito', NULL),  -- 16
    (15, 1, '2025-11-08', 'Realizado', 'Pix', NULL),  -- 17
    (14, 2, '2025-11-11', 'Realizado', 'Pix', NULL),  -- 18
    (17, 2, '2025-11-12', 'Realizado', 'Pix', NULL),  -- 19
    (16, NULL, '2025-11-15', 'Realizado', 'Pix', NULL),  -- 20
    (7, NULL, '2025-11-17', 'Realizado', 'Pix', NULL),  -- 21
    (4, 1, '2025-11-24', 'Faltou', NULL, 'Tutor não atendeu o telefone'),  -- 22
    (11, 1, '2025-11-25', 'Realizado', 'Dinheiro', NULL),  -- 23
    (10, 2, '2025-12-01', 'Faltou', NULL, NULL),  -- 24
    (13, 1, '2025-12-04', 'Faltou', NULL, NULL),  -- 25
    (2, 1, '2025-12-13', 'Realizado', 'Pix', NULL),  -- 26
    (6, 1, '2025-12-15', 'Realizado', 'Cartão de crédito', NULL),  -- 27
    (15, 2, '2025-12-15', 'Realizado', 'Dinheiro', NULL),  -- 28
    (18, 1, '2025-12-15', 'Realizado', 'Cartão de débito', NULL),  -- 29
    (1, 1, '2025-12-19', 'Realizado', 'Cartão de crédito', NULL),  -- 30
    (9, 1, '2025-12-22', 'Realizado', 'Pix', NULL),  -- 31
    (3, 1, '2025-12-26', 'Cancelado', NULL, NULL),  -- 32
    (17, 2, '2025-12-26', 'Cancelado', NULL, NULL),  -- 33
    (8, 2, '2026-01-13', 'Realizado', 'Dinheiro', NULL),  -- 34
    (4, 1, '2026-01-14', 'Realizado', 'Pix', NULL),  -- 35
    (19, 2, '2026-01-19', 'Realizado', 'Dinheiro', NULL),  -- 36
    (2, 1, '2026-01-27', 'Realizado', 'Pix', NULL),  -- 37
    (1, 1, '2026-01-28', 'Realizado', 'Cartão de crédito', NULL),  -- 38
    (15, 1, '2026-01-28', 'Faltou', NULL, NULL),  -- 39
    (14, 2, '2026-02-02', 'Realizado', 'Cartão de débito', NULL),  -- 40
    (16, 1, '2026-02-04', 'Realizado', 'Cartão de débito', NULL),  -- 41
    (20, 2, '2026-02-05', 'Realizado', 'Dinheiro', NULL),  -- 42
    (5, 1, '2026-02-09', 'Realizado', 'Dinheiro', NULL),  -- 43
    (3, 2, '2026-02-13', 'Realizado', 'Cartão de crédito', NULL),  -- 44
    (12, NULL, '2026-02-14', 'Realizado', 'Cartão de crédito', NULL),  -- 45
    (6, 3, '2026-02-16', 'Realizado', 'Cartão de crédito', NULL),  -- 46
    (13, 1, '2026-02-17', 'Realizado', 'Cartão de débito', NULL),  -- 47
    (21, 3, '2026-02-17', 'Realizado', 'Cartão de crédito', NULL),  -- 48
    (4, 1, '2026-02-21', 'Realizado', 'Pix', NULL),  -- 49
    (10, 1, '2026-02-23', 'Faltou', NULL, NULL),  -- 50
    (8, 3, '2026-03-12', 'Faltou', NULL, 'Tutor não atendeu o telefone'),  -- 51
    (7, 2, '2026-03-14', 'Realizado', 'Pix', NULL),  -- 52
    (20, NULL, '2026-03-23', 'Cancelado', NULL, NULL),  -- 53
    (17, 1, '2026-03-24', 'Realizado', 'Pix', NULL),  -- 54
    (11, 3, '2026-03-25', 'Realizado', 'Pix', NULL),  -- 55
    (6, 3, '2026-04-02', 'Realizado', 'Pix', NULL),  -- 56
    (18, NULL, '2026-04-02', 'Realizado', 'Pix', NULL),  -- 57
    (16, 1, '2026-04-03', 'Realizado', 'Pix', NULL),  -- 58
    (22, 3, '2026-04-03', 'Realizado', 'Cartão de crédito', NULL),  -- 59
    (15, 3, '2026-04-04', 'Realizado', 'Cartão de débito', NULL),  -- 60
    (3, 1, '2026-04-14', 'Realizado', 'Cartão de crédito', NULL),  -- 61
    (9, NULL, '2026-04-16', 'Realizado', 'Cartão de débito', NULL),  -- 62
    (19, 3, '2026-04-24', 'Realizado', 'Cartão de crédito', NULL),  -- 63
    (2, 1, '2026-04-25', 'Realizado', 'Cartão de crédito', NULL),  -- 64
    (1, NULL, '2026-04-27', 'Realizado', 'Dinheiro', NULL),  -- 65
    (8, NULL, '2026-04-28', 'Realizado', 'Cartão de crédito', NULL),  -- 66
    (23, NULL, '2026-05-02', 'Realizado', 'Cartão de crédito', NULL),  -- 67
    (10, 1, '2026-05-11', 'Realizado', 'Dinheiro', NULL),  -- 68
    (14, 1, '2026-05-14', 'Realizado', 'Cartão de crédito', NULL),  -- 69
    (6, NULL, '2026-05-18', 'Realizado', 'Cartão de crédito', NULL),  -- 70
    (20, NULL, '2026-05-18', 'Realizado', 'Cartão de débito', NULL),  -- 71
    (24, 3, '2026-05-18', 'Realizado', 'Dinheiro', NULL),  -- 72
    (25, 2, '2026-05-25', 'Faltou', NULL, NULL),  -- 73
    (12, NULL, '2026-05-27', 'Realizado', 'Cartão de débito', NULL),  -- 74
    (21, 2, '2026-06-01', 'Realizado', 'Pix', NULL),  -- 75
    (15, 2, '2026-06-02', 'Realizado', 'Cartão de crédito', NULL),  -- 76
    (5, 2, '2026-06-04', 'Realizado', 'Pix', NULL),  -- 77
    (22, 2, '2026-06-09', 'Realizado', 'Pix', NULL),  -- 78
    (4, 1, '2026-06-13', 'Realizado', 'Cartão de crédito', NULL),  -- 79
    (7, 1, '2026-06-16', 'Realizado', 'Cartão de débito', NULL),  -- 80
    (16, 3, '2026-06-16', 'Realizado', 'Cartão de crédito', NULL),  -- 81
    (2, 1, '2026-06-17', 'Realizado', 'Cartão de crédito', NULL),  -- 82
    (13, 3, '2026-06-17', 'Cancelado', NULL, NULL),  -- 83
    (18, 3, '2026-06-18', 'Faltou', NULL, 'Tutor não atendeu o telefone'),  -- 84
    (23, NULL, '2026-06-25', 'Realizado', 'Pix', NULL),  -- 85
    (3, NULL, '2026-06-30', 'Realizado', 'Pix', NULL),  -- 86
    (26, 1, '2026-06-30', 'Realizado', 'Pix', NULL),  -- 87
    (14, NULL, '2026-07-03', 'Realizado', 'Cartão de débito', NULL),  -- 88
    (10, 1, '2026-07-06', 'Realizado', 'Pix', NULL),  -- 89
    (11, 3, '2026-07-07', 'Realizado', 'Cartão de débito', NULL),  -- 90
    (9, NULL, '2026-07-09', 'Realizado', 'Cartão de crédito', NULL),  -- 91
    (5, 3, '2026-07-10', 'Realizado', 'Cartão de crédito', NULL),  -- 92
    (20, 1, '2026-07-16', 'Realizado', 'Pix', NULL),  -- 93
    (17, 2, '2026-07-20', 'Faltou', NULL, NULL),  -- 94
    (19, 1, '2026-07-25', 'Realizado', 'Pix', NULL),  -- 95
    (12, 1, '2026-07-29', 'Realizado', 'Cartão de débito', NULL),  -- 96
    (7, NULL, '2026-07-31', 'Realizado', 'Pix', NULL),  -- 97
    (21, 1, '2026-08-05', 'Realizado', 'Cartão de crédito', NULL),  -- 98
    (24, 2, '2026-08-06', 'Realizado', 'Cartão de débito', NULL),  -- 99
    (26, 1, '2026-08-06', 'Realizado', 'Cartão de crédito', NULL),  -- 100
    (28, 1, '2026-08-08', 'Cancelado', NULL, NULL),  -- 101
    (2, 1, '2026-08-10', 'Realizado', 'Cartão de débito', NULL),  -- 102
    (8, 3, '2026-08-13', 'Realizado', 'Pix', NULL),  -- 103
    (1, 3, '2026-08-15', 'Faltou', NULL, NULL),  -- 104
    (3, 2, '2026-08-15', 'Realizado', 'Dinheiro', NULL),  -- 105
    (27, 2, '2026-08-17', 'Realizado', 'Pix', NULL),  -- 106
    (6, 3, '2026-08-20', 'Realizado', 'Dinheiro', NULL),  -- 107
    (22, 2, '2026-08-20', 'Realizado', 'Cartão de crédito', NULL),  -- 108
    (4, 2, '2026-08-24', 'Realizado', 'Cartão de crédito', NULL),  -- 109
    (5, 3, '2026-08-24', 'Realizado', 'Cartão de débito', NULL),  -- 110
    (15, 2, '2026-08-28', 'Realizado', 'Cartão de crédito', NULL),  -- 111
    (17, 3, '2026-08-31', 'Cancelado', NULL, NULL),  -- 112
    (25, 1, '2026-09-01', 'Realizado', 'Cartão de débito', NULL),  -- 113
    (18, 1, '2026-09-02', 'Realizado', 'Pix', NULL),  -- 114
    (10, 3, '2026-09-14', 'Realizado', 'Pix', NULL),  -- 115
    (23, 1, '2026-09-15', 'Realizado', 'Cartão de débito', NULL),  -- 116
    (26, 2, '2026-09-16', 'Realizado', 'Pix', NULL),  -- 117
    (16, NULL, '2026-09-19', 'Realizado', 'Cartão de crédito', NULL),  -- 118
    (28, 2, '2026-09-21', 'Realizado', 'Dinheiro', NULL),  -- 119
    (13, 3, '2026-09-24', 'Realizado', 'Cartão de crédito', NULL),  -- 120
    (14, 2, '2026-09-29', 'Faltou', NULL, 'Tutor não atendeu o telefone'),  -- 121
    (5, 3, '2026-10-01', 'Realizado', 'Cartão de crédito', NULL),  -- 122
    (22, NULL, '2026-10-09', 'Realizado', 'Cartão de crédito', NULL),  -- 123
    (24, 4, '2026-10-10', 'Realizado', 'Pix', NULL),  -- 124
    (9, 2, '2026-10-12', 'Realizado', 'Pix', NULL),  -- 125
    (29, 4, '2026-10-14', 'Realizado', 'Cartão de débito', NULL),  -- 126
    (17, 4, '2026-10-15', 'Realizado', 'Pix', NULL),  -- 127
    (27, 2, '2026-10-16', 'Realizado', 'Cartão de crédito', NULL),  -- 128
    (1, 3, '2026-10-17', 'Realizado', 'Pix', NULL),  -- 129
    (20, NULL, '2026-10-19', 'Realizado', 'Pix', NULL),  -- 130
    (11, 1, '2026-10-22', 'Realizado', 'Pix', NULL),  -- 131
    (25, 2, '2026-10-29', 'Realizado', 'Cartão de crédito', NULL),  -- 132
    (1, 2, '2026-10-31', 'Agendado', NULL, NULL),  -- 133
    (4, 3, '2026-11-02', 'Agendado', NULL, NULL),  -- 134
    (18, 3, '2026-11-02', 'Agendado', NULL, NULL),  -- 135
    (19, 3, '2026-11-02', 'Agendado', NULL, NULL),  -- 136
    (6, 2, '2026-11-13', 'Agendado', NULL, NULL),  -- 137
    (10, 4, '2026-11-13', 'Agendado', NULL, NULL),  -- 138
    (7, 1, '2026-11-18', 'Agendado', NULL, NULL),  -- 139
    (28, 4, '2026-11-19', 'Agendado', NULL, NULL),  -- 140
    (24, 1, '2026-11-20', 'Agendado', NULL, NULL);  -- 141

INSERT INTO ItensAtendimento (IdAtendimento, IdServico, Quantidade, PrecoCobrado) VALUES
    (1, 1, 1, 140.00),
    (2, 1, 1, 140.00),
    (2, 4, 1, 65.00),
    (2, 5, 1, 100.00),
    (3, 1, 1, 140.00),
    (3, 3, 1, 90.00),
    (3, 4, 1, 65.00),
    (3, 11, 1, 40.00),
    (4, 1, 1, 140.00),
    (4, 3, 1, 90.00),
    (4, 4, 1, 65.00),
    (4, 11, 1, 40.00),
    (5, 1, 1, 140.00),
    (5, 3, 1, 90.00),
    (5, 4, 1, 65.00),
    (6, 1, 1, 140.00),
    (7, 1, 1, 140.00),
    (7, 3, 1, 90.00),
    (7, 4, 1, 65.00),
    (7, 11, 1, 40.00),
    (8, 1, 1, 140.00),
    (8, 3, 1, 90.00),
    (8, 4, 1, 65.00),
    (8, 11, 1, 40.00),
    (9, 8, 1, 55.00),
    (9, 9, 1, 65.00),
    (10, 1, 1, 140.00),
    (10, 3, 1, 90.00),
    (10, 4, 1, 65.00),
    (11, 1, 1, 140.00),
    (12, 1, 1, 140.00),
    (12, 4, 1, 65.00),
    (12, 5, 1, 100.00),
    (12, 11, 1, 40.00),
    (13, 1, 1, 140.00),
    (13, 4, 1, 65.00),
    (13, 5, 1, 100.00),
    (14, 1, 1, 140.00),
    (14, 3, 1, 90.00),
    (14, 4, 1, 65.00),
    (15, 2, 1, 75.00),
    (16, 8, 1, 55.00),
    (16, 9, 1, 65.00),
    (17, 1, 1, 140.00),
    (17, 4, 1, 65.00),
    (17, 5, 1, 100.00),
    (18, 2, 1, 75.00),
    (19, 1, 1, 140.00),
    (19, 3, 1, 90.00),
    (19, 4, 1, 65.00),
    (20, 8, 1, 55.00),
    (21, 8, 1, 55.00),
    (21, 9, 1, 65.00),
    (22, 1, 1, 140.00),
    (23, 1, 1, 140.00),
    (23, 6, 1, 80.00),
    (24, 1, 1, 140.00),
    (24, 7, 1, 200.00),
    (25, 1, 1, 140.00),
    (25, 6, 1, 80.00),
    (26, 1, 1, 140.00),
    (26, 7, 1, 200.00),
    (27, 2, 1, 75.00),
    (28, 1, 1, 140.00),
    (28, 6, 1, 80.00),
    (29, 1, 1, 140.00),
    (29, 3, 1, 90.00),
    (29, 4, 1, 65.00),
    (29, 11, 1, 40.00),
    (30, 1, 1, 140.00),
    (31, 1, 1, 140.00),
    (31, 6, 1, 80.00),
    (32, 1, 1, 140.00),
    (32, 7, 1, 200.00),
    (33, 1, 1, 140.00),
    (33, 6, 1, 80.00),
    (34, 1, 1, 140.00),
    (34, 3, 1, 90.00),
    (34, 4, 1, 65.00),
    (34, 11, 1, 40.00),
    (35, 2, 1, 75.00),
    (36, 1, 1, 140.00),
    (36, 4, 1, 65.00),
    (36, 5, 1, 100.00),
    (37, 1, 1, 140.00),
    (37, 4, 1, 65.00),
    (37, 5, 1, 100.00),
    (38, 1, 1, 140.00),
    (38, 7, 1, 200.00),
    (39, 1, 1, 140.00),
    (40, 1, 1, 140.00),
    (40, 3, 1, 90.00),
    (40, 4, 1, 65.00),
    (41, 1, 1, 140.00),
    (42, 1, 1, 140.00),
    (42, 3, 1, 90.00),
    (42, 4, 1, 65.00),
    (43, 1, 1, 140.00),
    (43, 6, 1, 80.00),
    (44, 1, 1, 140.00),
    (45, 8, 1, 55.00),
    (45, 9, 1, 65.00),
    (46, 1, 1, 140.00),
    (47, 1, 1, 140.00),
    (48, 1, 1, 140.00),
    (48, 4, 1, 65.00),
    (48, 5, 1, 100.00),
    (48, 11, 1, 40.00),
    (49, 1, 1, 140.00),
    (49, 6, 1, 80.00),
    (50, 1, 1, 140.00),
    (50, 3, 1, 90.00),
    (50, 4, 1, 65.00),
    (50, 11, 1, 40.00),
    (51, 1, 1, 140.00),
    (52, 1, 1, 140.00),
    (53, 8, 1, 55.00),
    (53, 9, 1, 65.00),
    (54, 1, 1, 140.00),
    (55, 1, 1, 140.00),
    (55, 7, 1, 200.00),
    (56, 2, 1, 75.00),
    (57, 8, 1, 55.00),
    (58, 1, 1, 140.00),
    (58, 3, 1, 90.00),
    (58, 4, 1, 65.00),
    (59, 1, 1, 140.00),
    (59, 3, 1, 90.00),
    (59, 4, 1, 65.00),
    (60, 2, 1, 75.00),
    (61, 1, 1, 140.00),
    (62, 8, 1, 55.00),
    (63, 1, 1, 140.00),
    (63, 6, 1, 80.00),
    (64, 1, 1, 140.00),
    (65, 8, 1, 55.00),
    (65, 9, 1, 65.00),
    (66, 8, 1, 55.00),
    (66, 9, 1, 65.00),
    (67, 8, 1, 55.00),
    (68, 1, 1, 140.00),
    (69, 1, 1, 140.00),
    (69, 6, 1, 80.00),
    (70, 8, 1, 55.00),
    (70, 9, 1, 65.00),
    (71, 8, 1, 55.00),
    (71, 9, 1, 65.00),
    (72, 1, 1, 140.00),
    (73, 1, 1, 140.00),
    (73, 3, 1, 90.00),
    (73, 4, 1, 65.00),
    (74, 8, 1, 55.00),
    (75, 1, 1, 140.00),
    (76, 1, 1, 140.00),
    (77, 1, 1, 140.00),
    (77, 10, 1, 600.00),
    (78, 1, 1, 140.00),
    (78, 7, 1, 200.00),
    (79, 1, 1, 140.00),
    (79, 6, 1, 80.00),
    (80, 2, 1, 75.00),
    (81, 1, 1, 140.00),
    (81, 6, 1, 80.00),
    (82, 1, 1, 140.00),
    (82, 6, 1, 80.00),
    (83, 1, 1, 140.00),
    (84, 1, 1, 140.00),
    (85, 8, 1, 55.00),
    (85, 9, 1, 65.00),
    (86, 8, 1, 55.00),
    (86, 9, 1, 65.00),
    (87, 1, 1, 140.00),
    (87, 4, 1, 65.00),
    (87, 5, 1, 100.00),
    (87, 11, 1, 40.00),
    (88, 8, 1, 55.00),
    (88, 9, 1, 65.00),
    (89, 2, 1, 75.00),
    (90, 1, 1, 140.00),
    (90, 6, 1, 80.00),
    (91, 8, 1, 55.00),
    (91, 9, 1, 65.00),
    (92, 1, 1, 140.00),
    (92, 6, 1, 80.00),
    (93, 1, 1, 140.00),
    (93, 6, 1, 80.00),
    (94, 1, 1, 140.00),
    (94, 7, 1, 200.00),
    (95, 1, 1, 140.00),
    (95, 6, 1, 80.00),
    (96, 1, 1, 140.00),
    (97, 8, 1, 55.00),
    (98, 1, 1, 140.00),
    (98, 6, 1, 80.00),
    (99, 1, 1, 140.00),
    (99, 4, 1, 65.00),
    (99, 5, 1, 100.00),
    (100, 1, 1, 140.00),
    (101, 1, 1, 140.00),
    (101, 3, 1, 90.00),
    (101, 4, 1, 65.00),
    (101, 11, 1, 40.00),
    (102, 1, 1, 140.00),
    (102, 7, 1, 200.00),
    (103, 1, 1, 140.00),
    (103, 6, 1, 80.00),
    (104, 1, 1, 140.00),
    (104, 3, 1, 90.00),
    (104, 4, 1, 65.00),
    (105, 1, 1, 140.00),
    (105, 3, 1, 90.00),
    (105, 4, 1, 65.00),
    (106, 1, 1, 140.00),
    (107, 1, 1, 140.00),
    (107, 3, 1, 90.00),
    (107, 4, 1, 65.00),
    (108, 1, 1, 140.00),
    (109, 2, 1, 75.00),
    (110, 1, 1, 140.00),
    (110, 4, 1, 65.00),
    (110, 5, 1, 100.00),
    (110, 11, 1, 40.00),
    (111, 1, 1, 140.00),
    (111, 6, 1, 80.00),
    (112, 2, 1, 75.00),
    (113, 1, 1, 150.00),
    (113, 3, 1, 95.00),
    (113, 4, 1, 70.00),
    (113, 11, 1, 45.00),
    (114, 1, 1, 150.00),
    (114, 7, 1, 220.00),
    (115, 1, 1, 150.00),
    (116, 1, 1, 150.00),
    (117, 1, 1, 150.00),
    (118, 8, 1, 60.00),
    (118, 9, 1, 70.00),
    (119, 1, 1, 150.00),
    (119, 3, 1, 95.00),
    (119, 4, 1, 70.00),
    (119, 11, 1, 45.00),
    (120, 1, 1, 150.00),
    (120, 4, 1, 70.00),
    (120, 5, 1, 110.00),
    (121, 1, 1, 150.00),
    (122, 2, 1, 80.00),
    (123, 8, 1, 60.00),
    (123, 9, 1, 70.00),
    (124, 1, 1, 150.00),
    (125, 1, 1, 150.00),
    (125, 3, 1, 95.00),
    (125, 4, 1, 70.00),
    (126, 1, 1, 150.00),
    (126, 4, 1, 70.00),
    (126, 5, 1, 110.00),
    (126, 11, 1, 45.00),
    (127, 1, 1, 150.00),
    (127, 3, 1, 95.00),
    (127, 4, 1, 70.00),
    (128, 1, 1, 150.00),
    (128, 3, 1, 95.00),
    (128, 4, 1, 70.00),
    (128, 11, 1, 45.00),
    (129, 1, 1, 150.00),
    (129, 7, 1, 220.00),
    (130, 8, 1, 60.00),
    (131, 1, 1, 150.00),
    (132, 1, 1, 150.00),
    (132, 7, 1, 220.00),
    (133, 1, 1, 150.00),
    (134, 1, 1, 150.00),
    (135, 1, 1, 150.00),
    (136, 1, 1, 150.00),
    (137, 1, 1, 150.00),
    (138, 1, 1, 150.00),
    (139, 1, 1, 150.00),
    (140, 1, 1, 150.00),
    (141, 1, 1, 150.00);

GO


/*
    Criando usuário do banco
*/

CREATE USER dev FOR LOGIN dev;

ALTER ROLE db_owner ADD MEMBER dev;



/* ---------------------------------------------------------------------
   3. CONFERÊNCIA - se tudo deu certo, o resultado deve ser:
      Tutores 22 | Pets 30 | Veterinarios 4 | Servicos 12 | Atendimentos 141 | ItensAtendimento 277
   --------------------------------------------------------------------- */
SELECT 'Tutores' AS Tabela, COUNT(*) AS Linhas FROM Tutores
UNION ALL SELECT 'Pets',             COUNT(*) FROM Pets
UNION ALL SELECT 'Veterinarios',     COUNT(*) FROM Veterinarios
UNION ALL SELECT 'Servicos',         COUNT(*) FROM Servicos
UNION ALL SELECT 'Atendimentos',     COUNT(*) FROM Atendimentos
UNION ALL SELECT 'ItensAtendimento', COUNT(*) FROM ItensAtendimento;