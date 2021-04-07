create or replace PROCEDURE "EVENTO_NOVO_CEDENTE" (
	p_empresa_id	IN	number,
	p_evento		IN	varchar2
	)
is
	l_eventos_record	eventos%rowtype;
	l_eventos_qtd		number := 0;
Begin
	If p_evento = 'NovoCedente' then


		-->> Verificar duplicidade de evento
		select count(id)
		into l_eventos_qtd
		from eventos
		where empresa_id = p_empresa_id
		and evento = p_evento;

		if l_eventos_qtd = 0 or l_eventos_qtd is null then
	        -->> Criar pedido de nova cedente no parceiro
			l_eventos_record.id                := null;                                        
			l_eventos_record.event_code        := null;                                
			l_eventos_record.username          := null;                                  
			l_eventos_record.data              := null;                                      
			l_eventos_record.tipo              := null;                                      
			l_eventos_record.evento            := p_evento;                                
			l_eventos_record.historico         := 'Solicitado criação de novo cedente.';
			l_eventos_record.record_id         := null;                                 
			l_eventos_record.empresa_id        := p_empresa_id;                         
			l_eventos_record.status            := null;                                    
			l_eventos_record.tentativas        := 0;                                   
			l_eventos_record.limite_tentativas := 15;                           
			l_eventos_record.alterado_em       := null;                               
			l_eventos_record.valor             := 0;                                        

			insert into eventos values l_eventos_record;
		end if;

	end if;
End;

