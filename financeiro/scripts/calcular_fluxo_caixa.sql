create or replace procedure "CALCULAR_FLUXO_CAIXA"
(p_data_inicial  IN Date,
 p_dias          IN number,
 p_empresa_id    IN number)
IS
    l_saldo_inicial_contas  number(14,2) := 0;
    l_total_saldo_contas    number(14,2) := 0;


    l_total_entradas        number(14,2) := 0;
    l_total_saidas          number(14,2) := 0;
    l_total_saldo           number(14,2) := 0;

    l_saldo                 number(14,2) := 0;

    l_contas_receber_total  number(14,2) := 0;
    l_cheques_receber_total number(14,2) := 0;
    l_contas_pagar_total    number(14,2) := 0;
    l_cheques_pagar_total   number(14,2) := 0;
    l_cartoes_receber_total number(14,2) := 0;
    l_cartoes_pagar_total   number(14,2) := 0;

    l_data                  date;
    l_data_final            date;

    c_data                  varchar2(20);

    l_record_fluxo          fluxo_caixa%rowtype;

Begin
    -- >> Excluir fluxo de caixa anterior
    Delete from fluxo_caixa where id > 0 and empresa_id = p_empresa_id;


    -- >> Encontrar saldo inicial das contas
    Select 
        sum(saldo_inicial_sistema)
    into 
        l_saldo_inicial_contas
    from 
        contas_financeiras, 
        tipos_contas_financeiras
    where 
        contas_financeiras.tipo_conta_id = tipos_contas_financeiras.id
    and contas_financeiras.empresa_id = p_empresa_id
    and tipos_contas_financeiras.mostrar_dashboard = 'Sim'
    and (tipos_contas_financeiras.mostrar_fluxo_caixa = 'Sim' 
    or tipos_contas_financeiras.mostrar_fluxo_caixa is null);

    dbms_output.put_line('Saldo Inicial:' || to_char(l_saldo_inicial_contas));

    -- >> Somar saldo anterior de todas as contas
    Select 
        sum(valor_entrada) - sum(valor_saida) as saldo
    into 
        l_total_saldo_contas
    from 
        lancamentos_financeiros, 
        contas_financeiras, 
        tipos_contas_financeiras
    where 
        lancamentos_financeiros.data <= p_data_inicial
    and lancamentos_financeiros.conta_financeira_id = contas_financeiras.id
    and lancamentos_financeiros.empresa_id = p_empresa_id
    and contas_financeiras.tipo_conta_id = tipos_contas_financeiras.id
    and tipos_contas_financeiras.mostrar_dashboard = 'Sim'
    and (tipos_contas_financeiras.mostrar_fluxo_caixa = 'Sim' 
    or tipos_contas_financeiras.mostrar_fluxo_caixa is null);

    dbms_output.put_line('Saldo anterior:' || to_char(l_total_saldo_contas));



    -- >> Calcular saldo inicial
    l_saldo := l_saldo_inicial_contas + l_total_saldo_contas;
    dbms_output.put_line('Saldo Inicial:' || to_char(l_saldo));


    -- >> Data final em X dias
    If p_dias is not null then
        l_data_final := p_data_inicial + p_dias;
    else
        l_data_final := p_data_inicial + 7;
    end if;

    -- >> Data do dia igual a data inicial;
    l_data := p_data_inicial;
    c_data := to_char(l_data);

    -- >> Loop para cálculos no periodo desejado
    WHILE l_data <= l_data_final
    LOOP
        -- >> Somar contas a receber pendentes
        select 
            sum(nvl(saldo, 0))
        into 
            l_contas_receber_total
        from 
            contas_receber
        where 
            data_agendamento = to_date(c_data, 'DD/MM/YY')
        and empresa_id = p_empresa_id;


        -- >> Somar contas a pagar pendentes
        select 
            sum(nvl(saldo, 0))
        into 
            l_contas_pagar_total
        from 
            contas_pagar
        where 
            data_agendamento = to_date(c_data, 'DD/MM/YY')
        and empresa_id = p_empresa_id;


        -- >> Somar cheques a receber pendentes
  -->> *** Desativado temporariamente      
        -- select 
     --        sum(nvl(valor, 0))
        -- into 
     --        l_cheques_receber_total
        -- from 
     --        cheques
        -- where 
     --        data = to_date(c_data, 'DD/MM/YY')
        -- and contas_receber_id > 0
     --    and empresa_id = V('SES_EMPRESAS_ID')
        -- and status = 'Pendente';

        -- -- >> Somar cheques a pagar pendentes
        -- select 
     --        sum(nvl(valor, 0))
        -- into 
     --        l_cheques_pagar_total
        -- from 
     --        cheques
        -- where 
     --        data = to_date(c_data, 'DD/MM/YY')
        -- and contas_pagar_id > 0
     --    and empresa_id = V('SES_EMPRESAS_ID')
        -- and status = 'Pendente';

     --    -->> Somar cartões a receber
     --    select 
     --        sum(nvl(valor_liquido, 0))
     --    into 
     --        l_cartoes_receber_total
     --    from 
     --        cartoes
        -- where 
     --        vencimento = to_date(c_data, 'DD/MM/YY')
        -- and contas_receber_id > 0
     --    and empresa_id = V('SES_EMPRESAS_ID');

     --    -->> Somar cartões a pagar
     --    select 
     --        sum(nvl(valor_liquido, 0))
     --    into 
     --        l_cartoes_pagar_total
     --    from 
     --        cartoes
        -- where 
     --        vencimento = to_date(c_data, 'DD/MM/YY')
        -- and contas_pagar_id > 0
     --    and empresa_id = V('SES_EMPRESAS_ID');

        -- >> Calcular totais
        l_total_entradas := nvl(l_contas_receber_total, 0) + nvl(l_cheques_receber_total, 0) + nvl(l_cartoes_receber_total, 0);
        l_total_saidas   := nvl(l_contas_pagar_total, 0) + nvl(l_cheques_pagar_total, 0) + nvl(l_cartoes_pagar_total, 0);



        -- >> Calcular saldo
        l_saldo := nvl(l_saldo, 0) + nvl(l_total_entradas, 0) - nvl(l_total_saidas, 0);


        -- >> Criar registro de fluxo de caixa
        l_record_fluxo.data             := l_data;
        l_record_fluxo.total_entradas   := nvl(l_total_entradas, 0);
        l_record_fluxo.total_saidas     := nvl(l_total_saidas, 0);
        l_record_fluxo.saldo            := nvl(l_saldo, 0);
        l_record_fluxo.empresa_id       := p_empresa_id;

        INSERT INTO fluxo_caixa values l_record_fluxo;

        l_data := l_data + 1;
        c_data := to_char(l_data);

    END LOOP;

End;
