-->> Alterado nome de Cartoes(existente) 
--	 para lancamentos_cartoes

CREATE TABLE  CARTOES
   (	
   	id number, 
	contas_pagas_id number, 
	contas_recebidas_id number, 
	data date, 
	numero varchar2(50), 
	forma_pagamento_id number, 
	vencimento date, 
	valor number(14,2), 
	status varchar2(50), 
	observacoes varchar2(400), 
	valor_taxa number(14,2), 
	valor_liquido number(14,2), 
	empresa_id number
   ) 
/

  CREATE UNIQUE INDEX  "CARTOES_PK" ON  "CARTOES" ("ID")
/

ALTER TABLE  "CARTOES" ADD CONSTRAINT "CARTOES_PK" PRIMARY KEY ("ID")
  USING INDEX  "CARTOES_PK"  ENABLE
/
ALTER TABLE  "CARTOES" ADD CONSTRAINT "CARTOES_CP_FK" FOREIGN KEY ("CONTAS_PAGAS_ID")
	  REFERENCES  "CONTAS_PAGAS" ("ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "CARTOES" ADD CONSTRAINT "CARTOES_CR_FK" FOREIGN KEY ("CONTAS_RECEBIDAS_ID")
	  REFERENCES  "CONTAS_RECEBIDAS" ("ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "CARTOES" ADD CONSTRAINT "CARTOES_FPGT_FK" FOREIGN KEY ("FORMA_PAGAMENTO_ID")
	  REFERENCES  "FORMAS_PAGAMENTOS" ("ID") ENABLE
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_CARTOES" 
BEFORE
insert on "CARTOES"
for each row
begin
if :NEW."ID" is null then 
    select "CARTOES_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end;


/
ALTER TRIGGER  "BI_CARTOES" ENABLE
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_CARTOES_TNT" Before insert on CARTOES 
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
END;


/
ALTER TRIGGER  "BI_CARTOES_TNT" ENABLE
/


