Create or replace /**
* -- Verificar saldo de contas a pagar ou receber
* -- Parâmetro:
* --
*/
function verificar_saldo(
	p_saldo 			IN number,
	p_valor_pago 		IN number,
	p_valor_juros 		IN number,
	p_valor_multa 		IN number,
	p_valor_outros 		IN number,
	p_valor_desconto 	IN number
	)
return boolean
is
	l_saldo		 number;
	l_valor_pago number;
begin
    l_saldo      := p_saldo;
    l_valor_pago := p_valor_pago - (p_valor_juros + p_valor_multa + p_valor_outros) + p_valor_desconto;
    
    if l_valor_pago > l_saldo then
    	return false;
    else
    	return true;
    end if;

end;

