-->> É necessário substituir o campo tenantid por empresa_id onde for necessário
--  As sequencias também precisam ser criadas


CREATE TABLE  "AUTORIZACOES" 
   (	"ID" NUMBER, 
	"NOME" VARCHAR2(255) COLLATE "USING_NLS_COMP", 
	"DESCRICAO" VARCHAR2(400) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP"
/

  CREATE UNIQUE INDEX  "AUTORIZACOES_PK" ON  "AUTORIZACOES" ("ID")
/

ALTER TABLE  "AUTORIZACOES" ADD CONSTRAINT "AUTORIZACOES_PK" PRIMARY KEY ("ID")
  USING INDEX  "AUTORIZACOES_PK"  ENABLE
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_AUTORIZACOES" 
  before insert on "AUTORIZACOES"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "AUTORIZACOES_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
end; 


/
ALTER TRIGGER  "BI_AUTORIZACOES" ENABLE
/





-------///////////////////////////////////////////////////////////////
CREATE TABLE  "PERFIS" 
   (  "ID" NUMBER, 
  "NOME" VARCHAR2(255) COLLATE "USING_NLS_COMP", 
  "TENANTID" NUMBER
   )  DEFAULT COLLATION "USING_NLS_COMP"
/

  CREATE UNIQUE INDEX  "PERFIS_PK" ON  "PERFIS" ("ID")
/

ALTER TABLE  "PERFIS" ADD CONSTRAINT "PERFIS_PK" PRIMARY KEY ("ID")
  USING INDEX  "PERFIS_PK"  ENABLE
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_PERFIS" 
  before insert on "PERFIS"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "PERFIS_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 

  :new.tenantid := V('SES_TENANTID');
  If :new.tenantid is null then
      :new.tenantid := -1;
  end if;
end; 


/
ALTER TRIGGER  "BI_PERFIS" ENABLE
/





-----//////////////////////////////////////////////////////////////////////
CREATE TABLE  "PERFIS_AUTORIZACOES" 
   (  "ID" NUMBER, 
  "PERFIL_ID" NUMBER, 
  "AUTORIZACAO_ID" NUMBER, 
  "TENANTID" NUMBER
   )  DEFAULT COLLATION "USING_NLS_COMP"
/

  CREATE UNIQUE INDEX  "PERFIS_AUTORIZACOES_PK" ON  "PERFIS_AUTORIZACOES" ("ID")
/

ALTER TABLE  "PERFIS_AUTORIZACOES" ADD CONSTRAINT "PERFIS_AUTORIZACOES_PK" PRIMARY KEY ("ID")
  USING INDEX  "PERFIS_AUTORIZACOES_PK"  ENABLE
/
ALTER TABLE  "PERFIS_AUTORIZACOES" ADD CONSTRAINT "PERFIS_AUT_AUT_FK" FOREIGN KEY ("AUTORIZACAO_ID")
    REFERENCES  "AUTORIZACOES" ("ID") ENABLE
/
ALTER TABLE  "PERFIS_AUTORIZACOES" ADD CONSTRAINT "PERFIS_AUT_PERFIL_FK" FOREIGN KEY ("PERFIL_ID")
    REFERENCES  "PERFIS" ("ID") ON DELETE CASCADE ENABLE
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_PERFIS_AUTORIZACOES" 
  before insert on "PERFIS_AUTORIZACOES"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "PERFIS_AUTORIZACOES_SEQ".nextval into :NEW."ID" from sys.dual; 
    :new.tenantid := V('SES_TENANTID');
  If :new.tenantid is null then
    :new.tenantid := -1;
  end if;
  end if; 
end; 


/
ALTER TRIGGER  "BI_PERFIS_AUTORIZACOES" ENABLE
/





----//////////////////////////////////////////////////////////////////////////////////
CREATE TABLE  "USUARIOS_AUTORIZACOES" 
   (  "ID" NUMBER, 
  "USUARIO_ID" NUMBER, 
  "TENANT_ID" NUMBER, 
  "AUTORIZACAO_ID" NUMBER 
   )  DEFAULT COLLATION "USING_NLS_COMP"
/

  CREATE UNIQUE INDEX  "USUARIOS_AUTORIZACOES_PK" ON  "USUARIOS_AUTORIZACOES" ("ID")
/

ALTER TABLE  "USUARIOS_AUTORIZACOES" ADD CONSTRAINT "USUARIOS_AUTORIZACOES_PK" PRIMARY KEY ("ID")
  USING INDEX  "USUARIOS_AUTORIZACOES_PK"  ENABLE
/
ALTER TABLE  "USUARIOS_AUTORIZACOES" ADD CONSTRAINT "USUARIOS_AUT_AUT_FK" FOREIGN KEY ("AUTORIZACAO_ID")
    REFERENCES  "AUTORIZACOES" ("ID") ENABLE
/
ALTER TABLE  "USUARIOS_AUTORIZACOES" ADD CONSTRAINT "USUARIOS_AUT_TNT_FK" FOREIGN KEY ("TENANT_ID")
    REFERENCES  "TENANTS" ("ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "USUARIOS_AUTORIZACOES" ADD CONSTRAINT "USUARIOS_AUT_USU_FK" FOREIGN KEY ("USUARIO_ID")
    REFERENCES  "USUARIOS" ("ID") ON DELETE CASCADE DISABLE
/

CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_USUARIOS_AUTORIZACOES" 
  before insert on "USUARIOS_AUTORIZACOES"               
  for each row  
begin   
  if :NEW."ID" is null then 
    select "USUARIOS_AUTORIZACOES_SEQ".nextval into :NEW."ID" from sys.dual; 
  end if; 
  if :new.tenant_id is null then
      :new.tenant_id := V('SES_TENANTID');
  end if;
end; 


/
ALTER TRIGGER  "BI_USUARIOS_AUTORIZACOES" ENABLE
/
