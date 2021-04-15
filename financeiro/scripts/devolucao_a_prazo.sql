create or replace procedure "DEVOLUCAO_A_PRAZO" (
	p_empresa_id 			IN 	number,
	p_numero_documento 		IN  varchar2,
	p_cupom_devolvido_id 	IN  number
)
as
	l_centro_devolucao_id			number;
	l_categoria_devolucao_id		number;
	l_fornecedor_id					number; -->> Fornecedor Vendas Canceladas
	l_conta_financeira_id			number; -->> Mesma do cupom original
	l_forma_pagamento_id			number; -->> Mesma do cupom original
	l_status_cancelado_id			number;
	l_status_liquidado_id			number;

	l_cupom_original_id				number;

	l_contas_pagar_record			contas_pagar%rowtype;
	l_contas_pagas_record			contas_pagas%rowtype;
	l_contas_pagar_id 				number;

	l_cupom_devolvido_rec 			caixas_cupons%rowtype;
	l_cupom_original_rec 			caixas_cupons%rowtype;

	l_tipo_devolucao 				varchar2(20) := 'Total';

	l_total_original				number;
	l_total_devolvido				number;
	l_novo_valor_titulo 			number;

	l_contas_receber_id 			number;
	l_quantidade_parcelas			number;
	l_parcela_devolvida				number;
Begin

	-->> Buscar cupom original. Se não existir, interromper o processo.

	-->> *****  Modificada a busca, para ignorar o tipo de lançamento
	--   		financeiro original, já que ele pode ser modificado.
	-- 			Ex.: Venda cancelada como 'DV', mas o cupom original
	-- 			veio como CR.
	Begin
		select *
		into l_cupom_original_rec
		from caixas_cupons
		where numero_documento = p_numero_documento
		and empresa_id = p_empresa_id
		and id <> p_cupom_devolvido_id;
	Exception
		when no_data_found then
			l_cupom_original_id := 0;
		when others then
			l_cupom_original_id := 0;
	End;


	-->> Mudança temporária para não Executar o bloco de código
	l_cupom_original_rec.id := 0;

	-->> Executar todo o bloco, somente se o cupom original existir
	if l_cupom_original_rec.id > 0 then

		-->> Buscar registro completo do cupom devolvido
		select * 
		into l_cupom_devolvido_rec
		from caixas_cupons
		where id = p_cupom_devolvido_id;

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

		-->> Buscar centro e categoria para devoluções
		select categoria_devolucao_id, centro_custo_fornecedor_id
		into l_categoria_devolucao_id, l_centro_devolucao_id
		from empresas_preferencias
		where empresa_id = p_empresa_id;



		-->> Buscar forma de pagamento 'Dinheiro'
		select id
		into l_forma_pagamento_id
		from formas_pagamentos_financeiros
		where lower(descricao) = 'dinheiro'
		and empresa_id = p_empresa_id;


		-->> Localizar contas a receber, e mudar status
		--   para cancelado, caso a devolução seja total

		-->> Devolução de venda a prazo pode ter mais de uma parcela.
		l_total_original := l_cupom_original_rec.dinheiro_valor 
						  + l_cupom_original_rec.cheque_valor
                          + l_cupom_original_rec.cheque_pre_valor
						  + l_cupom_original_rec.cartao_valor
						  + l_cupom_original_rec.a_prazo_valor
						  + l_cupom_original_rec.convenio_valor
						  + l_cupom_original_rec.outros_valor
						  + l_cupom_original_rec.pagamento_credito_valor;

	   l_total_devolvido := l_cupom_devolvido_rec.dinheiro_valor 
						  + l_cupom_devolvido_rec.cheque_valor
                          + l_cupom_original_rec.cheque_pre_valor
						  + l_cupom_devolvido_rec.cartao_valor
						  + l_cupom_devolvido_rec.a_prazo_valor
						  + l_cupom_devolvido_rec.convenio_valor
						  + l_cupom_devolvido_rec.outros_valor
						  + l_cupom_devolvido_rec.pagamento_credito_valor;


		if l_total_original <> l_total_devolvido then
			l_tipo_devolucao    := 'Parcial';
			l_novo_valor_titulo := l_total_original - l_total_devolvido;
		else
			l_novo_valor_titulo := 0;	
		end if;


		if l_cupom_devolvido_rec.pagamento_credito_valor > 0 then
			-->> Somar valor no saldo_crediario do cliente.
			update clientes_preferencias
			set saldo_crediario = saldo_crediario + l_cupom_devolvido_rec.pagamento_credito_valor
			where cliente_id = l_cupom_original_rec.cliente_id;

		end if;

		-->> Mudar valor / status contas a receber / recebidas
		--  Identificar número de parcelas
		Begin
			select count(id) 
			into l_quantidade_parcelas
			from contas_receber
			where cupom_id = l_cupom_original_rec.id;
		Exception
			when no_data_found then
				l_quantidade_parcelas := 1;
			when others then
				l_quantidade_parcelas := 1;
		End;

		-- Verificar se houve crédito para o cliente
		--  e descontar no contas a receber apenas a diferença
		if l_cupom_devolvido_rec.pagamento_credito_valor >= l_total_devolvido then
			l_parcela_devolvida := 0;
		else
			l_parcela_devolvida := (l_total_devolvido - l_cupom_devolvido_rec.pagamento_credito_valor) / l_quantidade_parcelas;

		end if;

		if l_quantidade_parcelas > 0 then

			-->> Criar loop de leitura para tratar o 
			--   número desconhecido de parcelas
			for rec in (
					select id
					from contas_receber
					where cupom_id = l_cupom_original_rec.id
				)
			loop
				if l_tipo_devolucao = 'Parcial' then
					update contas_receber
					set saldo = saldo - l_parcela_devolvida, 
						valor = valor - l_parcela_devolvida
					where id = rec.id;
				else
					update contas_receber
					set status_id = l_status_cancelado_id
					where id = rec.id;

				end if;
				

			end loop;

		end if;

		-->> Lançar contas a pagar com o valor devolvido
		CRIAR_LANCAMENTO_FINANCEIRO (
	        p_conta_financeira_id       =>  null, 
	        p_data                      =>  sysdate,
	        p_documento                 =>  p_numero_documento,
	        p_valor                     =>  l_total_devolvido,
	        p_centro_custos_id          =>  l_centro_devolucao_id,
	        p_categoria_financeira_id   =>  l_categoria_devolucao_id,
	        p_contas_pagas_id           =>  null,
	        p_contas_recebidas_id       =>  null,
	        p_tipo                      =>  'Devolucao',
	        p_empresa_id                =>  p_empresa_id,
	        p_conta_pagar_id            =>  null,
	        p_conta_receber_id          =>  l_contas_receber_id
	    );


	end if;

End;

