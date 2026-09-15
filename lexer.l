/* yylineno mantém a linha atual; yywrap não será chamado ao fim da entrada. */
%option noyywrap yylineno

%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−− Definições −−−−−−−−−−−−−−−−−−−−−−−−−−*/
#include<stdio.h>

/* Limites usados pela tabela de símbolos. */
#define MAX_IDS 100000
#define MAX_TAMANHO_ID 100

void coluna_comentario_multilinha();
int inserir_tabela(char *lexema);
void print_token(int numero_linha, int numero_coluna, char * lexema, char *token);

typedef struct{
    char lexema[MAX_TAMANHO_ID + 1]; 
} Simbolo;

/* A tabela armazena somente os identificadores encontrados. */
Simbolo tabela_simbolo[MAX_IDS];
int posicao = 0;

/* Coluna do próximo lexema a ser reconhecido. */
int column_number = 1;
%}

/* Classes básicas de lexemas. */
tipo "int"|"float"
relop "<="|">="|"=="|"<>"|"<"|">"
digit [0-9]
letter [A-Za-z]
delim [ \t]
number {digit}+(\.{digit}+)?
id {letter}({letter}|{digit})*

/* Comentários válidos são ignorados; o segundo padrão detecta falta de fechamento. */
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

                                                    fprintf(yyout, "Erro: comentário de múltiplas linhas iniciado na linha %d e coluna %d não foi fechado.\n", linha_inicio,column_number);
                                                }
{comentario_uma_linha}          {   }

    /* Palavras reservadas e tipos da linguagem. */
"if"            { print_token(yylineno, column_number, yytext, "<IF>"); column_number += yyleng; } // IF
"else"          { print_token(yylineno, column_number, yytext, "<ELSE>"); column_number += yyleng; } // ELSE
"while"         { print_token(yylineno, column_number, yytext, "<WHILE>"); column_number += yyleng; } // WHILE
"print"         { print_token(yylineno, column_number, yytext, "<PRINT>"); column_number += yyleng; } // PRINT
"read"          { print_token(yylineno, column_number, yytext, "<READ>"); column_number += yyleng; } // READ


    /* Operadores aritméticos. */
"+"             { print_token(yylineno, column_number, yytext, "<MAIS>"); column_number += yyleng; } // MAIS
"-"             { print_token(yylineno, column_number, yytext, "<MENOS>"); column_number += yyleng; } // MENOS
"*"             { print_token(yylineno, column_number, yytext, "<MULT>"); column_number += yyleng; } // MULT
"/"             { print_token(yylineno, column_number, yytext, "<DIV>"); column_number += yyleng; } // DIV
"%"             { print_token(yylineno, column_number, yytext, "<MOD>"); column_number += yyleng; } // MOD

    /* Operadores lógicos. */
"&&"            { print_token(yylineno, column_number, yytext, "<E>"); column_number += yyleng; } // E
"||"            { print_token(yylineno, column_number, yytext, "<OU>"); column_number += yyleng; } // OU
"!"             { print_token(yylineno, column_number, yytext, "<NAO>"); column_number += yyleng; } // NAO

    /* Símbolos de pontuação. */
";"             { print_token(yylineno, column_number, yytext, "<PONTO_VIRGULA>"); column_number += yyleng; } // PONTO_VIRGULA
","             { print_token(yylineno, column_number, yytext, "<VIRGULA>"); column_number += yyleng; } // VIRGULA
"("             { print_token(yylineno, column_number, yytext, "<ABRE_PARENTESES>"); column_number += yyleng; } // ABRE_PARENTESES
")"             { print_token(yylineno, column_number, yytext, "<FECHA_PARENTESES>"); column_number += yyleng; } // FECHA_PARENTESES
"{"             { print_token(yylineno, column_number, yytext, "<ABRE_CHAVES>"); column_number += yyleng; } // ABRE_CHAVES
"}"             { print_token(yylineno, column_number, yytext, "<FECHA_CHAVES>"); column_number += yyleng; } // FECHA_CHAVES

    /* Operadores relacionais.*/
{relop}         {
                    char token[50];

                    snprintf(token, sizeof(token), "<RELOP, %s >", yytext); 
                    print_token(yylineno, column_number, yytext, token); column_number += yyleng; 
                } // RELOP

    /* Tipos da linguagem.*/
{tipo}          {
                    char token[50];

                    snprintf(token, sizeof(token), "<TIPO, %s>", yytext); 
                    print_token(yylineno, column_number, yytext, token); column_number += yyleng; 
                } // TIPÓ
{id}            {
                    int valor_token_id = inserir_tabela(yytext);
                    char token[50];

                    /* O atributo de ID é a posição do lexema na tabela. */
                    if (valor_token_id == -1) {
                        fprintf(yyout, "Erro: número máximo de IDs atingido (%d) na linha %d e coluna %d. Entrada -> \"%s\"\n", MAX_IDS, yylineno, column_number, yytext);
                    } else if(valor_token_id == -2) {
                        fprintf(yyout, "Erro: o identificador excede o limite de %d caracteres na linha %d e coluna %d. Entrada -> \"%s\"\n", MAX_TAMANHO_ID, yylineno, column_number, yytext);
                    }
                    else {
                        snprintf(token, sizeof(token), "<ID, %d>", valor_token_id);
                        print_token(yylineno, column_number, yytext, token);
                    }
                    column_number += yyleng;
                } // ID             
{number}        {
                    char token[50];

                    /* O atributo numérico preserva o lexema reconhecido. */
                    snprintf(token, sizeof(token), "<NUMERO, %s>", yytext);
                    print_token(yylineno, column_number, yytext, token);
                    column_number += yyleng;
                } // NUMERO
    /* Espaços e tabulações avançam a coluna; nova linha a reinicia. */
\n              { column_number = 1; }
{ws}            { column_number += yyleng; }

    /* Qualquer caractere não coberto pelas regras anteriores é um erro léxico. */
{other}         {fprintf(yyout, "Erro léxico na linha %d e coluna %d. Entrada -> \"%s\"\n", yylineno, column_number, yytext); column_number+=yyleng;}

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

void print_token(int numero_linha, int numero_coluna, char * lexema, char *token) {
    /* Centraliza o formato de saída exigido para os tokens. */
    fprintf(yyout, "Linha: %d; Coluna: %d; Lexema: %s; Token: %s\n", numero_linha, numero_coluna, lexema, token);
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


int main(int argc, char *argv[]){
    /* A entrada é o arquivo recebido como primeiro argumento. */
    yyin = fopen(argv[1], "r");
    yyout=stdout;
    yylex();
    fclose(yyin);
    imprimir_tabela_simbolos();
    return 0;
}
