create or replace function "BUSCAR_CARTAO" (
		p_descricao		IN		varchar2,
		p_operacao		IN		varchar2,
		p_empresa_id	IN		number
	) return number
IS

	l_cartao_id	number;

Begin

	Begin
		select id
		into l_cartao_id
		from cartoes
		where lower(descricao) = lower(p_descricao)
		and lower(tipo_operacao) = lower(p_operacao)
		and empresa_id = p_empresa_id;
	exception
		when no_data_found then
			l_cartao_id := 0;
		when others then
			l_cartao_id := 0;
	End;

	return l_cartao_id;


End;

