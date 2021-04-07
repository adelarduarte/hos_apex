create or replace procedure "FECHAR_CONVENIOS"
IS
	l_contas_receber_record		contas_receber%rowtype;
	l_convenio_id				number;
	l_titulo_id					number;
	l_centro_custos_id			number;
	l_categoria_id				number;

	l_total						number(14,2);
	l_tipo_cliente_id			number;
	l_dia_fechamento			number;

	l_documento_fatura_id		number;
	l_documento_fechado_id		number; -->> convênio Fechado
	l_tipo_convenio_id			number;
	l_nova_fatura_id			number;
	l_status_pendente_id		number;

	l_vencimento_titulo			date;

	l_dia 						number;
	l_mes 						number;
	l_ano 						number;

	l_tipo_fechamento			varchar2(50);
	l_lista_de_empresas			varchar2(200); -->> Lista de empresas que compartilham dados
	l_lista_de_convenios		varchar2(200); -->> lista de convênios que permitem fechamento
	l_tipo_compartilhamento		varchar2(100);

	l_grupo_negocio_id			number;
	l_grupo_economico_id		number;
Begin
	-->> Buscar o id do tipo de cliente = 'Cliente'
	select id 
	into l_tipo_cliente_id
	from tipos_clientes
	where lower(descricao) = 'cliente';

	-->> Setar o dia de fechamento para filtro
	select to_number( to_char(sysdate, 'DD')) 
	into l_dia_fechamento
	from dual;

	-->> Tipo de documento Fatura
	select id
	into l_documento_fatura_id
	from tipos_documentos_financeiros
	where lower(descricao) = 'fatura';

	-->> Tipo de documento Convênio Fechado
	select id
	into l_documento_fechado_id
	from tipos_documentos_financeiros
	where lower(descricao) = 'convênio fechado';

	-->> Tipo de documento Convênio
	select id
	into l_tipo_convenio_id
	from tipos_documentos_financeiros
	where lower(descricao) = 'convênio';

	-->> Status de titulo Pendente
	select id
	into l_status_pendente_id
	from status_financeiros
	where lower(nome) = 'pendente';

	-->> Buscar empresas que fecham convênios de forma automática
	for rec_empresa in (
			select id, empresa_id, fechamento_convenio
			from empresas_preferencias
			where fechamento_convenio <> 'Manual'
	)
	loop
		-->> Buscar convênios fechando no dia, de forma automática
		for rec_convenio in (
			select c.id, c.nome, c.empresa_id, c.cnpj, cf.convenio_id, cf.dia_fechamento, 
					cf.dia_vencimento, cf.prazo_meses, cp.tipo_fechamento
			from clientes c, convenios_fechamentos cf, convenios_preferencias cp
			where c.tipo_cliente_id <> l_tipo_cliente_id
			and cf.convenio_id = c.id
			and cp.convenio_id = c.id
			and (cp.fechamento_automatico <> 'Não' or cp.fechamento_automatico is null)
			and cf.dia_fechamento = l_dia_fechamento
			and c.empresa_id = 341 -->> retirar filtro quando em produção
			-- and c.empresa_id = rec_empresa.empresa_id
		)
		loop
			l_total := 0;

			-->> Calcular vencimento título
			l_dia := rec_convenio.dia_vencimento;

			if rec_convenio.prazo_meses > 1 then
				l_vencimento_titulo := add_months(sysdate, rec_convenio.prazo_meses);

				l_mes := extract(month from l_vencimento_titulo);
				l_ano := extract(year from l_vencimento_titulo);

				l_vencimento_titulo := to_date( to_char(l_dia) || '/' || to_char(l_mes) || '/' || to_char(l_ano), 'DD/MM/YYYY');
			else
				l_vencimento_titulo := add_months(sysdate, 1);

				l_mes := extract(month from l_vencimento_titulo);
				l_ano := extract(year from l_vencimento_titulo);

				l_vencimento_titulo := to_date( to_char(l_dia) || '/' || to_char(l_mes) || '/' || to_char(l_ano), 'DD/MM/YYYY');
			end if;

			-->> Verificar se é fechamento agrupado ou individual
			if rec_convenio.tipo_fechamento = 'Agrupado' then
				-->> Verificar o tipo de compartilhamento do grupo de negócios da empresa;
				select gn.tipo_compartilhamento, gn.id, e.grupo_economico_id  
				into l_tipo_compartilhamento, l_grupo_negocio_id, l_grupo_economico_id
				from grupos_negocios gn, empresas e
				where e.grupo_negocio_id = gn.id 
				and e.id = rec_convenio.empresa_id;

				-->> Buscar as empresas que fazem parte do compartilhamento,
				if l_tipo_compartilhamento = 'Grupo' then
					-->> Selecionar empresas do mesmo grupo de negócios
					select listagg(id, ',')
					into l_lista_de_empresas
					from empresas 
					where grupo_negocio_id = l_grupo_negocio_id;

				end if;
				
				if l_tipo_compartilhamento = 'Rede' then
					-->> Selecionar empresas do mesmo grupo econômico (rede)
					select listagg(id, ',')
					into l_lista_de_empresas
					from empresas 
					where grupo_economico_id = l_grupo_economico_id;

				end if;

				if l_tipo_compartilhamento = 'Nenhum' then
					l_lista_de_empresas := rec_convenio.empresa_id;

				end if;

			else
				l_lista_de_empresas := rec_convenio.empresa_id;

			end if;
			-- dbms_output.put_line(' --- >>  Tipo de compartilhamento: ' || l_tipo_compartilhamento);


			-->> Criar lista de convênios que fecham de forma agrupada. Filtrar por CNPJ
			select listagg(c.id, ',')
			into l_lista_de_convenios 
			from clientes c, convenios_preferencias cp
			where cp.convenio_id = c.id
			and cp.tipo_fechamento = 'Agrupado'
			and c.cnpj = rec_convenio.cnpj;

			-->> Centro de custos e categoria do convênio
			select centro_custos_id, categoria_id 
			into l_centro_custos_id, l_categoria_id
			from clientes_preferencias
			where cliente_id = rec_convenio.id;

			-->> Somar saldo do título filtrado
			select sum(cr.saldo)
			into l_total
			from contas_receber cr, clientes cc
			where cr.cliente_id = cc.id		
			and cc.convenio_id in (select to_number(xt.column_value)
			           from   xmltable(l_lista_de_convenios) xt )
			and cr.data_emissao <= sysdate
			and cr.tipo_documento_id = l_tipo_convenio_id
			and cr.saldo > 0;

			-->> Caso tenha valor, criar novo titulo, como 'Fatura' retornando o id
			if l_total > 0 then
				-- dbms_output.put_line(' --- >>  Criando Título');

				l_contas_receber_record.id                      := null;
				l_contas_receber_record.data_emissao            := sysdate;
				l_contas_receber_record.data_vencimento         := l_vencimento_titulo;
				l_contas_receber_record.status_id               := l_status_pendente_id;
				l_contas_receber_record.cliente_id              := rec_convenio.convenio_id;
				l_contas_receber_record.centro_custo_id         := l_centro_custos_id;
				l_contas_receber_record.categoria_financeira_id := l_categoria_id;
				l_contas_receber_record.saldo                   := l_total;
				l_contas_receber_record.valor                   := l_total;
				l_contas_receber_record.tipo_documento_id       := l_documento_fatura_id;
				l_contas_receber_record.empresa_id  			:= rec_convenio.empresa_id;
				l_contas_receber_record.documento 				:= to_char(trunc(sys.dbms_random.value(1,100000)));
				l_contas_receber_record.recorrente 				:= 'Não';
				l_contas_receber_record.parcelado 				:= 'Não';
				l_contas_receber_record.cobranca_agrupada 		:= 'Sim';

				insert into contas_receber values l_contas_receber_record returning id into l_nova_fatura_id;

			end if;

			-->> Mudar o tipo de documento do titulo somado
			if l_total > 0 then
				-- dbms_output.put_line(' --- >>  Gravando IDs e mudando status');

				update contas_receber cr 
					set cr.boleto_convenio_id = l_nova_fatura_id,
					    cr.tipo_documento_id = l_documento_fechado_id,
					    cr.somar_valores = 'Não'
					where cr.id in ( select cr.id
						from contas_receber cr, clientes cc
						where cr.cliente_id = cc.id		
						and cc.convenio_id in (select to_number(xt.column_value)
						           from   xmltable(l_lista_de_convenios) xt )
						and cr.data_emissao <= sysdate
						and cr.tipo_documento_id = l_tipo_convenio_id
						and cr.saldo > 0
					);
			end if;
		end loop; -->> Convênios

	end loop; -->> Empresas preferências

End;



