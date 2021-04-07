Declare

    l_produtos_venda    produtos_venda%rowtype;
Begin

    APEX_JSON.parse(:body_text);


    for i in 1 .. apex_json.get_count(p_path => 'produtos_venda') LOOP
        -->> Criação do registro em produtos_venda
        l_produtos_venda.id                   := APEX_JSON.get_number(p_path => 'produtos_venda[%d].id', p0 => i);
        l_produtos_venda.venda_id             := APEX_JSON.get_number(p_path => 'produtos_venda[%d].venda_id', p0 => i);
        l_produtos_venda.produto_id           := APEX_JSON.get_number(p_path => 'produtos_venda[%d].produto_id', p0 => i);
        l_produtos_venda.quantidade           := APEX_JSON.get_number(p_path => 'produtos_venda[%d].quantidade', p0 => i);
        l_produtos_venda.quantidade_devolvida := APEX_JSON.get_number(p_path => 'produtos_venda[%d].quantidade_devolvida', p0 => i);
        l_produtos_venda.valor_unitario       := APEX_JSON.get_number(p_path => 'produtos_venda[%d].valor_unitario', p0 => i);
        l_produtos_venda.valor_total_liquido  := APEX_JSON.get_number(p_path => 'produtos_venda[%d].valor_total_liquido', p0 => i);
        l_produtos_venda.valor_total_bruto    := APEX_JSON.get_number(p_path => 'produtos_venda[%d].valor_total_bruto', p0 => i);
        l_produtos_venda.funcionario_id       := APEX_JSON.get_number(p_path => 'produtos_venda[%d].funcionario_id', p0 => i);
        l_produtos_venda.tipo_desconto        := APEX_JSON.get_varchar2(p_path => 'produtos_venda[%d].tipo_desconto', p0 => i);
        l_produtos_venda.aliquota             := APEX_JSON.get_varchar2(p_path => 'produtos_venda[%d].aliquota', p0 => i);
        l_produtos_venda.custo_contabil       := APEX_JSON.get_number(p_path => 'produtos_venda[%d].custo_contabil', p0 => i);
        l_produtos_venda.custo_compra         := APEX_JSON.get_number(p_path => 'produtos_venda[%d].custo_compra', p0 => i);
        
        insert into produtos_venda values l_produtos_venda;

    END LOOP;

    :status := 200;

End;