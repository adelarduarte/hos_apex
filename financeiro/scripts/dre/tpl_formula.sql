create or replace procedure "TPL_FORMULA" (
                p_empresa_id    IN number,
                p_formula       IN varchar2,
                p_nome          IN varchar2,
                p_ordem         IN number,
                p_codigo        IN varchar2,
                p_mes           IN varchar2,
                p_tipo          IN varchar2,
                p_fonte         IN varchar2
)
is
    l_var               varchar2(200) := p_formula;
    l_var_compacta      varchar2(200);
    l_exp               varchar2(1000);

    l_inicio            number;
    l_fim               number;
    l_tamanho           number;
    l_tamanho_total     number;

    l_contador          number;
    l_contador_seg      number; -->> Contador de segurança...

    l_codigo            varchar2(20);
    l_codigo_busca      varchar2(20);
    l_tipo              varchar2(20); -->> Variável / Literal

    l_valor_retornado   varchar2(100);
    l_valor             number(14,2);

    l_negativo          varchar2(10);
    
    l_template_dados    template_report_dados%rowtype;

begin
    dbms_output.put_line('-->> Fórmula');


    l_var_compacta := replace(l_var, ' ');

    l_tamanho_total := length(l_var_compacta);

    l_inicio   := 0;
    l_fim      := 0;
    l_contador := 0;

    -->> Contador usado para evitar loop infinito,
    --   em caso de fórmulas mal formadas.
    l_contador_seg := 1;

    l_exp      := l_var_compacta;


    while l_contador <= l_tamanho_total
    loop
        l_contador_seg := l_contador_seg + 1;

        exit when l_contador_seg > 50;

        l_inicio := instr(l_var_compacta, '[', (l_inicio + 1));

        if l_inicio > 0 then
            l_fim    := instr(l_var_compacta, ']', (l_fim + 1));
            l_tipo   := 'Variável';
        else
            l_inicio := instr(l_var_compacta, '#', (l_inicio + 1));
            l_fim    := instr(l_var_compacta, '#', (l_inicio + 1));
            l_tipo   := 'Literal';
        end if;

        l_tamanho := (l_fim + 1) - l_inicio;

        l_codigo       := substr(l_var_compacta, l_inicio, l_tamanho);

        if l_tipo = 'Variável' then
            l_codigo_busca := replace(l_codigo, '[');
            l_codigo_busca := replace(l_codigo_busca, ']');
        else
            l_codigo_busca := replace(l_codigo, '#');
            l_codigo_busca := replace(l_codigo_busca, '#');
        end if;


        if l_tipo = 'Variável' then
            -->> Buscar o valor do código encontrado para substituir.
            --   Precisa ser uma função, e levar em conta o mês.
            l_valor_retornado := tpl_buscar_valor(
                    p_codigo    => l_codigo_busca,
                    p_mes       => p_mes,
                    p_empresa_id => p_empresa_id
                );
        else
            l_valor_retornado := l_codigo_busca;
        end if;

        -->> substituir na expressão, o código pelo valor retornado.
        l_exp := replace(l_exp, l_codigo, l_valor_retornado);

        l_contador := l_inicio + l_tamanho;
    end loop;

    l_exp := replace(l_exp, ',', '.');
    l_exp := 'select (' || l_exp || ') from dual';

    -->> calcular a expressão, e gravar o valor
    begin
        execute immediate l_exp
        into l_valor;
    exception
    when others then
        l_valor := 0;
    end;

    -->> Testando aqui 
    --   Formatando valor como negativo, 
    --   quando marcado como tal, e gravado como positivo.
    
    --   Isso está sendo necessário, porque o IR não está colocando
    --   na mesma linha, campos com valores negativos e positivos, 
    --   quando vindo do banco de dados.
    
    --   A função tpl_buscar_valor tb foi modificada
    
    if l_valor < 0 then
        l_valor := l_valor * -1;
        l_negativo := 'Sim';
    else
        l_negativo := 'Não';
    end if;

    dbms_output.put_line(l_exp);

    l_template_dados.id         := null;
    l_template_dados.codigo     := p_codigo;
    l_template_dados.ordem      := p_ordem;
    l_template_dados.nome       := p_nome;
    l_template_dados.mes        := p_mes;
    l_template_dados.valor      := l_valor;
    l_template_dados.empresa_id := p_empresa_id;
    l_template_dados.tipo       := p_tipo;
    l_template_dados.fonte      := p_fonte;
    l_template_dados.negativo   := l_negativo;

    insert into template_report_dados values l_template_dados;


end;


