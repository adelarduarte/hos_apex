create or replace procedure "CANCELAMENTOS_E_DEVOLUCOES"
as
	l_status_devolucao		varchar2(50) := 'Processado';
Begin

	for rec in (
			select id, empresa_id, numero_documento, tipo_lancamento_financeiro
			from caixas_cupons
			where status_devolucao = 'Pendente'
		)
	loop
		case  
			when lower(rec.tipo_lancamento_financeiro) = 'dv' then
				devolucao_a_vista(
						p_empresa_id         => rec.empresa_id,
						p_numero_documento   => rec.numero_documento,
						p_cupom_devolvido_id => rec.id
					);

			when lower(rec.tipo_lancamento_financeiro) = 'dp' then
				devolucao_a_prazo(
						p_empresa_id         => rec.empresa_id,
						p_numero_documento   => rec.numero_documento,
						p_cupom_devolvido_id => rec.id
					);

			when lower(rec.tipo_lancamento_financeiro) in ('cc', 'cpix') then
				cancelamento_cupom(
						p_empresa_id         		 => rec.empresa_id,
						p_numero_documento   		 => rec.numero_documento,
						p_cupom_cancelado_id 		 => rec.id,
						p_tipo_lancamento_financeiro => rec.tipo_lancamento_financeiro
					);

			when lower(rec.tipo_lancamento_financeiro) = 'dc' then
				devolucao_de_convenio(
						p_empresa_id         => rec.empresa_id,
						p_numero_documento   => rec.numero_documento,
						p_cupom_devolvido_id => rec.id					
					);
			else
				null;

		end case;

		dbms_output.put_line(rec.tipo_lancamento_financeiro || ' - ' || rec.numero_documento);

		-->> Atualizar status do cupom 
		update caixas_cupons
		set status_devolucao = l_status_devolucao
		where id = rec.id;
		
	end loop;

End;

