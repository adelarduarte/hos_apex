
coalesce(:P160_DINHEIRO_VALOR_NOVO, 0) +
coalesce(:P160_CHEQUE_VALOR_NOVO, 0) +
coalesce(:P160_CARTAO_VALOR_NOVO, 0) +
coalesce(:P160_CREDIARIO_VALOR_NOVO, 0) +
coalesce(:P160_CONVENIO_VALOR_NOVO, 0)



Declare
	l_total_alterado	number;
	l_diferenca_valor	number;
	l_parcelas			number;

Begin

	l_parcelas := coalesce(:P160_CARTAO_PARCELAS, 0) 
				+ coalesce(:P160_CONVENIO_PARCELAS, 0)
				+ coalesce(:P160_CREDIARIO_PARCELAS, 0);

	case
	    when :P160_LISTA_ORIGEM = 'Dinheiro' then
	    	l_total_alterado := coalesce(:P160_CHEQUE_VALOR_NOVO, 0) +
	                coalesce(:P160_CARTAO_VALOR_NOVO, 0) +
	                coalesce(:P160_CREDIARIO_VALOR_NOVO, 0) +
	                coalesce(:P160_CONVENIO_VALOR_NOVO, 0);

	        l_diferenca_valor := to_number(:P160_DINHEIRO_VALOR) - l_total_alterado;
	        :P160_DINHEIRO_VALOR := to_number(:P160_DINHEIRO_VALOR) - l_total_alterado;
            :P160_CARTAO_VALOR := to_number(:P160_CARTAO_VALOR) + coalesce(:P160_CARTAO_VALOR_NOVO, 0);
            :P160_CHEQUE_VALOR := to_number(:P160_CHEQUE_VALOR) + coalesce(:P160_CHEQUE_VALOR_NOVO, 0);
	        
	    when :P160_LISTA_ORIGEM = 'Cartões' then
	    	l_total_alterado := coalesce(:P160_CHEQUE_VALOR_NOVO, 0) +
	                coalesce(:P160_DINHEIRO_VALOR_NOVO, 0) +
	                coalesce(:P160_CREDIARIO_VALOR_NOVO, 0) +
	                coalesce(:P160_CONVENIO_VALOR_NOVO, 0);

	        l_diferenca_valor := to_number(:P160_CARTAO_VALOR) - l_total_alterado;
	        :P160_CARTAO_VALOR := to_number(:P160_CARTAO_VALOR) - l_total_alterado;
            :P160_DINHEIRO_VALOR := to_number(:P160_DINHEIRO_VALOR) + coalesce(:P160_DINHEIRO_VALOR_NOVO, 0);
            :P160_CHEQUE_VALOR := to_number(:P160_CHEQUE_VALOR) + coalesce(:P160_CHEQUE_VALOR_NOVO, 0);

	    when :P160_LISTA_ORIGEM = 'Cheques' then
	    	l_total_alterado := coalesce(:P160_CARTAO_VALOR_NOVO, 0) +
	                coalesce(:P160_DINHEIRO_VALOR_NOVO, 0) +
	                coalesce(:P160_CREDIARIO_VALOR_NOVO, 0) +
	                coalesce(:P160_CONVENIO_VALOR_NOVO, 0);

	        l_diferenca_valor := to_number(:P160_CHEQUE_VALOR) - l_total_alterado;
	        :P160_CHEQUE_VALOR := to_number(:P160_CHEQUE_VALOR) - l_total_alterado;
            :P160_DINHEIRO_VALOR := to_number(:P160_DINHEIRO_VALOR) + coalesce(:P160_DINHEIRO_VALOR_NOVO, 0);
            :P160_CARTAO_VALOR := to_number(:P160_CARTAO_VALOR) + coalesce(:P160_CARTAO_VALOR_NOVO, 0);

	    when :P160_LISTA_ORIGEM = 'Cheques_Pré' then
	    	l_total_alterado := coalesce(:P160_CARTAO_VALOR_NOVO, 0) +
	                coalesce(:P160_DINHEIRO_VALOR_NOVO, 0) +
	                coalesce(:P160_CREDIARIO_VALOR_NOVO, 0) +
	                coalesce(:P160_CONVENIO_VALOR_NOVO, 0);

	        l_diferenca_valor := to_number(:P160_CHEQUE_PRE_VALOR) - l_total_alterado;
	        :P160_CHEQUE_PRE_VALOR := to_number(:P160_CHEQUE_PRE_VALOR) - l_total_alterado;
            :P160_DINHEIRO_VALOR := to_number(:P160_DINHEIRO_VALOR) + coalesce(:P160_DINHEIRO_VALOR_NOVO, 0);
            :P160_CARTAO_VALOR := to_number(:P160_CARTAO_VALOR) + coalesce(:P160_CARTAO_VALOR_NOVO, 0);

	    when :P160_LISTA_ORIGEM = 'Convênios' then
	    	l_total_alterado := coalesce(:P160_CARTAO_VALOR_NOVO, 0) +
	                coalesce(:P160_DINHEIRO_VALOR_NOVO, 0) +
	                coalesce(:P160_CREDIARIO_VALOR_NOVO, 0) +
	                coalesce(:P160_CHEQUE_VALOR_NOVO, 0);

	        l_diferenca_valor := to_number(:P160_CONVENIO_VALOR) - l_total_alterado;
	        :P160_CONVENIO_VALOR := to_number(:P160_CONVENIO_VALOR) - l_total_alterado;
            :P160_DINHEIRO_VALOR := to_number(:P160_DINHEIRO_VALOR) + coalesce(:P160_DINHEIRO_VALOR_NOVO, 0);
            :P160_CARTAO_VALOR := to_number(:P160_CARTAO_VALOR) + coalesce(:P160_CARTAO_VALOR_NOVO, 0);


	    when :P160_LISTA_ORIGEM = 'A_Prazo' then
	    	l_total_alterado := coalesce(:P160_CARTAO_VALOR_NOVO, 0) +
	                coalesce(:P160_DINHEIRO_VALOR_NOVO, 0) +
	                coalesce(:P160_CREDIARIO_VALOR_NOVO, 0) +
	                coalesce(:P160_CONVENIO_VALOR_NOVO, 0);

	        l_diferenca_valor := to_number(:P160_A_PRAZO_VALOR) - l_total_alterado;
	        :P160_A_PRAZO_VALOR := to_number(:P160_A_PRAZO_VALOR) - l_total_alterado;
            :P160_DINHEIRO_VALOR := to_number(:P160_DINHEIRO_VALOR) + coalesce(:P160_DINHEIRO_VALOR_NOVO, 0);
            :P160_CARTAO_VALOR := to_number(:P160_CARTAO_VALOR) + coalesce(:P160_CARTAO_VALOR_NOVO, 0);

	    when :P160_LISTA_ORIGEM = 'Pagamento_Crédito' then
	    	null;
	    when :P160_LISTA_ORIGEM = 'Outros' then
	        null;
	    when :P160_LISTA_ORIGEM = 'Boletos' then
	        null;
	    when :P160_LISTA_ORIGEM = 'PBM' then
	        null;
	        
	end case;


	ALTERAR_CUPOM (
			p_operacao_nova			=> :P160_SELECIONAR_FORMA,
	        p_cartao_nome       	=> :P160_CARTAO_NOME,
	        p_cartao_operacao   	=> :P160_CARTAO_OPERACAO,
	        p_cartao_bandeira   	=> :P160_CARTAO_BANDEIRA,
	        p_cartao_adquirente 	=> :P160_CARTAO_ADQUIRENTE,
	        p_cartao_nsu        	=> :P160_CARTAO_NSU,
	        p_cartao_valor      	=> to_number(:P160_CARTAO_VALOR_NOVO),
	        p_empresa_id        	=> :P160_EMPRESA_ID,
	        p_cliente_id        	=> :P160_CLIENTE_ID,
	        p_parcelas          	=> l_parcelas,
	        p_documento         	=> :P160_NUMERO_DOCUMENTO,
	        p_cupom_id          	=> :P160_ID,
	        p_eh_cartao				=> :P160_EH_CARTAO,
	        p_eh_cheque 			=> :P160_EH_CHEQUE,
			p_cheque_codigo_banco	=> :P160_CHEQUE_CODIGO_BANCO,
			p_cheque_agencia		=> :P160_CHEQUE_AGENCIA,
			p_cheque_numero_conta	=> :P160_CHEQUE_NUMERO_CONTA,
			p_cheque_numero_cheque	=> :P160_CHEQUE_NUMERO,
			p_cheque_numero_serie	=> :P160_CHEQUE_SERIE,
			p_cheque_titular		=> :P160_CHEQUE_TITULAR,
			p_cheque_data_cheque	=> :P160_CHEQUE_DATA,
			p_cheque_bom_para		=> :P160_CHEQUE_BOM_PARA,
			p_valor_cheque			=> to_number(:P160_CHEQUE_VALOR_NOVO),        
	        p_convenio_id         	=> :P160_CONVENIO_ID,
	        p_convenio_vencimento 	=> :P160_CONVENIO_VENCIMENTO,
	        p_convenio_valor      	=> to_number(:P160_CONVENIO_VALOR_NOVO),
	        p_diferenca_valor 		=> l_diferenca_valor,
	        p_crediario_vencimento  => :P160_CREDIARIO_VENCIMENTO,
	        p_crediario_valor 		=> to_number(:P160_CREDIARIO_VALOR_NOVO)
		);	

End;

        


