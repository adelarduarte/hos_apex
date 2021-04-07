create or replace PROCEDURE "CARREGAR_FINANCEIRO" 
(
    p_data_inicial      IN      date,
    p_data_final        IN      date,
    p_conta_id          IN      number,
    p_tipo              IN      varchar2
)
IS
    l_financeiro_tmp    financeiro_tmp%rowtype;
Begin
    -->> Se o parâmetro p_tipo for igual a 'Recebimento'
    --   devem ser lidas apenas as tabelas de contas a receber
    --   e movimento de contas de entradas. Caso seja 'Pagamento',
    --   devem ser lidas as tabelas de contas a pagar e movimento de contas
    --   de saídas.

    -->> Limpar arquivo anterior
    delete from financeiro_tmp
    where empresa_id = V('SES_EMPRESAS_ID');
    if p_tipo = 'Pagamento' then
        -->> Ler Contas a pagar
        for rec in (
                select  id,
                        documento,
                        data_emissao,
                        data_vencimento,
                        fornecedor_id,
                        categoria_financeira_id,
                        centro_custo_id,
                        saldo
                from contas_pagar
                where data_vencimento >= p_data_inicial
                and   data_vencimento <= p_data_final
                and   saldo > 0
                and   empresa_id = V('SES_EMPRESAS_ID'))
        LOOP
            -->> Criar o novo registro em financeiro_tmp
            l_financeiro_tmp.a_pagar_id                 := rec.id;
            l_financeiro_tmp.a_receber_id               := null;
            l_financeiro_tmp.movimento_id               := null;
            l_financeiro_tmp.documento                  := rec.documento;
            l_financeiro_tmp.data_emissao               := rec.data_emissao;
            l_financeiro_tmp.data_vencimento            := rec.data_vencimento;
            l_financeiro_tmp.cliente_fornecedor_id      := rec.fornecedor_id;
            l_financeiro_tmp.categoria_id               := rec.categoria_financeira_id;
            l_financeiro_tmp.centro_id                  := rec.centro_custo_id;
            l_financeiro_tmp.valor                      := rec.saldo;
            l_financeiro_tmp.empresa_id                 := V('SES_EMPRESAS_ID');
            l_financeiro_tmp.status                     := 'Pendente';
            insert into financeiro_tmp values l_financeiro_tmp;
        END LOOP;
    End if;
    if p_tipo = 'Recebimento' then
        -->> Ler Contas a receber
        for rec in (
                select  id,
                        documento,
                        data_emissao,
                        data_vencimento,
                        cliente_id,
                        categoria_financeira_id,
                        centro_custo_id,
                        saldo
                from contas_receber
                where data_vencimento >= p_data_inicial
                and   data_vencimento <= p_data_final
                and   saldo > 0
                and   empresa_id = V('SES_EMPRESAS_ID'))
        LOOP
            -->> Criar o novo registro em financeiro_tmp
            l_financeiro_tmp.a_pagar_id                 := null;
            l_financeiro_tmp.a_receber_id               := rec.id;
            l_financeiro_tmp.movimento_id               := null;
            l_financeiro_tmp.documento                  := rec.documento;
            l_financeiro_tmp.data_emissao               := rec.data_emissao;
            l_financeiro_tmp.data_vencimento            := rec.data_vencimento;
            l_financeiro_tmp.cliente_fornecedor_id      := rec.cliente_id;
            l_financeiro_tmp.categoria_id               := rec.categoria_financeira_id;
            l_financeiro_tmp.centro_id                  := rec.centro_custo_id;
            l_financeiro_tmp.valor                      := rec.saldo;
            l_financeiro_tmp.empresa_id                 := V('SES_EMPRESAS_ID');
            l_financeiro_tmp.status                     := 'Pendente';
            insert into financeiro_tmp values l_financeiro_tmp;
        END LOOP;
    End if;
    -->> Ler movimento de Contas - Pagamento
    if p_tipo = 'Pagamento' then
        for rec in (
            select  id,
                    data,
                    documento,
                    categoria_financeira_id,
                    centro_custo_id,
                    valor_saida as valor
            from lancamentos_financeiros
            where data >= p_data_inicial
            and   data <= p_data_final
            and   conta_financeira_id = p_conta_id
            and   empresa_id = V('SES_EMPRESAS_ID')
            and   conciliado != 'Sim'
            and   valor_saida > 0)
        LOOP
            -->> Criar novo registro em financeiro_tmp
                l_financeiro_tmp.a_pagar_id                 := null;
                l_financeiro_tmp.a_receber_id               := null;
                l_financeiro_tmp.movimento_id               := rec.id;
                l_financeiro_tmp.documento                  := rec.documento;
                l_financeiro_tmp.data_emissao               := rec.data;
                l_financeiro_tmp.data_vencimento            := null;
                l_financeiro_tmp.cliente_fornecedor_id      := null;
                l_financeiro_tmp.categoria_id               := rec.categoria_financeira_id;
                l_financeiro_tmp.centro_id                  := rec.centro_custo_id;
                l_financeiro_tmp.valor                      := rec.valor;
                l_financeiro_tmp.empresa_id                 := V('SES_EMPRESAS_ID');
                l_financeiro_tmp.status                     := 'Pendente';
                insert into financeiro_tmp values l_financeiro_tmp;
        END LOOP;
    end if;
    -->> Ler movimento de Contas - Recebimento
    if p_tipo = 'Recebimento' then
        for rec in (
            select  id,
                    data,
                    documento,
                    categoria_financeira_id,
                    centro_custo_id,
                    valor_entrada as valor
            from lancamentos_financeiros
            where data >= p_data_inicial
            and   data <= p_data_final
            and   conta_financeira_id = p_conta_id
            and   empresa_id = V('SES_EMPRESAS_ID')
            and   conciliado != 'Sim'
            and   valor_entrada > 0)
        LOOP
            -->> Criar novo registro em financeiro_tmp
                l_financeiro_tmp.a_pagar_id                 := null;
                l_financeiro_tmp.a_receber_id               := null;
                l_financeiro_tmp.movimento_id               := rec.id;
                l_financeiro_tmp.documento                  := rec.documento;
                l_financeiro_tmp.data_emissao               := rec.data;
                l_financeiro_tmp.data_vencimento            := null;
                l_financeiro_tmp.cliente_fornecedor_id      := null;
                l_financeiro_tmp.categoria_id               := rec.categoria_financeira_id;
                l_financeiro_tmp.centro_id                  := rec.centro_custo_id;
                l_financeiro_tmp.valor                      := rec.valor;
                l_financeiro_tmp.empresa_id                 := V('SES_EMPRESAS_ID');
                l_financeiro_tmp.status                     := 'Pendente';
                insert into financeiro_tmp values l_financeiro_tmp;
        END LOOP;
    end if;
End;


