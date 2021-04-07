from models import (
    eventos,
    empresas,
    empresas_integracoes,
    contas_financeiras,
    contas_fin_integracoes,
    convenio_banc_integracoes,
    bancos,
    notificacoes,
    contas_receber,
)
from ssh_server import engine, conn
from sqlalchemy.sql import select, func
from sqlalchemy import update, delete
from sqlalchemy.sql import text
import decimal
import datetime
import json
import base64
import requests
import os
from decouple import config


l_empresa_id  = 0
l_evento_id   = 0
l_convenio_id = 0


# ------------------------------------------  Encoder para datas e decimais em json
def alchemyencoder(obj):
    """JSON encoder function for SQLAlchemy special classes."""
    if isinstance(obj, datetime.date):
        return obj.isoformat()

    elif isinstance(obj, decimal.Decimal):
        return float(obj)


# ------------------------------------------  Verificar Eventos
def consultar_boletos():
    s = (
        contas_receber.select()
        .with_only_columns(
            [
                contas_receber.c.id,
                contas_receber.c.empresa_id,
                contas_receber.c.cliente_id,
                contas_receber.c.conta_financeira_id,
                contas_receber.c.convenio_bancario_id,
                contas_receber.c.documento,
                contas_receber.c.data_emissao,
                contas_receber.c.data_vencimento,
                contas_receber.c.valor,
                contas_receber.c.codigo_externo,
                contas_receber.c.protocolo_baixa_cobranca,
            ]
        )
        .where(contas_receber.c.codigo_externo != None )
        .where(contas_receber.c.protocolo_baixa_cobranca != None)
    )

    results = conn.execute(s)

    # Necessário armazenar o retorno para outros usos.
    rv = results.fetchall()

    # use special handler for dates and decimals
    results_json = json.dumps([dict(r) for r in rv], default=alchemyencoder)

    results_qtd = len(rv)

    if results_qtd > 0:
        json_data = json.loads(results_json)
        return json_data
    else:
        return None


# ------------------------------------------  Preparar dados para consulta
def preparar_dados(row):

    # Buscar api como variável de ambiente
    api_token   = config('API_TOKEN')
    api_encoded = base64.b64encode(api_token.encode("utf-8"))
    api_key = str(api_encoded, "utf-8")

    t_cnpj = ""

    p_empresa_id = row.get("empresa_id")
    p_titulo_id = row.get("id")
    p_codigo_externo = row.get("codigo_externo")
    p_protocolo_baixa_cobranca = row.get("protocolo_baixa_cobranca")

    sql_empresa = text("select cnpj " 
        "from empresas " 
        "where id = :empresa_id "
        )

    result = conn.execute(sql_empresa, empresa_id=p_empresa_id)
    rec = result.fetchone()

    t_cnpj = rec.cnpj


    url = "https://homologacao.plugboleto.com.br/api/v1/boletos/baixa/lote/" + p_protocolo_baixa_cobranca

    myHeaders = {
        "Content-Type": "application/json",
        "cnpj-sh": "00115150000140",
        "token-sh": api_token,
        "cnpj-cedente": t_cnpj,
        "Accept": "application/json",
    }

    myBody = None

    response = requests.get(url, json=myBody, headers=myHeaders)

    if response.status_code == 200:
        # print(response.status_code)
        # print(response.text)
        dados = json.loads(response.text)

        # print(dados)
        for retorno in dados["titulos"]:
            l_id_integracao = retorno["idintegracao"]

            # salvar a situacao do boleto
            gravar_situacao_boleto(l_id_integracao)


    else:
        print("Erro:" + str(response.status_code))
        print(response.text)

        dados = json.loads(response.text)

        # -->> Tratar mensagem de erro
        #      inserir em notificações
        l_titulo_erro = 'Erro consultando cobrança'

        nova_notificacao = notificacoes.insert().values(
            titulo=l_titulo_erro,
            texto="Registro não encontrado",
            tipo="tecnospeed",
            status="Erro",
            empresa_id=p_empresa_id,
        )

        result = conn.execute(nova_notificacao)


# ------------------------------------------  Gravar situação da cobrança
def gravar_situacao_boleto(p_id_integracao):
    u = update(contas_receber).where(contas_receber.c.codigo_externo == p_id_integracao)
    u = u.values(
            situacao_cobranca = None,
            protocolo_baixa_cobranca = None,
            codigo_externo = None
        )

    result = conn.execute(u)

    if result.rowcount > 0:
        print(str(result.rowcount))  # Número de linhas afetadas pelo update
    else:
        print("Erro atualizando situação do boleto")



# ------------------------------------------  Início da verificação de eventos
json_data = consultar_boletos()

if json_data:
    for row in json_data:

        # print(row)
        preparar_dados(row)

    print("Consulta de Baixas de Boletos: Processo finalizado!")
else:
    print("Sem baixas de boletos para consultar.")





