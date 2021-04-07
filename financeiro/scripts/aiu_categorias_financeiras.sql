create or replace TRIGGER "AIU_CATEGORIAS_FINANCEIRAS" 
  after insert or update on "CATEGORIAS_FINANCEIRAS"               
  for each row  

declare
	l_tipo_compartilhamento		varchar2(50);
	l_grupo_negocio_id 			number;
begin   

	if inserting then

		if :new.compartilhada <> 'Sim' or :new.compartilhada is null then
			-->> Verificar se a empresa compartilha dados;
			select grupo_negocio_id
			into l_grupo_negocio_id
			from empresas
			where id = :new.empresa_id;

			select tipo_compartilhamento
			into l_tipo_compartilhamento
			from grupos_negocios
			where id = l_grupo_negocio_id;

			if l_tipo_compartilhamento <> 'Nenhum' then

				CATEGORIA_COMPARTILHADA (
					p_empresa_id 			=> :new.empresa_id,
					p_categoria_id 			=> :new.id,
				 	p_grupo_categoria_id	=> :new.grupo_categoria_financeira_id,
				 	p_descricao				=> :new.descricao,
				 	p_tipo_operacao			=> :new.tipo_operacao,
				 	p_natureza				=> :new.natureza,
				 	p_ativo					=> :new.ativo,
				 	p_id_interno			=> :new.id_interno
				);

			end if;
		end if;

	end if;

	if updating then

		-->> Verificar se a empresa compartilha dados;
		select grupo_negocio_id
		into l_grupo_negocio_id
		from empresas
		where id = :new.empresa_id;

		select tipo_compartilhamento
		into l_tipo_compartilhamento
		from grupos_negocios
		where id = l_grupo_negocio_id;

		if l_tipo_compartilhamento <> 'Nenhum' then

			CATEGORIA_COMPARTILHADA (
				p_empresa_id 			=> :new.empresa_id,
				p_categoria_id 			=> :new.id,
			 	p_grupo_categoria_id	=> :new.grupo_categoria_financeira_id,
			 	p_descricao				=> :new.descricao,
			 	p_tipo_operacao			=> :new.tipo_operacao,
			 	p_natureza				=> :new.natureza,
			 	p_ativo					=> :new.ativo,
			 	p_id_interno			=> :new.id_interno
			);

		end if;
	end if;

end;
