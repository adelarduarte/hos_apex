create or replace function "CUPOM_CONVENIO_ALTERADO" (
        p_convenio_id   	  IN number,
        p_convenio_vencimento IN date,
        p_convenio_valor      IN number,
        p_empresa_id		  IN number,
        p_cupom_id			  IN number,
        p_documento 		  IN number,
        p_parcelas 			  IN number
	) return varchar2
IS

	l_contas_receber_id			number;
	l_contas_receber_record		contas_receber%rowtype;

	l_status_pendente_id		number;
	l_status_liquidado_id		number;
	l_tipo_documento_id 		number;
	l_centro_custos_id			number;
	l_categoria_financeira_id	number;

	l_valor_parcela				number;
	l_valor_ultima_parcela		number;

Begin
	-- >> Setar status pendente para contas a receber
	Select id
	into l_status_pendente_id
	from status_financeiros
	where nome = 'Pendente';

	-- >> Setar tipo de documento como 'Convênio'
	Select id
	into l_tipo_documento_id
	from tipos_documentos_financeiros
	where descricao = 'Convênio';

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


	l_valor_parcela 		:= p_convenio_valor / p_parcelas;
	l_valor_ultima_parcela  := p_convenio_valor - (l_valor_parcela * (p_parcelas -1));

	for i in 1 .. (p_parcelas -1) loop

		-->> Criar registro contas a receber, retornando o id.
		l_contas_receber_record.data_emissao            := sysdate;
		l_contas_receber_record.data_vencimento         := p_convenio_vencimento;
		l_contas_receber_record.valor                   := l_valor_parcela;
		l_contas_receber_record.saldo                   := l_valor_parcela;
		l_contas_receber_record.cliente_id              := p_convenio_id;
		l_contas_receber_record.empresa_id              := p_empresa_id;
		l_contas_receber_record.cupom_id 				:= p_cupom_id;
		l_contas_receber_record.status_id               := l_status_pendente_id;
		l_contas_receber_record.centro_custo_id         := l_centro_custos_id;
		l_contas_receber_record.categoria_financeira_id := l_categoria_financeira_id;
		l_contas_receber_record.documento 				:= to_char(p_documento);
		l_contas_receber_record.tipo_documento_id 		:= l_tipo_documento_id;

		insert into contas_receber values l_contas_receber_record returning id into l_contas_receber_id;
		
	end loop;

	-->> Criar registro da última parcela, com possível diferença de centavos
	l_contas_receber_record.data_emissao            := sysdate;
	l_contas_receber_record.data_vencimento         := p_convenio_vencimento;
	l_contas_receber_record.valor                   := l_valor_parcela;
	l_contas_receber_record.saldo                   := l_valor_parcela;
	l_contas_receber_record.cliente_id              := p_convenio_id;
	l_contas_receber_record.empresa_id              := p_empresa_id;
	l_contas_receber_record.cupom_id 				:= p_cupom_id;
	l_contas_receber_record.status_id               := l_status_pendente_id;
	l_contas_receber_record.centro_custo_id         := l_centro_custos_id;
	l_contas_receber_record.categoria_financeira_id := l_categoria_financeira_id;
	l_contas_receber_record.documento 				:= to_char(p_documento);
	l_contas_receber_record.tipo_documento_id 		:= l_tipo_documento_id;

	insert into contas_receber values l_contas_receber_record returning id into l_contas_receber_id;

	return to_char(l_contas_receber_id);

End;
