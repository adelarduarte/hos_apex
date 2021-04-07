CREATE OR REPLACE PROCEDURE CAREUP."CRIAR_USUARIO" (
 p_username IN VARCHAR2,
 p_nome IN VARCHAR2,
 p_sobrenome IN VARCHAR2,
 p_tenant_id IN NUMBER)
is

   v_isAdmin      char(1) := 'N';   
   v_username     varchar2(200) := p_username;
   v_password     varchar2(200);
   l_verify_id    usuarios.verify_id%type;

   l_body         clob;
   l_content      rwd_email.t_content;
   l_link_confirmacao    varchar2(400);
   l_app_id        number;

   l_count        number := 0;
   l_user_id      number := 0;

begin
   -- Gerar número inteiro aleatório, entre 1 e 100 mil.
   l_verify_id := trunc(sys.dbms_random.value(1,100000));

   -- Gerar cadeia de 20 caracteres aleatórios.
   -- Sendo 'A' para caracteres maiúsculos e minúsculos misturados.   
   v_password := sys.dbms_random.string('A', 20);

   -->> Antes de criar um novo usuário na tabela principal,   
   --   é necessário saber se ele já não existe em outra 
   --   empresa.
   --   Em caso afirmativo, deve ser criado apenas o registro
   --   na tabela usuarios_tenants, para associar o novo
   --   usuário, com a empresa que o está convidando.


   -->> ********** Fazer a busca nesse ponto *********** << --	
   SELECT COUNT(*)  
	INTO l_count  
	FROM usuarios  
	WHERE lower(username) = lower(p_username); 

	-->> Se o usuário for encontrado, então apenas	
    --   cria a ligação com a nova empresa
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
		  'N');          
          
        --Enviar email avisando da nova empresa
        l_content.logo_url := 'https://www.dropbox.com/s/nkz842cf7tfc6df/careup-blue160x60.png?raw=1';            
        l_content.welcome_title := 'Olá ' || p_nome;        
        l_content.sub_welcome_title := 'Você foi adicionado como usuário a uma nova empresa.';        
        l_content.top_paragraph := 'O acesso estará disponível pelo menu [Selecionar Empresas] no seu ambiente do Careup.';        
        l_content.bottom_paragraph := 'Se tiver dúvidas, estamos a disposição para ajuda-lo.';        
        l_content.social_title := 'Saiba das Novidades';        
        l_content.contact_info := 'Contatos:';        
        l_content.contact_phone := 'Skype: <b>suporte@careup.com.br</b>';        
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

	Else

       insert into USUARIOS (
           username, 
           password, 
           isadmin, 
           tenantid, 
           verify_id, 
           email, 
           nome, 
           sobrenome)
       values (
           v_username, 
           my_hash(v_username, v_password), 
           v_isAdmin, 
           p_tenant_id, 
           l_verify_id, 
           v_username, 
           p_nome, 
           p_sobrenome);

       --Enviar email pedindo confirmação para ativar conta
        l_link_confirmacao := 'http://167.99.11.109/ords/f?p=' || NV('APP_ID') || ':verify_user:::::P95_P:' || l_verify_id;
        l_content.logo_url := 'https://www.dropbox.com/s/nkz842cf7tfc6df/careup-blue160x60.png?raw=1';            
        l_content.welcome_title := 'Olá ' || p_nome;        
        l_content.sub_welcome_title := 'Você foi convidado(a) para usar o Careup. Por favor, siga as instruções abaixo.';        
        l_content.top_paragraph := 'Será solicitado que você crie uma senha no primeiro acesso.';        
        l_content.bottom_paragraph := 'Ative sua conta clicando no link a seguir, ou copie e cole no seu navegador '                                    
                                    || sys.utl_tcp.crlf
                                    || '<a href="' || l_link_confirmacao || '">Ativar Conta!</a>';        
        l_content.social_title := 'Saiba das Novidades';        
        l_content.contact_info := 'Contatos:';        
        l_content.contact_phone := 'Skype: <b>suporte@careup.com.br</b>';        
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

    end if;

end;

