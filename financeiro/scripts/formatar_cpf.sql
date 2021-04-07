create or replace FUNCTION "FORMATAR_CPF" (
	p_cpf	IN	varchar2
) return varchar2
is
	l_cpf		varchar2(20);
Begin
	if p_cpf is not null
	   and length(p_cpf) >= 11 then
	   	l_cpf := regexp_replace(p_cpf, '[^0-9]');
	else
		l_cpf := 'Inválido ou Vazio';
		return l_cpf;
	end if;
	if length(l_cpf) != 11 then
		l_cpf := 'Tamanho inválido';
		return l_cpf;
	end if;
	l_cpf := substr(l_cpf, 1, 3)  || '.' ||
			 substr(l_cpf, 4, 3)  || '.' ||
			 substr(l_cpf, 7, 3)  || '-' ||
			 substr(l_cpf, 10, 2);
	return l_cpf;
End;
