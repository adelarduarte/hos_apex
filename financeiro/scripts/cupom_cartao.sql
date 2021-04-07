create or replace function "CUPOM_CARTAO" (
        p_cartao_nome       IN varchar2,
        p_cartao_operacao   IN varchar2,
        p_cartao_bandeira   IN varchar2,
        p_cartao_adquirente IN varchar2,
        p_cartao_nsu        IN varchar2,
        p_cartao_valor      IN number,
        p_empresa_id		IN number,
        p_cliente_id 		IN number,
        p_parcelas			IN number,
        p_documento 		IN number
	) return number
IS

	l_cartao_id					 number;
	l_dias_vencimento			 number;
	l_status_pendente_id		 number;
	l_status_liquidado_id		 number;
	l_forma_pagamento_id		 number;
	l_conta_financeira_id		 number;
	l_tipo_documento_id 		 number;
	l_centro_custos_id			 number;
	l_categoria_financeira_id	 number;
	l_contas_receber_id			 number;
	l_contas_recebidas_id		 number;
	l_cliente_id 				 number;
	l_vencimento_cartao			 date := sysdate;
	l_dias_recebimento 			 number;
	l_taxa_fixa					 number(14,2);
	l_taxa_parcela 				 number(14,2);
	l_valor_taxa				 number(14,2);
	l_valor_liquido				 number(14,2);
	l_contas_receber_record		 contas_receber%rowtype;
	l_contas_recebidas_record    contas_recebidas%rowtype;
	l_lancamentos_cartoes_record lancamentos_cartoes%rowtype;

	l_valor_parcela_1			 number(14,2);
	l_valor_parcela 			 number(14,2);


Begin

	-->> Setar forma de pagamento como 'Cartão'   **** Incluir nos scripts iniciais
	select id
	into l_forma_pagamento_id
	from formas_pagamentos_financeiros
	where id_interno = 2
	and empresa_id = p_empresa_id;

	-->> Setar conta financeira como 'Caixa'     **** Verificar nos scripts iniciais
	select id
	into l_conta_financeira_id
	from contas_financeiras
	where id_interno = 1
	and empresa_id = p_empresa_id;

	-- >> Setar status liquidado para contas a receber
	Select id
	into l_status_liquidado_id
	from status_financeiros
	where nome = 'Liquidado';

	-- >> Setar tipo de documento como 'Cartão'
	Select id
	into l_tipo_documento_id
	from tipos_documentos_financeiros
	where descricao = 'Cartão';

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

	Begin
		select id
		into l_cartao_id
		from cartoes
		where lower(descricao) = lower(p_cartao_nome)
		and lower(translate(tipo_operacao, 'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
        'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy')) = lower(translate(p_cartao_operacao, 'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',
        'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy'))
		and empresa_id = p_empresa_id;
	exception
		when no_data_found then
			-->> Cadastrar cartão

			l_cartao_id := CADASTRAR_CARTAO(
		        p_cartao_nome       => p_cartao_nome,
		        p_cartao_operacao   => p_cartao_operacao,
		        p_cartao_bandeira   => p_cartao_bandeira,
		        p_cartao_adquirente => p_cartao_adquirente,
		        p_empresa_id		=> p_empresa_id,
		        p_parcelas			=> p_parcelas
			);

		when others then
			l_cartao_id := 0;
	End;


	if l_cartao_id > 0 then
		-->> Calcular parcelas e vencimentos
		if p_parcelas > 1 then
			l_valor_parcela   := p_cartao_valor / p_parcelas;
			l_valor_parcela_1 := p_cartao_valor - (l_valor_parcela * p_parcelas);

		else
			l_valor_parcela := p_cartao_valor;
			l_valor_parcela_1 := p_cartao_valor;

		end if;		


		for i in 1 .. p_parcelas loop



			-->> Criar registro contas a receber, retornando o id.
			l_contas_receber_record.data_emissao            := sysdate;
			l_contas_receber_record.data_vencimento         := l_vencimento_cartao;

			if i = 1 then
				l_contas_receber_record.valor  := l_valor_parcela + l_valor_parcela_1;
			else
				l_contas_receber_record.valor  := l_valor_parcela;
			end if;

			l_contas_receber_record.saldo                   := 0;
			l_contas_receber_record.cliente_id              := p_cliente_id;
			l_contas_receber_record.empresa_id              := p_empresa_id;
			-- l_contas_receber_record.cupom_id 				:= p_cupom_id;
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

			if i = 1 then
				l_contas_recebidas_record.valor	 		  := l_valor_parcela + l_valor_parcela_1;
				l_contas_recebidas_record.valor_recebido  := l_valor_parcela + l_valor_parcela_1;
				l_contas_recebidas_record.saldo			  := l_valor_parcela + l_valor_parcela_1;
			else
				l_contas_recebidas_record.valor	 		  := l_valor_parcela;
				l_contas_recebidas_record.valor_recebido  := l_valor_parcela;
				l_contas_recebidas_record.saldo			  := l_valor_parcela;
			end if;				

			l_contas_recebidas_record.forma_pagamento_id		:= l_forma_pagamento_id;
			l_contas_recebidas_record.descricao					:= 'Registro criado via api HOS Finanças';
			l_contas_recebidas_record.valor_juros				:= 0;
			l_contas_recebidas_record.valor_multa				:= 0;
			l_contas_recebidas_record.valor_desconto			:= 0;
			l_contas_recebidas_record.valor_outros				:= 0;

			insert into contas_recebidas values l_contas_recebidas_record returning id into l_contas_recebidas_id;


			-- >> Buscar dados do parcelamento de cartões
			Begin
				select 
					dias_recebimento,
					taxa_fixa,
					taxa_parcela
				into 
					l_dias_recebimento,
					l_taxa_fixa,
					l_taxa_parcela
				from cartoes_parcelas
				where cartao_id = l_cartao_id
				and parcela_inicial <= p_parcelas
				and parcela_final >= p_parcelas;
			exception
				when no_data_found then
					l_dias_recebimento := 40;
					l_taxa_fixa := 0;
					l_taxa_parcela := 0;
				when others then
					l_dias_recebimento := 40;
					l_taxa_fixa := 0;
					l_taxa_parcela := 0;
			end;

			l_vencimento_cartao := l_vencimento_cartao + l_dias_recebimento;

			l_valor_taxa := 0;

			l_valor_taxa := l_valor_parcela * (l_taxa_fixa / 100);
			l_valor_taxa := l_valor_taxa + (l_valor_parcela * (l_taxa_parcela / 100));

			l_valor_liquido := l_valor_parcela - l_valor_taxa;

		 	l_lancamentos_cartoes_record.contas_pagas_id := null;
		 	l_lancamentos_cartoes_record.contas_recebidas_id := l_contas_recebidas_id;
		 	l_lancamentos_cartoes_record.data := sysdate;
		 	l_lancamentos_cartoes_record.numero := to_char(p_documento);
		 	l_lancamentos_cartoes_record.forma_pagamento_id := l_forma_pagamento_id;
		 	l_lancamentos_cartoes_record.vencimento := l_vencimento_cartao;

		 	if i = 1 then
		 		l_lancamentos_cartoes_record.valor := l_valor_parcela + l_valor_parcela_1;
		 	else
		 		l_lancamentos_cartoes_record.valor := l_valor_parcela;
			end if;

		 	l_lancamentos_cartoes_record.status := 'Pendente';
		 	l_lancamentos_cartoes_record.observacoes := 'Registro criado via api HOS Finanças';
		 	l_lancamentos_cartoes_record.valor_taxa := l_valor_taxa;
		 	l_lancamentos_cartoes_record.valor_liquido := l_valor_liquido;
		 	l_lancamentos_cartoes_record.empresa_id := p_empresa_id;
		 	-- l_lancamentos_cartoes_record.cupom_id := p_cupom_id;

		 	insert into lancamentos_cartoes values l_lancamentos_cartoes_record;
				
		end loop;

	end if;

	return l_cartao_id;

End;


