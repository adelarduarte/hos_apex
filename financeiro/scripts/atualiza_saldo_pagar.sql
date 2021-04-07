Create or replace procedure "ATUALIZA_SALDO_PAGAR" (
	p_contas_pagar_id	IN number,
	p_valor_pago 		IN number,
	p_valor_juros 		IN number,
	p_valor_multa 		IN number,
	p_valor_outros 		IN number,
	p_valor_desconto 	IN number
)
AS
    l_saldo               Number;
    l_valor_Pago          Number;
    l_status_titulo_id    Number;

Begin
    Select saldo
    into l_saldo
    from contas_pagar
    where id = p_contas_pagar_id;

    l_valor_pago := p_valor_pago - (p_valor_juros + p_valor_multa + p_valor_outros) + p_valor_desconto; 

    If (l_saldo - l_valor_pago) <= 0 Then
        Select id 
        into l_status_titulo_id
        from status_financeiros
        where nome = 'Liquidado';

        Update contas_pagar
        set Saldo = 0, status_id = l_status_titulo_id
        where id = p_contas_pagar_id;
    else
        Select id 
        into l_status_titulo_id
        from status_financeiros
        where nome = 'Liquidando';

        Update contas_pagar
        set Saldo = (l_saldo - l_valor_pago), status_id = l_status_titulo_id
        where id = p_contas_pagar_id;
    End if;    
End;
