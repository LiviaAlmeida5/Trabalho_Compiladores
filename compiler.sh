#!/bin/bash

# Verifica se foi informado um arquivo
if [ $# -ne 1 ]; then
    echo "Uso: $0 <arquivo-fonte>"
    exit 1
fi

ARQUIVO="$1"

# Verifica se o arquivo existe
if [ ! -f "$ARQUIVO" ]; then
    echo "Erro: arquivo '$ARQUIVO' não encontrado."
    exit 1
fi

# Gera o analisador léxico
flex lexer.l

# Compila o código gerado
gcc lex.yy.c -o lexer -lfl

# Executa o analisador usando o arquivo fornecido
./lexer < "$ARQUIVO"