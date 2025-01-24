# Trab_3_PF
Trabalho 3 da disciplina de Programação Funcional

A notação que usamos normalmente para escrever expressões aritméticas é chamada de notação infixa, isso
porque os operadores ficam entre os operandos, como em 3 + 5 * 6. Também podemos utilizar a notação
posfixa, onde os operadores aparecem depois dos operandos. Na notação posfixa a expressão anterior é
escrita como 5 6 * 3 +. Dois aspectos são interessantes nessa notação: os parênteses não são necessários e
o algoritmo de avaliação da expressão é mais simples.

Para avaliar uma expressão na notação pós-fixa podemos utilizar o seguinte algoritmo, que utiliza uma pilha
para auxilar na avaliação:

1) Analise a expressão da esquerda para a direita, um símbolo por vez:
• Se o símbolo for um operando, empilhe-o;
• Se o símbolo for um operador, desempilhe dois valores da pilha, aplique o operador, e empilhe o
resultado.

2) Garanta que existe apenas um valor no topo da pilha e devolva esse valor.
Para o exemplo 5 6 * 3 + os passos do algoritmos seria:
• Analisando o 5: empilhar o 5
• Analisando o 6: empilhar o 6
• Analisando o *: desempilhar o 6 e o 5, multiplicar os dois e empilhar o 30
• Analisando o 3: empilhar o 3
• Analisando o +: desempilhar o 3 e o 30, somar os dois e empilhar o 33
• Acabou a sequência: assegurar que só tem um elemento na pilha e devolver o valor

Para converter uma expressão na forma infixa para a forma pós-fixa o algoritmo é um pouco mais elaborado,
ele usa uma pilha para os operadores e produz uma lista como saída:

1) Analise a expressão da esquerda para a direita, um símbolo por vez:
• Se o símbolo for um operando, adicione o símbolo na saída.
• Se o símbolo for um operador:
– Enquanto o topo da pilha tiver um operador de maior ou igual precedência que o operador
atual, remova-o da pilha e adicione-o à saída.
– Empilhe o operador atual.
• Se o símbolo for “(” , empilhe-o.
• Se o símbolo for “)”, remova operadores da pilha e adicione-os à saída até encontrar um “(”.

2) Remova todos os operadores restantes na pilha e adicione-os à saída.
O trabalho consiste na implementação de uma função que receba como entrada uma expressão (string) na
notação infixa, e calcule o valor da expressão. A implementação deve utilizar os dois algoritmos descritos
anteriormente. Note que a pilha no primeiro algoritmo só pode armazenar números e no segundo algoritmo
só pode armazenar operadores.

Requisitos:
O programa deve
1) Definir um tipo de dado para representar um símbolo em um expressão;
2) Tratar expressões inválidas.
3) Usar a função fold nos lugares adequados.
O programa não deve
1) Falhar;
2) Utilizar funções recursivas que não sejam em cauda.