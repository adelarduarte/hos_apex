 Declare

    l_dinheiro_total    number;
    l_cheque_total      number;
    l_cartao_total      number;
    l_a_prazo_total     number;
    l_convenio_total    number;
    l_outros_total      number;
    l_boleto_total      number;
    l_cheque_pre_total  number;
 Begin
    -->> Dinheiro
    l_dinheiro_total := totais_caixa(
                            p_caixa_id => to_number(:P157_CAIXA_ID),
                            p_campo => 'dinheiro_valor'
                        );

    :P157_DINHEIRO_TOTAL := to_char(l_dinheiro_total, '999G999G999G999G990D00');

    select to_char(nvl(dinheiro_informado, 0), '999G999G999G999G990D00') 
    into :P157_DINHEIRO_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_DINHEIRO_DIFERENCA := to_char(l_dinheiro_total - to_number(:P157_DINHEIRO_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(dinheiro_conferencia, 0), '999G999G999G999G990D00')
    into :P157_DINHEIRO_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Cheques
    l_cheque_total := totais_caixa(
                            p_caixa_id => to_number(:P157_CAIXA_ID),
                            p_campo => 'cheque_valor'
                        );

    :P157_CHEQUE_TOTAL := to_char(l_cheque_total, '999G999G999G999G990D00');

    select to_char(nvl(cheque_informado, 0), '999G999G999G999G990D00')
    into :P157_CHEQUE_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_CHEQUE_DIFERENCA := to_char(l_cheque_total - to_number(:P157_CHEQUE_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(cheque_conferencia, 0), '999G999G999G999G990D00') 
    into :P157_CHEQUE_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Cartões
    l_cartao_total := totais_caixa(
                            p_caixa_id => to_number(:P157_CAIXA_ID),
                            p_campo => 'cartao_total'
                        );

    :P157_CARTAO_TOTAL := to_char(l_cartao_total, '999G999G999G999G990D00');

    select to_char(nvl(cartao_informado, 0), '999G999G999G999G990D00') 
    into :P157_CARTAO_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_CARTAO_DIFERENCA := to_char(l_cartao_total - to_number(:P157_CARTAO_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(cartao_conferencia, 0), '999G999G999G999G990D00') 
    into :P157_CARTAO_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);

 
    -->> A Prazo
    l_a_prazo_total := totais_caixa(
                            p_caixa_id => to_number(:P157_CAIXA_ID),
                            p_campo => 'a_prazo_total'
                        );

    :P157_A_PRAZO_VALOR := to_char(l_a_prazo_total, '999G999G999G999G990D00');

    select to_char(nvl(a_prazo_informado, 0), '999G999G999G999G990D00') 
    into :P157_A_PRAZO_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_A_PRAZO_DIFERENCA := to_char(l_a_prazo_total - to_number(:P157_A_PRAZO_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(a_prazo_conferencia, 0), '999G999G999G999G990D00') 
    into :P157_A_PRAZO_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Convênios
    l_convenio_total := totais_caixa(
                            p_caixa_id => to_number(:P157_CAIXA_ID),
                            p_campo => 'convenio_total'
                        );

    :P157_CONVENIO_TOTAL := to_char(l_convenio_total, '999G999G999G999G990D00');

    select to_char(nvl(convenio_informado, 0), '999G999G999G999G990D00') 
    into :P157_CONVENIO_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_CONVENIO_DIFERENCA := to_char(l_convenio_total - to_number(:P157_CONVENIO_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(convenio_conferencia, 0), '999G999G999G999G990D00') 
    into :P157_CONVENIO_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Outros
    l_outros_total := totais_caixa(
                        p_caixa_id => to_number(:P157_CAIXA_ID),
                        p_campo => 'outros_total'
                    );

    :P157_OUTROS_TOTAL := to_char(l_outros_total, '999G999G999G999G990D00');

    select to_char(nvl(outros_informado, 0), '999G999G999G999G990D00') 
    into :P157_OUTROS_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_OUTROS_DIFERENCA := to_char(l_outros_total - to_number(:P157_OUTROS_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(outros_conferencia, 0), '999G999G999G999G990D00') 
    into :P157_OUTROS_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Bancário / Boletos
    l_boleto_total := totais_caixa(
                        p_caixa_id => to_number(:P157_CAIXA_ID),
                        p_campo => 'boleto_total'
                    );

    :P157_BANCARIO_TOTAL := to_char(l_boleto_total, '999G999G999G999G990D00');
    
    select to_char(nvl(boleto_informado, 0), '999G999G999G999G990D00') 
    into :P157_BANCARIO_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_BANCARIO_DIFERENCA := to_char(l_boleto_total - to_number(:P157_BANCARIO_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(boletos_conferencia, 0), '999G999G999G999G990D00') 
    into :P157_BANCARIO_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Pagto Crédito
    select to_char(nvl(pagamento_credito_total, 0), '999G999G999G999G990D00') 
    into :P157_PAGAMENTO_CREDITO_TOTAL
    from caixas where id = to_number(:P157_CAIXA_ID);
    
    select to_char(nvl(pagamento_credito_informado, 0), '999G999G999G999G990D00') 
    into :P157_PAGAMENTO_CREDITO_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Cheque Pré
    l_cheque_pre_total := totais_caixa(
                        p_caixa_id => to_number(:P157_CAIXA_ID),
                        p_campo => 'cheque_pre_total'
                    );

    :P157_CHEQUE_PRE_TOTAL := to_char(l_cheque_pre_total, '999G999G999G999G990D00');

    select to_char(nvl(cheque_pre_informado, 0), '999G999G999G999G990D00') 
    into :P157_CHEQUE_PRE_INFORMADO
    from caixas where id = to_number(:P157_CAIXA_ID);

    :P157_CHEQUE_PRE_DIFERENCA := to_char(l_cheque_pre_total - to_number(:P157_CHEQUE_PRE_INFORMADO), '999G999G999G999G990D00');

    select to_char(nvl(cheque_pre_conferencia, 0), '999G999G999G999G990D00') 
    into :P157_CHEQUE_PRE_CONFERENCIA
    from caixas where id = to_number(:P157_CAIXA_ID);


    -->> Cabeçalho do Caixa
    Select nome_operador, 
            numero_caixa, 
            to_char(data_inicial, 'DD/MM/YYYY'), 
            to_char(data_final, 'DD/MM/YYYY'),
            to_char(hora_inicial, 'HH:MI'),
            to_char(hora_final, 'HH:MI'),
            to_char(valor_inicial, '999G999G999G999G990D00'),
            to_char(valor_final, '999G999G999G999G990D00'),
            to_char(dinheiro, '999G999G999G999G990D00'),
            to_char(troco, '999G999G999G999G990D00')
    into :P157_NOME_OPERADOR, 
            :P157_NUMERO_CAIXA, 
            :P157_DATA_INICIAL, 
            :P157_DATA_FINAL,
            :P157_HORA_INICIAL,
            :P157_HORA_FINAL,
            :P157_VALOR_INICIAL,
            :P157_VALOR_FINAL,
            :P157_DINHEIRO,
            :P157_TROCO
    from caixas 
    where id = to_number(:P157_CAIXA_ID);

End;



