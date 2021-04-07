CREATE OR REPLACE PROCEDURE CAREUP."VERIFY" (p IN NUMBER) is 
begin 

    -->> Verifica a validade do email enviado ao     
    --   usuário Admin, liberando o acesso.

    update usuarios 
    set verify_id = null 
    where verify_id = p; 

    if sql%rowcount != 1 then 
        raise no_data_found; 
    end if; 

end verify; 
