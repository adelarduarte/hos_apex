Create or replace function "BUSCAR_EMPRESA_POR_API_KEY"(
		p_api_key	IN	varchar2
	) return number
IS

	l_empresa_id	number;
Begin

	Begin
		select nvl(id, 0)
		into l_empresa_id
		from empresas_apis
		where api_key = p_api_key;
	exception
		when no_data_found then
			l_empresa_id := 0;
		when others then
			l_empresa_id := 0;
	end;

	return l_empresa_id;

End;
