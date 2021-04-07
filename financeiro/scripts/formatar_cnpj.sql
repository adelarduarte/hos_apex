create or replace FUNCTION "FORMATAR_CNPJ" (
	p_cnpj	IN	varchar2
) return varchar2
is
	l_cnpj		varchar2(20);
Begin
	if p_cnpj is not null
	   and length(p_cnpj) >= 14 then
	   	l_cnpj := regexp_replace(p_cnpj, '[^0-9]');
	else
		l_cnpj := 'Inválido ou Vazio';
		return l_cnpj;
	end if;
	if length(l_cnpj) != 14 then
		l_cnpj := 'Tamanho inválido';
		return l_cnpj;
	end if;
	l_cnpj := substr(l_cnpj, 1, 2)  || '.' ||
			  substr(l_cnpj, 3, 3)  || '.' ||
			  substr(l_cnpj, 6, 3)  || '/' ||
			  substr(l_cnpj, 9, 4)  || '-' ||
			  substr(l_cnpj, 13, 2);
	return l_cnpj;
End;
