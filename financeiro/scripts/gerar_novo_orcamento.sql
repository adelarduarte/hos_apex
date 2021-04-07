CREATE OR REPLACE EDITIONABLE PROCEDURE "HOS"."GERAR_NOVO_ORCAMENTO" (
	p_origem		IN	varchar2,
	p_mes			IN	number,
	p_ano			IN	number,
	p_empresa_id	IN	number
)
IS
	l_valor_orcado	number(14,2) := 0;
	l_orcamento_record	orcamento_categorias%rowtype;

Begin
	-->> Leitura do orcamento de origem
	for rec in (
			select
				categoria_financeira_id,
				grupo_categoria_financeira_id,
				meta, 
				realizado,
                mes, 
                ano,
                mostrar_grafico
			from
				orcamento_categorias
			where
				empresa_id = p_empresa_id
			and mes = p_mes
			and ano = p_ano
		)
	loop
		l_orcamento_record.categoria_financeira_id			:= rec.categoria_financeira_id;
		l_orcamento_record.grupo_categoria_financeira_id	:= rec.grupo_categoria_financeira_id;
		l_orcamento_record.realizado						:= 0;
		l_orcamento_record.saldo							:= 0;
		l_orcamento_record.mostrar_grafico					:= rec.mostrar_grafico;
		l_orcamento_record.empresa_id						:= p_empresa_id;

		-->> Gera nova meta de acordo com escolha na tela
		if p_origem = 'Orçado' then
			l_orcamento_record.meta := rec.meta;
		else
			-->> Caso o realizado seja 0, preserva
			--	 a meta original
			if rec.realizado > 0 then 
				l_orcamento_record.meta := rec.realizado;
			else
				l_orcamento_record.meta := rec.meta;
			end if;
		end if;

		l_orcamento_record.ano := rec.ano;
		l_orcamento_record.mes := rec.mes + 1;

		if l_orcamento_record.mes = 13 then
			l_orcamento_record.mes := 1;
			l_orcamento_record.ano := rec.ano + 1;
		end if;

		insert into orcamento_categorias values l_orcamento_record;
	end loop;

End;

/
