create or replace procedure "TPL_TITULO" (
				p_empresa_id	IN number,
				p_titulo		IN varchar2,
				p_ordem			IN number,
				p_codigo		IN varchar2,
                p_tipo          IN varchar2,
                p_fonte         IN varchar2
)
is

	-->> criar uma variavel do tipo template_report_dados, para
	--   inserir os valores calculados
	l_template_dados		template_report_dados%rowtype;

Begin
    dbms_output.put_line('-->> Título');


	-->> Fazer com que o título apareça em todos os meses
	for mes IN 1..12
	LOOP
		l_template_dados.id 	    := null;
		l_template_dados.codigo     := p_codigo;
		l_template_dados.ordem 	    := p_ordem;
		l_template_dados.nome 	    := p_titulo;
		l_template_dados.mes 	    := to_char(mes);
		l_template_dados.valor 	    := null;
		l_template_dados.empresa_id := p_empresa_id;
		l_template_dados.tipo       := p_tipo;
		l_template_dados.fonte      := p_fonte;

		insert into template_report_dados values l_template_dados;

	END LOOP;

End;


