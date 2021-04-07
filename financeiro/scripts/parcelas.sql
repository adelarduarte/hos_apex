Declare
    -- Declare uma variável igual ao record de contas a receber.
    l_record   contasreceber%rowtype;

    l_parcelas number := :P96_NUMEROPARCELAS;
    l_intervalo number := CASE 
                          WHEN :P96_INTERVALOPARCELAS > 0 THEN :P96_INTERVALOPARCELAS
                          WHEN :P96_INTERVALOPARCELAS <= 0 THEN 30
                          ELSE 30
                          END;
    l_valor_parcela number(12,2);
    l_valor_parcela01 number(12,2);
    l_data_vencimento date := sysdate;
Begin
    l_valor_parcela := :P96_VALOR / l_parcelas;
    
   if l_intervalo = 30 then
        l_data_vencimento := add_months(to_date(:P96_DATAVENCIMENTO), 1);
    else
        l_data_vencimento := to_date(:P96_DATAVENCIMENTO) + l_intervalo;
    end if;
    
    -- Calcular a possível diferença da divisão.
    l_valor_parcela01 := :P96_VALOR - (l_valor_parcela * l_parcelas);    

    Select * into l_record 
    from contasreceber
    where id = :P96_ID;

    FOR i IN 1..(l_parcelas - 1)
    LOOP
        l_record.id             := contasreceber_id_seq.nextval;
        l_record.documentopaiid := :P96_ID;
        l_record.valortotal     := :P96_VALOR;
        l_record.valor          := l_valor_parcela;
        l_record.saldo          := l_valor_parcela;
        l_record.datavencimento := l_data_vencimento;
        l_record.dataagendamento := l_data_vencimento;
        l_record.documento      := :P96_DOCUMENTO || '-' || to_char(i);
        
        INSERT INTO contasreceber values l_record;
        
       if l_intervalo = 30 then
            l_data_vencimento := add_months(l_data_vencimento, 1);
        else
            l_data_vencimento := l_data_vencimento + l_intervalo;
        end if;
    
    END LOOP;
    
    -- Corrigir o título original
    Update contasreceber set 
        valor = (l_valor_parcela + l_valor_parcela01),
        saldo = (l_valor_parcela + l_valor_parcela01),
        valortotal = :P96_VALOR
    where id = :P96_ID;
            
End;
