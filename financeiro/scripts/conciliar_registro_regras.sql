create or replace procedure "CONCILIAR_REGISTRO_REGRAS"
    (p_data                 IN  date,
     p_documento            IN  varchar2,
     p_conta_financeira_id  IN  number,
     p_valor_entrada        IN  number,
     p_valor_saida          IN  number,
     p_extrato_id           IN  number,
     p_extrato_tmp_id       IN  number,
     p_regra_id             IN  number,
     p_empresa_id           IN  number)

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
    l_contas_movimento_id   number;
    l_formas_pagamento_id   number;

    -- >> Demais variaveis
    l_tipomovimento         varchar2(20);
    l_centro_custos_id      number;
    l_categoria_id          number;
    l_valor                 number;
    l_codigo_transferencia  varchar2(15);

    -- >> Define quem recebe valor de conciliado 'sim' ou 'não' nas transferências
    l_entrada_conciliada    varchar2(4);
    l_saida_conciliada      varchar2(4);

    -- >> Contas de entrada e saída de transferências
    l_conta_entrada         number;
    l_conta_saida           number;

    -->> Fornecedor ou Cliente, dependendo da regra
    l_fornecedor_id         number;
    l_cliente_id            number;

Begin

    If p_valor_entrada > 0 then
        l_valor := p_valor_entrada;
        l_entrada_conciliada := 'Sim';
        l_saida_conciliada   := 'Não';
    else
        l_valor := p_valor_saida;
        l_entrada_conciliada := 'Não';
        l_saida_conciliada   := 'Sim';
    end if;


    -- >> Setar centro e categoria de acordo com a regra
    Select centro_custos_id,
            categoria_id,
            tipomovimento,
            fornecedor_id,
            cliente_id
    into l_centro_custos_id,
            l_categoria_id,
            l_tipomovimento,
            l_fornecedor_id,
            l_cliente_id
    from banco_regras
    where id = p_regra_id;

    if l_tipomovimento = 'Transferência' then

        l_codigo_transferencia := sys.dbms_random.string('A', 15);

        -- >> Setar a conta de entrada e saida
        select conta_entrada_id, conta_saida_id
        into l_conta_entrada, l_conta_saida
        from banco_regras_transferencias
        where regra_id = p_regra_id;

        -- >> Setar tipo de lançamento para o movimento de contas
        Select id
        into l_tipo_lancamento_id
        from tipos_lancamentos_financeiros
        where descricao = 'Transferências';

        -- >> dependendo da origem no extrato, é declarado primeiro uma saída ou uma entrada
        If l_valor < 0 then
            l_valor := l_valor * -1;

            -- >> Criar o lançamento no movimento de contas, com informação do extrato e como conciliado
            l_lancamentos_financeiros.conta_financeira_id           := l_conta_saida;
            l_lancamentos_financeiros.data                          := p_data;
            l_lancamentos_financeiros.documento                     := p_documento;
            l_lancamentos_financeiros.valor_entrada                 := 0;
            l_lancamentos_financeiros.valor_saida                   := l_valor;
            l_lancamentos_financeiros.historico                     := 'transferência criada por regra de conciliação';
            l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
            l_lancamentos_financeiros.conciliado                    := l_saida_conciliada;
            l_lancamentos_financeiros.centro_custo_id               := l_centro_custos_id;
            l_lancamentos_financeiros.categoria_financeira_id       := l_categoria_id;
            l_lancamentos_financeiros.conta_paga_id                 := null;
            l_lancamentos_financeiros.conta_recebida_id             := null;
            l_lancamentos_financeiros.extrato_id                    := p_extrato_id;
            l_lancamentos_financeiros.transferencia_codigo          := l_codigo_transferencia;

            insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_contas_movimento_id;

            -- >> criar o lançamento no movimento de contas, com informação do extrato e como conciliado
            l_lancamentos_financeiros.conta_financeira_id           := l_conta_entrada;
            l_lancamentos_financeiros.data                          := p_data;
            l_lancamentos_financeiros.documento                     := p_documento;
            l_lancamentos_financeiros.valor_entrada                 := l_valor;
            l_lancamentos_financeiros.valor_saida                   := 0;
            l_lancamentos_financeiros.historico                     := 'transferência criada por regra de conciliação';
            l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
            l_lancamentos_financeiros.conciliado                    := l_entrada_conciliada;
            l_lancamentos_financeiros.centro_custo_id               := l_centro_custos_id;
            l_lancamentos_financeiros.categoria_financeira_id       := l_categoria_id;
            l_lancamentos_financeiros.conta_paga_id                 := null;
            l_lancamentos_financeiros.conta_recebida_id             := null;
            l_lancamentos_financeiros.extrato_id                    := p_extrato_id;
            l_lancamentos_financeiros.transferencia_codigo          := l_codigo_transferencia;

            insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_contas_movimento_id;

        else

            -- >> criar o lançamento no movimento de contas, com informação do extrato e como conciliado
            l_lancamentos_financeiros.conta_financeira_id           := l_conta_entrada;
            l_lancamentos_financeiros.data                          := p_data;
            l_lancamentos_financeiros.documento                     := p_documento;
            l_lancamentos_financeiros.valor_entrada                 := l_valor;
            l_lancamentos_financeiros.valor_saida                   := 0;
            l_lancamentos_financeiros.historico                     := 'transferência criada por regra de conciliação';
            l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
            l_lancamentos_financeiros.conciliado                    := l_entrada_conciliada;
            l_lancamentos_financeiros.centro_custo_id               := l_centro_custos_id;
            l_lancamentos_financeiros.categoria_financeira_id       := l_categoria_id;
            l_lancamentos_financeiros.conta_paga_id                 := null;
            l_lancamentos_financeiros.conta_recebida_id             := null;
            l_lancamentos_financeiros.extrato_id                    := p_extrato_id;
            l_lancamentos_financeiros.transferencia_codigo          := l_codigo_transferencia;

            insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_contas_movimento_id;

            -- >> criar o lançamento no movimento de contas, com informação do extrato e como conciliado
            l_lancamentos_financeiros.conta_financeira_id           := l_conta_saida;
            l_lancamentos_financeiros.data                          := p_data;
            l_lancamentos_financeiros.documento                     := p_documento;
            l_lancamentos_financeiros.valor_entrada                 := 0;
            l_lancamentos_financeiros.valor_saida                   := l_valor;
            l_lancamentos_financeiros.historico                     := 'transferência criada por regra de conciliação';
            l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
            l_lancamentos_financeiros.conciliado                    := l_saida_conciliada;
            l_lancamentos_financeiros.centro_custo_id               := l_centro_custos_id;
            l_lancamentos_financeiros.categoria_financeira_id       := l_categoria_id;
            l_lancamentos_financeiros.conta_paga_id                 := null;
            l_lancamentos_financeiros.conta_recebida_id             := null;
            l_lancamentos_financeiros.extrato_id                    := p_extrato_id;
            l_lancamentos_financeiros.transferencia_codigo          := l_codigo_transferencia;

            insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_contas_movimento_id;

        end if;

        -- ===========================================================
        -- >>>>>>>>>>>>>>>>>>> extrato bancário <<<<<<<<<<<<<<<<<<<<<<
        -- ===========================================================

        -- >> setar o extrato como conciliado, com o id do movimento de contas
        update extratos_bancarios
        set conciliado          = 'Sim',
            centro_custos_id    = l_centro_custos_id,
            categoria_custos_id = l_categoria_id,
            lancamento_financeiro_id = l_contas_movimento_id
        where id = p_extrato_id;



        -- >> mudar o status do extrato tmp para conciliado
        update extratos_tmp
        set status = 'Conciliado'
        where id = p_extrato_tmp_id;


    else

        -- >> setar tipo de lançamento para o movimento de contas
        select id
        into l_tipo_lancamento_id
        from tipos_lancamentos_financeiros
        where descricao = 'Regras';

        -- >> setar status pendente para contas a pagar e receber
        select id
        into l_status_pendente_id
        from status_financeiros
        where nome = 'Pendente';


        -- >> setar status liquidado para contas pagas e recebidas
        select id
        into l_status_liquidado_id
        from status_financeiros
        where nome = 'Liquidado';

        -- >> setar id da forma de pagamento como dinheiro
        select id
        into l_formas_pagamento_id
        from formas_pagamentos_financeiros
        where descricao = 'Dinheiro'
        and empresa_id = p_empresa_id;


        if l_fornecedor_id is not null or l_cliente_id is not null then

            if l_fornecedor_id is not null then
                -- ===========================================================
                -- >>>>>>>>>>>>>>>>>>> contas a pagar <<<<<<<<<<<<<<<<<<<<<<<<
                -- ===========================================================

                if l_valor < 0 then
                    l_valor := l_valor * -1;
                end if;


                -- >> criar lançamento de contas a pagar, como liquidado.
                l_contas_pagar.fornecedor_id           := l_fornecedor_id;
                l_contas_pagar.centro_custo_id         := l_centro_custos_id;
                l_contas_pagar.categoria_financeira_id := l_categoria_id;
                l_contas_pagar.documento               := p_documento;
                l_contas_pagar.data_emissao            := p_data;
                l_contas_pagar.data_vencimento         := p_data;
                l_contas_pagar.data_agendamento        := p_data;
                l_contas_pagar.recorrente              := 'Não';
                l_contas_pagar.parcelado               := 'Não';
                l_contas_pagar.valor                   := l_valor;
                l_contas_pagar.saldo                   := 0;
                l_contas_pagar.status_id               := l_status_liquidado_id;
                l_contas_pagar.descricao               := 'pagamento criado por regra de conciliação';

                insert into contas_pagar values l_contas_pagar returning id into l_contas_pagar_id;



                -- >> criar lançamento de contas pagas
                l_contas_pagas.conta_pagar_id          := l_contas_pagar_id;
                l_contas_pagas.fornecedor_id           := l_fornecedor_id;
                l_contas_pagas.centro_custo_id         := l_centro_custos_id;
                l_contas_pagas.categoria_financeira_id := l_categoria_id;
                l_contas_pagas.conta_financeira_id     := p_conta_financeira_id;
                l_contas_pagas.documento               := p_documento;
                l_contas_pagas.data_vencimento         := p_data;
                l_contas_pagas.data_pagamento          := p_data;
                l_contas_pagas.valor                   := l_valor;
                l_contas_pagas.valor_pago              := l_valor;
                l_contas_pagas.saldo                   := l_valor;
                l_contas_pagas.forma_pagamento_id      := l_formas_pagamento_id;
                l_contas_pagas.descricao               := 'Pagamento criado por regra de conciliação';
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
                l_lancamentos_financeiros.valor_saida                   := l_valor;
                l_lancamentos_financeiros.historico                     := 'Pagamento criado por regra de conciliação';
                l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
                l_lancamentos_financeiros.conciliado                    := 'Sim';
                l_lancamentos_financeiros.centro_custo_id               := l_centro_custos_id;
                l_lancamentos_financeiros.categoria_financeira_id       := l_categoria_id;
                l_lancamentos_financeiros.conta_paga_id                 := l_contas_pagas_id;
                l_lancamentos_financeiros.conta_recebida_id             := null;
                l_lancamentos_financeiros.extrato_id                    := p_extrato_id;

                insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_contas_movimento_id;


            else
                -- ===========================================================
                -- >>>>>>>>>>>>>>>>>>> contas a receber <<<<<<<<<<<<<<<<<<<<<<
                -- ===========================================================

                -- >> criar lançamento de contas a receber, como liquidado.
                l_contas_receber.cliente_id              := l_cliente_id;
                l_contas_receber.centro_custo_id         := l_centro_custos_id;
                l_contas_receber.categoria_financeira_id := l_categoria_id;
                l_contas_receber.documento               := p_documento;
                l_contas_receber.data_emissao            := p_data;
                l_contas_receber.data_vencimento         := p_data;
                l_contas_receber.data_agendamento        := p_data;
                l_contas_receber.recorrente              := 'Não';
                l_contas_receber.parcelado               := 'Não';
                l_contas_receber.valor                   := l_valor;
                l_contas_receber.saldo                   := 0;
                l_contas_receber.status_id               := l_status_liquidado_id;
                l_contas_receber.descricao               := 'Recebimento criado por regra de conciliação';

                insert into contas_receber values l_contas_receber returning id into l_contas_receber_id;


                -- >> criar lançamento de contas recebidas
                l_contas_recebidas.conta_receber_id        := l_contas_receber_id;
                l_contas_recebidas.cliente_id              := l_cliente_id;
                l_contas_recebidas.centro_custo_id         := l_centro_custos_id;
                l_contas_recebidas.categoria_financeira_id := l_categoria_id;
                l_contas_recebidas.conta_financeira_id     := p_conta_financeira_id;
                l_contas_recebidas.documento               := p_documento;
                l_contas_recebidas.data_vencimento         := p_data;
                l_contas_recebidas.data_recebimento        := p_data;
                l_contas_recebidas.valor                   := l_valor;
                l_contas_recebidas.forma_pagamento_id      := l_formas_pagamento_id;
                l_contas_recebidas.valor_recebido          := l_valor;
                l_contas_recebidas.saldo                   := l_valor;
                l_contas_recebidas.descricao               := 'Recebimento criado por regra de conciliação';
                l_contas_recebidas.valor_juros             := 0;
                l_contas_recebidas.valor_multa             := 0;
                l_contas_recebidas.valor_desconto          := 0;
                l_contas_recebidas.valor_outros            := 0;

                insert into contas_recebidas values l_contas_recebidas returning id into l_contas_recebidas_id;



                -- >> criar o lançamento no movimento de contas, com informação do extrato e como conciliado
                l_lancamentos_financeiros.conta_financeira_id           := p_conta_financeira_id;
                l_lancamentos_financeiros.data                          := p_data;
                l_lancamentos_financeiros.documento                     := p_documento;
                l_lancamentos_financeiros.valor_entrada                 := l_valor;
                l_lancamentos_financeiros.valor_saida                   := 0;
                l_lancamentos_financeiros.historico                     := 'Recebimento criado por regra de conciliação';
                l_lancamentos_financeiros.tipo_lancamento_financeiro_id := l_tipo_lancamento_id;
                l_lancamentos_financeiros.conciliado                    := 'Sim';
                l_lancamentos_financeiros.centro_custo_id               := l_centro_custos_id;
                l_lancamentos_financeiros.categoria_financeira_id       := l_categoria_id;
                l_lancamentos_financeiros.conta_paga_id                 := null;
                l_lancamentos_financeiros.conta_recebida_id             := l_contas_recebidas_id;
                l_lancamentos_financeiros.extrato_id                    := p_extrato_id;

                insert into lancamentos_financeiros values l_lancamentos_financeiros returning id into l_contas_movimento_id;


            end if;

            -- ===========================================================
            -- >>>>>>>>>>>>>>>>>>> extrato bancário <<<<<<<<<<<<<<<<<<<<<<
            -- ===========================================================

            -- >> setar o extrato como conciliado, com o id do movimento de contas
            update extratos_bancarios
            set conciliado          = 'Sim',
                centro_custos_id    = l_centro_custos_id,
                categoria_custos_id = l_categoria_id,
                lancamento_financeiro_id = l_contas_movimento_id
            where id = p_extrato_id;



            -- >> Mudar o status do extrato tmp para conciliado
            update extratos_tmp
            set status = 'Conciliado'
            where id = p_extrato_tmp_id;

        end if;

    end if;


End;