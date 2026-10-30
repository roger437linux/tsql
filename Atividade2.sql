
-- Nível 1 — Aquecimento

-- Q1. Quantas locações tiveram retirada em cada mês? Mostre o número do mês e a quantidade, em ordem de mês.

select month(DataRetirada) as 'mês', count(*) as qtde_locacoes
from Locacoes
where Status != 'Cancelada'
group by month(DataRetirada);


-- Q2. Liste o nome e o telefone de todos os clientes, mostrando não informado quando não houver telefone. 
--     Faça com ISNULL e com COALESCE, lado a lado. O que aconteceu com o ISNULL?

-- R: Com ISNULL a exibição tem a mesma quatidade de caracteres que o dado origianal.

select trim(Clientes.Nome),
isnull(Clientes.Telefone,   'NÃO INFORMADO') as fone_isnull,
coalesce(Clientes.Telefone, 'NÃO INFORMADO') as fone_coalesce
from Clientes;


-- Q3. Para as locações finalizadas, mostre o número da locação, a retirada, a devolução e quantos dias o carro ficou fora.

select IdLocacao, Status, 
convert(varchar(20), DataRetirada, 103) as DataRetirada, 
convert(varchar(20), DataDevolucao, 103) as DataDevolucao,
DATEDIFF(day, DataRetirada, DataDevolucao) as qtde_dias_fora
from Locacoes
where Status = 'Finalizada';


-- Q4. Classifique as categorias pela diária atual: até R$ 150 é Básica, até R$ 250 é Conforto, acima disso é Premium.

select NomeCategoria, ValorDiaria,
case
	when ValorDiaria <= 150 then 'Básica'
	when ValorDiaria <= 250 then 'Conforto'
	else 'Premium'
end as TipoCategoria
from Categorias
order by ValorDiaria asc;


-- Nível 2 — Regras do negócio

-- Q5. Para as locações em andamento, mostre o número da locação, o nome do cliente, a data prevista de devolução, 
--     a situação (Atrasada, Vence hoje ou No prazo) e os dias de atraso (0 para quem não está atrasado). 
--     Ordene do mais atrasado para o menos.


select IdLocacao, Clientes.Nome, 
DataPrevistaDevolucao, Status,
datediff(day, DataPrevistaDevolucao, GETDATE()) as dias_atraso,
case
	when datediff(day, GETDATE(), DataPrevistaDevolucao) < 0 then 'Atrasada'
	when datediff(day, GETDATE(), DataPrevistaDevolucao) = 0 then 'Vence hoje'
	when datediff(day, GETDATE(), DataPrevistaDevolucao) > 0 then 'No prazo'
end as situacao
from Locacoes
inner join Clientes
on Clientes.IdCliente = IdCliente
where Status = 'Em andamento';


-- Q6. Calcule o valor de cada locação finalizada: dias cobrados × diária do dia. Pela regra da locadora, cobra-se no mínimo 1 dia.


select 
convert(varchar(20), DataRetirada, 103) as DataRetirada, 
convert(varchar(20), DataDevolucao, 103) as DataDevolucao, 
ValorDiaria,
datediff(day, DataRetirada, DataDevolucao) as dias_cobrados,
(datediff(day, DataRetirada, DataDevolucao) * ValorDiaria) as valor_total_locacao,
Status
from Locacoes
where Status = 'Finalizada' and
datediff(day, DataRetirada, DataDevolucao) > 0;


-- Q7. Em uma única linha, mostre quantas locações estão finalizadas, quantas em andamento e quantas canceladas, cada uma numa coluna.


declare @Finalizadas varchar(20) = (select count(*) from Locacoes where Status = 'Finalizada');
declare @Andamento varchar(20)   = (select count(*) from Locacoes where Status = 'Em andamento');
declare @Cancelada varchar(20)   = (select count(*) from Locacoes where Status = 'Cancelada');
select @Finalizadas as Finalizadas, @Andamento as Andamento, @Cancelada as Canceladas;


-- Nível 3 — Desafio


-- Q8. Calcule a idade de cada cliente em @Hoje. Primeiro só com DATEDIFF(YEAR, ...); 
--     depois, a idade certa. Para quais clientes a primeira forma erra?


-- Q9. Seu Ricardo está pensando em cobrar multa de 1 diária por dia de atraso. 
--     Nas locações finalizadas que voltaram depois do prazo, quantas foram, 
--     quantos dias de atraso somaram e quanto a multa teria rendido?


-- Q10. Liste os clientes que fazem aniversário nos próximos 30 dias a partir de @Hoje: 
--      nome, data do aniversário deste ano no formato dd/mm/aaaa e quantos dias 
--      faltam, do mais próximo ao mais distante.
