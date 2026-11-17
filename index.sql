-- Relatório da campanha
--Contexto. Em 15/09/2026 a rede BichoFeliz fez uma campanha de vacinação antirrábica em todas as clínicas. 
--No dia seguinte, a coordenadora abre a tela “Aplicações por data” para fechar o balanço, e a tela demora vários segundos para responder. 
--A VacinasRede acumula anos de histórico, e a tela é usada o dia todo pelas recepções. 

-- “a consulta por data está lenta, dá para resolver?” ??????

-- Entender o problema,
-- 1. mediar e encontrar a causa do problema
-- 2. corrigir e em seguida medir novamente
-- Ciclo: medir -> achar a causa -> corrigir -> medir de novo


-- 0 - Preparação
-- Medidor de leituras (aba mensagens) 
SET STATISTICS IO ON;

-- Que índices a tabela já tem? (ponto de partida da investigação)
EXEC sp_helpindex 'dbo.VacinasRede';

--1. Reproduzir o problema:
-- "QUANTAS VACINAS/APLICAOES FIZEMANOS NA CAMPANHA ?"
SELECT COUNT(*) FROM VacinasRede WHERE DataAplicacao >= '2026-09-15' AND DataAplicacao <= '2026-10-15';
-- Resultado: 205 aplicações/3083
-- Plano:     Clustered Index Scan
-- Messages:  milhares de logical reads
-- Causa:     para achar 205 linhas, o SQL Server leu anos de histórico.
--            Não existe índice por data, então ele não tem atalho.

--2. Primeira correação:
--DROP INDEX dbo.VacinasRede.IX_VacinasRede_DataAplicacao;
CREATE NONCLUSTERED INDEX IX_VacinasRede_DataAplicacao
	ON dbo.VacinasRede (DataAplicacao);
-- Resultado: as mesmas 205/3083
-- Plano:     Index Seek (vai direto à data no índice)
-- Messages:  poucas leituras
-- Chamado resolvido... até a próxima pergunta.


-- 3. O CHAMADO VOLTA --------------------------------------------
-- Agora a coordenadora quer o detalhe: "quais vacinas, em quais clínicas?"
SELECT Vacina, Clinica
FROM dbo.VacinasRede
WHERE DataAplicacao = '2026-09-15';
-- Plano:     Index Seek + Key Lookup
-- Messages:  leituras sobem de novo
-- Causa:     o índice só guarda a data. Para cada uma das 205 linhas,
--            o SQL Server volta à tabela para buscar Vacina e Clinica.

-- 4. SEGUNDA CORREÇÃO
CREATE NONCLUSTERED INDEX IX_VacinasRede_DataAplicacao
    ON dbo.VacinasRede (DataAplicacao)      -- chave: serve para BUSCAR
    INCLUDE (Vacina, Clinica)               -- carga: serve para DEVOLVER
    WITH (DROP_EXISTING = ON);              -- recria o índice de mesmo nome


SELECT Vacina, Clinica
FROM VacinasRede
WHERE DataAplicacao = '2026-09-15';

--5.  Registrar os indices
EXEC sp_helpindex 'dbo.VacinasRede';


--6. LIMPEZA
DROP INDEX dbo.VacinasRede.IX_VacinasRede_DataAplicacao;
DROP INDEX IX_VacinasRede_DataAplicacao ON dbo.VacinasRede;

SET STATISTICS IO OFF;

--   DBCC CHECKALLOC verifica a consistência de alocação de
--   espaço em disco do banco atual.
DBCC CHECKALLOC;