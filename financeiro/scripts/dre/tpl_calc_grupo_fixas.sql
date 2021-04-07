create or replace procedure "TPL_CALC_GRUPO_FIXAS" (
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
    -->> Calcular grupo fixas - Competência <<--
    ----************************************----

	-->> criar uma variavel do tipo template_report_dados, para
	--   inserir os valores calculados
	l_template_dados		template_report_dados%rowtype;

    l_valor    number(14,2);
    l_mes      varchar2(10);

    l_qtd_rec    number;

    l_tipo_lancamento_id   number;

Begin

    dbms_output.put_line('-->> Calcular Grupo Fixas - Competência');
    l_qtd_rec := 0;

    -->> Verificar a existencia de registros;
    begin
        select count(contas_receber.id)
        into l_qtd_rec
        from contas_receber, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
        and   categorias_financeiras.tipo_operacao = 'Fixos'
        and   contas_receber.categoria_financeira_id = categorias_financeiras.id
        and   contas_receber.data_emissao >= p_data_inicial
        and   contas_receber.data_emissao <= p_data_final
        and   contas_receber.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
        and   grupos_categorias_financeiras.id = p_grupo_id
        and   contas_receber.empresa_id = p_empresa_id;
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
                select contas_receber.valor_dre,
                       to_char(contas_receber.data_emissao, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from contas_receber, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
                and   categorias_financeiras.tipo_operacao = 'Fixos'
                and   contas_receber.categoria_financeira_id = categorias_financeiras.id
                and   contas_receber.data_emissao >= p_data_inicial
                and   contas_receber.data_emissao <= p_data_final
                and   contas_receber.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   contas_receber.empresa_id = p_empresa_id
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
        select count(contas_pagar.id)
        into l_qtd_rec
        from contas_pagar, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
        and   categorias_financeiras.tipo_operacao = 'Fixos'
        and   contas_pagar.categoria_financeira_id = categorias_financeiras.id
        and   contas_pagar.data_emissao >= p_data_inicial
        and   contas_pagar.data_emissao <= p_data_final
        and   contas_pagar.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
        and   grupos_categorias_financeiras.id = p_grupo_id
        and   contas_pagar.empresa_id = p_empresa_id;
    exception
        when no_data_found then
            l_qtd_rec := 0;
    end;



    if l_qtd_rec > 0 then

        -->> Criar os registros no relatório, contas a pagar
        for rec in (
            -->> Listar categorias de um grupo, forma de registros
            select sum(valor) as valor, mes from
            (
                select contas_pagar.valor,
                       to_char(contas_pagar.data_emissao, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from contas_pagar, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
                and   categorias_financeiras.tipo_operacao = 'Fixos'
                and   contas_pagar.categoria_financeira_id = categorias_financeiras.id
                and   contas_pagar.data_emissao >= p_data_inicial
                and   contas_pagar.data_emissao <= p_data_final
                and   contas_pagar.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   contas_pagar.empresa_id = p_empresa_id
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


    -->> Calcular valores vindo das regras do movimento de contas
    ---- =================================================== ----

    -->> Buscar o id do tipo de lançamento que nos interessa
    select id
    into l_tipo_lancamento_id
    from tipos_lancamentos_financeiros
    where Descricao = 'Regras';


    l_qtd_rec := 0;

    -->> Verificar a existencia de registros;
    begin
        select count(lancamentos_financeiros.id)
        into l_qtd_rec
        from lancamentos_financeiros, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
        and   categorias_financeiras.tipo_operacao = 'Fixos'
        and   lancamentos_financeiros.categoria_financeira_id = categorias_financeiras.id
        and   lancamentos_financeiros.data >= p_data_inicial
        and   lancamentos_financeiros.data <= p_data_final
        and   lancamentos_financeiros.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
        and   grupos_categorias_financeiras.id = p_grupo_id
        and   lancamentos_financeiros.empresa_id = p_empresa_id
        and   lancamentos_financeiros.tipo_lancamento_financeiro_id = l_tipo_lancamento_id;
    exception
        when no_data_found then
            l_qtd_rec := 0;
    end;


    if l_qtd_rec > 0 then

        -->> Criar os registros no relatório, contas movimento
        for rec in (
            -->> Listar categorias de um grupo, forma de registros
            select sum(valor_entrada) as valor_entrada, sum(valor_saida) as valor_saida, mes
            from
            (
                select lancamentos_financeiros.valor_entrada as valor_entrada, lancamentos_financeiros.valor_saida as valor_saida,
                       to_char(lancamentos_financeiros.data, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from lancamentos_financeiros, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
                and   categorias_financeiras.tipo_operacao = 'Fixos'
                and   lancamentos_financeiros.categoria_financeira_id = categorias_financeiras.id
                and   lancamentos_financeiros.data >= p_data_inicial
                and   lancamentos_financeiros.data <= p_data_final
                and   lancamentos_financeiros.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   lancamentos_financeiros.empresa_id = p_empresa_id
                and   lancamentos_financeiros.tipo_lancamento_financeiro_id = l_tipo_lancamento_id
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

            if rec.valor_entrada > 0 then
                l_template_dados.valor 	   := rec.valor_entrada;
            else
                l_template_dados.valor 	   := rec.valor_saida * -1;
            end if;

            l_template_dados.empresa_id := p_empresa_id;
            l_template_dados.tipo      := p_tipo;
            l_template_dados.fonte     := p_fonte;

            insert into template_report_dados values l_template_dados;
        End loop;

    end if;

End;

