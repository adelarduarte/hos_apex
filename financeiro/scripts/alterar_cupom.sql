create or replace procedure "ALTERAR_CUPOM" (
		p_operacao_nova			IN varchar2,
        p_cartao_nome       	IN varchar2,
        p_cartao_operacao   	IN varchar2,
        p_cartao_bandeira   	IN varchar2,
        p_cartao_adquirente 	IN varchar2,
        p_cartao_nsu        	IN varchar2,
        p_cartao_valor      	IN number,
        p_empresa_id        	IN number,
        p_cliente_id        	IN number,
        p_parcelas          	IN number,
        p_documento         	IN varchar2,
        p_cupom_id          	IN number,
        p_eh_cartao				IN varchar2,
        p_eh_cheque 			IN varchar2,
		p_cheque_codigo_banco	IN varchar2,
		p_cheque_agencia		IN varchar2,
		p_cheque_numero_conta	IN varchar2,
		p_cheque_numero_cheque	IN varchar2,
		p_cheque_numero_serie	IN varchar2,
		p_cheque_titular		IN varchar2,
		p_cheque_data_cheque	IN date,
		p_cheque_bom_para		IN date,
		p_valor_cheque			IN number,        
        p_convenio_id         	IN number,
        p_convenio_vencimento 	IN date,
        p_convenio_valor      	IN number,
        p_diferenca_valor 		IN number,
        p_crediario_vencimento  IN date,
        p_crediario_valor       IN number
	)
is
	l_cartao_id 					number;
	l_qtd_lancamentos				number;
	l_cheque_id 					number;
	l_cheque_ok						varchar2(10);
	l_convenio_receber_id   		number;
	l_crediario_receber_id 			number;
	l_tipo_documento_convenio_id	number;
	l_tipo_documento_crediario_id   number;
	l_conta_receber_id				number;
Begin

	-->> De modo geral, se o parâmetro 'p_diferenca_valor'
	--	for = 0, exclui o contas a receber anterior.
	--	se for > 0, alterar o contas a receber, liquidadas 
	--	e lançamentos financeiros, para o novo valor.
	if p_diferenca_valor <= 0 then
		for rec in (
				select * 
				from contas_receber
				where cupom_id = p_cupom_id
			)
		loop
			delete from contas_recebidas
			where conta_receber_id = rec.id;
	    end loop;
	    delete from contas_receber where cupom_id = p_cupom_id;
	else
		for rec in (
				select * 
				from contas_receber
				where cupom_id = p_cupom_id
			)
		loop
			-->> percorrer registros, alterando valor e saldo
			if rec.saldo <= 0 then
				update contas_receber
				set valor = p_diferenca_valor
				where id = rec.id;
			else
				update contas_receber
				set valor = p_diferenca_valor,
				saldo = p_diferenca_valor;
			end if;

			-->> pegar id do contas a receber, para alterar contas_recebidas
			for recebidas in (
					select * from
					contas_recebidas
					where conta_receber_id = rec.id
				)
			loop
				-->> Correção contas a receber liquidadas
				update contas_recebidas
				set valor_recebido = p_diferenca_valor
				where conta_receber_id = recebidas.id;

				-->> Correção lançamentos financeiros
				update lancamentos_financeiros
				set valor_entrada = p_diferenca_valor
				where conta_recebida_id = recebidas.id;

			end loop;	

			-->> Verificar lançamentos de provisão...

		end loop;

	end if;



	-->> Verificar se existe cartão para excluir
	if p_eh_cartao = 'Sim' then
		Begin
			select count(id)
			into l_qtd_lancamentos
			from lancamentos_cartoes
			where cupom_id = p_cupom_id;
		Exception
			when no_data_found then
				l_qtd_lancamentos := 0;
			when others then
				l_qtd_lancamentos := 0;
		End;

		if l_qtd_lancamentos > 0 then
			-->> Excluir lançamentos existentes
			delete from lancamentos_cartoes
			where cupom_id = p_cupom_id;

			-->> Excluir contas recebidas
			for rec in (
					select * 
					from contas_receber
					where cupom_id = p_cupom_id
				)
			loop
				delete from contas_recebidas
				where conta_receber_id = rec.id;
		    end loop;
		    delete from contas_receber where cupom_id = p_cupom_id;

		end if;

	end if;


	-->> Verificar se existe cheque para excluir
	if p_eh_cheque = 'Sim' then
		Begin
			select count(id)
			into l_qtd_lancamentos
			from cheques
			where cupom_id = p_cupom_id;
		Exception
			when no_data_found then
				l_qtd_lancamentos := 0;
			when others then
				l_qtd_lancamentos := 0;
		End;

		if l_qtd_lancamentos > 0 then
			-->> Excluir lançamentos existentes
			delete from cheques
			where cupom_id = p_cupom_id;

			-->> Exclusão de contas recebidas
			for rec in (
					select * 
					from contas_receber
					where cupom_id = p_cupom_id
				)
			loop
				delete from contas_recebidas
				where conta_receber_id = rec.id;
		    end loop;
		    delete from contas_receber where cupom_id = p_cupom_id;

		end if;

	end if;


	if p_eh_cartao = 'Sim' then

		-->> Tratamento de cartões
	    l_cartao_id := cupom_cartao(
	            p_cartao_nome       => p_cartao_nome,
	            p_cartao_operacao   => p_cartao_operacao,
	            p_cartao_bandeira   => p_cartao_bandeira,
	            p_cartao_adquirente => p_cartao_adquirente,
	            p_cartao_nsu        => p_cartao_nsu,
	            p_cartao_valor      => p_cartao_valor,
	            p_empresa_id        => p_empresa_id,
	            p_cliente_id        => p_cliente_id,
	            p_parcelas          => p_parcelas,
	            p_documento         => p_documento,
	            p_cupom_id          => p_cupom_id
	        );
	end if;


	if p_eh_cheque = 'Sim' then

	    l_cheque_id := cadastrar_cheque_cupom(
	            p_cheque_codigo_banco       => p_cheque_codigo_banco,
	            p_cheque_agencia            => p_cheque_agencia,
	            p_cheque_numero_conta       => p_cheque_numero_conta,
	            p_cheque_numero_cheque      => p_cheque_numero_cheque,
	            p_cheque_numero_serie       => p_cheque_numero_serie,
	            p_cheque_titular            => p_cheque_titular,
	            p_cheque_data_cheque        => p_cheque_data_cheque,
	            p_cheque_bom_para           => p_cheque_bom_para,
	            p_valor_cheque              => p_valor_cheque,
	            P_cliente_id                => p_cliente_id,
	            p_empresa_id                => p_empresa_id,
	            p_cupom_id                  => p_cupom_id
	        );

	    l_cheque_ok := cupom_cheque(
	            p_cliente_id          => p_cliente_id,
	            p_cheque_vencimento   => p_cheque_bom_para,
	            p_cheque_valor        => p_valor_cheque,
	            p_empresa_id          => p_empresa_id,
	            p_cupom_id            => p_cupom_id,
	            p_documento           => p_documento
	        );
	end if;


	if p_operacao_nova = 'Convênio' then
		-->> excluir lançamentos de convênio anterior
		-->> **** Não permitir alteração parcial de convênio

		-->> Buscar tipo de documento Convênio
		Select id
		into l_tipo_documento_convenio_id
		from tipos_documentos_financeiros
		where lower(descricao) = 'convênio';

		-->> Excluir lançamentos anteriores
		delete from contas_receber
		where cupom_id = p_cupom_id
		and tipo_documento_id = l_tipo_documento_convenio_id;


        l_convenio_receber_id := cupom_convenio_alterado(   
                p_convenio_id         => p_convenio_id,
                p_convenio_vencimento => p_convenio_vencimento,
                p_convenio_valor      => p_convenio_valor,
                p_empresa_id          => p_empresa_id,
                p_cupom_id            => p_cupom_id,
                p_documento           => p_documento,
                p_parcelas 			  => p_parcelas 	    
            );
	end if;


	if p_operacao_nova = 'Crediário' then
		-->> excluir lançamentos de crediário anterior
		-->> **** Não permitir alteração parcial de crediário

		-->> Buscar tipo de documento Crediário
		Select id
		into l_tipo_documento_crediario_id
		from tipos_documentos_financeiros
		where lower(descricao) = 'crediário';

		-->> Excluir lançamentos anteriores
		delete from contas_receber
		where cupom_id = p_cupom_id
		and tipo_documento_id = l_tipo_documento_crediario_id;


        l_crediario_receber_id := cupom_crediario_alterado(
                p_cliente_id    => p_cliente_id,
                p_empresa_id    => p_empresa_id,
                p_cupom_id      => p_cupom_id,
                p_documento     => p_documento,
                p_vencimento    => p_crediario_vencimento,
                p_valor         => p_crediario_valor,
                p_parcelas      => p_parcelas
            );        
	end if;


End;



