create or replace procedure "CANCELAMENTO_CUPOM" (
	p_empresa_id 			     IN  number,
	p_numero_documento 		     IN  varchar2,
	p_cupom_cancelado_id 	     IN  number,
    p_tipo_lancamento_financeiro IN  varchar2
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

		-->> Setar conta financeira como 'PIX'
		--   ou caixa, se não houver conta PIX
		Begin
			select id
			into l_conta_financeira_id
			from contas_financeiras
			where conta_pix = 'Sim'
			and empresa_id = p_empresa_id;
		Exception
			when no_data_found then
				select id
				into l_conta_financeira_id
				from contas_financeiras
				where id_interno = 1
				and empresa_id = p_empresa_id;
		end;

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


		-->> Localizar contas a receber, e mudar status para cancelado
	   l_total_cancelado := l_cupom_cancelado_rec.dinheiro_valor 
						  + l_cupom_cancelado_rec.cheque_valor
                          + l_cupom_cancelado_rec.cheque_pre_valor
						  + l_cupom_cancelado_rec.cartao_valor
						  + l_cupom_cancelado_rec.a_prazo_valor
						  + l_cupom_cancelado_rec.convenio_valor
						  + l_cupom_cancelado_rec.outros_valor
                          + l_cupom_cancelado_rec.boleto_valor
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

			-->> Criar lançamento financeiro com o valor devolvido
   			CRIAR_LANCAMENTO_FINANCEIRO (
	            p_conta_financeira_id       =>  l_conta_financeira_id, 
	            p_data                      =>  sysdate,
	            p_documento                 =>  p_numero_documento,
	            p_valor                     =>  l_total_cancelado,
	            p_centro_custos_id          =>  l_centro_cancelamento_id,
	            p_categoria_financeira_id   =>  l_categoria_cancelamento_id,
	            p_contas_pagas_id           =>  null,
	            p_contas_recebidas_id       =>  null,
	            p_tipo                      =>  'Cancelamento',
	            p_empresa_id                =>  p_empresa_id,
	            p_conta_pagar_id            =>  null,
	            p_conta_receber_id          =>  l_contas_receber_id
            );

		end if;
	end if;
End;

