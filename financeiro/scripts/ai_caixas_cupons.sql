create or replace trigger "AI_CAIXAS_CUPONS"   
  after insert on "CAIXAS_CUPONS"               
  for each row  
begin   
	update caixas
	set 
		dinheiro_total          = dinheiro_total + :new.dinheiro_valor,
		cheque_total            = cheque_total + :new.cheque_valor,
		cartao_total            = cartao_total + :new.cartao_valor,
		a_prazo_total           = a_prazo_total + :new.a_prazo_valor,
		convenio_total          = convenio_total + :new.convenio_valor,
		outros_total            = outros_total + :new.outros_valor,
		boleto_total            = boleto_total + :new.boleto_valor,
		pagamento_credito_total = pagamento_credito_total + :new.pagamento_credito_valor
	where id = :new.caixa_id;
end;

