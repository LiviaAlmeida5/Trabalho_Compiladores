%{
/*------------------------------ Definições ------------------------------*/
#include <stdio.h>

int yylex(void);
void yyerror(const char *mensagem);

/* Variáveis e funções externas presentes em lexer.l */
extern FILE *yyin;
extern char *yytext;
extern int linha_token;
extern int coluna_token;
extern int houve_erro_lexico;
extern void imprimir_tabela_simbolos(void);

/* Variável auxiliar para indicar se houve pelo menos um erro sintático */
int houve_erro_sintatico = 0;
%}

/* Tokens */
%token TIPO ID NUMERO
%token IF ELSE WHILE PRINT READ
%token MAIS MENOS MULT DIV MOD ATRIBUICAO
%token RELOP E OU NAO
%token PONTO_VIRGULA VIRGULA ABRE_PARENTESES FECHA_PARENTESES
%token ABRE_CHAVES FECHA_CHAVES
%token ERRO_LEX

/* Precedência crescente e associatividade dos operadores. */
%left OU
%left E
%left RELOP
%left MAIS MENOS
%left MULT DIV MOD
%right NAO MENOS_UN

/*
 * Resolve o "dangling else": o if sem else tem precedencia menor que ELSE,
 * portanto cada else e associado ao if aberto mais proximo.
 */
%nonassoc IFX
%nonassoc ELSE

%%

programa
    : lista_itens
    ;

lista_itens
    : /* vazio */
    | lista_itens item
    /* Recupera comandos e declarações até o próximo ponto e vírgula. */
    | lista_itens error PONTO_VIRGULA
      {
          yyerrok;
      }
    ;

item
    : declaracao
    | comando
    ;

/* Declarações */
declaracao
    : TIPO lista_declaradores PONTO_VIRGULA
    ;

lista_declaradores
    : declarador
    | lista_declaradores VIRGULA declarador
    ;

declarador
    : ID
    | ID ATRIBUICAO expressao
    ;

/* Comandos */
comando
    : atribuicao
    | condicional
    | repeticao
    | impressao
    | leitura
    | bloco
    ;

atribuicao
    : ID ATRIBUICAO expressao PONTO_VIRGULA
    ;

condicional
    : IF ABRE_PARENTESES expressao FECHA_PARENTESES item %prec IFX
    | IF ABRE_PARENTESES expressao FECHA_PARENTESES item ELSE item
    ;

repeticao
    : WHILE ABRE_PARENTESES expressao FECHA_PARENTESES item
    ;

impressao
    : PRINT ABRE_PARENTESES expressao FECHA_PARENTESES PONTO_VIRGULA
    ;

leitura
    : READ ABRE_PARENTESES ID FECHA_PARENTESES PONTO_VIRGULA
    ;

bloco
    : ABRE_CHAVES lista_itens FECHA_CHAVES
    /* Recupera comandos e declarações até o próximo fecha chaves (fim de um bloco). */
    | ABRE_CHAVES lista_itens error FECHA_CHAVES
      {
          yyerrok;
      }
    ;

 /*
 * Expressão
 * As declarações de precedência na linha 28 resolvem as ambiguidades.
 * MENOS_UN distingue quando MENOS representa sinal de negativo ao invés da subtração de duas expressões.
 */
expressao
    : expressao OU expressao
    | expressao E expressao
    | expressao RELOP expressao
    | expressao MAIS expressao
    | expressao MENOS expressao
    | expressao MULT expressao
    | expressao DIV expressao
    | expressao MOD expressao
    | NAO expressao
    | MENOS expressao %prec MENOS_UN
    | ABRE_PARENTESES expressao FECHA_PARENTESES
    | ID
    | NUMERO
    ;

%%

/*-------------------------- Funções auxiliares --------------------------*/

void yyerror(const char *mensagem) {
    houve_erro_sintatico = 1;

    /* Tratamento para caso o simbolo inesperado seja o final do arquivo */
    if (yytext[0] == '\0') {
        fprintf(stderr, "Erro sintático de fim de arquivo na linha %d, coluna %d: %s.\n", linha_token, coluna_token, mensagem);
    } else {
        fprintf(stderr, "Erro sintático na linha %d, coluna %d, próximo a \"%s\": %s.\n", linha_token, coluna_token, yytext, mensagem);
    }
}

int main(int argc, char *argv[]) {
    int resultado;

    if (argc != 2) {
        fprintf(stderr, "Uso: %s <arquivo-fonte>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Erro: não foi possível abrir o arquivo '%s'.\n", argv[1]);
        return 1;
    }

    resultado = yyparse();
    fclose(yyin);

    imprimir_tabela_simbolos();

    if (resultado == 0 && !houve_erro_lexico && !houve_erro_sintatico) {
        printf("Análise sintática concluída com sucesso.\n");
        return 0;
    } else {
        printf("Análise concluída com erros.\n");
        return 0;
    }

    return 1;
}
