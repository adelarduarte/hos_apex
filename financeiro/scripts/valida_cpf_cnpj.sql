create or replace FUNCTION "VALIDA_CPF_CNPJ" (
    V_CPF_CNPJ IN VARCHAR2
  ) RETURN BOOLEAN AS
  /*  Função para validar CPF/CNPJ
      Banco de Dados: Oracle 11g XE
  */
  type array_dv is varray(2) of pls_integer;
  v_array_dv    array_dv := array_dv(0, 0);
  cpf_digit     constant pls_integer := 11;
  cnpj_digit    constant pls_integer := 14;
  is_cpf        boolean;
  is_cnpj       boolean;
  v_cpf_number  varchar2(20);
  total         number := 0;
  coeficiente   number := 0;
  dv1           number := 0;
  dv2           number := 0;
  digito        number := 0;
  j             integer;
  i             integer;

begin
  if v_cpf_cnpj is null then
    return false;
  end if;
  /*
    retira os caracteres não numéricos do cpf/cnpj
    caso seja enviado para validação um valor com
    a máscara.
  */
  v_cpf_number := regexp_replace(v_cpf_cnpj, '[^0-9]');  
  /*
    verifica se o valor passado é um cpf através do
    número de dígitos informados. cpf = 11
  */
  is_cpf := (length(v_cpf_number) = cpf_digit);
  /*
    verifica se o valor passado é um cnpj através do
    número de dígitos informados. cnpj = 14
  */
  is_cnpj := (length(v_cpf_number) = cnpj_digit);
  
  if (is_cpf or is_cnpj) then
    total := 0;
  else
    return false;
  end if;
   /*
    armazena os valores de dígitos informados para
    posterior comparação com os dígitos verificadores calculados.
  */
  dv1 := to_number(substr(v_cpf_number, length(v_cpf_number) - 1, 1));
  dv2 := to_number(substr(v_cpf_number, length(v_cpf_number), 1));
  v_array_dv(1) := 0;
  v_array_dv(2) := 0;
  /*
    laço para cálculo dos dígitos verificadores.
    é utilizado módulo 11 conforme norma da receita federal.
  */
  for j in 1 .. 2
  loop
    total := 0;
    coeficiente := 2;

    for i in reverse 1 .. ((length(v_cpf_number) - 3) + j)
    loop
      digito      := to_number(substr(v_cpf_number, i, 1));
      total       := total + (digito * coeficiente);
      coeficiente := coeficiente + 1;
      if (coeficiente > 9) and is_cnpj then        
        coeficiente := 2;
      end if;
    end loop; --for i

    v_array_dv(j) := 11 - mod(total, 11);
    if (v_array_dv(j) >= 10) then      
      v_array_dv(j) := 0;
    end if;
  end loop; --for j in 1..2
  /*
    compara os dígitos calculados com os informados para informar resultado.
  */
  return(dv1 = v_array_dv(1)) and(dv2 = v_array_dv(2));

end valida_cpf_cnpj;
