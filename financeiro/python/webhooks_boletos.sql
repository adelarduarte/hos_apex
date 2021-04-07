Declare

    l_boleto_id         varchar2(50);
    l_empresa_id        number;
    l_tipo_notificacao	varchar2(50);
    l_webhook_record    boletos_webhooks%rowtype;
    l_boleto_record	    boletos_retorno%rowtype;
    l_json_data			clob;
    l_cnpj_cedente      varchar2(20);
Begin

	l_json_data := :body_text;
    l_cnpj_cedente := :cnpj_cedente;


    -->> Buscar id da empresa cedente
    Begin
        select id
        into l_empresa_id
        from empresas
        where cnpj = l_cnpj_cedente;
    exception
        when no_data_found then
            l_empresa_id := 0;
        when others then
            l_empresa_id := 0;
    end;


    l_webhook_record.id := null;
    l_webhook_record.data := sysdate;
    l_webhook_record.status := 'Pendente';
    l_webhook_record.cnpjcpf := l_cnpj_cedente;
    l_webhook_record.empresa_id := l_empresa_id;
    l_webhook_record.json_data := l_json_data;
    
    insert into boletos_webhooks values l_webhook_record;
    

    APEX_JSON.parse(l_json_data);

    l_tipo_notificacao := APEX_JSON.get_varchar2(p_path => 'tipoWH');

    if l_tipo_notificacao = 'notifica_liquidou' then

		l_boleto_record.id                  := null;
		l_boleto_record.empresa_id          := l_empresa_id;
		l_boleto_record.idintegracao        := APEX_JSON.get_varchar2(p_path => 'idintegracao');       
		l_boleto_record.datahoraenvio       := APEX_JSON.get_varchar2(p_path => 'datahoraenvio');
		l_boleto_record.situacao            := APEX_JSON.get_varchar2(p_path => 'titulo.situacao');
		l_boleto_record.pagamentodata       := APEX_JSON.get_varchar2(p_path => 'titulo.PagamentoData');
		l_boleto_record.titulonossonumero   := APEX_JSON.get_varchar2(p_path => 'titulo.IituloNossoNumero');
		l_boleto_record.pagamentovalorpago  := APEX_JSON.get_varchar2(p_path => 'titulo.PagamentoValorPago');
		l_boleto_record.pagamentodatacredito:= APEX_JSON.get_varchar2(p_path => 'titulo.PagamentoDataCredito');
	    
	    insert into boletos_retorno values l_boleto_record;

	end if;

    :status_code := 200;
    :message := 'Dados recebidos com sucesso!';

End;



