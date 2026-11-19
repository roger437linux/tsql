▾
CREATE OR ALTER PROCEDURE dbo.usp_AgendaDoDia
    @Data DATE = '2026-10-31'          -- parâmetro com valor padrão: é opcional
AS
BEGIN
    SET NOCOUNT ON;                     -- tira as mensagens "(n rows affected)"
    SELECT a.DataAtendimento, p.Nome AS Pet, TRIM(t.Nome) AS Tutor,
           COALESCE(v.Nome, 'Estética') AS Veterinario
    FROM Atendimentos a
    INNER JOIN Pets p        ON p.IdPet = a.IdPet
    INNER JOIN Tutores t     ON t.IdTutor = p.IdTutor
    LEFT JOIN Veterinarios v ON v.IdVeterinario = a.IdVeterinario
    WHERE a.Status = 'Agendado' AND a.DataAtendimento = @Data;
END;
GO





EXEC dbo.usp_AgendaDoDia '2026-11-02';           -- pela posição: 3 linhas (Luna, Zeus e Lola)

EXEC dbo.usp_AgendaDoDia @Data = '2026-11-02';   -- pelo nome: mais claro, e a ordem não importa

EXEC dbo.usp_AgendaDoDia;                        -- usa o padrão, 31/10: 1 linha, o Thor







CREATE OR ALTER PROCEDURE dbo.usp_ContarAgendamentos

    @Data       DATE,

    @Quantidade INT OUTPUT

AS

BEGIN

    SET NOCOUNT ON;

    SELECT @Quantidade = COUNT(*)

    FROM Atendimentos

    WHERE Status = 'Agendado' AND DataAtendimento = @Data;

END;

GO



DECLARE @Qtd INT;



EXEC dbo.usp_ContarAgendamentos @Data = '2026-11-15', @Quantidade = @Qtd OUTPUT;



PRINT CONCAT('Agendamentos em 15/11: ', @Qtd);   -- Agendamentos em 02/11: 3



--Contexto. A Mel (atendimento 138) saiu da consulta e tomou a Vacina V10.

--A recepção precisa marcar o atendimento como Realizado e lançar a vacina.

--Hoje isso é feito com um script colado do bloco de notas.

--Dra. Helena: "Ou grava tudo, ou não grava nada."






