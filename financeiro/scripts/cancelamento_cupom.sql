create or replace procedure "CANCELAMENTO_CUPOM" (
	p_empresa_id 			IN 	number,
	p_numero_documento 		IN  varchar2,
	p_cupom_cancelado_id 	IN  number
)
as
	l_centro_cancelamento_id		number;
	l_categoria_cancelamento_id		number;
	l_fornecedor_id					number; -->> Fornecedor Vendas Canceladas
	l_conta_financeira_id			number; -->> Mesma do cupom original
	l_forma_pagamento_id			number; -->> Mesma do cupom original
	l_status_cancelado_id			number;
	l_status_liquidado_id			number;

	l_cupom_original_id				number;

	l_contas_pagar_record			contas_pagar%rowtype;
	l_contas_pagas_record			contas_pagas%rowtype;
	l_contas_pagar_id 				number;

	l_cupom_cancelado_rec 			caixas_cupons%rowtype;
	l_cupom_original_rec 			caixas_cupons%rowtype;

	l_tipo_devolucao 				varchar2(20) := 'Total';

	l_total_original				number;
	l_total_cancelado				number;
	l_novo_valor_titulo 			number;

	l_contas_receber_id 			number;
Begin

	-->> Buscar cupom original. Se não existir, interromper o processo.
	Begin
		select *
		into l_cupom_original_rec
		from caixas_cupons
		where numero_documento = p_numero_documento
		and empresa_id = p_empresa_id
		and id <> p_cupom_cancelado_id;
	Exception
		when no_data_found then
			l_cupom_original_id := 0;
		when others then
			l_cupom_original_id := 0;
	End;


	-->> Executar todo o bloco, somente se o cupom original existir
	if l_cupom_original_rec.id > 0 then

		-->> Buscar registro completo do cupom cancelado
		select * 
		into l_cupom_cancelado_rec
		from caixas_cupons
		where id = p_cupom_cancelado_id;

		-->> Buscar status de título cancelado
		select id
		into l_status_cancelado_id
		from status_financeiros
		where lower(nome) = 'cancelado';

		-->> Buscar status de título liquidado
		select id
		into l_status_liquidado_id
		from status_financeiros
		where lower(nome) = 'liquidado';

		-->> Buscar centro e categoria para cancelamento
		select categoria_cancelamento_id, centro_custo_fornecedor_id
		into l_categoria_cancelamento_id, l_centro_cancelamento_id
		from empresas_preferencias
		where empresa_id = p_empresa_id;



		-->> Buscar forma de pagamento 'Dinheiro'
		select id
		into l_forma_pagamento_id
		from formas_pagamentos_financeiros
		where lower(descricao) = 'dinheiro'
		and empresa_id = p_empresa_id;


		-->> Buscar fornecedor "Vendas Canceladas"
		--  O processo deve cadastrar, se não existir
		l_fornecedor_id := verificar_fornecedor(
				p_empresa_id => p_empresa_id,
				p_nome => 'Vendas Canceladas'
			);


		-->> Localizar contas a receber, e mudar status para cancelado
	   l_total_cancelado := l_cupom_cancelado_rec.dinheiro_valor 
						  + l_cupom_cancelado_rec.cheque_valor
						  + l_cupom_cancelado_rec.cartao_valor
						  + l_cupom_cancelado_rec.a_prazo_valor
						  + l_cupom_cancelado_rec.convenio_valor
						  + l_cupom_cancelado_rec.outros_valor
						  + l_cupom_cancelado_rec.pagamento_credito_valor;


		if l_cupom_cancelado_rec.pagamento_credito_valor > 0 then
			-->> Somar valor no saldo_crediario do cliente.
			update clientes_preferencias
			set saldo_crediario = saldo_crediario + l_cupom_cancelado_rec.pagamento_credito_valor
			where cliente_id = l_cupom_original_rec.cliente_id;
		end if;

		-->> Mudar valor / status contas a receber / recebidas
		Begin
			select id
			into l_contas_receber_id
			from contas_receber
			where cupom_id = l_cupom_original_rec.id;
		Exception
			when no_data_found then
				l_contas_receber_id := 0;
			when others then
				l_contas_receber_id := 0;
		End;

		If l_contas_receber_id > 0 then

			update contas_receber
			set status_id = l_status_cancelado_id
			where id = l_contas_receber_id;

			update contas_recebidas
			set valor_recebido = 0
			where conta_receber_id = l_contas_receber_id;

			-->> Lançar contas a pagar com o valor cancelado
			l_contas_pagar_record.id                      := null;
			l_contas_pagar_record.data_emissao            := l_cupom_cancelado_rec.data;
			l_contas_pagar_record.data_vencimento         := l_cupom_cancelado_rec.data;
			l_contas_pagar_record.data_agendamento        := l_cupom_cancelado_rec.data;
			l_contas_pagar_record.empresa_id              := p_empresa_id;
			l_contas_pagar_record.fornecedor_id           := l_fornecedor_id;
			l_contas_pagar_record.status_id               := l_status_liquidado_id;
			l_contas_pagar_record.recorrente              := 'Não';
			l_contas_pagar_record.parcelado               := 'Não';
			l_contas_pagar_record.valor                   := l_total_cancelado;
			l_contas_pagar_record.saldo                   := 0;
			l_contas_pagar_record.centro_custo_id         := l_centro_cancelamento_id;
			l_contas_pagar_record.categoria_financeira_id := l_categoria_cancelamento_id;
			l_contas_pagar_record.descricao               := 'Cancelamento de Cupom Fiscal';
			l_contas_pagar_record.documento               := 'CAN-' || to_char(sysdate);

			insert into contas_pagar values l_contas_pagar_record returning id into l_contas_pagar_id;


			-->> Lançar liquidação e movimento(Automático...)
			l_contas_pagas_record.id                      := null;
			l_contas_pagas_record.conta_pagar_id          := l_contas_pagar_id;
			l_contas_pagas_record.data_pagamento          := l_cupom_cancelado_rec.data;
			l_contas_pagas_record.data_vencimento         := l_cupom_cancelado_rec.data;
			l_contas_pagas_record.empresa_id              := p_empresa_id;
			l_contas_pagas_record.fornecedor_id           := l_fornecedor_id;
			l_contas_pagas_record.valor                   := l_total_cancelado;
			l_contas_pagas_record.valor_pago              := l_total_cancelado;
			l_contas_pagas_record.valor_juro              := 0;
			l_contas_pagas_record.valor_multa             := 0;
			l_contas_pagas_record.valor_desconto          := 0;
			l_contas_pagas_record.valor_outros            := 0;
			l_contas_pagas_record.saldo                   := 0;
			l_contas_pagas_record.conta_financeira_id     := l_conta_financeira_id;
			l_contas_pagas_record.forma_pagamento_id      := l_forma_pagamento_id;
			l_contas_pagas_record.centro_custo_id         := l_centro_cancelamento_id;
			l_contas_pagas_record.categoria_financeira_id := l_categoria_cancelamento_id;
			l_contas_pagas_record.descricao               := 'Cancelamento de Cupom Fiscal';
			l_contas_pagas_record.documento               := l_contas_pagar_record.documento;

			insert into contas_pagas values l_contas_pagas_record;

		end if;

	end if;

End;

