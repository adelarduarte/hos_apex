select json_object(
         'id' is f.id,
         'nome' is f.razaosocial,
         'email' is f.email,
         'contas' is (
            select json_arrayagg(
                     json_object(
                       'documento' is c.documento,
                       'vencimento' is c.datavencimento,
                       'valor' is c.valor
) )
              from contaspagar c
             where f.id = c.fornecedorid
         )
       ) fornecedores_contas
  from fornecedores f
 where f.id = 66967





-->> Exemplo funcional
              if l_atrasos_qtd > 0 then
                -->> Listar títulos em atraso
          select json_object(
                   'nome' is c.nome,
                   'limite_credito' is p.limite_credito,
                   'saldo_credito' is p.saldo_crediario,
                   'inadimplente' is l_inadimplente,
                   'liberado' is l_liberado,
                   'atrasos' is (
                      select json_arrayagg(
                               json_object(
                                 'documento' is cr.documento,
                                 'vencimento' is cr.data_vencimento,
                                 'valor' is cr.valor
          ) )
                        from contas_receber cr
                       where c.id = cr.cliente_id
                       and cr.saldo > 0
                   )
                 ) cliente_credito
            into l_data
            from clientes c, clientes_preferencias p
            where c.id = p.cliente_id
           and c.id = l_cliente_id;
        else
                -->> Retornar objeto sem os titulos
          select json_object(
                   'nome' is c.nome,
                   'limite_credito' is p.limite_credito,
                   'saldo_credito' is p.saldo_crediario,
                   'inadimplente' is l_inadimplente,
                   'liberado' is l_liberado,
                   'atrasos' is null
                 ) cliente_credito
            into l_data
            from clientes c, clientes_preferencias p
            where c.id = p.cliente_id
           and c.id = l_cliente_id;
              end if;
---- >> --->>  -->> 




// Retorno
{
  "Cliente": "Fulano de tal",
  "limite_credito": 1200.00,
  "saldo_credito": 320.50,
  "inadimplente": "Sim",
  "liberado": "Não",
  "atrasos": [
    {
      "cupom": 123,
      "vencimento": "10-09-2020",
      "valor": 65.50
    },
    {
      "cupom": 342,
      "vencimento": "23-09-2020",
      "valor": 40.12
    }   
  ]
}
