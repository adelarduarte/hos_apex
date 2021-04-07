create or replace TRIGGER "AI_CONTAS_PAGAS" 
  after insert on "CONTAS_PAGAS"               
  for each row  
begin
     ATUALIZA_SALDO_PAGAR (
         p_contas_pagar_id	=> :New.conta_pagar_id,
         p_valor_pago 		=> :New.valor_pago,
         p_valor_juros 		=> :New.valor_juro,
         p_valor_multa 		=> :New.valor_multa,
         p_valor_outros     => :New.valor_outros,
         p_valor_desconto 	=> :New.valor_desconto
     );

    CRIAR_LANCAMENTO_FINANCEIRO (
            p_conta_financeira_id       =>  :New.conta_financeira_id,
            p_data                      =>  :New.data_pagamento,
            p_documento                 =>  :New.documento,
            p_valor                     =>  :New.valor_pago,
            p_centro_custos_id          =>  :New.centro_custo_id,
            p_categoria_financeira_id   =>  :New.categoria_financeira_id,
            p_contas_pagas_id           =>  :New.id,
            p_contas_recebidas_id       =>  null,
            p_tipo                      =>  'Pagar',
            p_empresa_id                =>  :new.empresa_id,
            p_conta_pagar_id            =>  :new.conta_pagar_id,
            p_conta_receber_id          =>  null
    );

end;
