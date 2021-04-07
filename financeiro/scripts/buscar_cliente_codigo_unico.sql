Create or replace function "BUSCAR_CLIENTE_CODIGO_UNICO"(
		p_codigo_unico	IN	varchar2
	) return number
IS

	l_cliente_id	number;
Begin

	Begin
		select nvl(id, 0)
		into l_cliente_id
		from clientes
		where codigo_unico = p_codigo_unico;
	exception
		when no_data_found then
			l_cliente_id := 0;
		when others then
			l_cliente_id := 0;
	end;

	return l_cliente_id;

End;

