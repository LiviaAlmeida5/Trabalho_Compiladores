#!/bin/bash

# Interrompe a execução se alguma etapa de geração ou compilação falhar.
set -e

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <arquivo-fonte>" >&2
    exit 1
fi

ARQUIVO="$1"

if [ ! -f "$ARQUIVO" ]; then
    echo "Erro: arquivo '$ARQUIVO' não encontrado." >&2
    exit 1
fi

# O cabeçalho gerado pelo Bison contém os tokens usados pelo Flex.
bison -d -o parser.tab.c parser.y
flex -o lex.yy.c lexer.l

# Compila e integra os dois analisadores.
gcc parser.tab.c lex.yy.c -o compilador -lfl

# O analisador gerado abre o arquivo recebido como argumento.
./compilador "$ARQUIVO"
