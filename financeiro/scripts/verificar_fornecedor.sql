create or replace function "VERIFICAR_FORNECEDOR" (
	p_empresa_id	IN 		number,
	p_nome  		IN  	varchar2
) return number
is
	l_fornecedor_id		number;

Begin
	-->> ****** Verificação apenas para 
	--   fornecedores padronizados
	--   para devolução de vendas
	--   e cancelamento de vendas

	-->> Verificar existência do fornecedor
	Begin
		select id
		into l_fornecedor_id
		from fornecedores
		where lower(nome) = lower(p_nome);
	Exception
		when no_data_found then
			l_fornecedor_id := 0;
		when others then
			l_fornecedor_id := 0;
	End;

	if l_fornecedor_id > 0 then
		return l_fornecedor_id;
	else
		insert into fornecedores(id, nome, empresa_id)
			values(null, p_nome, p_empresa_id)
			returning id into l_fornecedor_id;

		return l_fornecedor_id;
	end if;

End;