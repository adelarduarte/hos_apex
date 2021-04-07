create or replace PROCEDURE "CONCILIAR_NOVO_REGISTRO" 
	(p_data					IN	date,
     p_data_comp            IN  date,
	 p_documento			IN	varchar2,
	 p_conta_financeira_id	IN	number,
	 p_centro_resultados_id	IN	number,
	 p_categoria_id			IN	number,
	 p_cliente_id			IN	number,
	 p_fornecedor_id		IN	number,
	 p_valor				IN	number,
	 p_historico			IN	varchar2,
	 p_extrato_id			IN	number,
	 p_extrato_tmp_id		IN	number)
Is
	-- >> Registros das tabelas envolvidas
    l_lancamentos_financeiros    lancamentos_financeiros%rowtype;
	l_contas_pagar		 		 contas_pagar%rowtype;
	l_contas_pagas	 			 contas_pagas%rowtype;
	l_contas_receber	 		 contas_receber%rowtype;
	l_contas_recebidas	 		 contas_recebidas%rowtype;

	-- >> Status de lançamentos
    l_tipo_lancamento_id 	number;
    l_status_pendente_id	number;
    l_status_liquidado_id	number;

    -- >> ID's para relacionamento
    l_contas_pagar_id				number;
    l_contas_pagas_id				number;
    l_contas_receber_id				number;
    l_contas_recebidas_id			number;
    l_lancamentos_financeiros_id	number;
    l_formas_pagamento_id   		number;
Begin
	-- >> Setar tipo de lançamento para o movimento de contas
	Select id
	into l_tipo_lancamento_id
	from tipos_lancamentos_financeiros
	where descricao = 'Conciliação';

	-- >> Setar status pendente para contas a pagar e receber
	Select id
	into l_status_pendente_id
	from status_financeiros
	where nome = 'Pendente';

	-- >> Setar status liquidado para contas pagas e recebidas
	Select id
	into l_status_liquidado_id
	from status_financeiros
	where nome = 'Liquidado';

    -- >> Setar id da forma de pagamento como Dinheiro
    Select id
    into l_formas_pagamento_id
    from formas_pagamentos_financeiros
    where descricao = 'Dinheiro'
    and empresa_id = V('SES_EMPRESAS_ID');
	If p_fornecedor_id > 0 then

		-- ===========================================================
		-- >>>>>>>>>>>>>>>>>>> Contas a Pagar <<<<<<<<<<<<<<<<<<<<<<<<
		-- ===========================================================

		-- >> Criar lançamento de contas a pagar, como liquidado.
		l_contas_pagar.fornecedor_id			:= p_fornecedor_id;
		l_contas_pagar.centro_custo_id			:= p_centro_resultados_id;
		l_contas_pagar.categoria_financeira_id	:= p_categoria_id;
		l_contas_pagar.documento				:= p_documento;
		l_contas_pagar.data_emissao				:= p_data;
		l_contas_pagar.data_vencimento			:= p_data;
		l_contas_pagar.data_agendamento			:= p_data;
		l_contas_pagar.recorrente				:= 'Não';
		l_contas_pagar.parcelado				:= 'Não';
		l_contas_pagar.valor					:= p_valor;
		l_contas_pagar.saldo					:= 0;
		l_contas_pagar.status_id				:= l_status_liquidado_id;
		l_contas_pagar.descricao				:= p_historico;

		insert into contas_pagar values l_contas_pagar returning id into l_contas_pagar_id;

		-- >> Criar lançamento de contas pagas
		l_contas_pagas.conta_pagar_id			:= l_contas_pagar_id;
		l_contas_pagas.fornecedor_id			:= p_fornecedor_id;
		l_contas_pagas.centro_custo_id			:= p_centro_resultados_id;
		l_contas_pagas.categoria_financeira_id	:= p_categoria_id;
		l_contas_pagas.conta_financeira_id		:= p_conta_financeira_id;
		l_contas_pagas.documento				:= p_documento;
		l_contas_pagas.data_vencimento			:= p_data;
		l_contas_pagas.data_pagamento			:= p_data;
		l_contas_pagas.valor					:= p_valor;
		l_contas_pagas.valor_pago				:= p_valor;
		l_contas_pagas.saldo					:= p_valor;
		l_contas_pagas.forma_pagamento_id		:= l_formas_pagamento_id;
		l_contas_pagas.descricao				:= p_historico;
		l_contas_pagas.valor_juro				:= 0;
		l_contas_pagas.valor_multa				:= 0;
		l_contas_pagas.valor_desconto			:= 0;
		l_contas_pagas.valor_outros				:= 0;

		insert into contas_pagas values l_contas_pagas returning id into l_contas_pagas_id;

		-- >> Criar o lançamento no movimento de contas, com informação do extrato e como conciliado
		l_lancamentos_financeiros.conta_financeira_id			:= p_conta_financeira_id;
		l_lancamentos_financeiros.data							:= p_data;
		l_lancamentos_financeiros.documento						:= p_documento;
		l_lancamentos_financeiros.valor_entrada					:= 0;
		l_lancamentos_financeiros.valor_saida					:= p_valor;
		l_lancamentos_financeiros.historico						:= p_historico;
		l_lancamentos_financeiros.tipo_lancamento_financeiro_id	:= l_tipo_lancamento_id;
		l_lancamentos_financeiros.conciliado					:= 'Sim';
		l_lancamentos_financeiros.centro_custo_id				:= p_centro_resultados_id;
		l_lancamentos_financeiros.categoria_financeira_id		:= p_categoria_id;
		l_lancamentos_financeiros.conta_paga_id					:= l_contas_pagas_id;
		l_lancamentos_financeiros.conta_recebida_id				:= null;
		l_lancamentos_financeiros.extrato_id					:= p_extrato_id;

		insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_lancamentos_financeiros_id;
	else
		-- ===========================================================
		-- >>>>>>>>>>>>>>>>>>> Contas a Receber <<<<<<<<<<<<<<<<<<<<<<
		-- ===========================================================

		-- >> Criar lançamento de contas a receber, como liquidado.
		l_contas_receber.cliente_id					:= p_cliente_id;
		l_contas_receber.centro_custo_id			:= p_centro_resultados_id;
		l_contas_receber.categoria_financeira_id	:= p_categoria_id;
		l_contas_receber.documento					:= p_documento;
		l_contas_receber.data_emissao				:= p_data;
		l_contas_receber.data_vencimento			:= p_data;
		l_contas_receber.data_agendamento			:= p_data;
		l_contas_receber.recorrente					:= 'Não';
		l_contas_receber.parcelado					:= 'Não';
		l_contas_receber.valor						:= p_valor;
		l_contas_receber.saldo						:= 0;
		l_contas_receber.status_id					:= l_status_liquidado_id;
		l_contas_receber.descricao					:= p_historico;

		insert into contas_receber values l_contas_receber returning id into l_contas_receber_id;

		-- >> Criar lançamento de contas recebidas
		l_contas_recebidas.conta_receber_id			:= l_contas_receber_id;
		l_contas_recebidas.cliente_id				:= p_cliente_id;
		l_contas_recebidas.centro_custo_id			:= p_centro_resultados_id;
		l_contas_recebidas.categoria_financeira_id	:= p_categoria_id;
		l_contas_recebidas.conta_financeira_id		:= p_conta_financeira_id;
		l_contas_recebidas.documento				:= p_documento;
		l_contas_recebidas.data_vencimento			:= p_data;
		l_contas_recebidas.data_recebimento			:= p_data;
		l_contas_recebidas.valor					:= p_valor;
		l_contas_recebidas.forma_pagamento_id		:= l_formas_pagamento_id;
		l_contas_recebidas.valor_recebido			:= p_valor;
		l_contas_recebidas.saldo					:= p_valor;
		l_contas_recebidas.descricao				:= p_historico;
		l_contas_recebidas.valor_juros				:= 0;
		l_contas_recebidas.valor_multa				:= 0;
		l_contas_recebidas.valor_desconto			:= 0;
		l_contas_recebidas.valor_outros				:= 0;

		insert into contas_recebidas values l_contas_recebidas returning id into l_contas_recebidas_id;

		-- >> Criar o lançamento no movimento de contas, com informação do extrato e como conciliado
		l_lancamentos_financeiros.conta_financeira_id			:= p_conta_financeira_id;
		l_lancamentos_financeiros.data							:= p_data;
		l_lancamentos_financeiros.documento						:= p_documento;
		l_lancamentos_financeiros.valor_entrada					:= p_valor;
		l_lancamentos_financeiros.valor_saida					:= 0;
		l_lancamentos_financeiros.historico						:= p_historico;
		l_lancamentos_financeiros.tipo_lancamento_financeiro_id	:= l_tipo_lancamento_id;
		l_lancamentos_financeiros.conciliado					:= 'Sim';
		l_lancamentos_financeiros.centro_custo_id				:= p_centro_resultados_id;
		l_lancamentos_financeiros.categoria_financeira_id		:= p_categoria_id;
		l_lancamentos_financeiros.conta_paga_id					:= null;
		l_lancamentos_financeiros.conta_recebida_id				:= l_contas_recebidas_id;
		l_lancamentos_financeiros.extrato_id					:= p_extrato_id;

		insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_lancamentos_financeiros_id;
	end if;
	-- ===========================================================
	-- >>>>>>>>>>>>>>>>>>> Extrato Bancário <<<<<<<<<<<<<<<<<<<<<<
	-- ===========================================================

	-- >> Setar o extrato como conciliado, com o id do movimento de contas
	update extratos_bancarios
	set conciliado 			= 'Sim',
		centro_custos_id			= p_centro_resultados_id,
		categoria_custos_id			= p_categoria_id,
		lancamento_financeiro_id	= l_lancamentos_financeiros_id
	where id = p_extrato_id;

	-- >> Mudar o status do extrato tmp para conciliado
	update extratos_tmp
	set status = 'Conciliado'
	where id = p_extrato_tmp_id;
End;
