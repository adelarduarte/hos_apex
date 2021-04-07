CREATE OR REPLACE PROCEDURE "EXCLUIR_LANCAMENTO_FINANCEIRO" (
	p_id					IN	number,
	p_transferencia_codigo	IN	varchar2,
	p_conta_paga_id			IN	number,
	p_conta_recebida_id		IN	number
)
IS


Begin
	-->> Excluir lançamento de transferência
	if p_transferencia_codigo is not null then
		delete from 
			lancamentos_financeiros
		where transferencia_codigo = p_transferencia_codigo
		and id <> p_id;
	end if;

    -->> Reabrir lançamento do contas a receber
    if p_conta_recebida_id > 0 then
        reabrir_recebimento(p_id => p_conta_recebida_id);
    end if;

    -->> Reabrir lançamento do contas a pagar
    if p_conta_paga_id > 0 then
        reabrir_pagamento(p_id => p_conta_paga_id);
    end if;

    delete from
    	lancamentos_financeiros
    where id = p_id;

end;