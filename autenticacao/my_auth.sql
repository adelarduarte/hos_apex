CREATE OR REPLACE FUNCTION CAREUP."MY_AUTH" (     
    p_username IN VARCHAR2,      
    p_password IN VARCHAR2)  
  RETURN BOOLEAN  
AS  
  l_password            VARCHAR2(2000);  
  l_stored_password     VARCHAR2(2000);  
  l_count               NUMBER;  
  l_tenantid            NUMBER;  
  l_userid              NUMBER;  
  l_nome_completo       VARCHAR2(100); 

  l_tenant_razao_social varchar2(255);
  l_tenant_cnpj         varchar2(20);
  l_tenants_qtd         number := 0;

  l_emite_notas_servicos       varchar2(10);
  l_emite_notas_mercadorias    varchar2(10);
  l_emite_cobrancas            varchar2(10);
BEGIN  

  -->> Primero, verificar se o usuário existe.    
  SELECT COUNT(*)  
  INTO l_count  
  FROM usuarios  
  WHERE lower(username) = lower(p_username) 
  AND verify_id is null;  -->> Esta parte verifica se a conta foi ativada   

  -->> Recuperar a senha hash armazenada    
  IF l_count     > 0 THEN           
    SELECT password, nome || ' ' || sobrenome      
    INTO l_stored_password, l_nome_completo  
    FROM usuarios  
    WHERE lower(username) = lower(p_username);  

    IF length(l_nome_completo) < 2 THEN               
        l_nome_completo := 'Desconhecido';        
    END IF; 

    -->> Aplicar a função hash a senha recebida por parâmetro      
    l_password := my_hash(lower(p_username), p_password);  

    -->> Comparar com a gravada e retornar verdadeiro ou falso      
    IF l_password = l_stored_password THEN  

      -->> Gravar o tenant principal do usuário na variável de sessão.            
      SELECT TENANTID, ID 
      INTO l_tenantid, l_userid   
      FROM USUARIOS  
      WHERE lower(USERNAME) = lower(p_username);  


      -->> Gravar razão social e cnpj em variáveis de sessão      
      Select razaosocial, 
              cnpj, 
              nf_servicos, 
              nf_produtos, 
              boletos
      into l_tenant_razao_social, 
              l_tenant_cnpj, 
              l_emite_notas_servicos, 
              l_emite_notas_mercadorias, 
              l_emite_cobrancas
      from tenants 
      where id = l_tenantid;


      -- >> Verificar se o usuário está presente em mais de um tenant      
      select count(id)
      into l_tenants_qtd
      from usuarios_tenants
      where usuario_id = l_userid;

      -- >> Setar variáveis de sessão      
      Apex_Util.Set_Session_State('SES_TENANTID', l_tenantid);                  
      Apex_Util.Set_Session_State('SES_USERID', l_userid);             
      Apex_Util.Set_Session_State('SES_NOME_COMPLETO', l_nome_completo);       
      Apex_Util.Set_Session_State('SES_TENANT_QTD', l_tenants_qtd); 
      Apex_Util.Set_Session_State('SES_RAZAO_SOCIAL', l_tenant_razao_social );       
      Apex_Util.Set_Session_State('SES_CNPJ', l_tenant_cnpj);       
      Apex_Util.Set_Session_State('SES_EMITE_NOTAS_SERVICOS', l_emite_notas_servicos);             
      Apex_Util.Set_Session_State('SES_EMITE_NOTAS_MERCADORIAS', l_emite_notas_mercadorias);       
      Apex_Util.Set_Session_State('SES_EMITE_COBRANCAS', l_emite_cobrancas); 

      RETURN true;  
    ELSE  
      RETURN false;  
    END IF;  
  ELSE  

    -->> Usuário não encontrado      
    RETURN false;  

  END IF;  

END;  

