-- Seu Ricardo vai começar a mandar mensagens para os clientes, e o balcão precisa 
-- imprimir um comprovante a cada retirada. Só que os dados foram digitados às pressas: 
-- tem nome com espaço sobrando, e-mail em maiúsculas, CPF e placa sem pontuação.
-- Hoje você vai preparar esses textos com T-SQL, sem alterar nada na tabela: 
-- só mudando a forma de mostrar.


SELECT TOP 5 TRIM(c.Nome) as Cliente,
CASE
    WHEN c.Email IS NULL THEN ' '
    ELSE LOWER(TRIM(c.Email))
END AS Email,
CASE
    WHEN LEN(TRIM(c.CPF)) = 11
        THEN STUFF(STUFF(STUFF(TRIM(c.CPF), 10, 0, '-'), 7, 0, '.'), 4, 0, '.')
    WHEN LEN(c.CPF) = 9
        THEN STUFF(STUFF(TRIM(c.CPF), 7, 0, '.'), 4, 0, '.')
    ELSE c.CPF
END AS Cpf,
CASE
    WHEN SUBSTRING(TRIM(v.Placa), 4, 1) != ' ' THEN STUFF(TRIM(v.Placa), 4, 0, ' ') 
END AS Placa
FROM Clientes c
INNER JOIN Locacoes l
ON c.IdCliente = l.IdCliente
INNER JOIN Veiculos v
ON v.IdVeiculo = l.IdVeiculo;


-- ---------------------------------------

-- Declaração e inicialização de variável

DECLARE @NomeLoja VARCHAR(100) = 'Locadora Veloz';
DECLARE @DataAtual DATE = GETDATE();
DECLARE @DataHora DATETIME2 = SYSDATETIME();
DECLARE @DiariaBase DECIMAL(10,2);		-- Não inicializada fica com valor NULL

SET @DiariaBase = 120.00;

SELECT  @NomeLoja AS Loja, 
        @DataAtual AS Data,
        @DataHora AS DataHora,
        @DiariaBase AS Diaria;


-- ---------------------------------------


-- Atribuir valor em variável a partir do SELECT

DECLARE @TotalClientes INT;

SET @TotalClientes = (SELECT COUNT(*)  FROM Clientes);

PRINT 'Total clientes cadastrador: ' + CAST(@TotalClientes AS VARCHAR(10));
PRINT CONCAT('Total clientes cadastrador: ', @TotalClientes);
PRINT(SQRT(@TotalClientes + 5) * 2);


-- ---------------------------------------

-- Função TRIM
DECLARE @Cidade VARCHAR(50) = 'Campinas';

SELECT TRIM(Nome), Cidade
FROM Clientes
WHERE Cidade = @Cidade;


-- ---------------------------------------

-- Funções: UPPER, LOWER, LEN, RTRIM, LTRIM

PRINT UPPER('locadora veloz');
PRINT LOWER('Locadora Veloz');

PRINT LEN('locadora veloz');

PRINT TRIM ('           Locadora Veloz        ')
PRINT RTRIM('           Locadora Veloz        ')
PRINT LTRIm('           Locadora Veloz        ')


-- ---------------------------------------

-- Funções para slice e cut

-- Função LEFT E RIGHT 

PRINT LEFT ('locadora', 3);     -- Conta e corta depois a partir da esquerda
PRINT RIGHT('locadora', 3);     -- Conta e corta depois a partir da direita


-- Função SUBSTRING

PRINT SUBSTRING('La Casa de Papel', 4, 7);    -- Argumentos: Texto, Posição inicial, Qtde para manter


-- ---------------------------------------


-- CONCATENAR

PRINT CONCAT('Valor a pagar R$ ', 500, ',00');

DECLARE @Totale NUMERIC(10, 2) = 500.00;
PRINT CONCAT('Total: R$ ', @Totale)


-- CHAR INDEX -> Posição do caracter

DECLARE @Pos INT = (SELECT CHARINDEX('@', 'tux@email.com'));
PRINT CONCAT('Posição do caracter: ', @Pos);


-- REPLACE

PRINT REPLACE('120.00', '.', '?');


-- ---------------------------------------


-- Funções de conversão

-- CAST E CONVERT

DECLARE @Total INT = 15;
PRINT 'Temos ' + CAST(@Total AS VARCHAR(10)) + ' carros';
PRINT 'Temos ' + CONVERT(VARCHAR(10), @Total) + ' carros';
PRINT CONCAT('Temos ', @Total, ' carros');


-- CONVERT PARA DATAS
-- 103 DD/MM/YYYY
-- 23  YYYY/MM/DD
-- 113 YYYYMMDD


-- Formatação de valores monetários

SELECT CONCAT ('R$ ', REPLACE(ValorDiaria, '.',',')) AS 'Valor diária' FROM Categorias;


-- ---------------------------------------


-- Função  STUFF
-- Excluir trecho de string e no mesmo lugar, inserir novo caracter

-- STUFF (Text, Start, Length, Replace with expression )

SELECT TOP(5) 
STUFF(Cpf, 10, 0, ' *** ') 
FROM Clientes;


-- ---------------------------------------

-- Laço WHILE

DECLARE @contador INT = 1;
WHILE @contador <= 10
BEGIN
    PRINT @contador;
    SET @contador = @contador + 1;
END

