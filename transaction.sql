
-- Transação

-- Sequência de uma mais operações DML
-- Tratado como uma única unidade lógica de processamneto/lote/trabalho

-- Propiedades ACID
-- Atomicidade: Tudo ou nada.
-- Consistência: uma transação leva o banco de dados de um estado válido a outro estado válido, sem violar regras de integridade.
-- Integridade: é a garantia de que as informações armazenadas são precisas, consistentes e confiáveis ao longo de todo o seu ciclo de vida.
-- Durabilidade: Depois de commit não pode ser desfeita a transação.

-- Padrão de transação MSSQL Server: Autocommit [UPDADE, DELETE, INSERT]

-- Habilitar autocommit
-- SET IMPLIIT_TRANSACTION OFF;

SET IMPLIIT_TRANSACTION ON;


-- Transaction
BEGIN TRAN
SET XACT_ABORT ON -- Qualquer erro: ROLLBACK AUTOMÁTICO
	UPDATE Locacoes
	SET DataDevolucao = '2026-10-23', KmDevolucao = 38950, Status = 'Finalizada'
	WHERE IdLocacao = 144;

	SELECT * FROM Locacoes WHERE IdLocacao = 144;
-- ROLLBACK
COMMIT


BEGIN TRAN
	DELETE Locacoes WHERE Status = 'Cancelada';
	SELECT * FROM Locacoes;
ROLLBACK;

GO

-- PROCEDURE
CREATE OR ALTER PROCEDURE dbo.CadastrarNovosCarros
AS
BEGIN
	SET NOCOUNT ON	-- Não mostra linhas afetadas
	SET XACT_ABORT ON	-- Qq erro defaz a transação

	BEGIN TRY
		BEGIN TRAN

		INSERT INTO Veiculos (Placa, Marca, Modelo, AnoFabricacao, Cor, IdCategoria, Quilometragem, Status) VALUES
			('SCA1964', 'Simca', 'Chambord', 1964, 'Azul e Branco', 1, 142300, 'Disponível'),
			('VWK1968', 'Volkswagen', 'Karmann Ghia', 1968, 'Vermelho', 1, 98500, 'Alugado'),
			('WLY1967', 'Willys', 'Itamaraty', 1967, 'Preto', 1, 120450, 'Disponível');

		COMMIT
		SELECT 'Sucesso !!!' as resultado
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK

		SELECT 'Erro na transação' as resultado,
		ERROR_NUMBER() AS NumeroErro,
		ERROR_MESSAGE() AS  MensagemErro
	END CATCH
END;
GO


-- EXECUTAR PROCEDURE

EXEC CadastrarNovosCarros;

SELECT * FROM Veiculos;

