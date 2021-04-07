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
def verificar_contas_receber():
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
            ]
        )
        .where(contas_receber.c.codigo_externo == "Emitir_Cobranca")
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


# ------------------------------------------  Criar novo convênio
def preparar_dados(row):

    # Buscar api como variável de ambiente
    api_token   = config('API_TOKEN')
    api_encoded = base64.b64encode(api_token.encode("utf-8"))
    api_key = str(api_encoded, "utf-8")

    t_cnpj = ""

    p_empresa_id = row.get("empresa_id")
    p_titulo_id = row.get("id")

    sql_empresa = text("select cnpj " 
        "from empresas " 
        "where id = :empresa_id "
        )

    result = conn.execute(sql_empresa, empresa_id=p_empresa_id)
    rec = result.fetchone()

    t_cnpj = rec.cnpj

    sql_conta = text(
        "select cc.numero_conta, cc.digito_conta, cb.numero as numero_convenio, b.numero as numero_banco, "
        "c.email, c.numero as cliente_numero, c.bairro, c.cep, c.endereco, c.nome as nome_cliente, c.telefone, "
        "c.cnpj, cid.cidade as nome_cidade, est.uf, to_char(cr.data_emissao, 'DD/MM/YYYY') as data_emissao, "
        "to_char(cr.data_vencimento, 'DD/MM/YYYY') as data_vencimento, "
        "cr.documento, to_char(cr.valor, '999G999G999G999G990D00') as valor, cr.id, cr.codigo_externo, "
        "cr.mensagem_01, cr.mensagem_02, cr.mensagem_03, cr.mensagem_local_pagamento "
        "from  contas_financeiras cc, convenios_bancarios cb, "
        "bancos b, clientes c, contas_receber cr, "
        "cidades cid, estados est "
        "where cc.id = cr.conta_financeira_id "
        "and b.id = cc.banco_id "
        "and cb.id = cr.convenio_bancario_id "
        "and c.id = cr.cliente_id "
        "and cid.id = c.cidade_id "
        "and est.id = c.estado_id "
        "and cr.id = :titulo_id "
    )

    result = conn.execute(sql_conta, titulo_id=p_titulo_id)
    rec = result.fetchall()

    for row in rec:
        t_id              = row.id
        t_conta_numero    = row.numero_conta
        t_digito_conta    = row.digito_conta
        t_convenio_numero = row.numero_convenio
        t_numero_banco    = row.numero_banco
        t_email           = row.email
        t_endereco_numero = row.cliente_numero
        t_bairro          = row.bairro
        t_cep             = row.cep
        t_cidade          = row.nome_cidade
        t_estado          = row.uf
        t_logradouro      = row.endereco
        t_pais            = 'Brasil'
        t_cliente_nome    = row.nome_cliente
        t_cliente_cnpj    = row.cnpj
        t_telefone        = row.telefone
        t_data_emissao    = row.data_emissao
        t_data_vencimento = row.data_vencimento
        t_documento       = row.documento
        t_valor           = row.valor
        t_mensagem_01     = row.mensagem_01
        t_mensagem_02     = row.mensagem_02
        t_mensagem_03     = row.mensagem_03
        t_mensagem_local  = row.mensagem_local_pagamento

        url = "https://homologacao.plugboleto.com.br/api/v1/boletos/lote"

        myHeaders = {
            "Content-Type": "application/json",
            "cnpj-sh": "00115150000140",
            "token-sh": api_token,
            "cnpj-cedente": t_cnpj,
            "Accept": "application/json",
        }

        myBody = [
                    {
                        "CedenteContaNumero": t_conta_numero,
                        "CedenteContaNumeroDV": t_digito_conta,
                        "CedenteConvenioNumero": t_convenio_numero,
                        "CedenteContaCodigoBanco": t_numero_banco,
                        "SacadoCPFCNPJ": t_cliente_cnpj,
                        "SacadoEmail": t_email,
                        "SacadoEnderecoNumero": t_endereco_numero,
                        "SacadoEnderecoBairro": t_bairro,
                        "SacadoEnderecoCEP": t_cep,
                        "SacadoEnderecoCidade": t_cidade,
                        "SacadoEnderecoComplemento": "",
                        "SacadoEnderecoLogradouro": t_logradouro,
                        "SacadoEnderecoPais": "Brasil",
                        "SacadoEnderecoUF": t_estado,
                        "SacadoNome": t_cliente_nome,
                        "SacadoTelefone": t_telefone,
                        "SacadoCelular": t_telefone,
                        "TituloDataEmissao": t_data_emissao,
                        "TituloDataVencimento": t_data_vencimento,
                        "TituloMensagem01": t_mensagem_01,
                        "TituloMensagem02": t_mensagem_02,
                        "TituloMensagem03": t_mensagem_03,
                        "TituloNossoNumero": t_documento,
                        "TituloNumeroDocumento": t_documento,
                        "TituloValor": t_valor,
                        "TituloLocalPagamento": t_mensagem_local
                    }
                ] 

        # print(myBody)
        # print("------------------")
        response = requests.post(url, json=myBody, headers=myHeaders)

        if response.status_code == 200:
            # print(response.status_code)
            # print(response.text)

            dados = json.loads(response.text)

            # print(dados)
            for retorno in dados["_dados"]["_sucesso"]:
                id_retorno = retorno["idintegracao"]

                print("Id Integração: " + id_retorno)

                # salvar o id retornado no titulo
                gravar_codigo_externo_boleto(id_retorno, p_titulo_id)

        else:
            print("Erro:" + str(response.status_code))
            # print(response.text)

            dados = json.loads(response.text)

            # -->> Tratar mensagem de erro
            #      inserir em notificações
            l_titulo_erro = 'Erro gerando cobrança'

            for erro in dados["_dados"]["_falha"]:

                nova_notificacao = notificacoes.insert().values(
                    titulo=l_titulo_erro,
                    texto=erro["_erro"]["erros"]["boleto"],
                    tipo="tecnospeed",
                    status="Erro",
                    empresa_id=p_empresa_id,
                )

                result = conn.execute(nova_notificacao)


# ------------------------------------------  Gravar ID retornado da cobrança
def gravar_codigo_externo_boleto(p_id_retorno, p_titulo_id):

    u = update(contas_receber).where(contas_receber.c.id == p_titulo_id)
    u = u.values(codigo_externo=p_id_retorno)

    result = conn.execute(u)

    if result.rowcount > 0:
        print(str(result.rowcount))  # Número de linhas afetadas pelo update
    else:
        print("Erro atualizando status do evento")



# ------------------------------------------  Início da verificação de eventos
json_data = verificar_contas_receber()

if json_data:
    for row in json_data:

        # print(row)
        preparar_dados(row)

    print("Emissão de Cobranças: Processo finalizado!")
else:
    print("Nenhuma cobrança nova para gerar.")






