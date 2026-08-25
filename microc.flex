/* Nomes: Hugo Pagnozzi, Leonardo Loveira, Maria Fernanda 
 *
 * microc.flex
 *
 * Compilacao:
 *      flex microc.flex
 *      gcc lex.yy.c -o lexer
 *
 * Uso:
 *      ./lexer test.mc
 */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    /* ---------------------------------------------------------------------
     * 1. VOCABULARIO DE TOKENS (equivalente a tokens.h)
     * ------------------------------------------------------------------- */

    typedef enum 
    {
        TK_ID, 
        TK_NUM, 
        TK_CHAR,
        TK_STRING,
        TK_PLUS, 
        TK_MINUS, 
        TK_TIMES, 
        TK_DIV, 
        TK_ASSIGN, 
        TK_SEMI, 
        TK_EOF, 
        TK_ERRO
    } 
    TokenType;

    /* Nomes dos tokens, usados apenas pelo main() de teste abaixo para
     * imprimir o tipo de cada token de forma legivel. Mantenha esta lista
     * na MESMA ORDEM do enum TokenType. */

    static const char *nome_token[] = 
    {
        "TK_ID", 
        "TK_NUM",
        "TK_CHAR", 
        "TK_STRING",
        "TK_PLUS", 
        "TK_MINUS", 
        "TK_TIMES", 
        "TK_DIV", 
        "TK_ASSIGN", 
        "TK_SEMI", 
        "TK_EOF", 
        "TK_ERRO"
    };

    /* Valor semantico do token corrente. */

    typedef struct 
    {
        char *symbol;      /* lexema */
        char *error_msg;   /* mensagem de erro, usada apenas quando tipo == TK_ERRO */
    } 
    YYSTYPE;

    YYSTYPE microc_yylval;

    int linha_atual = 1;
    int linha_erro = 1;
    int coluna_atual = 1;
    int coluna_erro = 1;

    /* Funcao auxiliar para preencher microc_yylval.symbol com uma copia do
     * texto reconhecido (yytext). */

    static void guarda_lexema(void) 
    {
        microc_yylval.symbol = strdup(yytext);
    }
%}

/* -----------------------------------------------------------------------
 * 2. SECAO DE DEFINICOES
 * ------------------------------------------------------------------- */

DIGIT       [0-9]
LETRA       [a-zA-Z_]
ALFANUM     [a-zA-Z0-9_]

%%

 /* -----------------------------------------------------------------------
  * 3. SECAO DE REGRAS
  * ------------------------------------------------------------------ */

 /* --- Fim de arquivo -------------------------------------------------- */

<<EOF>>             { 
                        printf("(%s, ) \n", nome_token[TK_EOF]);
                        return TK_EOF; 
                    }

 /* --- Espacos em branco e quebras de linha ---------------------------- */

\n                  {    
                        linha_atual++;
                        coluna_atual = 1; 
                    }

[ \t\r]+            { coluna_atual += yyleng; }

 /* --- Comentarios ----------------------------------------------------- */

"//".*              { coluna_atual += yyleng; }

 /* --- Identificadores ------------------------------------------------- */

{LETRA}{ALFANUM}*   {
                        guarda_lexema();
                        coluna_atual += yyleng;
                        return TK_ID;
                    }

 /* --- Numeros inteiros ------------------------------------------------ */

"-"?{DIGIT}+        {
                        guarda_lexema();
                        coluna_atual += yyleng;
                        return TK_NUM;
                    }

 /* --- Caracteres ------------------------------------------------------ */

'[^'\n]'            {
                        guarda_lexema();
                        coluna_atual += yyleng;
                        return TK_CHAR;
                    }

 /* --- Strings --------------------------------------------------------- */

\"[^"\n]+\"         {
                        guarda_lexema();
                        coluna_atual += yyleng;
                        return TK_STRING;
                    }

 /* --- Operadores relacionais e logicos -------------------------------- */

"="                 {
                        coluna_atual += yyleng; 
                        return TK_ASSIGN; 
                    }

 /* --- Operadores aritmeticos e simbolos de pontuacao ------------------ */

"+"                 {
                        coluna_atual += yyleng; 
                        return TK_PLUS;  
                    }

"-"                 { 
                        coluna_atual += yyleng; 
                        return TK_MINUS; 
                    }

"*"                 { 
                        coluna_atual += yyleng; 
                        return TK_TIMES; 
                    }

"/"                 { 
                        coluna_atual += yyleng; 
                        return TK_DIV;   
                    }

";"                 { 
                        coluna_atual += yyleng; 
                        return TK_SEMI;  
                    }

 /* --- Tratamento de erros --------------------------------------------- */

'[^'\n]{2,}'                    {
                                    microc_yylval.error_msg = "Char nao pode conter mais de um caractere";
                                    coluna_erro = coluna_atual;
                                    linha_erro = linha_atual;
                                    coluna_atual += yyleng; 
                                    return TK_ERRO;
                                }

''                              {
                                    microc_yylval.error_msg = "Char nao pode ser vazio";
                                    coluna_erro = coluna_atual;
                                    linha_erro = linha_atual;
                                    coluna_atual += yyleng; 
                                    return TK_ERRO;
                                }

\"\"                            {
                                    microc_yylval.error_msg = "String nao pode ser vazia";
                                    coluna_erro = coluna_atual;
                                    linha_erro = linha_atual;
                                    coluna_atual += yyleng; 
                                    return TK_ERRO;
                                }

'[^'\n]*\n                      {
                                    microc_yylval.error_msg = "Char nao terminado";
                                    coluna_erro = coluna_atual;
                                    linha_erro = linha_atual;
                                    linha_atual++;
                                    coluna_atual = 1;
                                    return TK_ERRO;
                                }

\"[^"\n]*\n                     {
                                    microc_yylval.error_msg = "String nao terminada";
                                    coluna_erro = coluna_atual;
                                    linha_erro = linha_atual;
                                    linha_atual++;
                                    coluna_atual = 1;
                                    return TK_ERRO;
                                }

"-"?{DIGIT}+{LETRA}{ALFANUM}*   {
                                    microc_yylval.error_msg = "Identificador nao pode comecar com numero";
                                    coluna_erro = coluna_atual;
                                    linha_erro = linha_atual;
                                    coluna_atual += yyleng; 
                                    return TK_ERRO;
                                }

.                               {
                                    microc_yylval.error_msg = strdup(yytext);
                                    coluna_erro = coluna_atual;
                                    linha_erro = linha_atual;
                                    coluna_atual += yyleng; 
                                    return TK_ERRO;
                                }

%%

/* -----------------------------------------------------------------------
 * 4. SUB-ROTINAS DO USUARIO
 * ------------------------------------------------------------------- */

/* yywrap: informa ao flex que, ao atingir o EOF, a leitura deve
 * simplesmente parar (nao ha um proximo arquivo a processar). */

int yywrap(void) 
{
    return 1;
}

/* main() de teste: le o arquivo passado como argumento e imprime, para
 * cada token reconhecido, o par (token, lexema) */

int main(int argc, char **argv) 
{
    if (argc < 2) 
    {
        fprintf(stderr, "Uso: %s <arquivo.mc>\n", argv[0]);
        return 1;
    }

    FILE *arquivo_fonte = fopen(argv[1], "r");
    
    if (!arquivo_fonte) 
    {
        fprintf(stderr, "Erro: nao foi possivel abrir o arquivo '%s'\n", argv[1]);
        return 1;
    }

    yyin = arquivo_fonte;

    int tipo;

    while ((tipo = yylex()) != TK_EOF) 
    {
        if (tipo == TK_ERRO) 
        {
            printf("ERRO LEXICO (linha %d, coluna %d): %s \n", linha_erro, coluna_erro, microc_yylval.error_msg);
            continue;
        }
        if (tipo == TK_ID || tipo == TK_NUM || tipo == TK_CHAR || tipo == TK_STRING)
        {
            printf("(%s, %s) \n", nome_token[tipo], microc_yylval.symbol);
            continue;
        }
        printf("(%s, %s) \n", nome_token[tipo], yytext);
    }

    fclose(arquivo_fonte);
    return 0;
}
