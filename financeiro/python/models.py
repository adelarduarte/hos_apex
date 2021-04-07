from sqlalchemy import (
    MetaData,
    Table,
    Column,
    Integer,
    Numeric,
    String,
    DateTime,
    LargeBinary,
    create_engine,
)

metadata = MetaData()

empresas = Table(
    "empresas",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("cnpj", String(20)),
    Column("razao_social", String(200)),
    Column("nome_fantasia", String(200)),
    Column("endereco", String(200)),
    Column("bairro", String(200)),
    Column("cep", String(20)),
    Column("cidade_id", Integer()),
    Column("estado_id", Integer()),
    Column("grupo_negocio_id", Integer()),
    Column("tipo_empresa_id", Integer()),
    Column("grupo_economico_id", Integer()),
    Column("rede_associativa_id", Integer()),
    Column("numero", String(20)),
    Column("complemento", String(100)),
    Column("telefone", String(20)),
    Column("email", String(200)),
)

cidades = Table(
    "cidades",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("estado_id", Integer()),
    Column("cidade", String(200)),
    Column("codigo_ibge", String(100)),
)

estados = Table(
    "estados",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("estado", String(200)),
    Column("uf", String(5)),
    Column("codigo_ibge", String(20)),
)


categorias_financeiras = Table(
    "categorias_financeiras",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("empresa_id", Integer()),
    Column("grupo_categoria_financeira_id", Integer()),
    Column("descricao", String(250)),
    Column("tipo_operacao", String(250)),
    Column("natureza", String(250)),
    Column("ativo", String(10)),
    Column("id_interno", Integer()),
)


contas_financeiras = Table(
    "contas_financeiras",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("empresa_id", Integer()),
    Column("tipo_conta_id", Integer()),
    Column("banco_id", Integer()),
    Column("agencia", String(50)),
    Column("digito_agencia", String(50)),
    Column("numero_conta", String(50)),
    Column("digito_conta", String(50)),
    Column("nome_conta", String(100)),
    Column("data_inicial_sistema", DateTime()),
    Column("saldo_inicial_sistema", Numeric(14, 2)),
    Column("data_inicial_banco", DateTime()),
    Column("saldo_inicial_banco", Numeric(14, 2)),
    Column("integrar_contabilidade", String(10)),
    Column("conta_contabil", String(10)),
    Column("id_interno", Integer()),
    Column("codigo_beneficiario", String(100)),
    Column("codigo_empresa", String(100)),
    Column("usar_para_cobranca", String(10)),
)


contas_fin_integracoes = Table(
    "contas_fin_integracoes",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("conta_financeira_id", Integer()),
    Column("codigo_externo", String(100)),
    Column("integrador", String(50)),
)


convenios_bancarios = Table(
    "convenios_bancarios",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("conta_financeira_id", Integer()),
    Column("nome", String(100)),
    Column("numero", String(100)),
    Column("carteira", String(20)),
    Column("especie", String(100)),
    Column("padrao_cnab", String(100)),
    Column("reiniciar_numero_remessa", String(10)),
    Column("registro_instantaneo", String(10)),
    Column("api_id", String(100)),
    Column("api_key", String(100)),
    Column("api_secret", String(100)),
    Column("codigo_estacao", String(20)),
    Column("cobranca_automatica", String(10)),
)


convenio_banc_integracoes = Table(
    "convenio_banc_integracoes",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("convenio_id", Integer()),
    Column("codigo_externo", String(100)),
    Column("integrador", String(50)),
)


bancos = Table(
    "bancos",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("nome", String(100)),
    Column("numero", String(20)),
    Column("empresa_id", Integer()),
)


clientes_integracoes = Table(
    "clientes_integracoes",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("cliente_id", Integer()),
    Column("codigo_externo", String(100)),
    Column("integrador", String(50)),
)


empresas_integracoes = Table(
    "empresas_integracoes",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("empresa_id", Integer()),
    Column("codigo_externo", String(100)),
    Column("integrador", String(50)),
)


notificacoes = Table(
    "notificacoes",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("data", DateTime()),
    Column("titulo", String(100)),
    Column("texto", String(1000)),
    Column("tipo", String(100)),
    Column("status", String(100)),
    Column("empresa_id", Integer()),
    Column("evento_id", Integer()),
)

eventos = Table(
    "eventos",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("event_code", String(300)),
    Column("username", String(300)),
    Column("data", DateTime()),
    Column("tipo", String(50)),
    Column("evento", String(100)),
    Column("historico", String(300)),
    Column("record_id", Integer()),
    Column("empresa_id", Integer()),
    Column("status", String(50)),
    Column("tentativas", Integer()),
    Column("limite_tentativas", Integer()),
    Column("valor", Numeric(14, 2)),
)

contas_receber = Table(
    "contas_receber",
    metadata,
    Column("id", Integer(), primary_key=True),
    Column("data_emissao", DateTime()),
    Column("data_vencimento", DateTime()),
    Column("data_agendamento", DateTime()),
    Column("empresa_id", Integer()),
    Column("cliente_id", Integer()),
    Column("status_id", Integer()),
    Column("periodicidade", Integer()),
    Column("recorrente", String(10)),
    Column("parcelado", String(10)),
    Column("numero_parcelas", Integer()),
    Column("parcela", Integer()),
    Column("valor", Numeric(14,2)),
    Column("saldo", Numeric(14,2)),
    Column("centro_custo_id", Integer()),
    Column("categoria_financeira_id", Integer()),
    Column("descricao", String(100)),
    Column("documento", String(50)),
    Column("intervalo_parcelas", Integer()),
    Column("documento_pai_id", Integer()),
    Column("documento_renegociacao_id", Integer()),
    Column("nota_saida_id", Integer()),
    Column("valor_total", Numeric(14,2)),
    Column("data_limite_recorrencia", DateTime()),
    Column("tipo_documento_id", Integer()),
    Column("cupom_id", Integer()),
    Column("conta_financeira_id", Integer()),
    Column("convenio_bancario_id", Integer()),
    Column("codigo_externo", String(100)),
    Column("protocolo_geracao_pdf", String(50)),
    Column("situacao_cobranca", String(50)),
    Column("protocolo_baixa_cobranca", String(50)),
)




