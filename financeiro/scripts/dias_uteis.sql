create or replace function "DIAS_UTEIS" (
    p_data_inicial    IN    Date,
    p_data_final      IN    Date
) return number
IS
    l_dias           number;
Begin

    SELECT Count(*) BusDaysBtwn
      INTO l_dias
      FROM
      (
      SELECT p_data_inicial + LEVEL-1 InstallDate  
           , p_data_final CompleteDate           
           , TO_CHAR(p_data_inicial + LEVEL-1, 'DY') InstallDay  
        FROM dual 
      CONNECT BY LEVEL < p_data_final - p_data_inicial
       )
       WHERE InstallDay NOT IN ('SAT', 'SUN');

      return l_dias;
End;
