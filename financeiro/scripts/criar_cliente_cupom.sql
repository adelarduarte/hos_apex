create or replace function "CRIAR_CLIENTE_CUPOM" (
        p_cliente_codigo_unico	IN 		varchar2,
        p_cliente_nome			IN 		varchar2,
        p_cliente_cpf			IN 		varchar2,
        p_cliente_cnpj			IN 		varchar2,
        p_cliente_telefone		IN 		varchar2,
        p_empresa_id			IN 		number
	) return number
IS

	l_cliente_id		number;
	l_cliente_record	clientes%rowtype;
Begin
	-->> Tipo do cliente
	if p_cliente_cpf is not null then
		l_cliente_record.tipo_pessoa := 'Física';
	else
		l_cliente_record.tipo_pessoa := 'Jurídica';
	end if;

	-->> Estado e cidade do cliente, será o mesmo da empresa
	select 
		estado_id, 
		cidade_id
	into 
		l_cliente_record.estado_id,
		l_cliente_record.cidade_id
	from empresas
	where id = p_empresa_id; 


	-->> Tipo de cliente
	select
		id
	into 
		l_cliente_record.tipo_cliente_id
    from tipos_clientes
	where descricao = 'Cliente';


	l_cliente_record.nome          := p_cliente_nome;
	l_cliente_record.nome_fantasia := p_cliente_nome;
	l_cliente_record.cpf           := p_cliente_cpf;
	l_cliente_record.cnpj          := p_cliente_cnpj;
	l_cliente_record.telefone      := p_cliente_telefone;
	l_cliente_record.empresa_id    := p_empresa_id;
	l_cliente_record.codigo_unico  := p_cliente_codigo_unico;
	l_cliente_record.ativo         := 'Sim';
	l_cliente_record.observacao    := 'Cadastrado via API HOS Finanças';



	insert into clientes values l_cliente_record returning id into l_cliente_id;

	return l_cliente_id;

End;

