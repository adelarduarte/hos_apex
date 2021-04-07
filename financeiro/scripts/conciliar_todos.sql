create or replace procedure "CONCILIAR_TODOS"
IS
	l_linha		number;

BEGIN
	-- >> Ler a tabela Contas_movimento_extratos
	FOR extratos_rec IN (
	        SELECT linha_numero
	          FROM conta_movimento_extratos
	          WHERE id > 0
              and empresa_id = V('SES_EMPRESAS_ID'))
	   LOOP
	         -- >> Seta valores para chamar procedure de aplicação das regras
	         l_linha := extratos_rec.linha_numero;

	         CONCILIAR_RECONHECIDO(
	             p_linha => l_linha);

	   END LOOP;

END;