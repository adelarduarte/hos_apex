CREATE TABLE  FORMAS_PAGAMENTOS
   (	
   	id number, 
	nome varchar2(100), 
	cheque varchar2(10), 
	pedir_numero varchar2(10), 
	pedir_vencimento varchar2(10), 
	acao varchar2(100), 
	cartao varchar2(10), 
	cartao_taxa number(14,2), 
	cartao_vencimento number(2,0), 
	cartao_fechamento number(2,0), 
	empresa_id number, 
	centro_custos_id number, 
	categoria_id number, 
	tipo varchar2(50), 
	cartao_prazo_recebimento number(5,0), 
	cartao_bandeira_id number, 
	cartao_mensalidade number(14,2), 
	cartao_tarifa_venda number(14,2), 
	vindi_method_id number, 
	iugu_method_id number, 
   )
/

  CREATE UNIQUE INDEX  "FORMAS_PAGAMENTOS_PK" ON  "FORMAS_PAGAMENTOS" ("ID")
/

ALTER TABLE  "FORMAS_PAGAMENTOS" ADD CONSTRAINT "FORMAS_PAGAMENTOS_PK" PRIMARY KEY ("ID")
  USING INDEX  "FORMAS_PAGAMENTOS_PK"  ENABLE
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_FORMAS_PAGAMENTOS" 
  before insert on "FORMAS_PAGAMENTOS"                
  for each row   
begin    
  if :NEW."ID" is null then  
    select "FORMAS_PAGAMENTOS_SEQ".nextval into :NEW."ID" from sys.dual;  
  end if;  
end;  


/
ALTER TRIGGER  "BI_FORMAS_PAGAMENTOS" ENABLE
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_FORMAS_PAGAMENTOS_TNT" Before insert on FORMAS_PAGAMENTOS 
for each row
Begin
If inserting then
    if :new.empresa_id is null then
        :new.empresa_id := V('SES_EMPRESAS_ID');
        If :new.empresa_id is null then
            :new.empresa_id := -1;
        end if;
    end if;
end if;
End;


/
ALTER TRIGGER  "BI_FORMAS_PAGAMENTOS_TNT" ENABLE
/


