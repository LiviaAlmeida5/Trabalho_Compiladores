%option noyywrap yylineno

%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−− Definitions −−−−−−−−−−−−−−−−−−−−−−−−−−*/
#include<stdio.h>
#define MAX_IDS 100000
#define MAX_TAMANHO_ID 100

void coluna_comentario_multilinha();
int inserir_tabela(char *lexema);
int procurar_tabela(char *lexema);
void print_token(int numero_linha, int numero_coluna, char * lexema, char *token);

typedef struct{
    char lexema[MAX_TAMANHO_ID + 1]; 
} Simbolo;

Simbolo tabela_simbolo[MAX_IDS];
int posicao = 0;

int column_number = 1;
%}

digit [0-9]
letter [A-Za-z]
delim [ \t]
number {digit}+(\.{digit}+)?
id {letter}({letter}|{digit})*
comentario_uma_linha "//"([^\n])*
comentario_multiplas_linhas "/*"([^*]|(\*)+([^*/]))*(\*)+\/
comentario_multiplas_linhas_sem_fechamento "/*"([^*]|(\*)+([^*/]))*(\*)*
ws {delim}+
other .



%%
%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−−−−− Rules −−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/
%}

{comentario_multiplas_linhas}   { coluna_comentario_multilinha();}
{comentario_multiplas_linhas_sem_fechamento}   { fprintf(yyout, "Erro: comentário multilinha sem fechamento na linha %d e coluna %d\n", yylineno, column_number);}
{comentario_uma_linha}          {   }

"if"            { print_token(yylineno, column_number, yytext, "<IF>"); column_number += yyleng; } // IF
"else"          { print_token(yylineno, column_number, yytext, "<ELSE>"); column_number += yyleng; } // ELSE
"while"         { print_token(yylineno, column_number, yytext, "<WHILE>"); column_number += yyleng; } // WHILE
"print"         { print_token(yylineno, column_number, yytext, "<PRINT>"); column_number += yyleng; } // PRINT
"read"          { print_token(yylineno, column_number, yytext, "<READ>"); column_number += yyleng; } // READ

"int"           { print_token(yylineno, column_number, yytext, "<INT>"); column_number += yyleng; } // INT
"float"         { print_token(yylineno, column_number, yytext, "<FLOAT>"); column_number += yyleng; } // FLOAT

"+"             { print_token(yylineno, column_number, yytext, "<MAIS>"); column_number += yyleng; } // MAIS
"-"             { print_token(yylineno, column_number, yytext, "<MENOS>"); column_number += yyleng; } // MENOS
"*"             { print_token(yylineno, column_number, yytext, "<MULT>"); column_number += yyleng; } // MULT
"/"             { print_token(yylineno, column_number, yytext, "<DIV>"); column_number += yyleng; } // DIV
"%"             { print_token(yylineno, column_number, yytext, "<MOD>"); column_number += yyleng; } // MOD

"<="            { print_token(yylineno, column_number, yytext, "<MENOR_IGUAL>"); column_number += yyleng; } // MENOR_IGUAL
">="            { print_token(yylineno, column_number, yytext, "<MAIOR_IGUAL>"); column_number += yyleng; } // MAIOR_IGUAL
"=="            { print_token(yylineno, column_number, yytext, "<IGUAL>"); column_number += yyleng; } // IGUAL
"<>"            { print_token(yylineno, column_number, yytext, "<DIFERENTE>"); column_number += yyleng; } // DIFERENTE
"<"             { print_token(yylineno, column_number, yytext, "<MENOR>"); column_number += yyleng; } // MENOR
">"             { print_token(yylineno, column_number, yytext, "<MAIOR>"); column_number += yyleng; } // MAIOR

"&&"            { print_token(yylineno, column_number, yytext, "<E>"); column_number += yyleng; } // E
"||"            { print_token(yylineno, column_number, yytext, "<OU>"); column_number += yyleng; } // OU
"!"             { print_token(yylineno, column_number, yytext, "<NAO>"); column_number += yyleng; } // NAO

";"             { print_token(yylineno, column_number, yytext, "<PONTO_VIRGULA>"); column_number += yyleng; } // PONTO_VIRGULA
","             { print_token(yylineno, column_number, yytext, "<VIRGULA>"); column_number += yyleng; } // VIRGULA
"("             { print_token(yylineno, column_number, yytext, "<ABRE_PARENTESES>"); column_number += yyleng; } // ABRE_PARENTESES
")"             { print_token(yylineno, column_number, yytext, "<FECHA_PARENTESES>"); column_number += yyleng; } // FECHA_PARENTESES
"{"             { print_token(yylineno, column_number, yytext, "<ABRE_CHAVES>"); column_number += yyleng; } // ABRE_CHAVES
"}"             { print_token(yylineno, column_number, yytext, "<FECHA_CHAVES>"); column_number += yyleng; } // FECHA_CHAVES

{id}            {
                    int valor_token_id = inserir_tabela(yytext);
                    char token[50];

                    if (valor_token_id == -1) {
                        fprintf(yyout, "Erro: número máximo de IDs atingido (%d) na linha %d e coluna %d. Entrada -> \"%s\"\n", MAX_IDS, yylineno, column_number, yytext);
                    } else if(valor_token_id == -2) {
                        fprintf(yyout, "Erro: o identificador excede o limite de %d caracteres (%d) na linha %d e coluna %d. Entrada -> \"%s\"\n", MAX_TAMANHO_ID, yylineno, column_number, yytext);
                    }
                    else {
                        snprintf(token, sizeof(token), "<ID, %d>", valor_token_id);
                        print_token(yylineno, column_number, yytext, token);
                    }
                    column_number += yyleng;
                } // ID
{number}        {
                    char token[50];

                    snprintf(token, sizeof(token), "<NUMERO, %s>", yytext);
                    print_token(yylineno, column_number, yytext, token);
                    column_number += yyleng;
                } // NUMERO
\n              { column_number = 1; }
{ws}            { column_number += yyleng; }

{other}         {fprintf(yyout, "Erro léxico na linha %d e coluna %d. Input -> \"%s\"\n", yylineno, column_number, yytext); column_number+=yyleng;}

%%
/*−−−−−−−−−−−−−−−−−−−−−−−− User subrotines −−−−−−−−−−−−−−−−−−−−−−−−*/

void coluna_comentario_multilinha(){
    for(int i=0; i<yyleng; i++){
        if(yytext[i]=='\n'){
            column_number = 1;
        }else{
            column_number++;
        }
    }
}

void print_token(int numero_linha, int numero_coluna, char * lexema, char *token) {
    fprintf(yyout, "Linha: %d; Coluna: %d; Lexema: %s; Token: %s\n", numero_linha, numero_coluna, lexema, token);
}

int inserir_tabela(char *lexema){
   
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
    printf("\n===== TABELA DE SÍMBOLOS =====\n");
    printf("%-5s | %-30s\n", "ID", "LEXEMA");
    printf("--------------------------------------\n");

    for (int i = 0; i < posicao; i++) {
        printf("%-5d | %-30s\n", i, tabela_simbolo[i].lexema);
    }

    printf("--------------------------------------\n");
}


int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    yyout=stdout;
    yylex();
    fclose(yyin);
    imprimir_tabela_simbolos();
    return 0;
}

/*
Arrumar o nome das variáveis
A impressão dos símbolos na tela
*/
