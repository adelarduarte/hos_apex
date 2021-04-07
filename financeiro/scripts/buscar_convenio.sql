Create or replace function "BUSCAR_CONVENIO"(
		p_cnpj_cpf		IN	varchar2,
		p_empresa_id	IN 	number
	) return number
IS

	l_convenio_id				number;
	l_tipo_cliente_ambos_id		number;
	l_tipo_cliente_convenio_id	number;
	l_cnpj_cpf					varchar2(20);
Begin

	-->> Verificar tipos de clientes válidos para convênio
	select id 
	into l_tipo_cliente_convenio_id
	from tipos_clientes
	where descricao = 'Convênio';

	select id 
	into l_tipo_cliente_ambos_id
	from tipos_clientes
	where descricao = 'Ambos';


	-->> Modificar, tirando formatações do cnpj e cpf para comparar
	l_cnpj_cpf := regexp_replace(p_cnpj_cpf, '[^0-9]');

	If length(l_cnpj_cpf) > 11 then

		Begin
			select nvl(id, 0)
			into l_convenio_id
			from clientes
			where regexp_replace(cnpj, '[^0-9]') = l_cnpj_cpf;
			and empresa_id = p_empresa_id
			and tipo_cliente_id in(l_tipo_cliente_convenio_id, l_tipo_cliente_ambos_id)
		exception
			when no_data_found then
				l_convenio_id := 0;
			when others then
				l_convenio_id := 0;
		end;
	else
		Begin
			select nvl(id, 0)
			into l_convenio_id
			from clientes
			where regexp_replace(cpf, '[^0-9]') = l_cnpj_cpf;
			and empresa_id = p_empresa_id
			and tipo_cliente_id in(l_tipo_cliente_convenio_id, l_tipo_cliente_ambos_id)
		exception
			when no_data_found then
				l_convenio_id := 0;
			when others then
				l_convenio_id := 0;
		end;

	end if;

	return l_convenio_id;

End;
