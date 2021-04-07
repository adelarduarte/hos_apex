create or replace procedure "VERIFICAR_CATEGORIAS" (
	p_empresa_id 	IN 	number
)
as

	l_categoria_record 		categorias_financeiras%rowtype;
	l_grupo_categoria_id	number;
	l_grupo_id_interno  	number;

	l_categoria_encontrada	number;
Begin
	-->> Verifica se existem categorias novas
	-- incluídas por outras empresas do grupo
	-- ou modificadas.

	for rec_categoria in (
			select * 
			from categorias_modificadas
			where empresa_id = p_empresa_id
			order by id desc
	)
	loop
		l_grupo_categoria_id := rec_categoria.grupo_categoria_financeira_id;

		select id_interno
		into l_grupo_id_interno
		from grupos_categorias_financeiras
		where id = l_grupo_categoria_id;

		select id
		into l_grupo_categoria_id
		from grupos_categorias_financeiras
		where id_interno = l_grupo_id_interno
		and empresa_id = p_empresa_id;

		l_categoria_record.id 							 := null;
		l_categoria_record.grupo_categoria_financeira_id := l_grupo_categoria_id;
		l_categoria_record.descricao         			 := rec_categoria.descricao;
		l_categoria_record.tipo_operacao     			 := rec_categoria.tipo_operacao;
		l_categoria_record.natureza          			 := rec_categoria.natureza;
		l_categoria_record.ativo             			 := rec_categoria.ativo;
		l_categoria_record.id_interno        			 := rec_categoria.id_interno;
        l_categoria_record.compartilhada                 := 'Sim';


        Begin
        	select id
        	into l_categoria_encontrada
        	from categorias_financeiras
        	where id_interno = l_categoria_record.id_interno
        	and empresa_id = p_empresa_id;
        Exception
        	when no_data_found then
        		l_categoria_encontrada := 0;
        	when others then
        		l_categoria_encontrada := 0;
        End;

        if l_categoria_encontrada > 0 then
        	update categorias_financeiras
        	set grupo_categoria_financeira_id = l_grupo_categoria_id,
        		descricao = l_categoria_record.descricao,
        		tipo_operacao = l_categoria_record.tipo_operacao,
        		natureza = l_categoria_record.natureza,
        		ativo = l_categoria_record.ativo,
        		id_interno = l_categoria_record.id_interno,
        		compartilhada = 'Sim'
        	where id = l_categoria_encontrada
        	and empresa_id = p_empresa_id;
	    else
	        insert into categorias_financeiras values l_categoria_record;

	    end if;

        delete from categorias_modificadas 
        where id_interno = rec_categoria.id_interno
        and empresa_id = p_empresa_id;

	end loop;

End;
