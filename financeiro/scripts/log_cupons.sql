Declare
    l_empresa_id                number;
    l_caixa_id                  number;
    l_api_key                   varchar2(100);
    l_numero_caixa              number;

    l_dados            			clob;
Begin

    l_api_key := :empresa_api_key;
    l_dados := :body_text;

    -->> Verificar api_key da empresa
    l_empresa_id := buscar_empresa_por_api_key(p_api_key => l_api_key);
        
    -->> Criar log
    insert into caixas_cupons_log(empresa_id, dados_json) values(l_empresa_id, l_dados);


	:status_code := 201;
	:message := 'Cupom inserido em tabela de log!';

End;


