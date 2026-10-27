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

print upper('locadora veloz');
print lower('Locadora Veloz');

print len('locadora veloz');

print trim('           locadora veloz   ')
print rtrim('           locadora veloz   ')
print rtrim('           locadora veloz   ')

print left('locadora', 3);
print right('locadora', 3);

-- Slice
-- texto, posição inicial, qtde
print substring('1234567899', 5, 3);


-- charindex -> Posição do caracter
print charindex('@', 'tux@email.com');

print replace('120.00', '.', ',')

print concat('Valor a pagar R$ ', 500, ',00')


-- -----------------------------------------------------------------------

-- Funções de conversão
-- cast e convert

declare @Total int = 15;
print 'Temos ' + cast(@Total as varchar(10)) + ' carros';
print 'Temos ' + convert(varchar(10), @Total) + ' carros';
print concat('Temos ', @Total, ' carros');


-- Convert para datas
-- 103 dd/mm/yyyy
-- 23  yyyy/mm/dd
-- 113 yyyymmdd

-- convert(varchar(10), ColunaData, tipoPadrao)

-- Formatação de valores monetários
select concat ('R$ ', replace(ValorDiaria, '.',',')) from Categorias;

-- -----------------------------------------------------------------------


select trim(c.Nome) as Cliente, lower(c.Email) as 'E-mail', c.CPF, v.Placa from Clientes c
inner join Locacoes l
on c.IdCliente = l.IdCliente
inner join Veiculos v
on v.IdVeiculo = l.IdVeiculo;

