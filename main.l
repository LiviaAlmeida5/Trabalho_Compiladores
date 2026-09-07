%option noyywrap yylineno

%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−− Definitions −−−−−−−−−−−−−−−−−−−−−−−−−−*/
#include<stdio.h>
#define MAX_SIZE 100

typedef enum{
    IF,
    WHILE,
    ELSE,
    PRINT,
    READ,
    ID
} Tipo;

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
number [-|+]?{digit}+(\.{digit}+)?
id {letter}({letter}|{digit})*
comentario_uma_linha "//"([^\n])*
comentario_multiplas_linhas "/*"([^*]|(\*)+([^*/]))*(\*)+\/
ws {delim}+
other .


void inserir_tabela(char *lexema);
int procurar_tabela(char *lexema);


%%
%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−−−−− Rules −−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/
%}

{comentario_multiplas_linhas}   { coluna_comentario_multilinha();}
{comentario_uma_linha}          {   }

"if"            { fprintf(yyout,"%d(%d): if (IF)\n", yylineno,column_number); column_number+=yyleng; }
"else"          { fprintf(yyout,"%d(%d): else (ELSE)\n", yylineno,column_number); column_number+=yyleng; }
"while"         { fprintf(yyout,"%d(%d): while (WHILE)\n", yylineno,column_number); column_number+=yyleng; }
"print"         { fprintf(yyout,"%d(%d): print (PRINT)\n", yylineno,column_number); column_number+=yyleng; }
"read"          { fprintf(yyout,"%d(%d): read (READ)\n", yylineno,column_number); column_number+=yyleng; }

"+"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"-"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"*"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"/"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"%"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }

"<="            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
">="            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"<"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
">"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"=="            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"<>"            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }

"||"            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"&&"            { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }
"!"             { fprintf(yyout,"%d(%d): : (;)\n", yylineno,column_number); column_number+=yyleng; }

";"             { fprintf(yyout,"%d(%d): ; (;)\n", yylineno,column_number); column_number+=yyleng; }
","             { fprintf(yyout,"%d(%d): , (,)\n", yylineno,column_number); column_number+=yyleng; }
"("             { fprintf(yyout,"%d(%d): - (par)\n", yylineno,column_number); column_number+=yyleng; }
")"             { fprintf(yyout,"%d(%d): - (rap)\n", yylineno,column_number); column_number+=yyleng; }
"{"             { fprintf(yyout,"%d(%d): - (cha)\n", yylineno,column_number); column_number+=yyleng; }
"}"             { fprintf(yyout,"%d(%d): - (ahc)\n", yylineno,column_number); column_number+=yyleng; }

{declaracao}    { fprintf(yyout,"%d(%d): %s (DECLARACAO)\n", yylineno,column_number,yytext); column_number+=yyleng; }
{id}            { int algo = inserir_tabela(yytext); fprintf(yyout,"%d(%d): %s (ID%d)\n", yylineno,column_number,yytext,
                if(algo==-1)); column_number+=yyleng; }
{number}        { fprintf(yyout,"%d(%d): %s (NUMBER)\n", yylineno,column_number,yytext); column_number+=yyleng; }
\n              { column_number = 1; }
{ws}            { column_number += yyleng; }

{other}         {fprintf(yyout, "Lexical error on line %d and column %d. Input -> \"%s\"\n", yylineno, column_number, yytext);
column_number+=yyleng;}

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


int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    yyout=stdout;
    yylex();
    fclose(yyin);
    return 0;
}
