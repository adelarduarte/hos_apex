-- Liquidação a pagar /receber:

-- o form é direto em contas pagas / recebidas
-- passar como parâmetro o id do contas a pagar / receber para o form,
-- no ID de relacionamento.

-- Carregar saldo e descrição no início do form


-- Verificar saldo
-- Criada função verificar_saldo...

-- Atualizar título
Declare
    l_saldo               Number;
    l_valor_Pago          Number;
    l_status_titulo_id    Number;

Begin
    if :P97_CENTROCUSTOSID is not null and :P97_CATEGORIACUSTOSID is not null then
        Select saldo
        into l_saldo
        from contaspagar
        where id = :P97_CONTASPAGARID;

        l_valor_pago := :P97_VALORPAGO - (:P97_VALORJUROS + :P97_VALORMULTA + :P97_VALOROUTROS) + :P97_VALORDESCONTO; 

        If (l_saldo - l_valor_pago) <= 0 Then
            Select id 
            into l_status_titulo_id
            from STATUSTITULOS
            where nome = 'Liquidado';

            Update CONTASPAGAR
            set Saldo = 0, statusid = l_status_titulo_id
            where id = :P97_CONTASPAGARID;
        else
            Select id 
            into l_status_titulo_id
            from STATUSTITULOS
            where nome = 'Liquidando';

            Update CONTASPAGAR
            set Saldo = (l_saldo - l_valor_pago), statusid = l_status_titulo_id
            where id = :P97_CONTASPAGARID;
        End if;
    end if;
    
End;



-->> Registrar nos lançamentos financeiros
--   após o processamento do formulário
Declare
    l_tipo_lancamento_id    Number;
    l_record    contasmovimento%rowtype;
    
Begin
    Select id into l_tipo_lancamento_id
    from tiposlancamentosfinanceiros
    where nome = 'Financeiro';

    l_record.CONTAFINANCEIRAID := :P97_CONTAFINANCEIRAID;
    l_record.DATA              := :P97_DATAPAGAMENTO;
    l_record.DOCUMENTO         := :P97_DOCUMENTO;
    l_record.VALORENTRADA      := 0;
    l_record.VALORSAIDA        := to_number(:P97_VALORPAGO);
    l_record.HISTORICO         := 'Pago cfe documento ' || :P97_DOCUMENTO;
    l_record.TIPOLANCAMENTOID  := l_tipo_lancamento_id;
    l_record.CONCILIADO        := 'Não';
    l_record.CENTROCUSTOSID    := :P97_CENTROCUSTOSID;
    l_record.CATEGORIAID       := :P97_CATEGORIACUSTOSID;
    l_record.CONTASPAGASID     := :P97_ID;

    insert into contasmovimento values l_record;

End;
    


