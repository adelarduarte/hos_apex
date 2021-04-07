Declare
    l_empresa_id                number;
    l_api_key                   varchar2(100);

    l_cliente_id                number;
    l_cliente_codigo_unico      varchar2(50);
    l_cliente_nome				varchar2(100);
    l_liberado					varchar2(20);
    l_inadimplente				varchar2(20);

    l_limite_credito			number;
    l_saldo_credito				number;

    l_atrasos_qtd				number;

    l_contas 				    sys_refcursor;
Begin

    l_api_key := :empresa_api_key;


    -->> Verificar api_key da empresa
    l_empresa_id := buscar_empresa_por_api_key(p_api_key => l_api_key);


    if l_empresa_id > 0 then

        APEX_JSON.parse(:body_text);

        l_cliente_codigo_unico := APEX_JSON.get_varchar2(p_path => 'cliente');

        If l_cliente_codigo_unico is not null then
            l_cliente_id := buscar_cliente_codigo_unico(p_codigo_unico => l_cliente_codigo_unico);

            if l_cliente_id > 0 then

            	-->> buscar limites de crédito do cliente
            	select limite_credito, (limite_credito - saldo_crediario)
            	into l_limite_credito, l_saldo_credito
            	from clientes_preferencias
            	where cliente_id = l_cliente_id;

            	select nome 
            	into l_cliente_nome
            	from clientes
            	where id = l_cliente_id;


            	if l_saldo_credito >= l_limite_credito then
            		l_liberado := 'Não';
            	else
            		l_liberado := 'Sim';
            	end if;


            	-->> Verificar títulos em atraso
            	select count(id)
            	into l_atrasos_qtd
            	from contas_receber
            	where saldo > 0
            	and data_vencimento < sysdate;

            	if l_atrasos_qtd > 0 then
            		l_liberado := 'Não';
            		l_inadimplente := 'Sim';
            	else
            		l_inadimplente := 'Não';
            	end if;


            	if l_atrasos_qtd > 0 then
            		-->> Listar títulos em atraso
            		open l_contas for
            			select documento as cupom, 
                            data_emissao as data_compra, 
                            data_vencimento as vencimento, 
                            valor as valor_compra, 
                            saldo
            			from contas_receber
            			where cliente_id = l_cliente_id
            			and data_vencimento < sysdate
            			and saldo > 0;

            	end if;


				:nome           := l_cliente_nome;
				:limite_credito := l_limite_credito;
				:saldo_credito  := l_saldo_credito;
				:inadimplente   := l_inadimplente;
				:liberado       := l_liberado;
				:contas 		:= l_contas;


	        else
	         	:status_code := 401;
	         	:message := 'Cliente não encontrado';
        	end if;

		end if;
	end if;	
End;

