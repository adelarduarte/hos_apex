create or replace procedure "ATUALIZA_SALDO_RECEBER" (
	p_contas_receber_id	IN number,
	p_valor_recebido	IN number,
	p_valor_juros 		IN number,
	p_valor_multa 		IN number,
	p_valor_outros 		IN number,
	p_valor_desconto 	IN number
)
AS
    l_saldo               Number;
    l_valor_recebido      Number;
    l_status_titulo_id    Number;

Begin
    Select saldo
    into l_saldo
    from contas_receber
    where id = p_contas_receber_id;

    l_valor_recebido := p_valor_recebido - (p_valor_juros + p_valor_multa + p_valor_outros) + p_valor_desconto; 

    If (l_saldo - l_valor_recebido) <= 0 Then
        Select id 
        into l_status_titulo_id
        from status_financeiros
        where nome = 'Liquidado';

        Update contas_receber
        set Saldo = 0, status_id = l_status_titulo_id
        where id = p_contas_receber_id;
    else
        Select id 
        into l_status_titulo_id
        from status_financeiros
        where nome = 'Liquidando';

        Update contas_receber
        set Saldo = (l_saldo - l_valor_recebido), status_id = l_status_titulo_id
        where id = p_contas_receber_id;
    End if;    
End;
