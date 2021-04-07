create or replace procedure "TPL_CAT_GRUPO_CX" (
				p_empresa_id	IN number,
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
    -->> Categorias do grupo em regime de caixa <<--
    ----****************************************----


	-->> criar uma variavel do tipo template_report_dados, para
	--   inserir os valores calculados
	l_template_dados		template_report_dados%rowtype;

    l_qtd_rec    number;

Begin
    dbms_output.put_line('-->> Categorias Grupo - Caixa');

    l_qtd_rec := 0;

    -->> Verificar a existência de registros
    begin
        select count(lancamentos_financeiros.id)
        into l_qtd_rec
        from lancamentos_financeiros, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.grupo_categoria_financeira_id = grupos_categorias_financeiras.id
        and   lancamentos_financeiros.categoria_financeira_id = categorias_financeiras.id
        and   lancamentos_financeiros.data >= p_data_inicial
        and   lancamentos_financeiros.data <= p_data_final
        and   lancamentos_financeiros.status_lancamento <> 'Provisão'
        and   lancamentos_financeiros.CENTRO_CUSTO_ID in ( select (column_value).getnumberval() from xmltable(p_centros))
        and   grupos_categorias_financeiras.id = p_grupo_id
        and   lancamentos_financeiros.empresa_id = p_empresa_id;
    exception
        when no_data_found then
            l_qtd_rec := 0;
    end;



    if l_qtd_rec > 0 then

        -->> Criar os registros no relatório, contas a receber
        for rec in (
            -->> Listar categorias de um grupo, forma de registros
            select sum(valor_entrada) as valor, categoria, mes from
            (
                select lancamentos_financeiros.valor_entrada,
                       to_char(lancamentos_financeiros.data, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from lancamentos_financeiros, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.grupo_categoria_financeira_id = grupos_categorias_financeiras.id
                and   lancamentos_financeiros.categoria_financeira_id = categorias_financeiras.id
                and   lancamentos_financeiros.data >= p_data_inicial
                and   lancamentos_financeiros.data <= p_data_final
                and   lancamentos_financeiros.status_lancamento <> 'Provisão'
                and   lancamentos_financeiros.CENTRO_CUSTO_ID in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   lancamentos_financeiros.empresa_id = p_empresa_id
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
        select count(lancamentos_financeiros.id)
        into l_qtd_rec
        from lancamentos_financeiros, categorias_financeiras, grupos_categorias_financeiras
        where categorias_financeiras.grupo_categoria_financeira_id = grupos_categorias_financeiras.id
        and   lancamentos_financeiros.categoria_financeira_id = categorias_financeiras.id
        and   lancamentos_financeiros.data >= p_data_inicial
        and   lancamentos_financeiros.data <= p_data_final
        and   lancamentos_financeiros.status_lancamento <> 'Provisão'
        and   lancamentos_financeiros.CENTRO_CUSTO_ID in ( select (column_value).getnumberval() from xmltable(p_centros))
        and   grupos_categorias_financeiras.id = p_grupo_id
        and   lancamentos_financeiros.empresa_id = p_empresa_id;
    exception
        when no_data_found then
            l_qtd_rec := 0;
    end;


    if l_qtd_rec > 0 then

        -->> Criar os registros no relatório, contas a pagar
        for rec in (
            -->> Listar categorias de um grupo, forma de registros
            select sum(valor_saida) as valor, categoria, mes from
            (
                select lancamentos_financeiros.valor_saida,
                       to_char(lancamentos_financeiros.data, 'MM') as mes,
                       categorias_financeiras.descricao as categoria,
                       grupos_categorias_financeiras.descricao as grupo
                from lancamentos_financeiros, categorias_financeiras, grupos_categorias_financeiras
                where categorias_financeiras.grupo_categoria_financeira_id = grupos_categorias_financeiras.id
                and   lancamentos_financeiros.categoria_financeira_id = categorias_financeiras.id
                and   lancamentos_financeiros.data >= p_data_inicial
                and   lancamentos_financeiros.data <= p_data_final
                and   lancamentos_financeiros.status_lancamento <> 'Provisão'
                and   lancamentos_financeiros.CENTRO_CUSTO_ID in ( select (column_value).getnumberval() from xmltable(p_centros))
                and   grupos_categorias_financeiras.id = p_grupo_id
                and   lancamentos_financeiros.empresa_id = p_empresa_id
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


