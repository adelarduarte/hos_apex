create or replace procedure "TPL_SALDO_INICIAL" (
				p_empresa_id	IN number,
				p_data_inicial	IN date,
				p_data_final	IN date,
				p_ordem			IN number,
				p_codigo		IN varchar2,
                p_tipo          IN varchar2,
                p_fonte         IN varchar2,
                p_nome          IN varchar2,
                p_mes           IN varchar2
)
is
    -->> Saldo inicial de contas <<--
    ----*************************----


	-->> criar uma variavel do tipo template_report_dados, para
	--   inserir os valores calculados
	l_template_dados		template_report_dados%rowtype;

    l_qtd_rec               number;

    l_saldo_inicial_contas  number;
    l_total_saldo_contas    number;
    l_saldo                 number;

Begin
    dbms_output.put_line('-->> Saldo inicial de contas');

    l_qtd_rec := 0;

	-- >> Encontrar saldo inicial das contas
	Select coalesce(sum(saldo_inicial_sistema), 0)
	into l_saldo_inicial_contas
	from contas_financeiras, tipos_contas_financeiras
	where contas_financeiras.tipo_conta_id = tipos_contas_financeiras.id
    and contas_financeiras.empresa_id = p_empresa_id
	and tipos_contas_financeiras.mostrar_dashboard = 'Sim'
    and (tipos_contas_financeiras.mostrar_fluxo_caixa = 'Sim' or tipos_contas_financeiras.mostrar_fluxo_caixa is null);


	-- >> Somar saldo anterior de todas as contas
	Select coalesce(sum(valor_entrada), 0) - coalesce(sum(valor_saida), 0) as saldo
	into l_total_saldo_contas
	from lancamentos_financeiros, contas_financeiras, tipos_contas_financeiras
	where lancamentos_financeiros.data < p_data_inicial
	and lancamentos_financeiros.conta_financeira_id = contas_financeiras.id
    and lancamentos_financeiros.empresa_id = p_empresa_id
	and contas_financeiras.tipo_conta_id = tipos_contas_financeiras.id
	and tipos_contas_financeiras.mostrar_dashboard = 'Sim'
    and (tipos_contas_financeiras.mostrar_fluxo_caixa = 'Sim' or tipos_contas_financeiras.mostrar_fluxo_caixa is null);


	-- >> Calcular saldo inicial
	l_saldo := l_saldo_inicial_contas + l_total_saldo_contas;


    l_template_dados.id 	    := null;
    l_template_dados.codigo     := p_codigo;
    l_template_dados.ordem 	    := p_ordem;
    l_template_dados.nome 	    := p_nome;
    l_template_dados.mes 	    := p_mes;
    l_template_dados.valor 	    := l_saldo;
    l_template_dados.empresa_id := p_empresa_id;
    l_template_dados.tipo       := p_tipo;
    l_template_dados.fonte      := p_fonte;


    insert into template_report_dados values l_template_dados;

End;

