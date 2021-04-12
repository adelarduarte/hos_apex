Declare
    l_caixas          caixas%rowtype;
    l_caixas_cupons   caixas_cupons%ROWTYPE;
    l_caixa_id        number;
    l_empresa_id      number;
    l_api_key         varchar2(100);
    l_data_final      date;
    l_numero_caixa    number;
    l_caixa_existente number := 0;

    l_cliente_id      number;
    
    l_dados            clob;
Begin

    l_api_key := :empresa_api_key;
    l_dados := :body_text;

    -->> Verificar api_key da empresa
    l_empresa_id := buscar_empresa_por_api_key(p_api_key => l_api_key);
        
    -->> Criar log
    insert into caixas_log(empresa_id, dados_json) values(l_empresa_id, l_dados);


    if l_empresa_id > 0 then
    
        APEX_JSON.parse(l_dados);

        l_caixas.data_inicial  := to_date(APEX_JSON.get_varchar2(p_path => 'data_inicial'), 'DD-MM-YYYY');
        l_caixas.hora_inicial  := to_date(APEX_JSON.get_varchar2(p_path => 'hora_inicial'), 'DD-MM-YYYY HH:MI:SS');
        l_caixas.data_final    := to_date(APEX_JSON.get_varchar2(p_path => 'data_final'), 'DD-MM-YYYY');
        l_caixas.hora_final    := to_date(APEX_JSON.get_varchar2(p_path => 'hora_final'), 'DD-MM-YYYY HH:MI:SS');
        l_caixas.valor_inicial := APEX_JSON.get_number(p_path => 'valor_inicial');
        l_caixas.valor_final   := APEX_JSON.get_number(p_path => 'valor_final');
        l_caixas.dinheiro      := APEX_JSON.get_number(p_path => 'dinheiro');
        l_caixas.troco         := APEX_JSON.get_number(p_path => 'troco');
        l_caixas.nome_operador := APEX_JSON.get_varchar2(p_path => 'nome_operador');
        l_caixas.empresa_id    := l_empresa_id;
        l_caixas.status        := APEX_JSON.get_varchar2(p_path => 'status');
        l_caixas.numero_caixa  := APEX_JSON.get_number(p_path => 'numero_caixa');

        l_caixas.dinheiro_informado          := APEX_JSON.get_number(p_path => 'dinheiro_informado');
        l_caixas.cheque_informado            := APEX_JSON.get_number(p_path => 'cheque_informado');
        l_caixas.cartao_informado            := APEX_JSON.get_number(p_path => 'cartao_informado');
        l_caixas.a_prazo_informado           := APEX_JSON.get_number(p_path => 'aprazo_informado');
        l_caixas.convenio_informado          := APEX_JSON.get_number(p_path => 'convenio_informado');
        l_caixas.outros_informado            := APEX_JSON.get_number(p_path => 'outros_informado');
        l_caixas.boleto_informado            := APEX_JSON.get_number(p_path => 'boleto_informado');
        l_caixas.pagamento_credito_informado := APEX_JSON.get_number(p_path => 'pagamento_credito_informado');

        -->> Campos condicionais, até que as mudanças nos serviços de envio
        --   estejam atualizadas em todos os clientes

        if apex_json.does_exist(p_path => 'cheque_pre_informado') then
            l_caixas.cheque_pre_informado := APEX_JSON.get_number(p_path => 'cheque_pre_informado');
        else
            l_caixas.cheque_pre_informado := 0;
        end if;

        if apex_json.does_exist(p_path => 'status') then
            l_caixas.status := APEX_JSON.get_varchar2(p_path => 'status');
        else
            l_caixas.status := 'Aberto';
        end if;

        -->> Verificar abertura ou fechamento do caixa
        if l_caixas.data_final is not null then -->> Fechamento...
            update caixas
            set 
                data_final                  = l_caixas.data_final,
                hora_final                  = l_caixas.hora_final,
                valor_final                 = l_caixas.valor_final,
                dinheiro                    = l_caixas.dinheiro,
                troco                       = l_caixas.troco,
                dinheiro_informado          = l_caixas.dinheiro_informado,
                cheque_informado            = l_caixas.cheque_informado,
                cheque_pre_informado        = l_caixas.cheque_pre_informado,
                cartao_informado            = l_caixas.cartao_informado,
                a_prazo_informado           = l_caixas.a_prazo_informado,
                convenio_informado          = l_caixas.convenio_informado,
                outros_informado            = l_caixas.outros_informado,
                boleto_informado            = l_caixas.boleto_informado,
                pagamento_credito_informado = l_caixas.pagamento_credito_informado,
                status                      = l_caixas.status
            where numero_caixa = l_caixas.numero_caixa
            and empresa_id = l_empresa_id;

            -->> Verificar a existência de troco para o próximo caixa
            if l_caixas.troco > 0 then
                -->> Buscar cliente consumidor final
                select id
                into l_cliente_id
                from clientes
                where id_interno = 1
                and empresa_id = l_empresa_id;

                select id 
                into l_caixa_id
                from caixas
                where numero_caixa = l_caixas.numero_caixa
                and empresa_id = l_empresa_id;

                l_caixas_cupons.id                         := null;
                l_caixas_cupons.data                       := l_caixas.data_inicial;
                l_caixas_cupons.hora                       := l_caixas.hora_inicial;
                l_caixas_cupons.numero_caixa               := l_caixas.numero_caixa;
                l_caixas_cupons.tipo_lancamento_financeiro := 'FC';
                l_caixas_cupons.numero_documento           := 99999;
                l_caixas_cupons.cliente_id                 := l_cliente_id;
                l_caixas_cupons.dinheiro_valor             := l_caixas.troco;
                l_caixas_cupons.caixa_id                   := l_caixa_id;
                l_caixas_cupons.empresa_id                 := l_empresa_id;

                insert into caixas_cupons values l_caixas_cupons;
            end if;



            :status_code := 200;
            :message := 'Caixa fechado com sucesso!';

        else -->> Abertura...

            -->> Verificar se caixa já existe
            select count(id)
            into l_caixa_existente
            from caixas
            where numero_caixa = l_caixas.numero_caixa
            and empresa_id = l_empresa_id;


            -->> Criação do registro em caixas
            if l_caixa_existente = 0 then
                insert into caixas values l_caixas returning id into l_caixa_id;

                -->> Verificar existência de troco inicial
                if l_caixas.valor_inicial > 0 then
                    -->> Buscar cliente consumidor final
                    select id
                    into l_cliente_id
                    from clientes
                    where id_interno = 1
                    and empresa_id = l_empresa_id;

                    l_caixas_cupons.id                         := null;
                    l_caixas_cupons.data                       := l_caixas.data_inicial;
                    l_caixas_cupons.hora                       := l_caixas.hora_inicial;
                    l_caixas_cupons.numero_caixa               := l_caixas.numero_caixa;
                    l_caixas_cupons.tipo_lancamento_financeiro := 'AC';
                    l_caixas_cupons.cliente_id                 := l_cliente_id;
                    l_caixas_cupons.dinheiro_valor             := l_caixas.valor_inicial;
                    l_caixas_cupons.caixa_id                   := l_caixa_id;
                    l_caixas_cupons.empresa_id                 := l_empresa_id;
                    
                    insert into caixas_cupons values l_caixas_cupons;
                end if;

                :status_code := 201;
                :message := 'Caixa aberto com sucesso!';
            else
                :status_code := 401;
                :message := 'Caixa já aberto com esse número, nessa empresa.';

            end if;                

        end if;
    else
        :status_code := 401;
        :message := 'Código da chave da api inválido';
    end if;

End;

