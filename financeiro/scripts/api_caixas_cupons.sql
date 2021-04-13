Declare
    l_caixas_cupons             caixas_cupons%rowtype;
    l_caixas_itens              caixas_itens%rowtype;

    l_empresa_id                number;
    l_caixa_id                  number;
    l_api_key                   varchar2(100);
    l_numero_caixa              number;

    l_cliente_id                number;
    l_cliente_codigo_unico      varchar2(50);
    l_cliente_nome              varchar2(100);
    l_cliente_cpf               varchar2(20);
    l_cliente_cnpj              varchar2(20);
    l_cliente_telefone          varchar2(20);
    l_cheque_titular_cpf        varchar2(25);
    l_cheque_titular_observacao varchar2(255);

    l_cartao_id                 number;
    l_cartao_nome               varchar2(100);
    l_cartao_operacao           varchar2(100);
    l_cartao_bandeira           varchar2(100);
    l_cartao_adquirente         varchar2(100);
    l_cartao_nsu                varchar2(100);
    l_cartao_valor              number;
    l_cartao_total              number;
    l_cartao_parcelas           number;
    l_valor_pix                 number;

    l_convenio_id               number;
    l_convenio_cnpj_cpf         varchar2(20);
    l_convenio_nome             varchar2(100);
    l_convenio_vencimento       date;
    l_convenio_valor            number;
    l_convenio_receber_ids      varchar2(500); 
    l_convenio_total            number;
    l_convenio_receber_id       number;
    l_convenio_parcelas         number;

    l_cheque_id                 number;
    l_cheque_codigo_banco       varchar2(10);
    l_cheque_agencia            varchar2(100);
    l_cheque_numero_conta       varchar2(20);
    l_cheque_numero_cheque      varchar2(50);
    l_cheque_numero_serie       varchar2(50);
    l_cheque_titular            varchar2(100);
    l_cheque_data_cheque        date;
    l_cheque_bom_para           date;
    l_cheque_valor              number;
    l_cheque_total              number;
    l_cheque_ok                 varchar2(10);

    l_recebimentos_crediario    varchar2(500);
    l_crediarios                varchar2(500);
    l_cupom_dinheiro            varchar2(10);
    l_cupom_pbm                 varchar2(10);

    l_crediario_vencimento      date;
    l_crediario_valor           number;
    l_crediario_total           number;
    l_crediario_receber_ids     varchar2(500);
    l_crediario_parcelas        number;

    l_cupom_id                  number;
    l_cupom_numero              number;
    l_cupom_valor               number;
    l_cupom_juros               number;
    l_cupom_multa               number;
    l_cupom_acrescimo           number;
    l_cupom_desconto            number;

    l_dados_ok                  boolean;
    l_dados                     clob;

    l_tipo_lancamento_original  varchar2(10);

    l_valor_venda_dinheiro      number;
Begin
    l_dados_ok := true;

    l_api_key := :empresa_api_key;
    l_dados   := :body_text;

    -->> Verificar api_key da empresa
    l_empresa_id := buscar_empresa_por_api_key(p_api_key => l_api_key);

    -->> Log dos cupons
    insert into caixas_cupons_log(empresa_id, dados_json) values(l_empresa_id, l_dados);

    if l_empresa_id > 0 then

        APEX_JSON.parse(l_dados);

        -->> Pegar dados para verificar se é um cupom normal ou
        --   cancelamento de farmácia popular.
        l_caixas_cupons.tipo_lancamento_financeiro := APEX_JSON.get_varchar2(p_path => 'tipo_lancamento_financeiro');
        l_caixas_cupons.numero_documento           := APEX_JSON.get_number(p_path => 'numero_documento');
        l_caixas_cupons.numero_venda               := APEX_JSON.get_number(p_path => 'numero_venda');
    
        -->> Cancelar contas a receber PBM;
        if lower(l_caixas_cupons.tipo_lancamento_financeiro) = 'cfp' then
                CANCELA_PBM_RECEBER(
                        p_empresa_id       => l_empresa_id,
                        p_numero_documento => l_caixas_cupons.numero_documento,
                        p_numero_venda     => l_caixas_cupons.numero_venda
                    );

                l_dados_ok := false;
        end if;

        -->> Se não for um cancelamento de farmácia popular...
        if l_dados_ok then
            l_caixas_cupons.numero_caixa := APEX_JSON.get_number(p_path => 'numero_caixa');

            -->> Buscar o ID do caixa correspondente
            Begin
                select id
                into l_caixa_id
                from caixas
                where numero_caixa = l_caixas_cupons.numero_caixa
                and empresa_id = l_empresa_id;
            exception
                when no_data_found then
                    l_caixa_id := 0;
                    :status_code := 401;
                    :message := 'Número do caixa não encontrado: ' || to_char(l_caixas_cupons.numero_caixa) || ' | Empresa: ' || to_char(l_empresa_id);
                    l_dados_ok := false;
            end;

            l_cliente_codigo_unico                     := APEX_JSON.get_varchar2(p_path => 'cliente.codigo_unico');
            l_cliente_nome                             := APEX_JSON.get_varchar2(p_path => 'cliente.nome');
            l_cliente_cpf                              := APEX_JSON.get_varchar2(p_path => 'cliente.cpf');
            l_cliente_cnpj                             := APEX_JSON.get_varchar2(p_path => 'cliente.cnpj');
            l_cliente_telefone                         := APEX_JSON.get_varchar2(p_path => 'cliente.telefone');


            -->> Buscar cliente por código único
            If l_cliente_codigo_unico is not null then
                l_cliente_id := buscar_cliente_codigo_unico(p_codigo_unico => l_cliente_codigo_unico);

                if l_cliente_id = 0 then
                    -->> cadastrar novo cliente
                    l_cliente_id := criar_cliente_cupom(
                            p_cliente_codigo_unico  => l_cliente_codigo_unico,
                            p_cliente_nome          => l_cliente_nome,
                            p_cliente_cpf           => l_cliente_cpf,
                            p_cliente_cnpj          => l_cliente_cnpj,
                            p_cliente_telefone      => l_cliente_telefone,
                            p_empresa_id            => l_empresa_id      
                        );

                end if;
            else
                -->> Buscar cliente 'Consumidor Final'
                select id
                into l_cliente_id
                from clientes
                where id_interno = 1
                and empresa_id = l_empresa_id;
            end if;

            l_caixas_cupons.cliente_id                 := l_cliente_id;
            l_caixas_cupons.caixa_id                   := l_caixa_id;
            l_caixas_cupons.empresa_id                 := l_empresa_id;
            l_caixas_cupons.data                       := to_date(APEX_JSON.get_varchar2(p_path => 'data'), 'DD-MM-YYYY');
            l_caixas_cupons.hora                       := to_date(APEX_JSON.get_varchar2(p_path => 'hora'), 'DD-MM-YYYY HH24:MI:SS');
            l_caixas_cupons.ecf                        := APEX_JSON.get_number(p_path => 'ecf');
            l_caixas_cupons.serie                      := APEX_JSON.get_number(p_path => 'serie');
            l_caixas_cupons.numero_documento           := APEX_JSON.get_number(p_path => 'numero_documento');
            l_caixas_cupons.numero_venda               := APEX_JSON.get_number(p_path => 'numero_venda');
            l_caixas_cupons.tipo_lancamento_financeiro := APEX_JSON.get_varchar2(p_path => 'tipo_lancamento_financeiro');
            l_caixas_cupons.dinheiro_valor             := APEX_JSON.get_number(p_path => 'dinheiro_valor');
            l_caixas_cupons.cheque_valor               := APEX_JSON.get_number(p_path => 'cheque_valor');
            l_caixas_cupons.cartao_valor               := APEX_JSON.get_number(p_path => 'cartao_valor');
            l_caixas_cupons.a_prazo_valor              := APEX_JSON.get_number(p_path => 'aprazo_valor');
            l_caixas_cupons.convenio_valor             := APEX_JSON.get_number(p_path => 'convenio_valor');
            l_caixas_cupons.numero_parcelas            := APEX_JSON.get_number(p_path => 'numero_parcelas');
            l_caixas_cupons.outros_valor               := APEX_JSON.get_number(p_path => 'outros_valor');
            l_caixas_cupons.boleto_valor               := APEX_JSON.get_number(p_path => 'boleto_valor');
            l_caixas_cupons.pagamento_credito_valor    := APEX_JSON.get_number(p_path => 'pagamento_credito_valor');
            l_caixas_cupons.teleentrega                := APEX_JSON.get_varchar2(p_path => 'teleentrega');
            l_caixas_cupons.taxa_tele_entrega          := APEX_JSON.get_number(p_path => 'taxa_tele_entrega');
            l_caixas_cupons.troco_tele_entrega         := APEX_JSON.get_number(p_path => 'troco_tele_entrega');
            l_caixas_cupons.vencimento                 := to_date(APEX_JSON.get_varchar2(p_path => 'vencimento'), 'DD-MM-YYYY');
            l_caixas_cupons.caixa_retorno              := APEX_JSON.get_number(p_path => 'caixa_retorno');
            l_caixas_cupons.motivo_sangria_suprimento  := APEX_JSON.get_varchar2(p_path => 'motivo_sangria_suprimento');
            l_caixas_cupons.destino_sangria_suprimento := APEX_JSON.get_varchar2(p_path => 'destino_sangria_suprimento');
            l_caixas_cupons.pbm                        := APEX_JSON.get_varchar2(p_path => 'pbm');
            

            if apex_json.does_exist(p_path => 'cheque_pre_valor') then
                l_caixas_cupons.cheque_pre_valor := APEX_JSON.get_number(p_path => 'cheque_pre_valor');
            else
                l_caixas_cupons.cheque_pre_valor := 0;
            end if;
        end if;


        -->> Dados verificados e ok, criar o registro de cupom
        if l_dados_ok then

            -->> Transformar de cartão PIX para movimento bancário
                l_valor_pix := l_caixas_cupons.cartao_valor;

                for i in 1 .. apex_json.get_count(p_path => 'cartao') LOOP

                    l_cartao_nome       := APEX_JSON.get_varchar2(p_path => 'cartao[%d].nome', p0 => i);

                    if lower(l_cartao_nome) = 'pix' then
                        if lower(l_caixas_cupons.tipo_lancamento_financeiro) = 'cc' then
                            l_caixas_cupons.tipo_lancamento_financeiro := 'CPIX';
                            l_caixas_cupons.boleto_valor               := l_valor_pix;
                            l_caixas_cupons.cartao_valor               := 0;
                        else
                            l_caixas_cupons.tipo_lancamento_financeiro := 'PIX';
                            l_caixas_cupons.outros_valor               := l_valor_pix;
                            l_caixas_cupons.cartao_valor               := 0;
                        end if;
                    end if;

                end loop;


            if lower(l_caixas_cupons.teleentrega) = 'sim' then 

                -->> Lançamento de tele-venda e tele-venda em aberto
                --   para tratamento posterior
                l_tipo_lancamento_original := l_caixas_cupons.tipo_lancamento_financeiro;
                l_caixas_cupons.tipo_lancamento_financeiro := 'TVA';

                insert into caixas_cupons values l_caixas_cupons;

                l_caixas_cupons.tipo_lancamento_financeiro := l_tipo_lancamento_original;
                insert into caixas_cupons values l_caixas_cupons returning id into l_cupom_id;
            else
                -->> Lançamento de cupom que não é tele-venda
                insert into caixas_cupons values l_caixas_cupons returning id into l_cupom_id;

            end if;


            -->> Eliminar Tele-venda em aberto (negativa).
            if lower(l_caixas_cupons.tipo_lancamento_financeiro) = 'tv' then

                if l_caixas_cupons.numero_caixa = l_caixas_cupons.caixa_retorno then
                    delete from caixas_cupons
                    where tipo_lancamento_financeiro = 'TVA'
                    and numero_documento = l_caixas_cupons.numero_documento
                    and empresa_id = l_empresa_id;

                    delete from caixas_cupons where id = l_cupom_id;

                end if;

            end if;


            -->> Tratamento de cartões
            -->> Ignorar lançamento se for PIX
            if lower(l_caixas_cupons.tipo_lancamento_financeiro) <> 'pix' then
                for i in 1 .. apex_json.get_count(p_path => 'cartao') LOOP
                    l_cartao_nome       := APEX_JSON.get_varchar2(p_path => 'cartao[%d].nome', p0 => i);
                    l_cartao_operacao   := APEX_JSON.get_varchar2(p_path => 'cartao[%d].operacao', p0 => i);
                    l_cartao_bandeira   := APEX_JSON.get_varchar2(p_path => 'cartao[%d].bandeira', p0 => i);
                    l_cartao_adquirente := APEX_JSON.get_varchar2(p_path => 'cartao[%d].adquirente', p0 => i);
                    l_cartao_nsu        := APEX_JSON.get_varchar2(p_path => 'cartao[%d].nsu', p0 => i);
                    l_cartao_valor      := APEX_JSON.get_number(p_path => 'cartao[%d].valor', p0 => i);
                    l_cartao_parcelas   := APEX_JSON.get_number(p_path => 'cartao[%d].parcelas', p0 => i);

                    l_cartao_id := cupom_cartao(
                            p_cartao_nome       => l_cartao_nome,
                            p_cartao_operacao   => l_cartao_operacao,
                            p_cartao_bandeira   => l_cartao_bandeira,
                            p_cartao_adquirente => l_cartao_adquirente,
                            p_cartao_nsu        => l_cartao_nsu,
                            p_cartao_valor      => l_cartao_valor,
                            p_empresa_id        => l_empresa_id,
                            p_cliente_id        => l_cliente_id,
                            p_parcelas          => l_cartao_parcelas,
                            p_documento         => l_caixas_cupons.numero_documento,
                            p_cupom_id          => l_cupom_id
                        );

                    if l_cartao_id = 0 then

                        :status_code := 401;
                        :message := 'Cartão não identificado!';
                        l_dados_ok := false;
                    end if;

                end loop;
            end if;

            -->> Tratamento de crediários
            l_crediario_parcelas := apex_json.get_count(p_path => 'crediarios');

            for i in 1 .. apex_json.get_count(p_path => 'crediarios') LOOP
                l_crediario_vencimento       := to_date(APEX_JSON.get_varchar2(p_path => 'crediarios[%d].vencimento', p0 => i), 'DD-MM-YYYY');
                l_crediario_valor            := APEX_JSON.get_number(p_path => 'crediarios[%d].valor', p0 => i);


                l_crediario_receber_ids := cupom_crediario(
                        p_cliente_id    => l_cliente_id,
                        p_empresa_id    => l_empresa_id,
                        p_cupom_id      => l_cupom_id,
                        p_documento     => l_caixas_cupons.numero_documento,
                        p_vencimento    => l_crediario_vencimento,
                        p_valor         => l_crediario_valor                        
                    );

            end loop;        


            -->> Tratamento de convênios
            l_convenio_parcelas := apex_json.get_count(p_path => 'convenio');

            for i in 1 .. apex_json.get_count(p_path => 'convenio') LOOP
                l_convenio_cnpj_cpf         := APEX_JSON.get_varchar2(p_path => 'convenio[%d].cnpj_cpf', p0 => i);
                l_convenio_nome             := APEX_JSON.get_varchar2(p_path => 'convenio[%d].nome', p0 => i);
                l_convenio_vencimento       := to_date(APEX_JSON.get_varchar2(p_path => 'convenio[%d].vencimento', p0 => i), 'DD-MM-YYYY');
                l_convenio_valor            := APEX_JSON.get_number(p_path => 'convenio[%d].valor', p0 => i);


                -->> Buscar convênio
                l_convenio_id := buscar_convenio(
                        p_cnpj_cpf      =>  l_convenio_cnpj_cpf,
                        p_empresa_id    =>  l_empresa_id
                    );

                if l_convenio_id = 0 then
                    -->> cadastrar convênio
                    l_convenio_id := criar_convenio_cupom (
                            p_convenio_nome => l_convenio_nome,
                            p_cnpj_cpf      => l_convenio_cnpj_cpf,
                            p_empresa_id    =>  l_empresa_id
                        );
                end if;

                if l_convenio_id > 0 then
                    update clientes set convenio_id = l_convenio_id where id = l_cliente_id;
                end if;   

                l_convenio_receber_id := cupom_convenio(
                            p_convenio_id         => l_cliente_id,
                            p_convenio_vencimento => l_convenio_vencimento,
                            p_convenio_valor      => l_convenio_valor,
                            p_empresa_id          => l_empresa_id,
                            p_cupom_id            => l_cupom_id,
                            p_documento           => l_caixas_cupons.numero_documento
                        );

            end loop;


            -->> Tratamento de cheques
            for i in 1 .. apex_json.get_count(p_path => 'cheque') loop
                l_cheque_codigo_banco  := APEX_JSON.get_varchar2(p_path => 'cheque[%d].codigo_banco', p0 => i);
                l_cheque_agencia       := APEX_JSON.get_varchar2(p_path => 'cheque[%d].agencia', p0 => i); 
                l_cheque_numero_conta  := APEX_JSON.get_varchar2(p_path => 'cheque[%d].numero_conta', p0 => i); 
                l_cheque_numero_cheque := APEX_JSON.get_varchar2(p_path => 'cheque[%d].numero_cheque', p0 => i); 
                l_cheque_numero_serie  := APEX_JSON.get_varchar2(p_path => 'cheque[%d].numero_serie', p0 => i); 
                l_cheque_titular       := APEX_JSON.get_varchar2(p_path => 'cheque[%d].titular', p0 => i); 
                l_cheque_data_cheque   := to_date(APEX_JSON.get_varchar2(p_path => 'cheque[%d].data_cheque', p0 => i), 'DD-MM-YYYY'); 
                l_cheque_bom_para      := to_date(APEX_JSON.get_varchar2(p_path => 'cheque[%d].bom_para', p0 => i), 'DD-MM-YYYY'); 
                l_cheque_valor         := APEX_JSON.get_number(p_path => 'cheque[%d].valor', p0 => i);
                l_cheque_titular_cpf   := APEX_JSON.get_varchar2(p_path => 'cheque[%d].cpf', p0 => i); 
                l_cheque_titular_observacao := APEX_JSON.get_varchar2(p_path => 'cheque[%d].observacao', p0 => i); 


                l_cheque_id := cadastrar_cheque_cupom(
                        p_cheque_codigo_banco       => l_cheque_codigo_banco,
                        p_cheque_agencia            => l_cheque_agencia,
                        p_cheque_numero_conta       => l_cheque_numero_conta,
                        p_cheque_numero_cheque      => l_cheque_numero_cheque,
                        p_cheque_numero_serie       => l_cheque_numero_serie,
                        p_cheque_titular            => l_cheque_titular,
                        p_cheque_data_cheque        => l_cheque_data_cheque,
                        p_cheque_bom_para           => l_cheque_bom_para,
                        p_valor_cheque              => l_cheque_valor,
                        P_cliente_id                => l_cliente_id,
                        p_empresa_id                => l_empresa_id,
                        p_cupom_id                  => l_cupom_id,
                        p_telefone_emitente         => l_cliente_telefone,
                        p_observacao                => l_cheque_titular_observacao,
                        p_titular_cpf               => l_cheque_titular_cpf
                    );

                l_cheque_ok := cupom_cheque(
                        p_cliente_id          => l_cliente_id,
                        p_cheque_vencimento   => l_cheque_bom_para,
                        p_cheque_valor        => l_cheque_valor,
                        p_empresa_id          => l_empresa_id,
                        p_cupom_id            => l_cupom_id,
                        p_documento           => l_caixas_cupons.numero_documento
                    );
                
            end loop;


            if lower(l_caixas_cupons.tipo_lancamento_financeiro) not in('dv', 'cc', 'dc', 'dp', 'ex') then
                -->> Tratamento de venda em dinheiro
                if l_caixas_cupons.dinheiro_valor > 0 then

                    if l_caixas_cupons.outros_valor > 0 
                        and lower(l_caixas_cupons.pbm) = 'nenhum' then

                        l_valor_venda_dinheiro := nvl(l_caixas_cupons.dinheiro_valor, 0) 
                                                    + nvl(l_caixas_cupons.outros_valor, 0);
                    else
                        l_valor_venda_dinheiro := nvl(l_caixas_cupons.dinheiro_valor, 0);
                    end if;                        

                    l_cupom_dinheiro := cupom_dinheiro (
                            p_cliente_id          => l_cliente_id,
                            p_valor               => l_valor_venda_dinheiro,
                            p_empresa_id          => l_empresa_id,
                            p_cupom_id            => l_cupom_id,
                            p_documento           => l_caixas_cupons.numero_documento
                        );

                end if;

                -->> Tratamento de venda PBM
                if l_caixas_cupons.outros_valor > 0 
                    and lower(l_caixas_cupons.pbm) <> 'nenhum' then

                    l_cupom_pbm := cupom_pbm (
                            p_cliente_id          => l_cliente_id,
                            p_valor               => nvl(l_caixas_cupons.outros_valor, 0),
                            p_empresa_id          => l_empresa_id,
                            p_cupom_id            => l_cupom_id,
                            p_documento           => l_caixas_cupons.numero_documento,
                            p_pbm                 => l_caixas_cupons.pbm
                        );

                end if;

            end if;

            -->> tratar cupons de recebimentos de crediários
            l_recebimentos_crediario := '';

            for i in 1 .. apex_json.get_count(p_path => 'recebimentos_crediario') LOOP
                l_cupom_numero    := APEX_JSON.get_number(p_path => 'recebimentos_crediario[%d].cupom', p0 => i);
                l_cupom_valor     := APEX_JSON.get_number(p_path => 'recebimentos_crediario[%d].valor', p0 => i);
                l_cupom_juros     := APEX_JSON.get_number(p_path => 'recebimentos_crediario[%d].juros', p0 => i);
                l_cupom_multa     := APEX_JSON.get_number(p_path => 'recebimentos_crediario[%d].multa', p0 => i);
                l_cupom_acrescimo := APEX_JSON.get_number(p_path => 'recebimentos_crediario[%d].acrescimo', p0 => i);
                l_cupom_desconto  := APEX_JSON.get_number(p_path => 'recebimentos_crediario[%d].desconto', p0 => i);

                l_recebimentos_crediario := cupom_crediario_recebimento(
                        p_cliente_id    => l_cliente_id,
                        p_empresa_id    => l_empresa_id,
                        p_cupom         => l_cupom_numero,
                        p_valor         => l_cupom_valor,
                        p_juros         => l_cupom_juros,
                        p_multa         => l_cupom_multa,
                        p_acrescimo     => l_cupom_acrescimo,
                        p_desconto      => l_cupom_desconto);
            end loop;

            l_caixas_cupons.cupons_crediario := l_recebimentos_crediario;


            -->> Inserir itens do cupom
            for i in 1 .. apex_json.get_count(p_path => 'itens') LOOP
                l_caixas_itens.cupom_id            := l_cupom_id;
                l_caixas_itens.codigo_barras       := APEX_JSON.get_varchar2(p_path => 'itens[%d].codigo_barras', p0 => i);
                l_caixas_itens.quantidade          := APEX_JSON.get_number(p_path => 'itens[%d].quantidade', p0 => i);
                l_caixas_itens.preco_unitario      := APEX_JSON.get_number(p_path => 'itens[%d].preco_unitario', p0 => i);
                l_caixas_itens.desconto_percentual := APEX_JSON.get_number(p_path => 'itens[%d].desconto_percentual', p0 => i);
                l_caixas_itens.desconto_valor      := APEX_JSON.get_number(p_path => 'itens[%d].desconto_valor', p0 => i);
                l_caixas_itens.descricao           := APEX_JSON.get_varchar2(p_path => 'itens[%d].descricao', p0 => i);
                l_caixas_itens.ncm                 := APEX_JSON.get_varchar2(p_path => 'itens[%d].ncm', p0 => i);
                l_caixas_itens.custo_contabil      := APEX_JSON.get_number(p_path => 'itens[%d].custo_contabil', p0 => i);

                insert into caixas_itens values l_caixas_itens;

            end loop;


            -->> Correção de dados para cupons - cartões
            update caixas_cupons
                set numero_parcelas = l_cartao_parcelas,
                    cartao_operacao = l_cartao_operacao
                where l_cartao_valor > 0
                and id = l_cupom_id;

            -->> Correção de dados para cupons - crediário
            update caixas_cupons
                set numero_parcelas = l_crediario_parcelas
                where l_crediario_valor > 0
                and id = l_cupom_id;


            -->> Correção de dados para cupons - convênio
            update caixas_cupons
                set convenio_id = l_convenio_id,
                    numero_parcelas = l_convenio_parcelas
                where l_convenio_valor > 0
                and id = l_cupom_id;


            :status_code := 201;
            :message := 'Cupom inserido com sucesso!';
        end if;

    else
        :status_code := 401;
        :message := 'Código da chave da api inválido';
    end if;

End;
