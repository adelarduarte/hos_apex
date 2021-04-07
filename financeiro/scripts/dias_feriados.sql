create or replace function "DIAS_FERIADOS" (
    p_data_inicial    IN    Date,
    p_data_final      IN    Date,
    p_empresa_id      IN    number
) return number
IS
    l_dia_inicial     number;
    l_dia_final       number;
    l_mes_inicial     number;
    l_mes_final       number;

    l_dias_feriado     number;
Begin
    l_dia_inicial := EXTRACT(day from p_data_inicial);
    l_dia_final   := EXTRACT(day from p_data_final);
    l_mes_inicial := EXTRACT(month from p_data_inicial);
    l_mes_final   := EXTRACT(month from p_data_final);

    Begin
      SELECT Count(*) 
      INTO l_dias_feriado
      FROM feriados
      where dia between l_dia_inicial and l_dia_final
      and mes between l_mes_inicial and l_mes_final
      and empresa_id = p_empresa_id;
    exception
      when no_data_found then
          l_dias_feriado := 0;
      when others then
          l_dias_feriado := 0;
    end;

    return l_dias_feriado;
End;
