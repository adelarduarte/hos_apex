create or replace procedure "GERAR_REGRAS_CON"
is
    extrato_record        extratos_bancarios%rowtype;
    extrato_tmp_record    extratos_tmp%rowtype;
    l_status_nome         varchar2(10) := 'Ativo';

    l_historico_tmp       varchar2(500);

    l_extrato_repeticao   number;
    l_qtd_registros       number;
begin
   -- >> início da leitura da tabela de regras de conciliação
   FOR regras_rec IN (
        SELECT *
          FROM banco_regras
          WHERE status = l_status_nome
          and empresa_id = V('SES_EMPRESAS_ID'))
   LOOP
          -- >> Percorre os registros de extratos_tmp "Desconhecidos"
          For extratos_rec IN (
              select *
              from extratos_tmp
              where status = 'Desconhecido'
              and empresa_id = V('SES_EMPRESAS_ID'))
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

              Select count(id)
              into l_qtd_registros
              from lancamentos_financeiros
              where conta_financeira_id = extratos_rec.conta_financeira_id
                  and DATA = extratos_rec.data
                  and (VALOR_ENTRADA = extratos_rec.VALOR_ENTRADA or VALOR_SAIDA = extratos_rec.VALOR_SAIDA)
                  and CONCILIADO != 'Sim';

              If regras_rec.conta_financeira_id = extratos_rec.conta_financeira_id
                 or regras_rec.conta_financeira_id is null then
                    If regras_rec.regra_historico = 'For Igual a' then
                        l_historico_tmp := replace(extratos_rec.historico, chr(9));
                        l_historico_tmp := replace(l_historico_tmp, chr(10));

                        -- If trim(extratos_rec.historico) = trim(regras_rec.historico) then
                        If trim(l_historico_tmp) = trim(regras_rec.historico) and (l_qtd_registros = 0 or l_extrato_repeticao = 1) then

                            Update extratos_tmp
                            Set status = 'Regras', regra_bancaria_id = regras_rec.id
                            where id = extratos_rec.id;

                        end if;

                    end if;

                    if regras_rec.regra_historico = 'Contiver' then
                        l_historico_tmp := replace(extratos_rec.historico, chr(9));
                        l_historico_tmp := replace(l_historico_tmp, chr(10));

                        If instr(l_historico_tmp, regras_rec.historico) > 0 and (l_qtd_registros = 0 or l_extrato_repeticao = 1) then

                            Update extratos_tmp
                            Set status = 'Regras', regra_bancaria_id = regras_rec.id
                            where id = extratos_rec.id;

                        end if;

                    end if;

              end if;

          END LOOP;


   END LOOP;
end;