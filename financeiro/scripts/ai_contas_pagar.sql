create or replace TRIGGER "AI_CONTAS_PAGAR" 
  after insert on "CONTAS_PAGAR"               
  for each row  
begin

    CRIAR_LANCAMENTO_FINANCEIRO (
            p_conta_financeira_id       =>  null, 
            p_data                      =>  :New.data_vencimento,
            p_documento                 =>  :New.documento,
            p_valor                     =>  :New.saldo,
            p_centro_custos_id          =>  :New.centro_custo_id,
            p_categoria_financeira_id   =>  :New.categoria_financeira_id,
            p_contas_pagas_id           =>  null,
            p_contas_recebidas_id       =>  null,
            p_tipo                      =>  'Pagar_Provisao',
            p_empresa_id                =>  :new.empresa_id,
            p_conta_pagar_id            =>  :new.id,
            p_conta_receber_id          =>  null
    );

end;
