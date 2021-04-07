create or replace function "CRIAR_CONVENIO_CUPOM" (
        p_convenio_nome			IN 		varchar2,
		p_cnpj_cpf				IN		varchar2,
        p_empresa_id			IN 		number
	) return number
IS

	l_convenio_id		number;
	l_convenio_record	clientes%rowtype;
	l_cnpj_Cpf			varchar2(20);
Begin


	-->> Modificar, tirando formatações do cnpj e cpf para comparar
	l_cnpj_cpf := regexp_replace(p_cnpj_cpf, '[^0-9]');

	If length(l_cnpj_cpf) > 11 then
		l_convenio_record.tipo_pessoa := 'Jurídica';
		l_convenio_record.cnpj := l_cnpj_cpf;
	else	
		l_convenio_record.tipo_pessoa := 'Física';
		l_convenio_record.cpf := l_cnpj_cpf;
	end if;

	-->> Estado e cidade do convenio, será o mesmo da empresa
	select 
		estado_id, 
		cidade_id
	into 
		l_convenio_record.estado_id,
		l_convenio_record.cidade_id
	from empresas
	where id = p_empresa_id; 


	-->> Tipo de convenio
	select
		id
	into 
		l_convenio_record.tipo_cliente_id
    from tipos_clientes
	where descricao = 'Convênio';


	l_convenio_record.nome          := p_convenio_nome;
	l_convenio_record.nome_fantasia := p_convenio_nome;
	l_convenio_record.empresa_id    := p_empresa_id;
	l_convenio_record.ativo         := 'Sim';
	l_convenio_record.observacao    := 'Cadastrado via API HOS Finanças';


	insert into clientes values l_convenio_record returning id into l_convenio_id;

	return l_convenio_id;

End;

