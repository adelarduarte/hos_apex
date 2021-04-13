create or replace function "TOTAIS_CAIXA_BANCARIO"(
        p_caixa_id         IN  number,
        p_campo_outros     IN  varchar2,
        p_campo_dinheiro   IN  varchar2,
        p_campo_boleto     IN  varchar2
    ) return number
is
    l_valor_outros       number(14,2);
    l_valor_dinheiro     number(14,2);
    l_valor_boleto       number(14,2);
    l_query     varchar2(1000);
begin
    -->> Soma Outros
    l_query := 'select sum(nvl(' || p_campo_outros || ', 0))'
            || ' from ( select     
                        case when lower(tipo_lancamento_financeiro) in (''dv'', ''cc'', ''dc'', ''dp'', ''ex'', ''tva'', ''cpix'') then
                            to_number(' || '-' || p_campo_outros || ')'
                      ||  ' else '
                      ||  p_campo_outros
                      ||  ' end ' || p_campo_outros 
                      ||  ' from caixas_cupons
                            where caixa_id = ' || p_caixa_id || 
                          ' and lower(tipo_lancamento_financeiro) in (''pb'', ''eb'', ''pix'', ''cpix'') ' ||
                            ')';

    execute immediate l_query into l_valor_outros;                        


    -->> Soma dinheiro
    l_query := 'select sum(nvl(' || p_campo_dinheiro || ', 0))'
            || ' from ( select     
                        case when lower(tipo_lancamento_financeiro) in (''dv'', ''cc'', ''dc'', ''dp'', ''ex'', ''tva'', ''cpix'') then
                            to_number(' || '-' || p_campo_dinheiro || ')'
                      ||  ' else '
                      ||  p_campo_dinheiro
                      ||  ' end ' || p_campo_dinheiro 
                      ||  ' from caixas_cupons
                            where caixa_id = ' || p_caixa_id || 
                          ' and lower(tipo_lancamento_financeiro) in (''pb'', ''eb'', ''pix'', ''cpix'') ' ||
                            ')';

    execute immediate l_query into l_valor_dinheiro;                        


    -->> Soma boleto
    l_query := 'select sum(nvl(' || p_campo_boleto || ', 0))'
            || ' from ( select     
                        case when lower(tipo_lancamento_financeiro) in (''dv'', ''cc'', ''dc'', ''dp'', ''ex'', ''tva'', ''cpix'') then
                            to_number(' || '-' || p_campo_boleto || ')'
                      ||  ' else '
                      ||  p_campo_boleto
                      ||  ' end ' || p_campo_boleto
                      ||  ' from caixas_cupons
                            where caixa_id = ' || p_caixa_id || 
                          ' and lower(tipo_lancamento_financeiro) in (''pb'', ''eb'', ''pix'', ''cpix'') ' ||
                            ')';

    execute immediate l_query into l_valor_boleto;                        


    return l_valor_outros + l_valor_dinheiro + l_valor_boleto;
end;
