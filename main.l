%option noyywrap yylineno

%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−− Definitions −−−−−−−−−−−−−−−−−−−−−−−−−−*/
#include<stdio.h>

int column_number = 1;
%}

digit [0-9]
letter [A-Za-z]
delim [ \t\n]
declaracao "int"|"float"
number [-|+]?{digit}+(\.{digit}+)?
id {letter}({letter}|{digit})*
comentario_uma_linha "//"([^\n])*
comentario_multiplas_linhas "/*"([^*])*\*\/
ws {delim}+
other .



%%
%{
/*−−−−−−−−−−−−−−−−−−−−−−−−−−−−− Rules −−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/
%}

{comentario_multiplas_linhas}   { fprintf(yyout,"%d(%d): : (  comeentário)\n", yylineno,column_number); column_number+=yyleng; }
{comentario_uma_linha}          { }

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
{id}            { fprintf(yyout,"%d(%d): %s (ID)\n", yylineno,column_number,yytext); column_number+=yyleng; }
{number}        { fprintf(yyout,"%d(%d): %s (NUMBER)\n", yylineno,column_number,yytext); column_number+=yyleng; }
\n              { column_number = 1; }
{ws}            { column_number += yyleng; }

{other}         {fprintf(yyout, "Lexical error on line %d and column %d. Input -> \"%s\"\n", yylineno, column_number, yytext);
column_number+=yyleng;}

%%
/*−−−−−−−−−−−−−−−−−−−−−−−− User subrotines −−−−−−−−−−−−−−−−−−−−−−−−*/
int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    yyout=stdout;
    yylex();
    fclose(yyin);
    return 0;
}