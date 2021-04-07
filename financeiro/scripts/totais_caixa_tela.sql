 Begin
 	-->> Dinheiro
 	select to_char(nvl(dinheiro_total, 0), '999G999G999G999G990D00') 
 	into :P157_DINHEIRO_TOTAL
 	from caixas where id = 5921;

 	select to_char(nvl(dinheiro_informado, 0), '999G999G999G999G990D00') 
 	into :P157_DINHEIRO_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(dinheiro_total, 0) - nvl(dinheiro_informado, 0), '999G999G999G999G990D00')
 	into :P157_DINHEIRO_DIFERENCA
 	from caixas where id = 5921;


 	-->> Cheques
 	select to_char(nvl(cheque_total, 0), '999G999G999G999G990D00') 
 	into :P157_CHEQUE_TOTAL
 	from caixas where id = 5921;

 	select to_char(nvl(cheque_informado, 0), '999G999G999G999G990D00')
 	into :P157_CHEQUE_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(cheque_total, 0) - nvl(cheque_informado, 0), '999G999G999G999G990D00')
 	into :P157_CHEQUE_DIFERENCA
 	from caixas where id = 5921;


 	-->> Cartões
 	select to_char(nvl(cartao_total, 0), '999G999G999G999G990D00') 
 	into :P157_CARTAO_TOTAL
 	from caixas where id = 5921;

 	select to_char(nvl(cartao_informado, 0), '999G999G999G999G990D00') 
 	into :P157_CARTAO_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(cartao_total, 0) - nvl(cartao_informado, 0), '999G999G999G999G990D00')
 	into :P157_CARTAO_DIFERENCA
 	from caixas where id = 5921;

 
 	-->> A Prazo
 	select to_char(nvl(a_prazo_total, 0), '999G999G999G999G990D00') 
 	into :P157_A_PRAZO_VALOR
 	from caixas where id = 5921;

 	select to_char(nvl(a_prazo_informado, 0), '999G999G999G999G990D00') 
 	into :P157_A_PRAZO_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(a_prazo_total, 0) - nvl(a_prazo_informado, 0), '999G999G999G999G990D00')
 	into :P157_A_PRAZO_DIFERENCA
 	from caixas where id = 5921;


 	-->> Convênios
 	select to_char(nvl(convenio_total, 0), '999G999G999G999G990D00') 
 	into :P157_CONVENIO_TOTAL
 	from caixas where id = 5921;

 	select to_char(nvl(convenio_informado, 0), '999G999G999G999G990D00') 
 	into :P157_CONVENIO_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(convenio_total, 0) - nvl(convenio_informado, 0), '999G999G999G999G990D00')
 	into :P157_CONVENIO_DIFERENCA
 	from caixas where id = 5921;


 	-->> Outros
 	select to_char(nvl(outros_total, 0), '999G999G999G999G990D00') 
 	into :P157_OUTROS_TOTAL
 	from caixas where id = 5921;

 	select to_char(nvl(outros_informado, 0), '999G999G999G999G990D00') 
 	into :P157_OUTROS_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(outros_total, 0) - nvl(outros_informado, 0), '999G999G999G999G990D00')
 	into :P157_OUTROS_DIFERENCA
 	from caixas where id = 5921;


 	-->> Bancário / Boletos
 	select to_char(nvl(boleto_total, 0), '999G999G999G999G990D00') 
 	into :P157_BANCARIO_TOTAL
 	from caixas where id = 5921;
 	
 	select to_char(nvl(boleto_informado, 0), '999G999G999G999G990D00') 
 	into :P157_BANCARIO_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(boleto_total, 0) - nvl(boleto_informado, 0), '999G999G999G999G990D00')
 	into :P157_BANCARIO_DIFERENCA
 	from caixas where id = 5921;


 	-->> Pagto Crédito
 	select to_char(nvl(pagamento_credito_total, 0), '999G999G999G999G990D00') 
 	into :P157_PAGAMENTO_CREDITO_TOTAL
 	from caixas where id = 5921;
 	
 	select to_char(nvl(pagamento_credito_informado, 0), '999G999G999G999G990D00') 
 	into :P157_PAGAMENTO_CREDITO_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(pagamento_credito_total, 0) - nvl(pagamento_credito_informado, 0), '999G999G999G999G990D00')
 	into :P157_PAGAMENTO_CREDITO_DIFERENCA
 	from caixas where id = 5921;


 	-->> Cheque Pré
 	select to_char(nvl(cheque_pre_total, 0), '999G999G999G999G990D00') 
 	into :P157_CHEQUE_PRE_TOTAL
 	from caixas where id = 5921;
 	
 	select to_char(nvl(cheque_pre_informado, 0), '999G999G999G999G990D00') 
 	into :P157_CHEQUE_PRE_INFORMADO
 	from caixas where id = 5921;

 	select to_char(nvl(cheque_pre_total, 0) - nvl(cheque_pre_informado, 0), '999G999G999G999G990D00')
 	into :P157_CHEQUE_PRE_DIFERENCA
 	from caixas where id = 5921;

End;





