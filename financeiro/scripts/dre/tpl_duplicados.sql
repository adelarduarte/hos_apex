create or replace procedure "TPL_DUPLICADOS"(
   p_empresa_id IN number
)
IS
	l_report_dados		template_report_dados%rowtype;

	l_valor_ant			number;
	l_valor_atu			number;
	l_valor_total		number;

	l_id_ant			number := 0;
	l_codigo_ant		varchar2(20) := '';
	l_nome_ant			varchar2(100) := '';
	l_mes_ant			varchar2(2) := '';

	l_contador			number := 1;
Begin
	
	for rec in (
		select *
		from template_report_dados
		where codigo = '410'
		and empresa_id = p_empresa_id
		order by codigo, to_number(mes), nome
		)
	LOOP
		if rec.codigo = l_codigo_ant
			and rec.mes = l_mes_ant
			and rec.nome = l_nome_ant then

			l_valor_total := l_valor_total + rec.valor;
			l_contador := l_contador + 1;

			If l_contador = 2 then
				update template_report_dados
				set valor = l_valor_total
				where id = l_id_ant;

				update template_report_dados
				set tipo = 'EX'
				where id = rec.id;

				l_contador := 1;

			end if;

		else
			l_codigo_ant := rec.codigo;
			l_mes_ant := rec.mes;
			l_nome_ant := rec.nome;

			l_valor_total := rec.valor;
			l_id_ant := rec.id;

		end if;

	END LOOP;

    delete from template_report_dados
    where tipo = 'EX';

End;

