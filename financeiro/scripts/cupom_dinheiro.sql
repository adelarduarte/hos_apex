create or replace function "CUPOM_DINHEIRO" (
        p_cliente_id	   	  IN number,
        p_valor 		      IN number,
        p_empresa_id		  IN number,
        p_cupom_id			  IN number,
        p_documento 		  IN number
	) return varchar2
IS

	l_contas_receber_id			number;
	l_contas_receber_record		contas_receber%rowtype;
    l_contas_recebidas_record   contas_recebidas%rowtype;

	l_status_liquidado_id		number;
	l_tipo_documento_id 		number;
	l_centro_custos_id			number;
	l_categoria_financeira_id	number;
	l_conta_financeira_id 		number;
    l_forma_pagamento_id        number;

Begin
	-- >> Setar status liquidado para contas a receber
	Select id
	into l_status_liquidado_id
	from status_financeiros
	where lower(nome) = 'liquidado';

	-- >> Setar tipo de documento como 'Fatura'
	Select id
	into l_tipo_documento_id
	from tipos_documentos_financeiros
	where lower(descricao) = 'fatura';

	-->> Buscar centro de custos
	select nvl(centro_custos_id, 0)
	into l_centro_custos_id
	from empresas_preferencias
	where empresa_id = p_empresa_id;

	-->> Buscar categoria financeira
	select nvl(categoria_financeira_id, 0)
	into l_categoria_financeira_id
	from empresas_preferencias
	where empresa_id = p_empresa_id;


	-->> Setar conta financeira como 'Caixa'     
	select id
	into l_conta_financeira_id
	from contas_financeiras
	where id_interno = 1
	and empresa_id = p_empresa_id;

	-->> Setar forma de pagamento como 'Dinheiro'
	select id
	into l_forma_pagamento_id
	from formas_pagamentos_financeiros
	where id_interno = 1
	and empresa_id = p_empresa_id;


	-->> Criar registro contas a receber, retornando o id.
	l_contas_receber_record.data_emissao            := sysdate;
	l_contas_receber_record.data_vencimento         := sysdate;

	l_contas_receber_record.valor  					:= p_valor;

	l_contas_receber_record.saldo                   := 0;
	l_contas_receber_record.cliente_id              := p_cliente_id;
	l_contas_receber_record.empresa_id              := p_empresa_id;
	l_contas_receber_record.cupom_id 				:= p_cupom_id;
	l_contas_receber_record.status_id               := l_status_liquidado_id;
	l_contas_receber_record.centro_custo_id         := l_centro_custos_id;
	l_contas_receber_record.categoria_financeira_id := l_categoria_financeira_id;
	l_contas_receber_record.documento 				:= to_char(p_documento);
	l_contas_receber_record.tipo_documento_id 		:= l_tipo_documento_id;

	insert into contas_receber values l_contas_receber_record returning id into l_contas_receber_id;



	-->> Criar registro de conta recebida
	l_contas_recebidas_record.conta_receber_id			:= l_contas_receber_id;
	l_contas_recebidas_record.cliente_id				:= p_cliente_id;
	l_contas_recebidas_record.empresa_id                := p_empresa_id;
	l_contas_recebidas_record.centro_custo_id			:= l_centro_custos_id;
	l_contas_recebidas_record.categoria_financeira_id	:= l_categoria_financeira_id;
	l_contas_recebidas_record.conta_financeira_id		:= l_conta_financeira_id;
	l_contas_recebidas_record.documento					:= to_char(p_documento);
	l_contas_recebidas_record.data_vencimento			:= sysdate;
	l_contas_recebidas_record.data_recebimento			:= sysdate;

	l_contas_recebidas_record.valor	 		  			:= p_valor;
	l_contas_recebidas_record.valor_recebido  			:= p_valor;
	l_contas_recebidas_record.saldo			  			:= p_valor;

	l_contas_recebidas_record.forma_pagamento_id		:= l_forma_pagamento_id;
	l_contas_recebidas_record.descricao					:= 'Registro criado via api HOS Finanças';
	l_contas_recebidas_record.valor_juros				:= 0;
	l_contas_recebidas_record.valor_multa				:= 0;
	l_contas_recebidas_record.valor_desconto			:= 0;
	l_contas_recebidas_record.valor_outros				:= 0;

	insert into contas_recebidas values l_contas_recebidas_record;

	return to_char(l_contas_receber_id);

End;

