create or replace procedure "EXCLUIR_ORCAMENTO" (
	p_mes			IN	number,
	p_ano			IN	number,
	p_empresa_id	IN	number
)
IS
	l_orcamento_record	orcamento_categorias%rowtype;

Begin
	-->> Exclusão do orcamento de origem
	delete from
		orcamento_categorias
	where
		ano = p_ano
	and
		mes = p_mes
	and
		empresa_id = p_empresa_id;

End;
