from models import (
    eventos,
    empresas,
    empresas_integracoes,
    contas_financeiras,
    contas_fin_integracoes,
    convenio_banc_integracoes,
    bancos,
    notificacoes,
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
def verificar_eventos():
    s = (
        eventos.select()
        .with_only_columns(
            [
                eventos.c.id,
                eventos.c.event_code,
                eventos.c.evento,
                eventos.c.data,
                eventos.c.username,
                eventos.c.tipo,
                eventos.c.empresa_id,
            ]
        )
        .where(eventos.c.status == "Pendente")
        .where(eventos.c.evento == "NovoConvenio")
    )

    results = conn.execute(s)

    # Necessário armazenar o retorno para outros usos.
    rv = results.fetchall()

    # use special handler for dates and decimals
    results_json = json.dumps([dict(r) for r in rv], default=alchemyencoder)
    # print(results_json)

    results_qtd = len(rv)

    if results_qtd > 0:
        json_data = json.loads(results_json)
        return json_data
    else:
        return None


# ------------------------------------------  Criar evento processando
def criar_evento_processando(json_data):

    for key, value in json_data.items():
        if key == "empresa_id":
            global l_empresa_id
            l_empresa_id = value

        if key == "id":
            global l_evento_id
            l_evento_id = value

            u = update(eventos).where(eventos.c.id == l_evento_id)
            u = u.values(
                status="Processando", historico="Processando criação de novo convênio"
            )

            result = conn.execute(u)

            if result.rowcount > 0:
                print(str(result.rowcount))  # Número de linhas afetadas pelo update
            else:
                print("Erro atualizando status do evento")


# ------------------------------------------  Criar evento ok
def criar_evento_ok(row):

    l_novo_evento = json.loads(row)

    # Final do processamento do evento
    u = update(eventos).where(eventos.c.id == l_evento_id)
    u = u.values(status="Finalizado", historico="Convênio criado com sucesso")

    result = conn.execute(u)

    if result.rowcount > 0:
        print(str(result.rowcount))  # Número de linhas afetadas pelo update
    else:
        print("Erro atualizando status do evento")

    # Evento para o próximo microservice
    # -- Nenhum, nesse caso...

# ------------------------------------------  Criar novo convênio
def criar_novo_convenio(row):

    # Buscar registro para obter a api
    # api_token = "5f67cfd82864d50690961714d9dbaa23"
    api_token = config('API_TOKEN')
    api_encoded = base64.b64encode(api_token.encode("utf-8"))
    api_key = str(api_encoded, "utf-8")

    t_cnpj = ""

    p_empresa_id = row.get("empresa_id")

    sql_empresa = text("select cnpj " 
        "from empresas " 
        "where id = :empresa_id "
        )

    result = conn.execute(sql_empresa, empresa_id=p_empresa_id)
    rec = result.fetchone()

    # print(rec.cnpj)

    t_cnpj = rec.cnpj

    sql_conta = text(
        "select cc.codigo_externo, c.id, c.conta_financeira_id, c.nome, c.numero, "
        "c.carteira, c.especie, c.padrao_cnab, c.reiniciar_numero_remessa, "
        "c.registro_instantaneo, c.api_id, c.api_key, "
        "c.api_secret, c.codigo_estacao "
        "from convenios_bancarios c, contas_fin_integracoes cc "
        "where c.conta_financeira_id = cc.conta_financeira_id "
    )
    result = conn.execute(sql_conta)
    rec = result.fetchall()

    for row in rec:
        t_id                    = row.id
        t_numero_convenio       = row.numero
        t_descricao             = row.nome
        t_carteira              = row.carteira
        t_especie               = row.especie
        t_padrao_cnab           = row.padrao_cnab
        t_reiniciar_diariamente = row.reiniciar_numero_remessa
        t_conta                 = row.codigo_externo
        t_api_id                = row.api_id
        t_api_key               = row.api_key
        t_api_secret            = row.api_secret
        t_codigo_estacao        = row.codigo_estacao

        global l_convenio_id
        l_convenio_id = t_id

        url = "https://homologacao.plugboleto.com.br/api/v1/cedentes/contas/convenios"

        myHeaders = {
            "Content-Type": "application/json",
            "cnpj-sh": "00115150000140",
            "token-sh": api_token,
            "cnpj-cedente": t_cnpj,
            "Accept": "application/json",
        }

        myBody = {
          "ConvenioNumero": t_numero_convenio,
          "ConvenioDescricao": t_descricao,
          "ConvenioCarteira": t_carteira,
          "ConvenioEspecie": t_especie,
          "ConvenioPadraoCNAB": t_padrao_cnab,
          "ConvenioNumeroRemessa": "1",
          "ConvenioDensidadeRemessa": "1600",
          "ConvenioRegistroInstantaneo": True,
          "ConvenioApiId": t_api_id,
          "ConvenioApiKey": t_api_key,
          "ConvenioApiSecret": t_api_secret,
          "ConvenioEstacao": t_codigo_estacao,
          "ConvenioNossoNumeroBanco": False,
          "ConvenioReiniciarDiariamente": True,
          "Conta": t_conta
        }

        # print(myBody)
        # print("------------------")

        response = requests.post(url, json=myBody, headers=myHeaders)

        if response.status_code == 200:
            print(response.status_code)
            print(response.text)

            dados = json.loads(response.text)

            print(dados)

            nova_notificacao = notificacoes.insert().values(
                titulo="Processo Concluído",
                texto="Convênio cadastrado com sucesso.",
                tipo="tecnospeed",
                status="Sucesso",
                empresa_id=l_empresa_id,
            )

            result = conn.execute(nova_notificacao)

            gravar_codigo_externo_convenio(dados)

        else:
            print("Erro:" + str(response.status_code))
            print(response.text)

            dados = json.loads(response.text)

            # -->> Tratar mensagem de erro
            #      inserir em notificações
            l_titulo_erro = dados.get("_mensagem")

            for erro in dados["_dados"]:

                nova_notificacao = notificacoes.insert().values(
                    titulo=l_titulo_erro,
                    texto=erro["_campo"] + ": " + erro["_erro"],
                    tipo="tecnospeed",
                    status="Erro",
                    empresa_id=l_empresa_id,
                    evento_id=l_evento_id,
                )

                result = conn.execute(nova_notificacao)



# ------------------------------------------  Gravar chaves retornadas da API
def gravar_codigo_externo_convenio(p_dados):
    l_convenio_id_externo = p_dados.get("_dados").get("id")

    nova_integracao = convenio_banc_integracoes.insert().values(
        convenio_id=l_convenio_id,
        codigo_externo=l_convenio_id_externo,
        integrador="tecnospeed",
    )
    result = conn.execute(nova_integracao)


# ------------------------------------------  Início da verificação de eventos
json_data = verificar_eventos()

if json_data:
    for row in json_data:

        # print(row)

        criar_evento_processando(row)

        criar_novo_convenio(row)

        l_novo_evento = json.dumps(row)

        criar_evento_ok(l_novo_evento)

    print("Criação de Convênios: Processo finalizado!")
else:
    print("Nenhum convênio a ser criado.")
    





