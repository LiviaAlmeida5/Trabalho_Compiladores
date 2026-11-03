# Trabalho_Compiladores

Analisadores léxico (Flex) e sintático (Bison) de uma mini linguagem.

Dependências: Bison, Flex, GCC e a biblioteca `libfl`.

Comando para executar:

```bash
./compiler.sh programa.txt
```

Os corpos de `if`, `else` e `while` podem ser um único item ou um bloco delimitado
por chaves. Em condicionais aninhadas sem chaves, o `else` é associado ao `if`
aberto mais próximo.
