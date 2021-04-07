from models import eventos, empresas, cidades, empresas_integracoes, notificacoes
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


l_empresa_id = 0
l_evento_id = 0


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
        .where(eventos.c.evento == "NovoCedente")
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
                status="Processando", historico="Processando criação de novo cedente"
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
    u = u.values(status="Finalizado", historico="Cedente criado com sucesso")

    result = conn.execute(u)

    if result.rowcount > 0:
        print(str(result.rowcount))  # Número de linhas afetadas pelo update
    else:
        print("Erro atualizando status do evento")

    # Evento para o próximo microservice
    novo_evento = eventos.insert().values(
        username="MS Novas Contas",
        tipo=l_novo_evento.get("tipo"),
        evento="NovaConta",
        historico="Criar conta bancária",
        empresa_id=l_novo_evento.get("empresa_id"),
        status="Pendente",
    )
    result = conn.execute(novo_evento)


# ------------------------------------------  Gravar chaves retornadas da API
def gravar_codigo_externo_cedente(p_dados):
    l_cedente_id = p_dados.get("_dados").get("id")

    nova_integracao = empresas_integracoes.insert().values(
        empresa_id=l_empresa_id,
        codigo_externo=l_cedente_id,
        integrador="tecnospeed",
    )
    result = conn.execute(nova_integracao)


# ------------------------------------------  Criar novo cedente
def criar_novo_cedente(row):

    # Buscar registro para obter a api
    # api_token   = "5f67cfd82864d50690961714d9dbaa23"

    # Buscar como variável de ambiente
    api_token   = config('API_TOKEN')
    api_encoded = base64.b64encode(api_token.encode("utf-8"))
    api_key     = str(api_encoded, "utf-8")

    t_razao_social = ""
    t_fantasia     = ""
    t_cnpj         = ""
    t_endereco     = ""
    t_numero       = ""
    t_complemento  = ""
    t_bairro       = ""
    t_cep          = ""
    t_codigo_ibge  = ""
    t_telefone     = ""
    t_email        = ""

    p_empresa_id = row.get("empresa_id")

    sql = text(
        "select e.razao_social, e.nome_fantasia, e.cnpj, "
        "e.endereco, e.numero, e.complemento, "
        "e.bairro, e.cep, c.codigo_ibge, "
        "e.telefone, e.email "
        "from empresas e, cidades c "
        "where e.id = :empresa_id "
        "and c.id = e.cidade_id "
    )

    result = conn.execute(sql, empresa_id=p_empresa_id)
    rec = result.fetchall()

    # print(rec)

    for row in rec:
        t_razao_social = row[0]
        t_fantasia     = row[1]
        t_cnpj         = row[2]
        t_endereco     = row[3]
        t_numero       = row[4]
        t_complemento  = row[5]
        t_bairro       = row[6]
        t_cep          = row[7]
        t_codigo_ibge  = row[8]
        t_telefone     = row[9]
        t_email        = row[10]

        url = "http://homologacao.plugboleto.com.br/api/v1/cedentes"

        myHeaders = {
            "Content-Type": "application/json",
            "cnpj-sh": "00115150000140",
            "token-sh": api_token,
            "Accept": "application/json",
        }

        myBody = {
            "CedenteRazaoSocial": t_razao_social,
            "CedenteNomeFantasia": t_fantasia,
            "CedenteCPFCNPJ": t_cnpj,
            "CedenteEnderecoLogradouro": t_endereco,
            "CedenteEnderecoNumero": t_numero,
            "CedenteEnderecoComplemento": t_complemento,
            "CedenteEnderecoBairro": t_bairro,
            "CedenteEnderecoCEP": t_cep,
            "CedenteEnderecoCidadeIBGE": t_codigo_ibge,
            "CedenteTelefone": t_telefone,
            "CedenteEmail": t_email,
        }

        # print(myBody)

        response = requests.post(url, json=myBody, headers=myHeaders)

        if response.status_code == 200:
            print(response.status_code)
            print(response.text)

            dados = json.loads(response.text)

            print(dados)

            nova_notificacao = notificacoes.insert().values(
                titulo="Processo Concluído",
                texto="Cedente cadastrado com sucesso.",
                tipo="tecnospeed",
                status="Sucesso",
                empresa_id=l_empresa_id,
            )

            result = conn.execute(nova_notificacao)

            criar_webhook(t_cnpj)

            criar_eventos_notificacoes(t_cnpj)

            return dados

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

            return None



def criar_webhook(p_cnpj):

        # api_token   = "5f67cfd82864d50690961714d9dbaa23"
        api_token   = config('API_TOKEN')



        url = "http://homologacao.plugboleto.com.br/api/v1/webhooks"

        myHeaders = {
            "Content-Type": "application/json",
            "cnpj-sh": "00115150000140",
            "token-sh": api_token,
            "cnpj-cedente": p_cnpj,
            "Accept": "application/json",
        }

        myBody = {
             "ativo": True,
             "url": "http://dev.hos.com.br:8080/ords/hos/financas/boletos/",
             "eventos": {
                "registrou": False,
                "liquidou": True,
                "baixou": True,
                "alterou": False,
                "rejeitou": False
             },
             "headers": {
               "cnpj_cedente": p_cnpj
             }
        }


        response = requests.post(url, json=myBody, headers=myHeaders)


        if response.status_code == 200:
            dados_webhook = json.loads(response.text)

            nova_notificacao = notificacoes.insert().values(
                titulo="Processo Concluído",
                texto="Webhook cadastrado com sucesso.",
                tipo="tecnospeed",
                status="Sucesso",
                empresa_id=l_empresa_id,
            )

            result = conn.execute(nova_notificacao)

        else:
            dados_webhook = json.loads(response.text)

            l_titulo_erro = dados_webhook.get("_mensagem")

            for erro in dados_webhook["_dados"]:

                nova_notificacao = notificacoes.insert().values(
                    titulo     = l_titulo_erro,
                    texto      = erro["_campo"] + ": " + erro["_erro"],
                    tipo       = "tecnospeed",
                    status     = "Erro",
                    empresa_id = l_empresa_id,
                    evento_id  = l_evento_id,
                )

                result = conn.execute(nova_notificacao)


def criar_eventos_notificacoes(p_cnpj):
        #api_token   = "5f67cfd82864d50690961714d9dbaa23"
        api_token   = config('API_TOKEN')


        url = "http://homologacao.plugboleto.com.br/api/v1/notificacoes/agendamentos"

        myHeaders = {
            "Content-Type": "application/json",
            "cnpj-sh": "00115150000140",
            "token-sh": api_token,
            "cnpj-cedente": p_cnpj,
            "Accept": "application/json",
        }

        l_10_dias_antes = 10
        l_2_dias_antes = 2
        l_2_dias_depois = 2
        l_5_dias_depois = 5

        criar_notificacao(url, myHeaders, l_10_dias_antes, 0, 'Antes')
        criar_notificacao(url, myHeaders, l_2_dias_antes, 0, 'Antes')
        criar_notificacao(url, myHeaders, 0, l_2_dias_depois, 'Depois')
        criar_notificacao(url, myHeaders, 0, l_5_dias_depois, 'Depois')


def criar_notificacao(p_url, p_headers, p_dias_antes, p_dias_depois, p_quando):

        if p_quando == 'Antes':
            myBody = {
                "nome":"Agendamento " + str(p_dias_antes) + " antes do vencimento",
                "tipo":"email",
                "quando":"-" + str(p_dias_antes),
                "assunto":"Link para pagamento",
                "mensagem":"Prezado(a) ${SacadoNome}. Segue link para pagamento do seu boleto. ${linkBoleto}",
                "dias_para_vencer": p_dias_antes
            }
        else:
            myBody = {
                "nome":"Agendamento " + str(p_dias_depois) + " dias após o vencimento",
                "tipo":"email",
                "quando": str(p_dias_depois),
                "assunto":"Boleto vencido",
                "mensagem":"Prezado(a) ${SacadoNome}. Segue link para pagamento do seu boleto vencido em ${TituloDataVencimento}. ${linkBoleto}",
                "dias_para_vencer": p_dias_depois
            }

        response = requests.post(p_url, json=myBody, headers=p_headers)

        if response.status_code == 200:
            nova_notificacao = notificacoes.insert().values(
                titulo     = "Notificação de Agendamento",
                texto      = "Notificação de agendamento criada com sucesso!",
                tipo       = "tecnospeed",
                status     = "Sucesso",
                empresa_id = l_empresa_id,
                evento_id  = l_evento_id,
            )

            result = conn.execute(nova_notificacao)

        else:
            dados_webhook = json.loads(response.text)

            l_titulo_erro = dados_webhook.get("_mensagem")

            for erro in dados_webhook["_dados"]:

                nova_notificacao = notificacoes.insert().values(
                    titulo     = l_titulo_erro,
                    texto      = erro["_campo"] + ": " + erro["_erro"],
                    tipo       = "tecnospeed",
                    status     = "Erro",
                    empresa_id = l_empresa_id,
                    evento_id  = l_evento_id,
                )

                result = conn.execute(nova_notificacao)


# ------------------------------------------  Início da verificação de eventos
json_data = verificar_eventos()

if json_data:
    for row in json_data:

        # print(row)

        criar_evento_processando(row)

        keys_nova_conta = criar_novo_cedente(row)

        if keys_nova_conta:
            gravar_codigo_externo_cedente(keys_nova_conta)

            l_novo_evento = json.dumps(row)

            criar_evento_ok(l_novo_evento)

    print("Criação de Cedentes: Processo finalizado!")
else:
    print("Nenhum Cedente a ser criado.")
    
