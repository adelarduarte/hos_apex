create or replace procedure GERAR_MOVIMENTO_TMP
  (p_conta_financeira_id IN number,
    p_empresa_id  IN number)
is
    conta_movimento_extratos_record CONTA_MOVIMENTO_EXTRATOS%rowtype;
    l_valor_saida                   number  := 0;
    l_registro_encontrado           boolean := false;
    l_qtd_registros                 number  := 0;
    l_conta_movimento_id            number  := 0;
    l_extrato_repeticao             number;

begin
   -->> Limpa o arquivo conta_movimento_extratos
   Delete from conta_movimento_extratos
   where id > 0 and empresa_id = p_empresa_id;

   -- >> início da leitura do arquivo extratos_tmp
   FOR extratos_rec IN (
        SELECT *
          FROM extratos_tmp
          WHERE STATUS = 'Desconhecido'
          and empresa_id = p_empresa_id)
   LOOP
          select count(id)
          into l_extrato_repeticao
          from extratos_tmp
          where DATA = extratos_rec.data
              and DOCUMENTO = extratos_rec.documento
              and HISTORICO = extratos_rec.historico
              and CONTA_FINANCEIRA_ID = extratos_rec.conta_financeira_id
              and VALOR_ENTRADA = extratos_rec.VALOR_ENTRADA
              and VALOR_SAIDA = extratos_rec.VALOR_SAIDA;

          -- Verificar Entrada
          If extratos_rec.VALOR_ENTRADA > 0 then
            -- Select contasmovimento
            Select count(id)
            into l_qtd_registros
            from lancamentos_financeiros
            where CONTA_FINANCEIRA_ID = p_conta_financeira_id
              and DATA = extratos_rec.data
              and VALOR_ENTRADA = extratos_rec.VALOR_ENTRADA
              and CONCILIADO != 'Sim';

            If l_qtd_registros = 1 then
              Select
                ID,
                CONTA_FINANCEIRA_ID,
                DATA,
                DOCUMENTO,
                VALOR_ENTRADA,
                VALOR_SAIDA,
                HISTORICO,
                TIPO_LANCAMENTO_FINANCEIRO_ID,
                CONCILIADO,
                CENTRO_CUSTO_ID,
                CATEGORIA_FINANCEIRA_ID,
                EMPRESA_ID
              into
                conta_movimento_extratos_record.TIPO_LANCAMENTO_ID,
                conta_movimento_extratos_record.CONTA_FINANCEIRA_ID,
                conta_movimento_extratos_record.DATA,
                conta_movimento_extratos_record.DOCUMENTO,
                conta_movimento_extratos_record.VALOR_ENTRADA,
                conta_movimento_extratos_record.VALOR_SAIDA,
                conta_movimento_extratos_record.HISTORICO,
                conta_movimento_extratos_record.TIPO_LANCAMENTO_ID,
                conta_movimento_extratos_record.CONCILIADO,
                conta_movimento_extratos_record.CENTRO_CUSTOS_ID,
                conta_movimento_extratos_record.CATEGORIA_ID,
                conta_movimento_extratos_record.EMPRESA_ID
              from lancamentos_financeiros
              where CONTA_FINANCEIRA_ID = p_conta_financeira_id
                and DATA = extratos_rec.data
                and VALOR_ENTRADA = extratos_rec.VALOR_ENTRADA
                and CONCILIADO != 'Sim';

                l_registro_encontrado := true;
            else
                l_registro_encontrado := false;

            end if;

          end if;

          -- Verificar Saída
          if extratos_rec.VALOR_SAIDA < 0 then
              l_valor_saida := extratos_rec.VALOR_SAIDA * -1;
              -- Select contasmovimento
              Select count(id)
              into l_qtd_registros
              from lancamentos_financeiros
              where CONTA_FINANCEIRA_ID = p_conta_financeira_id
                and DATA = extratos_rec.data
                and VALOR_SAIDA = l_valor_saida
                and CONCILIADO != 'Sim';

              If l_qtd_registros = 1 then
                Select
                  ID,
                  CONTA_FINANCEIRA_ID,
                  DATA,
                  DOCUMENTO,
                  VALOR_ENTRADA,
                  VALOR_SAIDA,
                  HISTORICO,
                  TIPO_LANCAMENTO_FINANCEIRO_ID,
                  CONCILIADO,
                  CENTRO_CUSTO_ID,
                  CATEGORIA_FINANCEIRA_ID,
                  EMPRESA_ID
                into
                  conta_movimento_extratos_record.TIPO_LANCAMENTO_ID,
                  conta_movimento_extratos_record.CONTA_FINANCEIRA_ID,
                  conta_movimento_extratos_record.DATA,
                  conta_movimento_extratos_record.DOCUMENTO,
                  conta_movimento_extratos_record.VALOR_ENTRADA,
                  conta_movimento_extratos_record.VALOR_SAIDA,
                  conta_movimento_extratos_record.HISTORICO,
                  conta_movimento_extratos_record.TIPO_LANCAMENTO_ID,
                  conta_movimento_extratos_record.CONCILIADO,
                  conta_movimento_extratos_record.CENTRO_CUSTOS_ID,
                  conta_movimento_extratos_record.CATEGORIA_ID,
                  conta_movimento_extratos_record.EMPRESA_ID
                from lancamentos_financeiros
                where CONTA_FINANCEIRA_ID = p_conta_financeira_id
                  and DATA = extratos_rec.data
                  and VALOR_SAIDA = l_valor_saida
                  and CONCILIADO != 'Sim';

                  l_registro_encontrado := true;
              else
                  l_registro_encontrado := false;

              end if;

          end if;

          -- >> Cria um registro na conta_movimento_extratos
          If l_registro_encontrado = true and l_extrato_repeticao = 1 then
              conta_movimento_extratos_record.EXTRATO_ID   := extratos_rec.EXTRATO_ID;
              conta_movimento_extratos_record.LINHA_NUMERO := extratos_rec.linha_numero;

              insert into conta_movimento_extratos values conta_movimento_extratos_record;

              -- >> Atualiza o registro do extrato como "Reconhecido"
              update extratos_tmp
              set STATUS = 'Reconhecido'
              where id = extratos_rec.id;

          end if;

   END LOOP;
end;