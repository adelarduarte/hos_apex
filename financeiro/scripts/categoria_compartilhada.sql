create or replace procedure "CATEGORIA_COMPARTILHADA" (
	p_empresa_id 			IN 	number,
	p_categoria_id 			IN  number,
 	p_grupo_categoria_id	IN  number,
 	p_descricao				IN  varchar2,
 	p_tipo_operacao			IN  varchar2,
 	p_natureza				IN  varchar2,
 	p_ativo					IN  varchar2,
 	p_id_interno			IN  number
)
as

	l_categoria_record		categorias_financeiras%rowtype;
	l_qtd_empresas			number;

	l_tipo_compartilhamento	varchar2(50);
	l_grupo_negocio_id		number;
	l_grupo_economico_id	number;
Begin
	-->> Grupo / Rede / Nenhum
	select grupo_negocio_id, 
		grupo_economico_id
	into l_grupo_negocio_id,
		l_grupo_economico_id
	from empresas
	where id = p_empresa_id;

	-->> Tipo de compartilhamento
	select tipo_compartilhamento
	into l_tipo_compartilhamento
	from grupos_negocios
	where id = l_grupo_negocio_id;


	if l_tipo_compartilhamento <> 'Nenhum' then

		-->> Registro da categoria
		l_categoria_record.grupo_categoria_financeira_id := p_grupo_categoria_id;
		l_categoria_record.descricao         			 := p_descricao;
		l_categoria_record.tipo_operacao     			 := p_tipo_operacao;
		l_categoria_record.natureza          			 := p_natureza;
		l_categoria_record.ativo             			 := p_ativo;
		l_categoria_record.id_interno        			 := p_id_interno;
        l_categoria_record.compartilhada                 := 'Sim';


		-->> Criação de categorias para compartilhamento com grupo de negócios
		if l_tipo_compartilhamento = 'Grupo' then
			for rec_empresa in (
					select id
					from empresas
					where grupo_negocio_id = l_grupo_negocio_id
					and id <> p_empresa_id
				)
			loop
				l_categoria_record.empresa_id := rec_empresa.id;

				insert into categorias_modificadas values l_categoria_record;			
			end loop;
		end if;


		-->> Criação de categorias para compartilhamento com grupo econômico
		if l_tipo_compartilhamento = 'Rede' then
			for rec_empresa in (
					select id
					from empresas
					where grupo_economico_id = l_grupo_economico_id
					and id <> p_empresa_id
				)
			loop
				l_categoria_record.empresa_id := rec_empresa.id;

				insert into categorias_modificadas values l_categoria_record;			
			end loop;
		end if;

	end if;

End;

