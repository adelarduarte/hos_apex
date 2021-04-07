CREATE OR REPLACE PROCEDURE CAREUP."VERIFY_USER" (
    p IN NUMBER, p_password IN VARCHAR2) 
is 
    l_username    usuarios.username%type;
    l_password    varchar2(200);

begin 

    -->> Verifica a validade do email    
    --   do usuário convidado, liberando o acesso

    select username
    into l_username
    from usuarios
    where verify_id = p;

    l_password := my_hash(l_username, p_password);

    update usuarios 
    set verify_id = null, password = l_password 
    where verify_id = p; 

    if sql%rowcount != 1 then 
        raise no_data_found; 
    end if; 

end verify_user;
