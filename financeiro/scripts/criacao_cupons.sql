Dinheiro para cheques:

x = cadastrar_cheque_cupom(
                        p_cheque_codigo_banco       => l_cheque_codigo_banco,
                        p_cheque_agencia            => l_cheque_agencia,
                        p_cheque_numero_conta       => l_cheque_numero_conta,
                        p_cheque_numero_cheque      => l_cheque_numero_cheque,
                        p_cheque_numero_serie       => l_cheque_numero_serie,
                        p_cheque_titular            => l_cheque_titular,
                        p_cheque_data_cheque        => l_cheque_data_cheque,
                        p_cheque_bom_para           => l_cheque_bom_para,
                        p_valor_cheque              => l_cheque_valor,
                        P_cliente_id                => l_cliente_id,
                        p_empresa_id                => l_empresa_id,
                        p_cupom_id                  => l_cupom_id
                    );


Dinheiro para cartões:

x = cupom_cartao(
                        p_cartao_nome       		=> l_cartao_nome,
                        p_cartao_operacao   		=> l_cartao_operacao,
                        p_cartao_bandeira   		=> l_cartao_bandeira,
                        p_cartao_adquirente 		=> l_cartao_adquirente,
                        p_cartao_nsu        		=> l_cartao_nsu,
                        p_cartao_valor      		=> l_cartao_valor,
                        p_empresa_id        		=> l_empresa_id,
                        p_cliente_id        		=> l_cliente_id,
                        p_parcelas          		=> l_cartao_parcelas,
                        p_documento         		=> l_caixas_cupons.numero_documento,
                        p_cupom_id          		=> l_cupom_id
                    );

Para Crediário:

x = cupom_crediario(
                        p_cliente_id    			=> l_cliente_id,
                        p_empresa_id    			=> l_empresa_id,
                        p_cupom_id      			=> l_cupom_id,
                        p_documento     			=> l_caixas_cupons.numero_documento,
                        p_vencimento    			=> l_crediario_vencimento,
                        p_valor         			=> l_crediario_valor                        
                    );


x = cupom_convenio(
                        p_convenio_id         		=> l_cliente_id,
                        p_convenio_vencimento 		=> l_convenio_vencimento,
                        p_convenio_valor      		=> l_convenio_valor,
                        p_empresa_id          		=> l_empresa_id,
                        p_cupom_id            		=> l_cupom_id,
                        p_documento           		=> l_caixas_cupons.numero_documento
                    );







Caixas para verificar outros e pbm
4294, 3501





