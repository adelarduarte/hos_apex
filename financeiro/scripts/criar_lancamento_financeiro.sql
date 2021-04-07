create or replace procedure "CRIAR_LANCAMENTO_FINANCEIRO" (
        p_conta_financeira_id       IN  number,
        p_data                      IN  date,
        p_documento                 IN  varchar2,
        p_valor                     IN  number,
        p_centro_custos_id          IN  number,
        p_categoria_financeira_id   IN  number,
        p_contas_pagas_id           IN  number,
        p_contas_recebidas_id       IN  number,
        p_tipo                      IN  varchar2,
        p_empresa_id                IN  number,
        p_conta_pagar_id            IN  number,
        p_conta_receber_id          IN  number
    )
IS
    l_tipo_lancamento_id        Number;
    l_conta_financeira_id       Number;
    l_record                    lancamentos_financeiros%rowtype;

    l_lancamento_provisao_id    number;
    l_valor_provisao            number;
    
Begin
    Select id into l_tipo_lancamento_id
    from tipos_lancamentos_financeiros
    where lower(descricao) = 'financeiro';

    if p_conta_financeira_id is null then
        -->> Setar conta financeira como 'Caixa'     **** Verificar nos scripts iniciais
        select id
        into l_conta_financeira_id
        from contas_financeiras
        where id_interno = 1
        and empresa_id = p_empresa_id;
    else
        l_conta_financeira_id := p_conta_financeira_id;
    end if;

    if p_tipo = 'Pagar' then
        l_record.valor_saida := p_valor;
        l_record.valor_entrada := 0;
        l_record.historico := 'Pago conforme documento ' || p_documento;
        l_record.status_lancamento := '';
    end if;

    if p_tipo = 'Devolucao' then
        l_record.valor_saida := p_valor;
        l_record.valor_entrada := 0;
        l_record.historico := 'Valor devolvido conforme documento ' || p_documento;
        l_record.status_lancamento := 'Devolução';
    end if;

    if p_tipo = 'Cancelamento' then
        l_record.valor_saida := p_valor;
        l_record.valor_entrada := 0;
        l_record.historico := 'Valor cancelado conforme documento ' || p_documento;
        l_record.status_lancamento := 'Cancelamento';
    end if;

    if p_tipo = 'Pagar_Provisao' then
        l_record.valor_saida := p_valor;
        l_record.valor_entrada := 0;
        l_record.historico := 'Provisionado conforme documento ' || p_documento;
        l_record.status_lancamento := 'Provisão';
    end if;

    if p_tipo = 'Receber' then
        l_record.valor_saida := 0;
        l_record.valor_entrada := p_valor;
        l_record.historico := 'Recebido conforme documento ' || p_documento;
        l_record.status_lancamento := '';
    end if;        

    if p_tipo = 'Receber_Provisao' then
        l_record.valor_saida := 0;
        l_record.valor_entrada := p_valor;
        l_record.historico := 'Provisionado conforme documento ' || p_documento;
        l_record.status_lancamento := 'Provisão';
    end if;        


    l_record.conta_financeira_id            := l_conta_financeira_id;
    l_record.data                           := p_data;
    l_record.documento                      := p_documento;
    l_record.tipo_lancamento_financeiro_id  := l_tipo_lancamento_id;
    l_record.conciliado                     := 'Não';
    l_record.centro_custo_id                := p_centro_custos_id;
    l_record.categoria_financeira_id        := p_categoria_financeira_id;
    l_record.conta_paga_id                  := p_contas_pagas_id;
    l_record.conta_recebida_id              := p_contas_recebidas_id;
    l_record.empresa_id                     := p_empresa_id;
    l_record.conta_pagar_id                 := p_conta_pagar_id;
    l_record.conta_receber_id               := p_conta_receber_id;

    insert into lancamentos_financeiros values l_record;

    -->> Liquidar lançamento de Provisão a Receber
    if p_tipo = 'Receber' then
        Begin
            select id, valor_entrada
            into l_lancamento_provisao_id, l_valor_provisao
            from lancamentos_financeiros
            where conta_receber_id = p_conta_receber_id
            and status_lancamento = 'Provisão';
        Exception
            when no_data_found then
                l_lancamento_provisao_id := 0;
            when others then
                l_lancamento_provisao_id := 0;
        End;

        if l_lancamento_provisao_id > 0 then

            if p_valor >= l_valor_provisao then
                update lancamentos_financeiros
                set valor_entrada = 0, 
                    status_lancamento = 'Liquidado'
                where id = l_lancamento_provisao_id;
            else
                update lancamentos_financeiros
                  set valor_entrada = valor_entrada - p_valor
                where id = l_lancamento_provisao_id;
            end if;

        end if;

    end if;



    -->> Liquidar lançamento de Provisão a Pagar
    if p_tipo = 'Pagar' then
        Begin
            select id, valor_saida
            into l_lancamento_provisao_id, l_valor_provisao
            from lancamentos_financeiros
            where conta_pagar_id = p_conta_pagar_id
            and status_lancamento = 'Provisão';
        Exception
            when no_data_found then
                l_lancamento_provisao_id := 0;
            when others then
                l_lancamento_provisao_id := 0;
        End;

        if l_lancamento_provisao_id > 0 then

            if p_valor >= l_valor_provisao then
                update lancamentos_financeiros
                set valor_saida = 0, 
                    status_lancamento = 'Liquidado'
                where id = l_lancamento_provisao_id;
            else
                update lancamentos_financeiros
                  set valor_saida = valor_saida - p_valor
                where id = l_lancamento_provisao_id;
            end if;

        end if;

    end if;

End;
