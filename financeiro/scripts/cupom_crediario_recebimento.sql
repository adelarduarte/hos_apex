create or replace function "CUPOM_CREDIARIO_RECEBIMENTO" (
        p_cliente_id	   	  IN number,
        p_empresa_id		  IN number,
        p_cupom   	 		  IN number,
        p_valor 			  IN number,
        p_juros				  IN number,
        p_multa 			  IN number,
        p_acrescimo 		  IN number,
        p_desconto 			  IN number
	) return varchar2
IS

	l_contas_receber_id			number;
	l_contas_receber_record		contas_receber%rowtype;
	l_contas_recebidas_record	contas_recebidas%rowtype;

	l_status_liquidado_id		number;
	l_status_liquidando_id 		number;

	l_tipo_documento_id 		number;

	l_forma_pagamento_id		number;
	l_conta_financeira_id		number;

	l_cupom_id					number;

Begin
	-- >> Setar status liquidado para contas a receber
	Select id
	into l_status_liquidado_id
	from status_financeiros
	where nome = 'Liquidado';

	-- >> Setar status liquidando para contas a receber
	select id
	into l_status_liquidando_id
	from status_financeiros
	where nome = 'Liquidando';

	-->> Setar forma de pagamento como 'Dinheiro'   
	select id
	into l_forma_pagamento_id
	from formas_pagamentos_financeiros
	where id_interno = 1
	and empresa_id = p_empresa_id;

	-->> Setar conta financeira como 'Caixa'     
	select id
	into l_conta_financeira_id
	from contas_financeiras
	where id_interno = 1
	and empresa_id = p_empresa_id;

	-->> Buscar cupom no sistema
	select id 
	into l_cupom_id
	from caixas_cupons
	where numero_documento = p_cupom
	and empresa_id = p_empresa_id;

	-->> Buscar dados do contas a receber
	Begin
		select * 
		into l_contas_receber_record
		from contas_receber
		where cupom_id = l_cupom_id
		and empresa_id = p_empresa_id
		and status_id <> l_status_liquidado_id;
	Exception
		when no_data_found then
			l_contas_receber_record.id := 0;
		when others then
			l_contas_receber_record.id := 0;
	end;



	if l_contas_receber_record.id > 0 then

		-->> Verificar saldo do contas a receber
		l_contas_receber_record.saldo := l_contas_receber_record.saldo - p_valor;

		if l_contas_receber_record.saldo <= 0 then
			-->> Mudar status e saldo do registro. Liquidação total
			update contas_receber
			set status_id = l_status_liquidado_id,
				saldo = 0
			where id = l_contas_receber_record.id;
		else
			-->> Mudar status e saldo do registro. Liquidação parcial
			update contas_receber
			set status_id = l_status_liquidando_id,
				saldo = saldo - p_valor
			where id = l_contas_receber_record.id;

		end if;


		-->> Criar registro contas recebidas
		l_contas_recebidas_record.id                      := null;
		l_contas_recebidas_record.empresa_id              := p_empresa_id;
		l_contas_recebidas_record.conta_receber_id        := l_contas_receber_record.id;
		l_contas_recebidas_record.data_recebimento        := sysdate;
		l_contas_recebidas_record.data_vencimento         := l_contas_receber_record.data_vencimento;
		l_contas_recebidas_record.cliente_id              := l_contas_receber_record.cliente_id;
		l_contas_recebidas_record.valor                   := l_contas_receber_record.valor;
		l_contas_recebidas_record.valor_recebido          := p_valor;
		l_contas_recebidas_record.valor_juros             := p_juros;
		l_contas_recebidas_record.valor_multa             := p_multa;
		l_contas_recebidas_record.valor_desconto          := p_desconto;
		l_contas_recebidas_record.valor_outros            := p_acrescimo;
		l_contas_recebidas_record.saldo                   := 0;
		l_contas_recebidas_record.conta_financeira_id     := l_conta_financeira_id;
		l_contas_recebidas_record.forma_pagamento_id      := l_forma_pagamento_id;
		l_contas_recebidas_record.centro_custo_id         := l_contas_receber_record.centro_custo_id;
		l_contas_recebidas_record.categoria_financeira_id := l_contas_receber_record.categoria_financeira_id;
		l_contas_recebidas_record.descricao               := 'Liquidado via api HOS Finanças';
		l_contas_recebidas_record.documento               := l_contas_receber_record.documento;


		insert into contas_recebidas values l_contas_recebidas_record;


		-->>  Baixar no saldo de crediário do cliente;
		update clientes_preferencias
		set saldo_crediario = saldo_crediario - p_valor
		where cliente_id = p_cliente_id;


		return to_char(l_contas_receber_id);
	else
		-->>  Baixar apenas no saldo de crediário do cliente;
		update clientes_preferencias
		set saldo_crediario = saldo_crediario - p_valor
		where cliente_id = p_cliente_id;

		return 'saldo';
	end if;
End;

