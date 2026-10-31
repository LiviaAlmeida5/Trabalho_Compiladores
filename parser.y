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

/* Tokens com nomes em português e abreviados. */
%token TIP ID NUM
%token SE SEN ENQ IMP LER
%token MAIS MENOS MULT DIV MOD ATR
%token OP_REL E_LOG OU_LOG NAO
%token P_VIRG VIRG A_PAR F_PAR A_CH F_CH
%token ERRO_LEX

/* Precedência crescente e associatividade dos operadores. */
%left OU_LOG
%left E_LOG
%left OP_REL
%left MAIS MENOS
%left MULT DIV MOD
%right NAO MENOS_UN

%define parse.error verbose
%start programa

%%

/* Um programa é uma sequência, possivelmente vazia, de itens. */
programa
    : lista_itens
    ;

lista_itens
    : /* vazio */
    | lista_itens item
    ;

item
    : declaracao
    | comando
    ;

/* Declarações admitem um ou mais identificadores do mesmo tipo. */
declaracao
    : TIP lista_ids P_VIRG
    ;

lista_ids
    : ID
    | lista_ids VIRG ID
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
    : ID ATR expressao P_VIRG
    ;

/*
 * Os ramos do if e o corpo do while são sempre blocos. Essa decisão de
 * sintaxe elimina a ambiguidade do else, pois cada else pertence ao if que
 * aparece imediatamente antes de seu bloco.
 */
condicional
    : SE A_PAR expressao F_PAR bloco
    | SE A_PAR expressao F_PAR bloco SEN bloco
    ;

repeticao
    : ENQ A_PAR expressao F_PAR bloco
    ;

/* print e read são as funções predefinidas de saída e entrada. */
impressao
    : IMP A_PAR expressao F_PAR P_VIRG
    ;

leitura
    : LER A_PAR ID F_PAR P_VIRG
    ;

bloco
    : A_CH lista_itens F_CH
    ;

/*
 * A gramática abaixo reconhece expressões aritméticas, relacionais e
 * lógicas. As declarações de precedência acima resolvem as ambiguidades;
 * MENOS_UN distingue o sinal negativo da subtração.
 */
expressao
    : expressao OU_LOG expressao
    | expressao E_LOG expressao
    | expressao OP_REL expressao
    | expressao MAIS expressao
    | expressao MENOS expressao
    | expressao MULT expressao
    | expressao DIV expressao
    | expressao MOD expressao
    | NAO expressao
    | MENOS expressao %prec MENOS_UN
    | A_PAR expressao F_PAR
    | ID
    | NUM
    ;

%%

/*-------------------------- Funções auxiliares --------------------------*/

void yyerror(const char *mensagem) {
    /* O erro léxico já foi descrito pelo Flex com sua posição. */
    if (houve_erro_lexico) {
        return;
    }

    houve_erro_sintatico = 1;

    if (feof(yyin)) {
        fprintf(stderr,
                "Erro sintático no fim do arquivo, linha %d, coluna %d: %s.\n",
                linha_token, coluna_token, mensagem);
    } else {
        fprintf(stderr,
                "Erro sintático na linha %d, coluna %d, próximo a \"%s\": %s.\n",
                linha_token, coluna_token, yytext, mensagem);
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
