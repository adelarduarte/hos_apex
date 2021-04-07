create or replace procedure "APLICAR_REGRAS_CONCILIACAO"(
    p_conta_financeira_id    IN    number,
    p_empresa_id             IN    number)
is
	 l_data				     date;
	 l_documento		   varchar2(50);
	 l_valor_entrada	 number;
   l_valor_saida		 number;
	 l_extrato_id		   number;
	 l_id 				     number;
   l_regra_id			   number;

begin
   -- >> início da leitura da tabela extratos_tmp para aplicar as regras
   FOR extratos_rec IN (
        SELECT *
          FROM extratos_tmp
          WHERE status = 'Regras'
          and empresa_id = p_empresa_id)
   LOOP
         -- >> Seta valores para chamar procedure de aplicação das regras
         l_data          := extratos_rec.data;
         l_documento     := extratos_rec.documento;
         l_valor_entrada := extratos_rec.valor_entrada;
         l_valor_saida   := extratos_rec.valor_saida;
         l_extrato_id    := extratos_rec.extrato_id;
         l_id            := extratos_rec.id;
         l_regra_id      := extratos_rec.regra_bancaria_id;

         CONCILIAR_REGISTRO_REGRAS(
             p_data                => l_data,
             p_documento           => l_documento,
             p_conta_financeira_id => p_conta_financeira_id,
             p_valor_entrada       => l_valor_entrada,
             p_valor_saida         => l_valor_saida,
             p_extrato_id          => l_extrato_id,
             p_extrato_tmp_id      => l_id,
             p_regra_id            => l_regra_id,
             p_empresa_id          => p_empresa_id);

   END LOOP;
end;