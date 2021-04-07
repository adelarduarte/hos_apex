create or replace PROCEDURE "LANCAMENTO_MANUAL" (
	p_id 					IN	number,
	p_tipo_movimento		IN	varchar2,
	p_conta_financeira_id	IN	number,
	p_conta_destino_id		IN	number,
	p_valor					IN	number
)
IS
	l_tipo_lancamento_id	number;
	l_codigo_transferencia	varchar2(20);
	l_record				lancamentos_financeiros%rowtype;

Begin
	if p_tipo_movimento <> 'Transferência' then
		select id
		into l_tipo_lancamento_id
		from tipos_lancamentos_financeiros
		where descricao = 'Caixa';
	else
		select id
		into l_tipo_lancamento_id
		from tipos_lancamentos_financeiros
		where descricao = 'Transferência';
	end if;


	Case
		when p_tipo_movimento = 'Pagamento' then
			update lancamentos_financeiros
			set valor_saida = p_valor,
				valor_entrada = null,
				tipo_lancamento_financeiro_id = l_tipo_lancamento_id
			where id = p_id;

		when p_tipo_movimento = 'Recebimento' then
			update lancamentos_financeiros
			set valor_saida = null,
				valor_entrada = p_valor,
				tipo_lancamento_financeiro_id = l_tipo_lancamento_id
			where id = p_id;

		when p_tipo_movimento = 'Transferência' then
			-->> Gerar código de Transferência
			l_codigo_transferencia := sys.dbms_random.string('A', 10);

			-->> Buscar registro atual para gerar entrada 
			--	 na conta de destino
			select * into l_record
			from lancamentos_financeiros
			where id = p_id;

			-->> Corrigir origem
			update lancamentos_financeiros
			set valor_saida = p_valor,
				valor_entrada = null,
				transferencia_codigo = l_codigo_transferencia,
				tipo_lancamento_financeiro_id = l_tipo_lancamento_id
			where id = p_id;

			l_record.id 							:= null;
			l_record.valor_entrada  				:= p_valor;
			l_record.valor_saida					:= null;
			l_record.transferencia_codigo 			:= l_codigo_transferencia;
			l_record.tipo_lancamento_financeiro_id  := l_tipo_lancamento_id;
			l_record.conta_financeira_id 			:= p_conta_destino_id;

			insert into lancamentos_financeiros values l_record;

	End Case;

End;
