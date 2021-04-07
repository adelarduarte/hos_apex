create or replace function "TPL_BUSCAR_VALOR" (
	p_codigo	IN	varchar2,
	p_mes		IN  varchar2,
	p_empresa_id IN  number
) return varchar2
is
	l_valor 			number(14,2);
	l_valor_retorno		varchar2(100);
    l_negativo          varchar2(10);

Begin
	-->> Buscar o valor referente ao código e mês
    begin
        select valor, negativo
        into l_valor, l_negativo
        from template_report_dados
        where codigo = p_codigo
        and   mes = p_mes
        and   empresa_id = p_empresa_id;
    exception
        when no_data_found then
            l_valor := 0;
        when others then
            l_valor := 0;
    end;

    -->> Mudei aqui, para testar valor marcado como negativo, mas gravado como positivo
    if l_negativo = 'Sim' then
        l_valor := l_valor * -1;
    end if;
    
	l_valor_retorno := to_char(l_valor);

	return l_valor_retorno;

End;

