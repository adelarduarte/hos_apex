create or replace function "CADASTRAR_CARTAO" (
        p_cartao_nome       IN varchar2,
        p_cartao_operacao   IN varchar2,
        p_cartao_bandeira   IN varchar2,
        p_cartao_adquirente IN varchar2,
        p_empresa_id		IN number,
        p_parcelas			IN number
	) return number
IS
	l_administradora_id				number;
	l_bandeira_id					number;
	l_cartao_id						number;

	l_cartoes_rec	 				cartoes%rowtype;
	l_cartoes_bandeiras_rec			cartoes_bandeiras%rowtype;
	l_cartoes_parcelas_rec  		cartoes_parcelas%rowtype;
	l_cartoes_administradoras_rec	cartoes_administradoras%rowtype;

	l_operacao 						varchar2(20);
Begin
	-->> Criar administradora(adquirente), se não existir
	Begin
		select id
		into l_administradora_id
		from cartoes_administradoras
		where lower(nome) = lower(p_cartao_adquirente)
		and empresa_id = p_empresa_id;
	Exception
		when no_data_found then
			l_cartoes_administradoras_rec.id := null;
			l_cartoes_administradoras_rec.nome := p_cartao_adquirente;
			l_cartoes_administradoras_rec.empresa_id := p_empresa_id;
			l_cartoes_administradoras_rec.data_adesao := sysdate;

			insert into cartoes_administradoras values l_cartoes_administradoras_rec returning id into l_administradora_id;
	End;			

	-->> Criar bandeira, se não existir
	Begin
		select id
		into l_bandeira_id
		from cartoes_bandeiras
		where lower(descricao) = lower(p_cartao_bandeira)
		and empresa_id = p_empresa_id;
	Exception
		when no_data_found then
			l_cartoes_bandeiras_rec.id := null;
			l_cartoes_bandeiras_rec.descricao := p_cartao_bandeira;
			l_cartoes_bandeiras_rec.empresa_id := p_empresa_id;

			insert into cartoes_bandeiras values l_cartoes_bandeiras_rec returning id into l_bandeira_id;
	End;

	-->> Cadastrar cartão
	if trim(p_cartao_operacao) = 'CREDITO' then
		l_operacao := 'Crédito';
	else
		l_operacao := 'Débito';
	end if;

	l_cartoes_rec.id                       := null;
	l_cartoes_rec.descricao                := p_cartao_nome;
	l_cartoes_rec.cartao_administradora_id := l_administradora_id;
	l_cartoes_rec.tipo_operacao            := l_operacao;
	l_cartoes_rec.empresa_id               := p_empresa_id;
	l_cartoes_rec.cartao_bandeira_id       := l_bandeira_id;

	insert into cartoes values l_cartoes_rec returning id into l_cartao_id;


	-->> Cadastrar parcelas
	l_cartoes_parcelas_rec.id               := null;
	l_cartoes_parcelas_rec.cartao_id        := l_cartao_id;
	l_cartoes_parcelas_rec.empresa_id       := p_empresa_id;
	l_cartoes_parcelas_rec.parcela_inicial  := 1;
	l_cartoes_parcelas_rec.parcela_final    := 12;
	l_cartoes_parcelas_rec.dias_recebimento := 30;
	l_cartoes_parcelas_rec.taxa_fixa        := 0;
	l_cartoes_parcelas_rec.taxa_parcela     := 0;
	l_cartoes_parcelas_rec.ativo            := 'Ativo';

	insert into cartoes_parcelas values l_cartoes_parcelas_rec;


	return l_cartao_id;


End;

