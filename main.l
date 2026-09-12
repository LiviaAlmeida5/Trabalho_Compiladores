%option noyywrap yylineno

%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−− Definitions −−−−−−−−−−−−−−−−−−−−−−−−−−*/
#include<stdio.h>
#define MAX_SIZE 100000

void coluna_comentario_multilinha();
int inserir_tabela(char *lexema);
int procurar_tabela(char *lexema);
void print_token(int numero_linha, int numero_coluna, char * lexema, char *token);

typedef struct{
    char lexema[100]; 
} Simbolo;

Simbolo tabela_simbolo[MAX_SIZE];
int posicao = 0;

int column_number = 1;
%}

digit [0-9]
letter [A-Za-z]
delim [ \t\n]
declaracao "int"|"float"
number {digit}+(\.{digit}+)?
id {letter}({letter}|{digit})*
comentario_uma_linha "//"([^\n])*
comentario_multiplas_linhas "/*"([^*]|(\*)+([^*/]))*(\*)+\/
ws {delim}+
other .



%%
%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−−−−− Rules −−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/
%}

{comentario_multiplas_linhas}   { coluna_comentario_multilinha();}
{comentario_uma_linha}          {   }

"if"            { fprintf(yyout,"%d(%d): if (IF)\n", yylineno,column_number); column_number+=yyleng; } // IF
"else"          { fprintf(yyout,"%d(%d): else (ELSE)\n", yylineno,column_number); column_number+=yyleng; } // ELSE
"while"         { fprintf(yyout,"%d(%d): while (WHILE)\n", yylineno,column_number); column_number+=yyleng; } // WHILE
"print"         { fprintf(yyout,"%d(%d): print (PRINT)\n", yylineno,column_number); column_number+=yyleng; } // PRINT
"read"          { fprintf(yyout,"%d(%d): read (READ)\n", yylineno,column_number); column_number+=yyleng; } // READ

"int"           { fprintf(yyout,"%d(%d): int (INT)\n", yylineno,column_number); column_number+=yyleng; } // INT
"float"         { fprintf(yyout,"%d(%d): if (IF)\n", yylineno,column_number); column_number+=yyleng; } // FLOAT

"+"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MAIS
"-"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MENOS
"*"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MULT
"/"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // DIV
"%"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MOD

"<="            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MAIOR_IGUAL
">="            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MENOR_IGUAL
"<"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MENOR
">"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // MAIOR
"=="            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // IGUAL
"<>"            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // DIFERENTE

"||"            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // E
"&&"            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // OU
"!"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; } // NAO

";"             { fprintf(yyout,"%d(%d): ; (;)\n", yylineno,column_number); column_number+=yyleng; } // PONTO_VIRGULA
","             { fprintf(yyout,"%d(%d): , (,)\n", yylineno,column_number); column_number+=yyleng; } // VIRGULA
"("             { fprintf(yyout,"%d(%d): - (par)\n", yylineno,column_number); column_number+=yyleng; } // ABRE_PARENTESES
")"             { fprintf(yyout,"%d(%d): - (rap)\n", yylineno,column_number); column_number+=yyleng; } // FECHA_PARENTESES
"{"             { fprintf(yyout,"%d(%d): - (cha)\n", yylineno,column_number); column_number+=yyleng; } // ABRE_CHAVES
"}"             { fprintf(yyout,"%d(%d): - (ahc)\n", yylineno,column_number); column_number+=yyleng; } // FECHA_CHAVES

{declaracao}    { fprintf(yyout,"%d(%d): %s (DECLARACAO)\n", yylineno,column_number,yytext); column_number+=yyleng; }
{id}            { int algo = inserir_tabela(yytext); char texto[50]; snprintf(texto, sizeof(texto), "<ID, %d>", algo); if(algo == -1) fprintf(yyout, "Erro: máximo de ids atingios na linha %d e coluna %d. Input -> \"%s\"\n", yylineno, column_number, yytext); algoelse print_lexema(yylineno, column_number, yytext, texto); column_number+=yyleng; }
{number}        { fprintf(yyout,"%d(%d): %s (NUMBER)\n", yylineno,column_number,yytext); column_number+=yyleng; } <NUMBER, 1.7>
\n              { column_number = 1; }
{ws}            { column_number += yyleng; }

{other}         {fprintf(yyout, "Lexical error on line %d and column %d. Input -> \"%s\"\n", yylineno, column_number, yytext); column_number+=yyleng;}

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

int procurar_tabela(char *lexema){
    for(int i=0; i<posicao; i++){
        if(strcmp(tabela_simbolo[i].lexema, lexema) == 0){
            return i;
        }
    }
    return -1;
}

int inserir_tabela(char *lexema){
    int p = procurar_tabela(lexema);
    
    if(p == -1){
        if(posicao>=MAX_SIZE){
            return -1;
        }
        strncpy(tabela_simbolo[posicao].lexema, lexema, sizeof(tabela_simbolo[posicao].lexema) - 1);
        tabela_simbolo[posicao].lexema[sizeof(tabela_simbolo[posicao].lexema) - 1] = '\0';
        posicao++;
        return posicao-1;
    }else{
        return p;
    }
}

void imprimirTabelaSimbolos() {
    printf("\n===== TABELA DE SIMBOLOS =====\n");
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
    imprimirTabelaSimbolos();
    return 0;
}

/*
Arrumar o nome das variáveis
A impressão dos símbolos na tela
*/