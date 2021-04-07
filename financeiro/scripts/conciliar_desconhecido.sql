create or replace procedure "CONCILIAR_DESCONHECIDO"
    (p_data                 IN  date,
     p_documento            IN  varchar2,
     p_conta_financeira_id  IN  number,
     p_centro_custos_id     IN  number,
     p_categoria_id         IN  number,
     p_cliente_id           IN  number,
     p_fornecedor_id        IN  number,
     p_valor                IN  number,
     p_extrato_id           IN  number,
     p_pagar_id             IN  number,
     p_receber_id           IN  number,
     p_movimento_id         IN  number,
     p_extrato_tmp_id       IN  number)

Is
    -- >> Registros das tabelas envolvidas
    l_lancamentos_financeiros    lancamentos_financeiros%rowtype;
    l_contas_pagar               contas_pagar%rowtype;
    l_contas_pagas               contas_pagas%rowtype;
    l_contas_receber             contas_receber%rowtype;
    l_contas_recebidas           contas_recebidas%rowtype;

    -- >> Status de lançamentos
    l_tipo_lancamento_id    number;
    l_status_pendente_id    number;
    l_status_liquidado_id   number;

    -- >> ID's para relacionamento
    l_contas_pagar_id       number;
    l_contas_pagas_id       number;
    l_contas_receber_id     number;
    l_contas_recebidas_id   number;
    l_lancamentos_financeiros_id    number;
    l_formas_pagamento_id   number;

    l_historico             varchar2(300);

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

    -- >> Retirada etapa forma de pagamento, por não podermos 
    --    garantir a existência
    --    da forma correta.
    -- >> ******** Setar id da forma de pagamento como Dinheiro
    Select id
    into l_formas_pagamento_id
    from formas_pagamentos_financeiros
    where descricao = 'Dinheiro'
    and empresa_id = V('SES_EMPRESAS_ID');


    If p_pagar_id > 0 then
        -- ===========================================================
        -- >>>>>>>>>>>>>>>>>>> Contas a Pagar <<<<<<<<<<<<<<<<<<<<<<<<
        -- ===========================================================

        -- >> Alterar o Contas a pagar, para retirar o saldo e mudar o status.
        update contas_pagar
        set status_id    = l_status_liquidado_id,
            saldo       = 0
        where id = p_pagar_id;

        select descricao
        into l_historico
        from contas_pagar
        where id = p_pagar_id;


        -- >> criar lançamento de contas pagas
        l_contas_pagas.conta_pagar_id          := p_pagar_id;
        l_contas_pagas.fornecedor_id           := p_fornecedor_id;
        l_contas_pagas.centro_custo_id         := p_centro_custos_id;
        l_contas_pagas.categoria_financeira_id := p_categoria_id;
        l_contas_pagas.conta_financeira_id     := p_conta_financeira_id;
        l_contas_pagas.documento               := p_documento;
        l_contas_pagas.data_vencimento         := p_data;
        l_contas_pagas.data_pagamento          := p_data;
        l_contas_pagas.valor                   := p_valor;
        l_contas_pagas.valor_pago              := p_valor;
        l_contas_pagas.saldo                   := 0;
        l_contas_pagas.forma_pagamento_id      := null;
        l_contas_pagas.descricao               := l_historico;
        l_contas_pagas.valor_juro              := 0;
        l_contas_pagas.valor_multa             := 0;
        l_contas_pagas.valor_desconto          := 0;
        l_contas_pagas.valor_outros            := 0;

        insert into contas_pagas values l_contas_pagas returning id into l_contas_pagas_id;



        -- >> criar o lançamento no movimento de contas, com informação do extrato e como conciliado
        l_lancamentos_financeiros.conta_financeira_id           := p_conta_financeira_id;
        l_lancamentos_financeiros.data                          := p_data;
        l_lancamentos_financeiros.documento                     := p_documento;
        l_lancamentos_financeiros.valor_entrada                 := 0;
        l_lancamentos_financeiros.valor_saida                   := p_valor;
        l_lancamentos_financeiros.historico                     := l_historico;
        l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
        l_lancamentos_financeiros.conciliado                    := 'sim';
        l_lancamentos_financeiros.centro_custo_id               := p_centro_custos_id;
        l_lancamentos_financeiros.categoria_financeira_id       := p_categoria_id;
        l_lancamentos_financeiros.conta_paga_id                 := l_contas_pagas_id;
        l_lancamentos_financeiros.conta_recebida_id             := null;
        l_lancamentos_financeiros.extrato_id                    := p_extrato_id;

        insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_lancamentos_financeiros_id;

    end if;


    if p_receber_id > 0 then
        -- ===========================================================
        -- >>>>>>>>>>>>>>>>>>> contas a receber <<<<<<<<<<<<<<<<<<<<<<
        -- ===========================================================

        -- >> alterar o contas a receber, para retirar o saldo e mudar o status.
        update contas_receber
        set status_id    = l_status_liquidado_id,
            saldo       = 0
        where id = p_receber_id;

        select descricao
        into l_historico
        from contas_receber
        where id = p_receber_id;

        -- >> criar lançamento de contas recebidas
        l_contas_recebidas.conta_receber_id       := p_receber_id;
        l_contas_recebidas.cliente_id              := p_cliente_id;
        l_contas_recebidas.centro_custo_id         := p_centro_custos_id;
        l_contas_recebidas.categoria_financeira_id := p_categoria_id;
        l_contas_recebidas.conta_financeira_id     := p_conta_financeira_id;
        l_contas_recebidas.documento               := p_documento;
        l_contas_recebidas.data_vencimento         := p_data;
        l_contas_recebidas.data_recebimento        := p_data;
        l_contas_recebidas.valor                   := p_valor;
        l_contas_recebidas.forma_pagamento_id      := null;
        l_contas_recebidas.valor_recebido          := p_valor;
        l_contas_recebidas.saldo                   := 0;
        l_contas_recebidas.descricao               := l_historico;
        l_contas_recebidas.valor_juros             := 0;
        l_contas_recebidas.valor_multa             := 0;
        l_contas_recebidas.valor_desconto          := 0;
        l_contas_recebidas.valor_outros            := 0;

        insert into contas_recebidas values l_contas_recebidas returning id into l_contas_recebidas_id;



        -- >> criar o lançamento no movimento de contas, com informação do extrato e como conciliado
        l_lancamentos_financeiros.conta_financeira_id           := p_conta_financeira_id;
        l_lancamentos_financeiros.data                          := p_data;
        l_lancamentos_financeiros.documento                     := p_documento;
        l_lancamentos_financeiros.valor_entrada                 := p_valor;
        l_lancamentos_financeiros.valor_saida                   := 0;
        l_lancamentos_financeiros.historico                     := l_historico;
        l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
        l_lancamentos_financeiros.conciliado                    := 'sim';
        l_lancamentos_financeiros.centro_custo_id               := p_centro_custos_id;
        l_lancamentos_financeiros.categoria_financeira_id       := p_categoria_id;
        l_lancamentos_financeiros.conta_paga_id                 := null;
        l_lancamentos_financeiros.conta_recebida_id             := l_contas_recebidas_id;
        l_lancamentos_financeiros.extrato_id                    := p_extrato_id;

        insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_lancamentos_financeiros_id;


    end if;


    if p_movimento_id > 0 then
        -- ===========================================================
        -- >>>>>>>>>>>>>>>>> movimento de contas <<<<<<<<<<<<<<<<<<<<<
        -- ===========================================================

        -- >> alterar o movimento de contas, para setar o extrato e mudar o status.
        update lancamentos_financeiros
        set conciliado = 'sim',
            extrato_id  = p_extrato_id
        where id = p_movimento_id;


    end if;


    -- ===========================================================
    -- >>>>>>>>>>>>>>>>>>> extrato bancário <<<<<<<<<<<<<<<<<<<<<<
    -- ===========================================================

    -- >> setar o extrato como conciliado, com o id do movimento de contas
    update extratos_bancarios
    set 
        conciliado               = 'sim',
        centro_custos_id         = p_centro_custos_id,
        categoria_custos_id      = p_categoria_id,
        lancamento_financeiro_id = l_lancamentos_financeiros_id
    where id = p_extrato_id;



    -- >> mudar o status do extrato tmp para conciliado
    update extratos_tmp
    set status = 'conciliado'
    where id = p_extrato_tmp_id;


End;
