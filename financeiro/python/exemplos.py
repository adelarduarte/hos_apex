# ------------------------------------------  Incluindo novo registro
new_event = eventos.insert().values(
    evento="Teste SQLAlchemy",
    username="fulano@email.com",
    tipo="Teste",
    tenant_id=101,
    historico="Inserindo evento via API",
    status="Pendente",
)

result = conn.execute(new_event)
# print(result.inserted_primary_key)


# ------------------------------------------  Buscando todos os registros
s = select([eventos])
rp = conn.execute(s)
results = rp.fetchall()

# verificar a sentença sql...
print(str(s))

for record in results:
    print(record.id, record.evento, record.historico, record.status)


# ------------------------------------------  buscando com filtro
s = select([eventos]).where(eventos.c.tenant_id == 101)
result = conn.execute(s)

for record in results:
    print(record.id, record.evento, record.historico, record.status)


# ------------------------------------------  Atualizando registro
u = update(eventos).where(eventos.c.id == 1)
u = u.values(historico="Teste histórico alerado")
result = conn.execute(u)

print(result.rowcount)  # Número de linhas afetadas pelo update


# ------------------------------------------  Excluindo registro
d = delete(eventos).where(eventos.c.id == 1)
result = conn.execute(d)
print(result.rowcount)  # Número de linhas excluídas
