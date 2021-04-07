create or replace function "CADASTRAR_CHEQUE_CUPOM" (
        p_cheque_codigo_banco		IN varchar2,
        p_cheque_agencia			IN varchar2,
        p_cheque_numero_conta		IN varchar2,
        p_cheque_numero_cheque		IN varchar2,
        p_cheque_numero_serie		IN varchar2,
        p_cheque_titular			IN varchar2,
        p_cheque_data_cheque		IN date,
        p_cheque_bom_para			IN date,
        p_valor_cheque				IN number,
        P_cliente_id				IN number,
        p_empresa_id				IN number
	) return number
IS

	l_cheque_id			number;
	l_cheques_record	cheques%rowtype;
Begin

	l_cheques_record.agencia        := p_cheque_agencia;
	l_cheques_record.conta_corrente := p_cheque_numero_conta;
	l_cheques_record.numero_cheque  := p_cheque_numero_cheque;
	l_cheques_record.observacoes    := 'Série: ' || p_cheque_numero_serie;
	l_cheques_record.emitente       := p_cheque_titular;
	l_cheques_record.data_cheque    := p_cheque_data_cheque;
	l_cheques_record.bom_para       := p_cheque_bom_para;
	l_cheques_record.valor_cheque   := p_valor_cheque;
	l_cheques_record.cliente_id     := P_cliente_id;
	l_cheques_record.empresa_id     := p_empresa_id;


	insert into cheques values l_cheques_record returning id into l_cheque_id;

	return l_cheque_id;

End;
