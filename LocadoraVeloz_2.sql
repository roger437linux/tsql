-- Seu Ricardo vai começar a mandar mensagens para os clientes, e o balcão precisa 
-- imprimir um comprovante a cada retirada. Só que os dados foram digitados às pressas: 
-- tem nome com espaço sobrando, e-mail em maiúsculas, CPF e placa sem pontuação.
-- Hoje você vai preparar esses textos com T-SQL, sem alterar nada na tabela: 
-- só mudando a forma de mostrar.


DECLARE @NomeLoja VARCHAR(100) = 'Locadora Veloz';
-- declare @DataAtual date = '2026-10-26';
DECLARE @DataAtual DATE = GETDATE();
DECLARE @DiariaBase DECIMAL(10,2);		-- Não inicializada fica com valor NULL

SET @DiariaBase = 120.00;

SELECT @NomeLoja AS Loja, @DataAtual AS Data, @DiariaBase AS Diaria;

-- -----------------------------------------------------------------------

declare @TotalClientes int;
set @TotalClientes = (select count(*)  from Clientes);
print 'Total clientes cadastrador: ' + cast(@TotalClientes as varchar(10));
print concat('Total clientes cadastrador: ', @TotalClientes);
print(sqrt(@TotalClientes) * 2);


-- -----------------------------------------------------------------------


declare @Cidade varchar(50) = 'Campinas';

select trim(Nome), Cidade
from Clientes
where Cidade = @Cidade;


-- -----------------------------------------------------------------------




-- -----------------------------------------------------------------------

/* 
select trim(c.Nome) as Cliente, lower(c.Email) as 'E-mail', c.CPF, v.Placa from Clientes c
inner join Locacoes l
on c.IdCliente = l.IdCliente
inner join Veiculos v
on v.IdVeiculo = l.IdVeiculo;
*/
