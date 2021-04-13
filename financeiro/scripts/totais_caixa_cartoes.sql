create or replace function "TOTAIS_CAIXA_CARTOES"(
        p_caixa_id  IN  number,
        p_campo     IN  varchar2
    ) return number
is
    l_valor     number(14,2);
    l_query     varchar2(1000);
begin
    l_query := 'select sum(nvl(' || p_campo || ', 0))'
            || ' from ( select     
                        case 
                        when lower(tipo_lancamento_financeiro) in (''cc'') and '
                      || p_campo || ' > 0 then '  
                      ||  ' to_number(' || '-' || p_campo || ') '
                      ||  'when lower(tipo_lancamento_financeiro) in (''cr'') then '
                      ||  p_campo
                      ||  ' end ' || p_campo 
                      ||  ' from caixas_cupons
                            where caixa_id = ' || p_caixa_id
                      ||  ' and ' || p_campo || ' > 0'
                      ||  ')';                            

    execute immediate l_query into l_valor;                        

    return l_valor;
end;
