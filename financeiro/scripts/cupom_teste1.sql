Declare
    l_response      clob;
    l_status        varchar2(100);

    l_api_key   varchar2(20) := 'qumlkcgggefmoerlmf';

    l_body      clob;
   
Begin
    l_body := 
    '
        {
        "data": "15-09-2020",
        "hora": "15-09-2020 08:31:02 ",
        "numero_caixa": 125,
        "ecf": 65,
        "serie": 1,
        "numero_documento": 364888,
        "numero_venda": 1456735,
        "tipo_lancamento_financeiro": "CR",
        "cliente": null,
        "dinheiro_valor": 0.0,
        "cartao_valor": 116.77,
        "cheque_valor": 0.0,
        "aprazo_valor": 0.0,
        "convenio_valor": 0.0,
        "outros_valor": 0.0,
        "boleto_valor": 0.0,
        "pagamento_credito_valor": 0.0,
        "teleentrega": "NÃO",
        "crediarios": [],
        "caixa_retorno": null,
        "motivo_sangria_suprimento": null,
        "destino_sangria_suprimento": null,
        "pbm": "NENHUM",
        "cartao": [
            {
                "nome": "TECBIZ - SFPM",
                "operacao": "CREDITO",
                "bandeira": "TECBIZ",
                "adquirente": "CIELO S.A.",
                "nsu": 10040,
                "parcelas": 3,
                "valor": 116.77
            }
        ],
        "convenio": [],
        "cheque": [],
        "recebimentos_crediario": [],
        "itens": [
                {
                    "codigo_barras": 0,
                    "quantidade": 1,
                    "preco_unitario": 40.0,
                    "desconto_percentual": 0.0,
                    "desconto_valor": 0.0
                },
                {
                    "codigo_barras": 7898049792351,
                    "quantidade": 3,
                    "preco_unitario": 16.42,
                    "desconto_percentual": 0.0,
                    "desconto_valor": 0.0
                },
                {
                    "codigo_barras": 7896112125662,
                    "quantidade": 1,
                    "preco_unitario": 27.51,
                    "desconto_percentual": 0.0,
                    "desconto_valor": 0.0
                }
            ]
        }
    ';


    apex_web_service.g_request_headers(1).name  := 'Content-Type';   	    
    apex_web_service.g_request_headers(1).value := 'application/json';  	    
    
	l_response := apex_web_service.make_rest_request(
	  p_url => 'http://dev.hos.com.br:8080/ords/hos/financas/cupons/' || l_api_key
	  , p_http_method => 'POST'
      , p_body => l_body
	);


    if apex_web_service.g_status_code = 200 then --ok  

        dbms_output.put_line('Processo Ok');            
	else
        dbms_output.put_line('Erro no Processo');            

	end if;
    
End;





