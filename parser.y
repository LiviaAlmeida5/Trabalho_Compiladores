%{
/*------------------------------ Definições ------------------------------*/
#include <stdio.h>

int yylex(void);
void yyerror(const char *mensagem);

extern FILE *yyin;
extern char *yytext;
extern int linha_token;
extern int coluna_token;
extern int houve_erro_lexico;
extern void imprimir_tabela_simbolos(void);

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

// %define parse.error verbose // ver oq esse trem faz
// %start programa

%%

/* Um programa é uma sequência, possivelmente vazia, de itens. */
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

/* Declarações admitem um ou mais identificadores do mesmo tipo. */
declaracao
    : TIPO lista_declaradores PONTO_VIRGULA
    ;

lista_declaradores
    : declarador
    | lista_declaradores VIRGULA declarador
    ;

/* A inicialização na declaração é reconhecida somente sintaticamente. */
declarador
    : ID
    | ID ATRIBUICAO expressao
    ;

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

/*
 * Os ramos do if e o corpo do while são sempre blocos. Essa decisão de
 * sintaxe elimina a ambiguidade do else, pois cada else pertence ao if que
 * aparece imediatamente antes de seu bloco.
 */
condicional
    : IF ABRE_PARENTESES expressao FECHA_PARENTESES bloco
    | IF ABRE_PARENTESES expressao FECHA_PARENTESES bloco ELSE bloco
    ;

repeticao
    : WHILE ABRE_PARENTESES expressao FECHA_PARENTESES bloco
    ;

/* print e read são as funções predefinidas de saída e entrada. */
impressao
    : PRINT ABRE_PARENTESES expressao FECHA_PARENTESES PONTO_VIRGULA
    ;

leitura
    : READ ABRE_PARENTESES ID FECHA_PARENTESES PONTO_VIRGULA
    ;

bloco
    : ABRE_CHAVES lista_itens FECHA_CHAVES
    /* Em um bloco, também é possível sincronizar diretamente em '}'. */
    | ABRE_CHAVES lista_itens error FECHA_CHAVES
      {
          yyerrok;
      }
    ;

/*
 * A gramática abaixo reconhece expressões aritméticas, relacionais e
 * lógicas. As declarações de precedência acima resolvem as ambiguidades;
 * MENOS_UN distingue o sinal negativo da subtração.
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
    }

    return 1;
}
