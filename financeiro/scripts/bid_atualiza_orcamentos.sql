create or replace TRIGGER BID_ATUALIZA_ORCAMENTOS 
AFTER INSERT OR DELETE ON LANCAMENTOS_FINANCEIROS 
for each row  
declare
    l_existe        number;
    l_natureza      varchar2(50);

    l_mes           number;
    l_ano           number;
    l_categoria_id  number;
    l_empresa_id    number;
BEGIN
    -->> Preparar variáveis para verificar inserção ou exclusao
    if inserting then
        l_mes := extract(month from :new.data);
        l_ano := extract(year from :new.data);
        l_categoria_id := :new.categoria_financeira_id;
        l_empresa_id := :new.empresa_id;
    else
        l_mes := extract(month from :old.data);
        l_ano := extract(year from :old.data);
        l_categoria_id := :old.categoria_financeira_id;
        l_empresa_id := :old.empresa_id;
    end if;

    -->> Verificar se a categoria financeira está presente no orçamento
    select count(*)
    into l_existe
    from orcamento_categorias oc
    where oc.categoria_financeira_id = l_categoria_id
    AND l_mes = oc.mes
    AND l_ano = oc.ano
    AND oc.EMPRESA_ID = l_empresa_id;
    
    if l_existe > 0 then
    
		if INSERTING THEN        
			update orcamento_categorias
			set realizado = coalesce(realizado, 0) + coalesce(:new.valor_saida, 0) + coalesce(:new.valor_entrada, 0)
			where categoria_financeira_id = l_categoria_id
            AND mes = l_mes
            AND ano = l_ano;
            
			update orcamento_categorias 
			set saldo = coalesce(meta, 0) - coalesce(realizado, 0)
            where categoria_financeira_id = l_categoria_id
            AND mes = l_mes
            AND ano = l_ano;
	    End if;

		IF DELETING THEN
			update orcamento_categorias 
			set realizado = coalesce(realizado, 0) - coalesce(:old.valor_saida, 0) - coalesce(:old.valor_entrada, 0)
			where categoria_financeira_id = l_categoria_id
            AND mes = l_mes
            AND ano = l_ano;
                     		
			update orcamento_categorias 
			set saldo = coalesce(meta, 0) - coalesce(realizado, 0)
            where categoria_financeira_id = l_categoria_id
            AND mes = l_mes
            AND ano = l_ano;
        end if;

    end if;
END;