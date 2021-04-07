create or replace procedure "TPL_CATEGORIAS_GRUPO" (
				p_empresa_id		IN number,
				p_data_inicial	IN date,
				p_data_final	IN date,
				p_grupo_id		IN number,
				p_ordem			IN number,
				p_codigo		IN varchar2,
                p_tipo          IN varchar2,
                p_fonte         IN varchar2,
                p_centros       IN varchar2
)
is
    -->> Categorias do Grupo por Competência <<--
    ----*************************************----


	-->> criar uma variavel do tipo template_report_dados, para
	--   inserir os valores calculados
	l_template_dados		template_report_dados%rowtype;

    l_qtd_rec    number;

Begin
    dbms_output.put_line('-->> Categorias Grupo - Competência');

    l_qtd_rec := 0;

    -->> Verificar a existência de registros
    begin
        select count(contas_receber.id)
        into l_qtd_rec
        from contas_receber, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
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
            select sum(valor_dre) as valor, categoria, mes from
            (
                select contas_receber.valor_dre,
                       to_char(contas_receber.data_emissao, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from contas_receber, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
                and   contas_receber.categoria_financeira_id = categorias_financeiras.id
                and   contas_receber.data_emissao >= p_data_inicial
                and   contas_receber.data_emissao <= p_data_final
                and   contas_receber.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   contas_receber.empresa_id = p_empresa_id
            )
            group by mes, categoria
            order by mes
        )
        Loop
            l_template_dados.id 	    := null;
            l_template_dados.codigo     := p_codigo;
            l_template_dados.ordem 	    := p_ordem;
            l_template_dados.nome 	    := rec.categoria;
            l_template_dados.mes 	    := rec.mes;
            l_template_dados.valor 	    := rec.valor;
            l_template_dados.empresa_id := p_empresa_id;
            l_template_dados.tipo       := p_tipo;
            l_template_dados.fonte      := p_fonte;

            insert into template_report_dados values l_template_dados;

        End loop;

    end if;

    l_qtd_rec := 0;



    -->> Verificar a existência de registros
    begin
        select count(contas_pagar.id)
        into l_qtd_rec
        from contas_pagar, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
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
            select sum(valor) as valor, categoria, mes from
            (
                select contas_pagar.valor,
                       to_char(contas_pagar.data_emissao, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from contas_pagar, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.GRUPO_CATEGORIA_FINANCEIRA_ID = grupos_categorias_financeiras.id
                and   contas_pagar.categoria_financeira_id = categorias_financeiras.id
                and   contas_pagar.data_emissao >= p_data_inicial
                and   contas_pagar.data_emissao <= p_data_final
                and   contas_pagar.centro_custo_id in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   contas_pagar.empresa_id = p_empresa_id
            )
            group by mes, categoria
            order by mes
        )
        Loop
            l_template_dados.id 	    := null;
            l_template_dados.codigo     := p_codigo;
            l_template_dados.ordem 	    := p_ordem;
            l_template_dados.nome 	    := rec.categoria;
            l_template_dados.mes 	    := rec.mes;
            l_template_dados.valor 	    := rec.valor * -1;
            l_template_dados.empresa_id := p_empresa_id;
            l_template_dados.tipo       := p_tipo;
            l_template_dados.fonte      := p_fonte;


            insert into template_report_dados values l_template_dados;
        End loop;

    end if;

End;