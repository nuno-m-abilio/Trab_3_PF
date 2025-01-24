//   Projeto dos tipos de dados: Para solucionar o problema, é conveniente criar tipos de dados que
// adequem-se aos requisitos que são apresentados. Inicialmente vou criar uma estutura de dados para
// representar os operadores válidos da expressão. Além disso, vou criar um tipo enumerado com 2
// valores opcionais para poder representar um operador e um número em um mesmo tipo de dados. Por
// fim, para a operação de conversão da String para uma lista de símbolos, vou criar uma estrutura
// enumerada para indicar o qual foi o último tipo de dado lido.

/// Estrutura enumerada que representa os operadores válidos da expressão
pub type Operador {
  // Representa o operação de adição +
  Add
  // Representa o operador de subtração -
  Sub
  // Representa o operador de multiplicação *
  Mul
  // Representa o operador de divisão inteira //
  Div
  // Representa o parenteses à esquerda/Left (
  LPa
  // Representa o parenteses à direita/Right
  RPa
}

/// Estrutura que representa um símbolo em uma expressaõ, que pode ser tanto operador quanto operando
pub type Symbol {
  // Representa um Operador
  Operador(Operador)
  // Representa um Operando
  Operando(Int)
}

/// Estrutura enumerada que representa tipo de símbolo lido anteriormente - Operador ou Operando
pub type Last {
  // Representa que o último dado lido compõe uma Operação
  Op
  // Representa que o último dado lido compõe um Número
  Num
}
