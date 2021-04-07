create or replace TRIGGER "AI_CONTAS_RECEBIDAS" 
  after insert on "CONTAS_RECEBIDAS"               
  for each row  
begin
    
  

     ATUALIZA_SALDO_RECEBER (
         p_contas_receber_id   => :New.conta_receber_id,
         p_valor_recebido      => :New.valor_recebido,
         p_valor_juros         => :New.valor_juros,
         p_valor_multa         => :New.valor_multa,
         p_valor_outros        => :New.valor_outros,
         p_valor_desconto      => :New.valor_desconto
     );

    CRIAR_LANCAMENTO_FINANCEIRO (
            p_conta_financeira_id       =>  :New.conta_financeira_id,
            p_data                      =>  :New.data_recebimento,
            p_documento                 =>  :New.documento,
            p_valor                     =>  :New.valor_recebido,
            p_centro_custos_id          =>  :New.centro_custo_id,
            p_categoria_financeira_id   =>  :New.categoria_financeira_id,
            p_contas_pagas_id           =>  null,
            p_contas_recebidas_id       =>  :New.id,
            p_tipo                      =>  'Receber',
            p_empresa_id                =>  :new.empresa_id,
            p_conta_receber_id          =>  :new.conta_receber_id,
            p_conta_pagar_id            =>  null
    );

   if :new.cobranca_agrupada = 'Sim' then
       LIQUIDAR_AGRUPADOS (
           p_contas_receber_id => :new.conta_receber_id
       );    
    end if;
end;
