Declare
    -- Declara uma variável igual ao record de contas a receber.
    l_record   contasreceber%rowtype;

    l_intervalo number := CASE 
                          WHEN :P96_INTERVALORECORRENCIA > 0 THEN :P96_INTERVALORECORRENCIA
                          WHEN :P96_INTERVALORECORRENCIA <= 0 THEN 30
                          ELSE 30
                          END;

    l_data_vencimento date := sysdate;
    l_data_emissao    date := sysdate;
Begin
   -- Calcula a primeira data de vencimento e emissao, recorrência
    if l_intervalo = 30 then
        l_data_vencimento := add_months(to_date(:P96_DATAVENCIMENTO), 1);
        l_data_emissao    := add_months(to_date(:P96_DATAEMISSAO), 1);
    else
        l_data_vencimento := to_date(:P96_DATAVENCIMENTO) + l_intervalo;
        l_data_emissao    := to_date(:P96_DATAEMISSAO) + l_intervalo;
    end if;
    
    Select * into l_record 
    from contasreceber
    where id = :P96_ID;

    WHILE l_data_vencimento <= :P96_DATALIMITERECORRENCIA
    LOOP
        l_record.id              := contasreceber_id_seq.nextval;
        l_record.documentopaiid  := :P96_ID;
        l_record.valortotal      := :P96_VALOR;
        l_record.valor           := :P96_VALOR;
        l_record.saldo           := :P96_VALOR;
        l_record.dataemissao     := l_data_emissao;
        l_record.datavencimento  := l_data_vencimento;
        l_record.dataagendamento := l_data_vencimento;
        l_record.documento       := :P96_DOCUMENTO;
        
        INSERT INTO contasreceber values l_record;
        
       if l_intervalo = 30 then
            l_data_vencimento := add_months(l_data_vencimento, 1);
            l_data_emissao    := add_months(l_data_emissao, 1);
        else
            l_data_vencimento := l_data_vencimento + l_intervalo;
            l_data_emissao    := l_data_emissao + l_intervalo;
        end if;
    
    END LOOP;
    
End;


-- Criar Setar saldo
-- Alterar Saldo
-- Criar parcelamento
-- Criar recorrência
