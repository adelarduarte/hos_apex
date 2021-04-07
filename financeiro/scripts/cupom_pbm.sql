create or replace function "CUPOM_PBM" (
        p_cliente_id	   	  IN number,
        p_valor 		      IN number,
        p_empresa_id		  IN number,
        p_cupom_id			  IN number,
        p_documento 		  IN number,
        p_pbm 				  IN varchar2
	) return varchar2
IS
	l_contas_receber_id			number;
	l_contas_receber_record		contas_receber%rowtype;
	l_status_pendente_id 		number;

	l_tipo_documento_id 		number;
	l_centro_custos_id			number;
	l_categoria_financeira_id	number;
    
    l_tipo_fechamento           varchar2(50);
    l_dia_fechamento            number;
    l_dia_vencimento            number;

    t_mes_vencimento            number;
    t_ano_vencimento            number;
	t_dia_venda					number;
    l_data_vencimento           date;
Begin
	-- >> Setar status pendente para contas a receber
	Select id
	into l_status_pendente_id
	from status_financeiros
	where lower(nome) = 'pendente';

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


    -->> Buscar preferências de fechamento
    --   de PBM, para calcular vencimento
    --   do título
    Begin
        select dia_fechamento, dia_vencimento, tipo_fechamento
        into l_dia_fechamento, l_dia_vencimento, l_tipo_fechamento
        from empresas_preferencias
        where empresa_id = p_empresa_id;
    Exception
        when no_data_found then
            l_tipo_fechamento := 'Indefinido';
        when others then
            l_tipo_fechamento := 'Indefinido';
    End;
    
    -->> Calcular vencimento
    if l_tipo_fechamento <> 'Indefinido' then

		if lower(l_tipo_fechamento) = 'ultimo_dia' then
			-->> Cálculo do vencimento é sempre o dia indicado do próximo mês.
			select extract(month from sysdate) 
			into t_mes_vencimento
			from dual;

			select extract(year from sysdate)
			into t_ano_vencimento
			from dual;

			t_mes_vencimento := t_mes_vencimento + 1;

			if t_mes_vencimento > 12 then
				t_ano_vencimento := t_ano_vencimento + 1;
				t_mes_vencimento := 1;
			end if;
		else
			-->> Cálculo do vencimento leva em conta a data de fechamento das vendas,
			--	 podendo ser um dia do próximo mês, ou do mês subsequente.
			select extract(day from sysdate)
			into t_dia_venda
			from dual;

			select extract(month from sysdate) 
			into t_mes_vencimento
			from dual;

			select extract(year from sysdate)
			into t_ano_vencimento
			from dual;

			-->> Verificar dia da venda em relação ao fechamento
			if t_dia_venda <= l_dia_fechamento then
				t_mes_vencimento := t_mes_vencimento + 1;
			else
				t_mes_vencimento := t_mes_vencimento + 2;
			end if;

			if t_mes_vencimento > 12 then
				t_ano_vencimento := t_ano_vencimento + 1;
				t_mes_vencimento := t_mes_vencimento - 12;
			end if;
		end if;

        l_data_vencimento := to_date(to_char(l_dia_vencimento) || '/' || to_char(t_mes_vencimento) || '/' || to_char(t_ano_vencimento), 'DD/MM/YYYY');
    else
        l_data_vencimento := sysdate;
    end if;
    
    
	-->> Criar registro contas a receber, retornando o id.
	l_contas_receber_record.data_emissao            := sysdate;
	l_contas_receber_record.data_vencimento         := l_data_vencimento;

	l_contas_receber_record.valor  					:= p_valor;

	l_contas_receber_record.saldo                   := p_valor;
	l_contas_receber_record.cliente_id              := p_cliente_id;
	l_contas_receber_record.empresa_id              := p_empresa_id;
	l_contas_receber_record.cupom_id 				:= p_cupom_id;
	l_contas_receber_record.status_id               := l_status_pendente_id;
	l_contas_receber_record.centro_custo_id         := l_centro_custos_id;
	l_contas_receber_record.categoria_financeira_id := l_categoria_financeira_id;
	l_contas_receber_record.documento 				:= to_char(p_documento);
	l_contas_receber_record.tipo_documento_id 		:= l_tipo_documento_id;
	l_contas_receber_record.pbm 					:= p_pbm;
    
    -->> Setar o Status Popular 
    IF upper(p_pbm) = 'FARMACIA POPULAR' THEN
            l_contas_receber_record.status_popular := 'Aberta';
    END IF;

	insert into contas_receber values l_contas_receber_record returning id into l_contas_receber_id;

	return to_char(l_contas_receber_id);

End;
