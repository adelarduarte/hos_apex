create or replace procedure "LIQUIDAR_AGRUPADOS" (
		p_contas_receber_id		IN 	number
	)
is
	l_forma_pagamento_id		number;
	l_conta_financeira_id		number;
	l_status_liquidado_id 		number;
	l_contas_recebidas_record	contas_recebidas%rowtype;
Begin
	for rec in (
		select id, 
				documento,
				cliente_id,
				data_emissao,
				data_vencimento,
				empresa_id,
				saldo, 
				valor,
				centro_custo_id, 
				categoria_financeira_id
		from contas_receber
		where boleto_convenio_id = p_contas_receber_id
	)
	loop
		-->> Buscar forma de pagamento = dinheiro
		select id 
		into l_forma_pagamento_id
		from formas_pagamentos_financeiros
		where id_interno = 1
		and empresa_id = rec.empresa_id;

		-->> Buscar conta financeira = caixa
		select id 
		into l_conta_financeira_id
		from contas_financeiras
		where id_interno = 1
		and empresa_id = rec.empresa_id;

		-->> Criar registro de liquidação
		l_contas_recebidas_record.id                      := null;	
		l_contas_recebidas_record.empresa_id              := rec.empresa_id;
		l_contas_recebidas_record.conta_receber_id        := p_contas_receber_id;
		l_contas_recebidas_record.data_recebimento        := sysdate;
		l_contas_recebidas_record.data_vencimento         := rec.data_vencimento;	
		l_contas_recebidas_record.cliente_id              := rec.cliente_id;
		l_contas_recebidas_record.valor                   := rec.valor;
		l_contas_recebidas_record.valor_recebido          := rec.saldo;	
		l_contas_recebidas_record.valor_juros             := 0;	
		l_contas_recebidas_record.valor_multa             := 0;	
		l_contas_recebidas_record.valor_desconto          := 0;	
		l_contas_recebidas_record.valor_outros            := 0;	
		l_contas_recebidas_record.saldo                   := 0;	
		l_contas_recebidas_record.conta_financeira_id     := l_conta_financeira_id;
		l_contas_recebidas_record.forma_pagamento_id      := l_forma_pagamento_id;	
		l_contas_recebidas_record.centro_custo_id         := rec.centro_custo_id;	
		l_contas_recebidas_record.categoria_financeira_id := rec.categoria_financeira_id;	
		l_contas_recebidas_record.cheque_numero           := null;
		l_contas_recebidas_record.cheque_data_vencimento  := null;	
		l_contas_recebidas_record.descricao               := 'Liquidado via api HOS Finanças';	
		l_contas_recebidas_record.documento               := rec.documento;
		l_contas_recebidas_record.parcela                 := null;	

		insert into contas_recebidas values l_contas_recebidas_record;

		-->> O registro na tabela lancamentos_financeiros, é automático, por trigger.
	end loop;
End;

