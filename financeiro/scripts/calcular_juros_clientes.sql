create or replace function "CALCULAR_JUROS_CLIENTE" (
	p_cliente_id	IN	number,
	p_empresa_id	IN	number,
	p_valor			IN	number,
	p_data_vencimento	IN 	date,
	p_data_recebimento	IN  date
) return number
IS
	l_cliente_juros				varchar2(10);
	l_empresa_juros				varchar2(10);
	l_percentual_juros_cliente	number;
	l_percentual_juros_empresa	number;
	l_valor_juros				number;

	l_dias_uteis				number;
	l_dias_feriados				number;
Begin
	-->> Tratar finais de semana e feriados para juros
	l_dias_uteis := dias_uteis(
		p_data_inicial 	=> p_data_vencimento,
		p_data_final	=> p_data_recebimento
		);

	l_dias_feriados := dias_feriados(
		p_data_inicial 	=> p_data_vencimento,
		p_data_final	=> p_data_recebimento,
		p_empresa_id	=> p_empresa_id
		);

	Begin
		select coalesce(percentual_juros_mensais, 0), 
			   coalesce(cobrar_juros, 'Empresa')
		into l_percentual_juros_cliente,
			 l_cliente_juros
		from clientes_preferencias
		where cliente_id = p_cliente_id;
	exception
		when no_data_found then
			l_cliente_juros := 'Empresa';
			l_percentual_juros_cliente := 0;
	end;


	if l_cliente_juros = 'Empresa' then
		Begin
			select coalesce(percentual_juros_mensais, 0), 
				   coalesce(cobrar_juros, 'Não')
			into l_percentual_juros_cliente,
				 l_cliente_juros
			from empresas_preferencias
			where empresa_id = p_empresa_id;
		exception
			when no_data_found then
				l_cliente_juros := 'Não';
				l_percentual_juros_cliente := 0;
		end;

	end if;

	if l_percentual_juros_cliente > 0 then
		-->> Calcular valor dos juros
		l_valor_juros := p_valor * ((l_percentual_juros_cliente / 30) / 100) * (l_dias_uteis - l_dias_feriados);
	else
		l_valor_juros := 0;

	end if;

	return l_valor_juros;

End;
