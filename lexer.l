/* yylineno mantém a linha atual; yywrap não será chamado ao fim da entrada. */
%option noyywrap yylineno

%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−− Definições −−−−−−−−−−−−−−−−−−−−−−−−−−*/
#include<stdio.h>
#include<string.h>

/* Integração: tokens declarados no arquivo parser.y pelo Bison. */
#include "parser.tab.h"

/* Limites usados pela tabela de símbolos. */
#define MAX_IDS 100000
#define MAX_TAMANHO_ID 100

void coluna_comentario_multilinha();
int inserir_tabela(char *lexema);

typedef struct{
    char lexema[MAX_TAMANHO_ID + 1]; 
} Simbolo;

/* A tabela armazena somente os identificadores encontrados. */
Simbolo tabela_simbolo[MAX_IDS];
int posicao = 0;

/* Coluna do próximo lexema a ser reconhecido. */
int column_number = 1;

/* Integração: posição do último token devolvido ao analisador sintático. */
int linha_token = 1;
int coluna_token = 1;
int houve_erro_lexico = 0;
%}

/* Classes básicas de lexemas. */
tipo "int"|"float"
relop "<="|">="|"=="|"<>"|"<"|">"
digit [0-9]
letter [A-Za-z]
delim [ \t]
number {digit}+(\.{digit}+)?
id {letter}({letter}|{digit})*

/* Comentários válidos são ignorados; o terceiro padrão detecta falta de fechamento. */
comentario_uma_linha "//"([^\n])*
comentario_multiplas_linhas "/*"([^*]|(\*)+([^*/]))*(\*)+\/
comentario_multiplas_linhas_sem_fechamento "/*"([^*]|(\*)+([^*/]))*(\*)*
ws {delim}+
other .



%%
%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−−−−− Regras −−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/
%}

    /* Comentários não produzem tokens, mas atualizam a posição de leitura. */
{comentario_multiplas_linhas}   { coluna_comentario_multilinha();}
{comentario_multiplas_linhas_sem_fechamento}   {
                                                    int linha_inicio = yylineno;

                                                    for (int i = 0; i < yyleng; i++) {
                                                        if (yytext[i] == '\n') {
                                                            linha_inicio--;
                                                        }
                                                    }

                                                    linha_token = linha_inicio;
                                                    coluna_token = column_number;
                                                    houve_erro_lexico = 1;
                                                    fprintf(yyout, "Erro: comentário de múltiplas linhas iniciado na linha %d e coluna %d não foi fechado.\n", linha_inicio,column_number);
                                                    return ERRO_LEX;
                                                }
{comentario_uma_linha}          {   }

    /* Palavras reservadas e tipos da linguagem. */
"if"            { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return IF; } // IF
"else"          { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return ELSE; } // ELSE
"while"         { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return WHILE; } // WHILE
"print"         { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return PRINT; } // PRINT
"read"          { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return READ; } // READ

    /* Operadores aritméticos. */
"+"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return MAIS; } // MAIS
"-"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return MENOS; } // MENOS
"*"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return MULT; } // MULT
"/"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return DIV; } // DIV
"%"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return MOD; } // MOD

    /* Operador de atribuição. */
"="             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return ATRIBUICAO; } // ATRIBUICAO
 
    /* Operadores lógicos. */
"&&"            { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return E; } // E
"||"            { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return OU; } // OU
"!"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return NAO; } // NAO

    /* Símbolos de pontuação. */
";"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return PONTO_VIRGULA; } // PONTO_VIRGULA
","             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return VIRGULA; } // VIRGULA
"("             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return ABRE_PARENTESES; } // ABRE_PARENTESES
")"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return FECHA_PARENTESES; } // FECHA_PARENTESES
"{"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return ABRE_CHAVES; } // ABRE_CHAVES
"}"             { linha_token = yylineno; coluna_token = column_number; column_number += yyleng; return FECHA_CHAVES; } // FECHA_CHAVES

    /* Operadores relacionais.*/
{relop}         {
                    linha_token = yylineno;
                    coluna_token = column_number;
                    column_number += yyleng;
                    return RELOP;
                } // RELOP

    /* Tipos da linguagem.*/
{tipo}          {
                    linha_token = yylineno;
                    coluna_token = column_number;
                    column_number += yyleng;
                    return TIPO;
                } // TIPÓ

{id}            {
                    int valor_token_id = inserir_tabela(yytext);

                    linha_token = yylineno;
                    coluna_token = column_number;

                    /* O atributo de ID é a posição do lexema na tabela. */
                    if (valor_token_id == -1) {
                        houve_erro_lexico = 1;
                        fprintf(yyout, "Erro: número máximo de IDs atingido (%d) na linha %d e coluna %d. Entrada -> \"%s\"\n", MAX_IDS, yylineno, column_number, yytext);
                        column_number += yyleng;
                        return ERRO_LEX;
                    } else if(valor_token_id == -2) {
                        houve_erro_lexico = 1;
                        fprintf(yyout, "Erro: o identificador excede o limite de %d caracteres na linha %d e coluna %d. Entrada -> \"%s\"\n", MAX_TAMANHO_ID, yylineno, column_number, yytext);
                        column_number += yyleng;
                        return ERRO_LEX;
                    }
                    column_number += yyleng;
                    return ID;
                } // ID             
{number}        {
                    linha_token = yylineno;
                    coluna_token = column_number;
                    column_number += yyleng;
                    return NUMERO;
                } // NUMERO

    /* Espaços e tabulações avançam a coluna; nova linha a reinicia. */
\n              { column_number = 1; }
{ws}            { column_number += yyleng; }

    /* Qualquer caractere não coberto pelas regras anteriores é um erro léxico. */
{other}         {
                    linha_token = yylineno;
                    coluna_token = column_number;
                    houve_erro_lexico = 1;
                    fprintf(yyout, "Erro léxico na linha %d e coluna %d. Entrada -> \"%s\"\n", yylineno, column_number, yytext);
                    column_number+=yyleng;
                    return ERRO_LEX;
                }

    /* Integração: registra a posição do fim da entrada para yyerror. */
<<EOF>>        { linha_token = yylineno; coluna_token = column_number; return 0; }

%%
/*−−−−−−−−−−−−−−−−−−−−−−−− Funções auxiliares −−−−−−−−−−−−−−−−−−−−−−−−*/

void coluna_comentario_multilinha(){
    /* Calcula a coluna após um comentário que pode conter novas linhas. */
    for(int i=0; i<yyleng; i++){
        if(yytext[i]=='\n'){
            column_number = 1;
        }else{
            column_number++;
        }
    }
}

int inserir_tabela(char *lexema){
    /* Reutiliza um ID existente ou insere um novo identificador. */
   
    for(int i=0; i<posicao; i++){
        if(strcmp(tabela_simbolo[i].lexema, lexema) == 0){
            return i;
        }
    }

    if(posicao>=MAX_IDS){
        return -1;
    }

    if(strlen(lexema) > MAX_TAMANHO_ID) return -2;

    strncpy(tabela_simbolo[posicao].lexema, lexema, sizeof(tabela_simbolo[posicao].lexema) - 1);
    tabela_simbolo[posicao].lexema[sizeof(tabela_simbolo[posicao].lexema) - 1] = '\0';
    return posicao++;
} 

void imprimir_tabela_simbolos() {
    /* Exibe os IDs criados durante a análise. */
    printf("\n===== TABELA DE SÍMBOLOS =====\n");
    printf("%-5s | %-30s\n", "ID", "LEXEMA");
    printf("--------------------------------------\n");

    for (int i = 0; i < posicao; i++) {
        printf("%-5d | %-30s\n", i, tabela_simbolo[i].lexema);
    }

    printf("--------------------------------------\n");
}
