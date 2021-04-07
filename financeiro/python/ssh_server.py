import cx_Oracle
import os
from sshtunnel import SSHTunnelForwarder
from sqlalchemy import create_engine

HOST = "68.183.63.201"
REMOTE_PORT = 1539
LOCAL_PORT = 1539
USER_NAME = "root"
USER_PASSWORD = "senha"


# importante para ler corretamente os acentos no Oracle
os.environ["NLS_LANG"] = "AMERICAN_AMERICA.UTF8"

oracle_connection_string = (
    "oracle+cx_oracle://{username}:{password}@"
    + cx_Oracle.makedsn("{hostname}", "{port}", service_name="{database}")
)


engine = create_engine(
    oracle_connection_string.format(
        username="HOS",
        password="h0$77P@s$",
        hostname="hoserp.ckeqxfgnthqe.us-east-2.rds.amazonaws.com",
        port="1521",
        database="ORCL",
    )
)

conn = engine.connect()
