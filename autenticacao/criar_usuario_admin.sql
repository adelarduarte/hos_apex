CREATE OR REPLACE PROCEDURE CAREUP."CRIAR_USUARIO_ADMIN" 	(
     p_username IN VARCHAR2,
	 p_password IN VARCHAR2,
	 p_nome IN VARCHAR2,
	 p_sobrenome IN VARCHAR2,
	 p_tenant_id IN NUMBER)
is

	v_isAdmin      char(1) := 'S';	
    v_username     varchar2(200) := p_username;
	v_password     varchar2(200) := p_password;
	l_verify_id    usuarios.verify_id%type;

	l_body         clob;
	l_content      rwd_email.t_content;
	l_link_confirmacao    varchar2(400);

	l_count        number := 0;
	l_user_id      number := 0;

    l_fone         varchar2(20);

begin

	-->> Antes de criar um novo usuário Admin na tabela principal,	
    --   é necessário saber se ele já não existe em outra 
	--   empresa.
	--   Em caso afirmativo, deve ser criado apenas o registro
	--   na tabela usuarios_tenants, para associar o novo
	--   usuário, com a nova empresa.

	-->> ********** Fazer a busca nesse ponto *********** << --	
    SELECT COUNT(*)  
	INTO l_count  
	FROM usuarios  
	WHERE lower(username) = lower(p_username); 

	-->> Se o usuário for encontrado, então apenas	
    --   cria a ligação com a nova empresa, como Admin
	if l_count > 0 then		
        SELECT id  
		INTO l_user_id  
		FROM usuarios  
		WHERE lower(username) = lower(p_username);

		insert into usuarios_tenants(
		  usuario_id,
		  tenant_id,
		  isadmin)
		values(
		  l_user_id,
		  p_tenant_id,
		  'S');	
    Else
        -->> Buscar o telefone do tenant para informar no email        
        select coalesce(fone, '')        
        into l_fone
        from tenants
        where id = p_tenant_id;


		-->> Se o usuário for um novo usuário, então		
        --   segue o processo normal de criação e envio
		--   de email para confirmação da conta

		-->> Gerar número inteiro aleatório, entre 1 e 100 mil.		
        l_verify_id := trunc(sys.dbms_random.value(1,100000));

		-->> Gerar cadeia de 20 caracteres aleatórios.		
        -- Sendo 'A' para caracteres maiúsculos e minúsculos misturados.		
        -- l_verify_id := sys.dbms_random.string('A', 20);
		-- >> Gravar usuário na tabela principal        
        insert into USUARIOS (
		   username, 
		   password, 
		   isadmin, 
		   tenantid, 
		   verify_id, 
		   email, 
		   primeiro_acesso, 
		   nome, 
		   sobrenome)
		values (
		   v_username, 
		   my_hash(v_username, v_password), 
		   v_isAdmin, 
		   p_tenant_id, 
		   l_verify_id, 
		   v_username, 
		   'S', 		   
            p_nome, 
		   p_sobrenome);


		-- >> A inserção do usuário na tabela 		
        --    usuarios_tenants, se dá por meio
		--    de trigger.
		-- >> 

		-->> Enviar email pedindo confirmação para ativar conta		
        l_link_confirmacao := 'http://167.99.11.109/ords/f?p=' || NV('APP_ID') || ':verify:::::P54_P:' || l_verify_id;
		l_content.logo_url := 'https://www.dropbox.com/s/nkz842cf7tfc6df/careup-blue160x60.png?raw=1';    		
        l_content.welcome_title := 'Bem-vindo';		
        l_content.sub_welcome_title := 'Seu espaço de trabalho no Careup está quase pronto. Por favor, siga as instruções abaixo.';		
        l_content.top_paragraph := 'Precisamos confirmar seu endereço de email, para garantir a segurança dos seus dados.';		
        l_content.bottom_paragraph := 'Por favor, clique no link a seguir, ou copie e cole no seu navegador '		                            
                                    || sys.utl_tcp.crlf
		                            || '<a href="' || l_link_confirmacao || '">Ativar Conta!</a>';		
        l_content.social_title := 'Saiba das Novidades';		
        l_content.contact_info := 'Contatos:';		
        l_content.contact_phone := 'Fone: <b>(54)1111-1111</b>';		
        l_content.contact_email := 'Email: <a href="mailto:suporte@careup.com.br">suporte@careup.com.br</a>';		
        l_content.footer_links := '<a href="#">Termos</a> | <a href="#">Privacidade</a>';
        
		l_body := rwd_email.basic(l_content);

		apex_mail.send (
		    p_to        => v_username,		    
            p_from      => 'suporte@careup.com.br',		    
            p_body      => l_body,		    
            p_body_html => l_body,		    
            p_subj      => 'Careup - Ative sua conta.');
            
		apex_mail.push_queue;



        -->> Enviar email comunicando nova empresa        
        l_content.logo_url := 'https://www.dropbox.com/s/nkz842cf7tfc6df/careup-blue160x60.png?raw=1';            
        l_content.welcome_title := 'Nova Empresa!';        
        l_content.sub_welcome_title := '</br></br>Temos um novo cliente!';        
        l_content.top_paragraph := 'Email: ' || v_username 
                                    || ' - Fone: ' || l_fone        		                 
                                    || sys.utl_tcp.crlf
                                    || 'Nome: ' || p_nome || ' ' || p_sobrenome;
                                    
        l_content.bottom_paragraph := 'A entrega de emails pode sofrer demoras ocasionais.';
        l_body := rwd_email.basic(l_content);

        apex_mail.send (
            p_to        => 'adduarte@icloud.com',            
            p_from      => 'suporte@careup.com.br',            
            p_cc        => '',            
            p_body      => l_body,            
            p_body_html => l_body,            
            p_subj      => 'Novo cliente: ' || v_username );


        apex_mail.push_queue;

	end if;

end;
