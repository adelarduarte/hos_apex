create or replace procedure "TPL_CALC_GRUPO_FIXAS_CX" (
				p_empresa_id		IN number,
				p_data_inicial	IN date,
				p_data_final	IN date,
				p_grupo_id		IN number,
				p_nome			IN varchar2,
				p_ordem			IN number,
				p_codigo		IN varchar2,
                p_tipo          IN varchar2,
                p_fonte         IN varchar2,
                p_centros       IN varchar2
)
is
    -->> Calcular grupo Fixas - Caixa <<--
    ----******************************----


	-->> criar uma variavel do tipo template_report_dados, para
	--   inserir os valores calculados
	l_template_dados		template_report_dados%rowtype;

    l_valor    number(14,2);
    l_mes      varchar2(10);

    l_qtd_rec    number;

Begin

    dbms_output.put_line('-->> Calcular Grupo Fixas - Caixa');
    l_qtd_rec := 0;

    -->> Verificar a existencia de registros;
    begin
        select count(contas_recebidas.id)
        into l_qtd_rec
        from contas_recebidas, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
        and   categorias_financeiras.tipo_operacao = 'Fixos'
        and   contas_recebidas.categoria_financeira_id = categorias_financeiras.id
        and   contas_recebidas.data_recebimento >= p_data_inicial
        and   contas_recebidas.data_recebimento <= p_data_final
        and   contas_recebidas.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
        and   grupos_categorias_financeiras.id = p_grupo_id
        and   contas_recebidas.empresa_id = p_empresa_id;
    exception
        when no_data_found then
            l_qtd_rec := 0;
    end;



    if l_qtd_rec > 0 then

        -->> Criar os registros no relatório, contas a receber
        for rec in (
            -->> Listar categorias de um grupo, forma de registros
            select sum(valor_dre) as valor, mes
            from
            (
                select contas_recebidas.valor_dre,
                       to_char(contas_recebidas.data_recebimento, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from contas_recebidas, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
                and   categorias_financeiras.tipo_operacao = 'Fixos'
                and   contas_recebidas.categoria_financeira_id = categorias_financeiras.id
                and   contas_recebidas.data_recebimento >= p_data_inicial
                and   contas_recebidas.data_recebimento <= p_data_final
                and   contas_recebidas.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   contas_recebidas.empresa_id = p_empresa_id
            )
            group by mes
            order by mes
        )
        Loop
            l_template_dados.id 	   := null;
            l_template_dados.codigo    := p_codigo;
            l_template_dados.ordem 	   := p_ordem;
            l_template_dados.nome 	   := p_nome;
            l_template_dados.mes 	   := rec.mes;
            l_template_dados.valor 	   := rec.valor;
            l_template_dados.empresa_id := p_empresa_id;
            l_template_dados.tipo      := p_tipo;
            l_template_dados.fonte     := p_fonte;

            insert into template_report_dados values l_template_dados;
        End loop;

    end if;

    l_qtd_rec := 0;



    -->> Verificar a existência de registros;
    begin
        select count(contas_pagas.id)
        into l_qtd_rec
        from contas_pagas, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
        and   categorias_financeiras.tipo_operacao = 'Fixos'
        and   contas_pagas.categoria_financeira_id = categorias_financeiras.id
        and   contas_pagas.data_pagamento >= p_data_inicial
        and   contas_pagas.data_pagamento <= p_data_final
        and   contas_pagas.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
        and   grupos_categorias_financeiras.id = p_grupo_id
        and   contas_pagas.empresa_id = p_empresa_id;
    exception
        when no_data_found then
            l_qtd_rec := 0;
    end;



    if l_qtd_rec > 0 then

        -->> Criar os registros no relatório, contas a pagar
        for rec in (
            -->> Listar categorias de um grupo, forma de registros
            select sum(valor_pago) as valor, mes from
            (
                select contas_pagas.valor_pago,
                       to_char(contas_pagas.data_pagamento, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from contas_pagas, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
                and   categorias_financeiras.tipo_operacao = 'Fixos'
                and   contas_pagas.categoria_financeira_id = categorias_financeiras.id
                and   contas_pagas.data_pagamento >= p_data_inicial
                and   contas_pagas.data_pagamento <= p_data_final
                and   contas_pagas.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   contas_pagas.empresa_id = p_empresa_id
            )
            group by mes
            order by mes
        )
        Loop
            l_template_dados.id 	   := null;
            l_template_dados.codigo    := p_codigo;
            l_template_dados.ordem 	   := p_ordem;
            l_template_dados.nome 	   := p_nome;
            l_template_dados.mes 	   := rec.mes;
            l_template_dados.valor 	   := rec.valor * -1;
            l_template_dados.empresa_id := p_empresa_id;
            l_template_dados.tipo      := p_tipo;
            l_template_dados.fonte     := p_fonte;


            insert into template_report_dados values l_template_dados;
        End loop;

    end if;

End;