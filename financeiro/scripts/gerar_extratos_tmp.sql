create or replace procedure "GERAR_EXTRATOS_TMP" (
    p_conta_financeira_id IN number,
    p_data_inicial        IN date,
    p_data_final          IN date)
is
    extrato_record        extratos_bancarios%rowtype;
    extrato_tmp_record    extratos_tmp%rowtype;
    l_linha_numero        number := 1;

begin
   -->> Limpa o arquivo extratos tmp
   Delete from extratos_tmp
   where id > 0
   and empresa_id = V('SES_EMPRESAS_ID');

   -- >> início da leitura do arquivo extratos_bancarios
   FOR extratos_rec IN (
        SELECT *
          FROM extratos_bancarios
          WHERE CONTA_FINANCEIRA_ID = p_conta_financeira_id
          AND DATA between p_data_inicial and  p_data_final
          AND CONCILIADO = 'Não')
   LOOP
          -- >> Cria um registro nos Extratos Bancários tmp
          extrato_tmp_record.banco_id                 := extratos_rec.banco_id;
          extrato_tmp_record.conta_financeira_id      := extratos_rec.conta_financeira_id;
          extrato_tmp_record.data                     := extratos_rec.data;
          extrato_tmp_record.documento                := extratos_rec.documento;
          extrato_tmp_record.checknum                 := extratos_rec.checknum;
          extrato_tmp_record.fitid                    := extratos_rec.fitid;
          extrato_tmp_record.centro_custos_id         := extratos_rec.centro_custos_id;
          extrato_tmp_record.categoria_financeira_id  := extratos_rec.categoria_custos_id;
          extrato_tmp_record.valor_entrada            := extratos_rec.valor_entrada;
          extrato_tmp_record.valor_saida              := extratos_rec.valor_saida;
          extrato_tmp_record.historico                := extratos_rec.historico;
          extrato_tmp_record.conciliado               := extratos_rec.conciliado;
          extrato_tmp_record.lancamento_financeiro_id := extratos_rec.lancamento_financeiro_id;
          extrato_tmp_record.extrato_id               := extratos_rec.id;
          extrato_tmp_record.empresa_id               := extratos_rec.enpresa_id;
          extrato_tmp_record.linha_numero             := l_linha_numero;
          extrato_tmp_record.saldo_extrato            := 0;
          extrato_tmp_record.saldo_diferenca          := 0;
          extrato_tmp_record.status                   := 'Desconhecido';

          insert into extratos_tmp values extrato_tmp_record;

          l_linha_numero := l_linha_numero + 1;          

   END LOOP;
end;
