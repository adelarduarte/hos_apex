create or replace procedure reset_seq (
    p_seq_name  IN VARCHAR2, 
    p_new_value IN NUMBER DEFAULT NULL 
) IS
  l_val number;
begin

  -->> Reseta uma sequência baseado no novo valor passado
  
  execute immediate
  'select ' || p_seq_name || '.nextval from dual' INTO l_val;

  l_val := -l_val + COALESCE(p_new_value, 0);

  --debug( 'alter sequence ' || p_seq_name || ' increment by ' || l_val ||' minvalue 0');
  execute immediate
  'alter sequence ' || p_seq_name || ' increment by ' || l_val || ' minvalue 0';

  execute immediate
  'select ' || p_seq_name || '.nextval from dual' INTO l_val;

  execute immediate
  'alter sequence ' || p_seq_name || ' increment by 1 minvalue 0';
end;
