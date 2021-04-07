create or replace procedure "TPL_CRIAR_RELATORIO" (
	p_data_inicial  IN 	date,
	p_data_final	IN 	date,
	p_empresa_id	IN  number,
    p_template_id   IN  number,
    p_periodo       IN  varchar2,
    p_centros       IN  varchar2
)
is

	l_teste		      number;

    l_data_inicial    date;
    l_data_final      date;

    l_contador        number;
    l_mes_formula     varchar2(10);

    l_periodo         varchar2(100); -->> Caixa / Competência

Begin
    l_periodo := p_periodo;

	-->> Limpar dados de um possível relatório anterior

	-->> Listar os registros do template, analisando cada tipo de linha

	-->> Tipos de linhas do template
    -- 1 - Total do Grupo - Fixas
	-- 2 - Total do Grupo - Variáveis
	-- 3 - Categorias do Grupo - Fixas
	-- 4 - Categorias do Grupo - Variáveis
	-- 5 - Total do Grupo
	-- 6 - Categorias do Grupo
	-- 7 - Fórmula
	-- 8 - Título
	-- 9 - Saldo Inicial de Contas

    l_contador := 1;


    for mes in 1..12
    loop

        l_data_inicial := add_months(p_data_inicial, mes -1);
        l_data_final   := last_day(l_data_inicial);

        dbms_output.put_line('Mês: ' || mes);
        dbms_output.put_line('-------------');
        dbms_output.put_line('l_data_inicial : ' || l_data_inicial);
        dbms_output.put_line('l_data_final: ' || l_data_final);
        dbms_output.put_line('p_data_final: ' || p_data_final);

        select to_char(l_data_final, 'MM') into l_mes_formula from dual;

        if l_data_final <= p_data_final then

            for rec in (
                select *
                from template_report_lines
                where template_report_id = p_template_id
                order by ordem
            )
            loop
                --l_contador := l_contador + 1;

                --exit when l_contador > 50;

                --dbms_output.put_line(l_contador);

              --if 1 = 2 then -->> Inicio bloco desativado
                if rec.tipo = 1 then -- Total de grupo - Fixas
                    if l_periodo = 'Compet' then
                        tpl_calc_grupo_fixas(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_nome         => rec.nome,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    else
                        tpl_calc_grupo_fixas_cx(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_nome         => rec.nome,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    end if;

                end if;

                if rec.tipo = 2 then -- Total de grupo - Variáveis
                    if l_periodo = 'Compet' then
                        tpl_calc_grupo_variaveis(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_nome         => rec.nome,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    else
                        tpl_calc_grupo_variav_cx(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_nome         => rec.nome,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    end if;
                end if;

                if rec.tipo = 3 then -- Categorias do Grupo - Fixas
                    if l_periodo = 'Compet' then
                        tpl_categ_grupo_fixas(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    else
                        tpl_categ_grupo_fixas_cx(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    end if;
                end if;

                if rec.tipo = 4 then -- Categorias do grupo - Variáveis
                    if l_periodo = 'Compet' then
                        tpl_categ_grupo_variaveis(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    else
                        tpl_categ_grupo_variav_cx(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    end if;

                end if;
              --end if;  -->> Fim do bloco desativado

                if rec.tipo = 5 then -- Total de grupo
                    if l_periodo = 'Compet' then
                        tpl_calcular_grupo(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_nome         => rec.nome,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    else
                        tpl_calc_grupo_cx(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_nome         => rec.nome,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    end if;
                end if;

                if rec.tipo = 6 then -- Categorias do grupo
                    if l_periodo = 'Compet' then
                        tpl_categorias_grupo(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    else
                        tpl_cat_grupo_cx(
                            p_empresa_id   => p_empresa_id,
                            p_data_inicial => l_data_inicial,
                            p_data_final   => l_data_final,
                            p_grupo_id     => REC.GRUPO_CATEGORIA_FINANCEIRA_ID,
                            p_ordem        => rec.ordem,
                            p_codigo       => rec.codigo,
                            p_tipo         => rec.tipo,
                            p_fonte        => rec.fonte,
                            p_centros      => p_centros
                        );
                    end if;
                end if;

                -- if 1 = 2 then -->> Bloco desativado
                if rec.tipo = 7 then -- Fórmula
                    tpl_formula(
                        p_empresa_id => p_empresa_id,
                        p_formula    => rec.formula,
                        p_nome       => rec.nome,
                        p_ordem      => rec.ordem,
                        p_codigo     => rec.codigo,
                        p_mes        =>  to_char(l_mes_formula),        --'10',
                        p_tipo       => rec.tipo,
                        p_fonte      => rec.fonte
                    );
                end if;
               -- end if; -->> Fim bloco desativado

                --if 1 = 2 then -->> Bloco desativado
                if rec.tipo = 9 then -- Saldo Inicial
                    tpl_saldo_inicial(
                        p_empresa_id   => p_empresa_id,
                        p_data_inicial => l_data_inicial,
                        p_data_final   => l_data_final,
                        p_ordem        => rec.ordem,
                        p_codigo       => rec.codigo,
                        p_tipo         => rec.tipo,
                        p_fonte        => rec.fonte,
                        p_nome         => rec.nome,
                        p_mes          => to_char(l_mes_formula)
                    );
                end if;
                --end if; -->> Fim bloco desativado

            end loop;
        end if;

    end loop;


	for rec in (
		select *
		from template_report_lines
		where template_report_id = p_template_id
		order by ordem
	)
	loop
		if rec.tipo = 8 then -- Título
			tpl_titulo(
                p_empresa_id => p_empresa_id,
                p_titulo     => rec.nome,
                p_ordem      => rec.ordem,
                p_codigo     => rec.codigo,
                p_tipo       => rec.tipo,
                p_fonte      => rec.fonte
			);
		end if;

	end loop;

--    tpl_duplicados (
--        p_empresa_id => p_empresa_id
--    );


End;