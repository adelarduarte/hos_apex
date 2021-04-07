create or replace function "CALCULAR_MULTA_CLIENTE" (
	p_cliente_id	IN	number,
	p_empresa_id	IN	number,
	p_valor			IN	number,
	p_data_vencimento	IN 	date,
	p_data_recebimento	IN  date
) return number
IS
	l_cliente_multa				varchar2(10);
	l_empresa_multa				varchar2(10);
	l_percentual_multa_cliente	number;
	l_percentual_multa_empresa	number;
	l_valor_multa				number;
	l_dias_uteis				number;
	l_dias_feriados				number;
Begin
	-->> Não tratar finais de semana e feriados para multa

	Begin
		select coalesce(percentual_multa, 0), 
			   coalesce(cobrar_multa, 'Empresa')
		into l_percentual_multa_cliente,
			 l_cliente_multa
		from clientes_preferencias
		where cliente_id = p_cliente_id;
	exception
		when no_data_found then
			l_cliente_multa := 'Empresa';
			l_percentual_multa_cliente := 0;
	end;


	if l_cliente_multa = 'Empresa' then
		Begin
			select coalesce(percentual_multa, 0), 
				   coalesce(cobrar_multa, 'Não')
			into l_percentual_multa_cliente,
				 l_cliente_multa
			from empresa_preferencias
			where empresa_id = p_empresa_id;
		exception
			when no_data_found then
				l_cliente_multa := 'Não';
				l_percentual_multa_cliente := 0;
		end;

	end if;

	if l_percentual_multa_cliente > 0 then
		-->> Calcular valor de multa
		l_valor_multa := p_valor * (l_percentual_multa_cliente / 100);
	else
		l_valor_multa := 0;

	end if

	return l_valor_multa;

End;