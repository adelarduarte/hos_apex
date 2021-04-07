create or replace PROCEDURE "CRIAR_DADOS_INICIAIS" (
		p_empresa_id		IN 	number
	)
IS
	l_Receitas_id				number;
    l_Receitas_D_id             number;
	l_Receitas_N_id				number;
    l_Despesas_D_id             number;
    l_Despesas_N_id             number;
	l_Custos_id 				number;
	l_Despesas_id				number;
	l_Deducoes_Receita_id		number;
	l_Impostos_faturamento_id	number;
    l_Devolucoes_Vendas_id      number;
    l_Cancelamentos_Vendas_id   number;
	l_Impostos_lucro_id			number;
	l_Investimentos_id			number;
	l_Financiamentos_id			number;
	l_Transferências_id			number;
	l_grupo_centro_id			number;
	l_tipo_conta_caixa_id		number;
    l_grupo_negocios_id        number;
    l_grupo_economico_id        number;
    l_report_id                 number;
    l_categoria_vendas_padrao_id number;
    l_compras_mercadoria_id    number;
    l_centro_custo_id         number;
    
    
Begin
	-->> Criar formas de pagamento
	insert into formas_pagamentos_financeiros(
	 	descricao,
	 	cheque,
	 	pedir_numero,
	 	pedir_vencimento,
	 	acao,
	 	cartao,
	 	empresa_id,
	    id_interno
	)
	values(
		'Cartão',
		'Não',
		'Não',
		'Sim',
		'Liquidar Título',
		'Sim',
		p_empresa_id,
	    2
	);

	insert into formas_pagamentos_financeiros(
	 	descricao,
	 	cheque,
	 	pedir_numero,
	 	pedir_vencimento,
	 	acao,
	 	cartao,
	 	empresa_id,
	    id_interno
	)
	values(
		'Dinheiro',
		'Não',
		'Não',
		'Não',
		'Liquidar Título',
		'Não',
		p_empresa_id,
	    1
	);

	insert into formas_pagamentos_financeiros(
	 	descricao,
	 	cheque,
	 	pedir_numero,
	 	pedir_vencimento,
	 	acao,
	 	cartao,
	 	empresa_id,
	    id_interno
	)
	values(
		'Cheque',
		'Sim',
		'Não',
		'Não',
		'Liquidar Título',
		'Sim',
		p_empresa_id,
	    3
	);


	-->> Criar grupos de categorias
	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Receitas Operacionais', 366, p_empresa_id) returning id into l_Receitas_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Despesas Operacionais', 367, p_empresa_id) returning id into l_Despesas_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Custos', 368, p_empresa_id) returning id into l_Custos_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Impostos S/ Faturamento', 369, p_empresa_id) returning id into l_Impostos_faturamento_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Impostos S/ Lucro', 369, p_empresa_id) returning id into l_Impostos_lucro_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Investimentos', 370, p_empresa_id) returning id into l_Investimentos_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Financiamentos', 371, p_empresa_id) returning id into l_Financiamentos_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Transferências', 372, p_empresa_id) returning id into l_Transferências_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Receitas Não Operacionais', 373, p_empresa_id) returning id into l_Receitas_N_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Deduções de Receitas', 374, p_empresa_id) returning id into l_Receitas_D_id;

	insert into grupos_categorias_financeiras(descricao, id_interno, empresa_id)
		values('Despesas Não Operacionais', 375, p_empresa_id) returning id into l_Despesas_N_id;



	-->> Criar categorias de resultados
	-->> Grupo Receitas Operacionais
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Receitas de Serviços', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',366);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Receitas Financeiras', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',367);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Venda a Vista', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',368);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Venda a Prazo', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',369);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Venda Convênio', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',370);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Venda Cartão', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',371);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Venda Cheque', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',373);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza, id_interno)
	values('Receitas com Vendas', l_Receitas_id, p_empresa_id, 'Variável', 'Recebimento',374) returning id into l_categoria_vendas_padrao_id;


	-->> Grupo Custos
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Materiais p/ uso na Prest. Serviços', l_Custos_id, p_empresa_id, 'Variável', 'Pagamento',368);

	-->> Grupo Despesas Operacionais
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Água e Esgoto ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',369);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Aluguel e Condomínio ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',370);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Energia ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',371);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Despesas Financeiras ', l_Despesas_id, p_empresa_id, 'Variável', 'Pagamento',372);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Tarifas Bancárias ', l_Despesas_id, p_empresa_id, 'Variável', 'Pagamento',373);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Salários ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',374);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Rescisões ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',375);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Férias ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',376);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('13o Salário ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',377);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('FGTS ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',378);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('INSS ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',379);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Serviços Prestados por Terceiros ', l_Despesas_id, p_empresa_id, 'Fixa', 'Pagamento',380);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Taxas e Contribuições ', l_Despesas_id, p_empresa_id, 'Variável', 'Pagamento',381);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Compras de Mercadoria ', l_Despesas_id, p_empresa_id, 'Variável', 'Pagamento',382) returning id into l_compras_mercadoria_id;

	-->> Grupo Deduções de Receitas
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Descontos em vendas ', l_Deducoes_Receita_id, p_empresa_id, 'Variável', 'Pagamento',383);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Devoluções de Vendas ', l_Deducoes_Receita_id, p_empresa_id, 'Variável', 'Pagamento',384) returning ID into l_Devolucoes_vendas_id;
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Cancelamentos de Vendas ', l_Deducoes_Receita_id, p_empresa_id, 'Variável', 'Pagamento',402) returning ID into l_Cancelamentos_vendas_id;

	-->> Grupo Impostos S/ Faturamento
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Simples Nacional ', l_Impostos_faturamento_id, p_empresa_id, 'Variável', 'Pagamento',385);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('ISS', l_Impostos_faturamento_id, p_empresa_id, 'Variável', 'Pagamento',386);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('PIS', l_Impostos_faturamento_id, p_empresa_id, 'Variável', 'Pagamento',387);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('COFINS', l_Impostos_faturamento_id, p_empresa_id, 'Variável', 'Pagamento',388);

	-->> Grupo Impostos S/ Lucro
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Imposto de Renda', l_Impostos_lucro_id, p_empresa_id, 'Variável', 'Pagamento',389);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Contribuição Social', l_Impostos_lucro_id, p_empresa_id, 'Variável', 'Pagamento',390);

	-->> Grupo Investimentos
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Equipamentos', l_Investimentos_id, p_empresa_id, 'Variável', 'Pagamento',391);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Mobília', l_Investimentos_id, p_empresa_id, 'Variável', 'Pagamento',392);

	-->> Grupo Financiamentos
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Aporte de Capital', l_Financiamentos_id, p_empresa_id, 'Variável', 'Recebimento',393);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Empréstimos Recebidos', l_Financiamentos_id, p_empresa_id, 'Variável', 'Recebimento',394);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Pagamento de Empréstimos', l_Financiamentos_id, p_empresa_id, 'Variável', 'Pagamento',395);

	-->> Grupo Transferências
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Saques', l_Transferências_id, p_empresa_id, 'Variável', 'Transferência',396);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Depósitos', l_Transferências_id, p_empresa_id, 'Variável', 'Transferência',397);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Transferência entre Contas', l_Transferências_id, p_empresa_id, 'Variável', 'Transferência',398);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Aplicações Financeiras', l_Transferências_id, p_empresa_id, 'Variável', 'Transferência',399);
	insert into categorias_financeiras(descricao, grupo_categoria_financeira_id, empresa_id, tipo_operacao, natureza,id_interno)
	values('Resgates de Aplicações', l_Transferências_id, p_empresa_id, 'Variável', 'Transferência',400);

	UPDATE CATEGORIAS_FINANCEIRAS SET ATIVO = 'Sim' where empresa_id = p_empresa_id;


	-->> Criar grupos de centros de resultados
	--insert into gruposcentroscustos(descricao, empresa_id)
	--values('Único', p_empresa_id) returning id into l_grupo_centro_id;

	-->> Criar centros de resultados
	insert into centros_custos(descricao, ativo, empresa_id)
	values('Único', 'Ativo', p_empresa_id) returning id into l_centro_custo_id;

	-->> Atualiza Preferencia da empresa
	update empresas_preferencias set categoria_financeira_id = l_categoria_vendas_padrao_id,
	                            categoria_fornecedor_id = l_compras_mercadoria_id,
	                            centro_custo_fornecedor_id = l_centro_custo_id,
	                            centro_custos_id = l_centro_custo_id,
	                            categoria_devolucao_id = l_devolucoes_vendas_id,
	                            categoria_cancelamento_id = l_cancelamentos_vendas_id
	                            where empresa_id = p_empresa_id;

	-->> Criar tipos de contas bancárias
	insert into tipos_contas_financeiras(nome, mostrar_dashboard, mostrar_fluxo_caixa, empresa_id)
	values('Caixa', 'Sim', 'Sim', p_empresa_id) returning id into l_tipo_conta_caixa_id;
	insert into tipos_contas_financeiras(nome, mostrar_dashboard, mostrar_fluxo_caixa, empresa_id)
	values('Banco', 'Sim', 'Sim', p_empresa_id);
	insert into tipos_contas_financeiras(nome, mostrar_dashboard, mostrar_fluxo_caixa, empresa_id)
	values('Adiantamentos', 'Não', 'Não', p_empresa_id);
	insert into tipos_contas_financeiras(nome, mostrar_dashboard, mostrar_fluxo_caixa, empresa_id)
	values('Operadora de Cartão', 'Não', 'Não', p_empresa_id);

	-->> Criar bancos
	insert into bancos(numero, nome, empresa_id)
	values('237', 'Banco Bradesco S.A.', p_empresa_id);
	insert into bancos(numero, nome, empresa_id)
	values('756', 'Banco Cooperativo do Brasil S.A. - Sicoob', p_empresa_id);
	insert into bancos(numero, nome, empresa_id)
	values('001', 'Banco do Brasil S.A.', p_empresa_id);
	insert into bancos(numero, nome, empresa_id)
	values('341', 'Banco Itaú S.A.', p_empresa_id);
	insert into bancos(numero, nome, empresa_id)
	values('033', 'Banco Santander(Brasil) S.A.', p_empresa_id);
	insert into bancos(numero, nome, empresa_id)
	values('104', 'Caixa Econômica Federal', p_empresa_id);

	-->> Criar contas financeiras
	insert into contas_financeiras(
			tipo_conta_id,
			nome_conta,
			data_inicial_sistema,
			saldo_inicial_sistema,
			data_inicial_banco,
			saldo_inicial_banco,
			integrar_contabilidade,
			empresa_id,
			id_interno
		)
	values(
			l_tipo_conta_caixa_id,
			'Caixa',
			sysdate,
			0,
			sysdate,
			0,
			'Sim',
			p_empresa_id,
			1
		);

	-->> Criar Permissões do Perfil administrador
	insert into perfis_autorizacoes (perfil_id,autorizacao_id,empresa_id)
	select 1,id,p_empresa_id from autorizacoes;


	-->> Criar clientes
	insert into clientes(nome, tipo_pessoa, empresa_id, id_interno,ativo)
	values('Consumidor Final', 'Fisíca', p_empresa_id, 1,'Sim');

	-->> Criar fornecedores
	insert into fornecedores(nome,nome_fantasia, tipo_pessoa, empresa_id, id_interno,ativo,tipo_fornecedor)
	values('Fornecedor Padrão','Fornecedor Padrão', 'Jurídica', p_empresa_id, 2,'Sim',23);


	-->> Criar Relatórios DRE/DLP/DFC

	-->> Cabeçalho DLP
	INSERT INTO TEMPLATE_REPORT (NOME,DESCRICAO,EMPRESA_ID) VALUES ('DLP - Demonstrativo de Lucros e Perdas','DLP - Demonstrativo de Lucros e Perdas',p_empresa_id) RETURNING id INTO l_report_id;
	-->> Linhas DLP
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,5,5,'Vendas Brutas',5,'','',l_Receitas_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,10,10,'Categorias de vendas Brutas',6,'','',l_Receitas_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,15,15,'Descontos Concedidos na Venda',5,'','',l_Receitas_D_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,20,20,'Categoria dos Descontos',6,'','',l_Receitas_D_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,25,25,'Vendas Liquidas (=)',7,'[5] - [15]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,30,30,'CMV (-)',5,'','',l_Receitas_D_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,35,35,'Categoria de CMV',6,'','',l_Receitas_D_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,40,40,'Lucro Bruto (=)',7,'[25] - [30]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,45,45,'Despesas Variáveis (-)',2,'','',l_Despesas_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,50,50,'Categoria de Despesas Variaveis',4,'','',l_Despesas_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,55,55,'Margem de Contribuição (=)',7,'[40] + [45]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,60,60,'Despesas Fixas (-)',1,'','',l_Despesas_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,65,65,'Categorias de Despesas fixas',3,'','',l_Despesas_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,70,70,'Lucro Operacional (=)',7,'[55] + [60]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,75,75,'Receitas Não Operacionais (+)',5,'','',l_Receitas_N_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,80,80,'Despesas Não Operacionais (-)',5,'','',l_Despesas_N_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,85,85,'Lucro Líquido (=)',7,'[70] + [75] - [80]','','','Negrito');

	--Cabeçalho DFC
	INSERT INTO TEMPLATE_REPORT (NOME,DESCRICAO,EMPRESA_ID) VALUES ('DFC - Demonstrativo de Fluxo de Caixa','DFC - Demonstrativo de Fluxo de Caixa',p_empresa_id) RETURNING id INTO l_report_id;
	--Linhas DFC
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,5,5,'Receita Líquida Operacional (+)',5,'','',l_Receitas_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,10,10,'Categoria de Receita Líquida Operacional',6,'','',l_Receitas_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,15,15,'Fornecedores Pagos Efetivamente no Período',2,'','',l_Custos_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,20,20,'Lucro Bruto (=)',7,'[5] + [15]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,25,25,'Despesas Variáveis',2,'','',l_Despesas_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,30,30,'Categoria de Despesas Variáveis',4,'','',l_Despesas_N_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,35,35,'Margem de Contribuição (=)',7,'[20] + [25]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,40,40,'Despesas Fixas (-)',1,'','',l_Custos_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,45,45,'Categorias de Despesas Fixas',3,'','',l_Custos_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,50,50,'Lucro Operacional (=)',7,'[35] - [40]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,55,55,'Receitas Não Operacionais',5,'','',l_Receitas_N_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,60,60,'Despesas Não Operacionais',5,'','',l_Despesas_N_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,65,65,'Lucro Líquido (=)',7,'[50] + [55] - [60]','','','Negrito');

	--Cabeçalho DRE
	INSERT INTO TEMPLATE_REPORT (NOME,DESCRICAO,EMPRESA_ID) VALUES ('DRE - Demonstrativo de Resultados Econômico','DRE - Demonstrativo de Resultados Econômico',p_empresa_id) RETURNING id INTO l_report_id;
	--Linhas DRE
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,5,5,'Receitas (+)',5,'','',l_Receitas_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,15,15,'Deduções (-)',5,'','',l_Receitas_D_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,20,20,'Deduções de Receita Bruta',6,'','',l_Receitas_D_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,25,25,'Receita Operacional Liquida (=)',7,'[5] - [15]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,35,35,'Custos Gerais',6,'','',l_Custos_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,30,30,'Custos (-)',5,'','',l_Custos_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,40,40,'Lucro (Prejuízo) Bruto (=)',7,'[25] + [30]','','','Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,10,10,'Receitas Operacionais',6,'','',l_Receitas_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,45,45,'Despesas Operacionais (-)',5,'','',l_Despesas_id,'Negrito');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,50,50,'Despesas Operacionais',6,'','',l_Despesas_id,'Normal');
	INSERT INTO TEMPLATE_REPORT_LINES (TEMPLATE_REPORT_ID ,ORDEM,CODIGO,NOME,TIPO,FORMULA,VALOR_FIXO,GRUPO_CATEGORIA_FINANCEIRA_ID,FONTE) VALUES (l_report_id,55,55,'Lucro (Prejuízo) Operacional (=)',7,'[40] + [45]','','','Negrito');


	-->> Insere Sequências Padrões para N de Documento Automático  Contas a Pagar/ Contas a Receber
	INSERT INTO SEQUENCIAS_GERAIS (EMPRESA_ID,DESCRICAO,VALOR)  VALUES (p_empresa_id,'Contas a Pagar',0);
	INSERT INTO SEQUENCIAS_GERAIS (EMPRESA_ID,DESCRICAO,VALOR)  VALUES (p_empresa_id,'Contas a Receber',0);
       
End;

