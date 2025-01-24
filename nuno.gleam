import gleam/list
import gleam/string
import sgleam/check

//   Projeto dos tipos de dados: Para solucionar o problema, é conveniente criar tipos de dados que
// adequem-se aos requisitos que são apresentados. Inicialmente vou criar uma estutura de dados para
// representar os operadores válidos da expressão. Além disso, vou criar um tipo enumerado com 2
// valores opcionais para poder representar um operador e um número em um mesmo tipo de dados. Uma
// estrutura para representar os tipos de erros que podem ser encontrados na entrada também será
// necessária. Por fim, para a operação de conversão da String para uma lista de símbolos, vou
// criar uma estrutura enumerada para indicar o qual foi o último tipo de dado lido.

/// Estrutura enumerada que representa os operadores válidos da expressão
pub type Operador {
  // Representa o operação de adição +
  Add
  // Representa o operador de subtração -
  Sub
  // Representa o operador de multiplicação *
  Mul
  // Representa o operador de divisão inteira /
  Div
}

pub type Parentesis {
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

/// Estrutura enumerada que representa o tipo de erro presente na String de entrada
pub type ErroConvert {
  LetraPresente
  ParentesesErrado
  ExcessoOperador
  ExcessoOperando
}

/// Estrutura enumerada que representa os erros na 
pub type ErroAvalia {
  ErroDivPorZero
  ErroFaltaOperandos
  ErroExcessoOperandos
}

/// Estrutura enumerada que representa tipo de símbolo lido anteriormente - Operador ou Operando
pub type Last {
  // Representa que o último dado lido compõe uma Operação
  Op
  // Representa que o último dado lido compõe um Número
  Num
}
// // Projeto de funções principais e auxiliares para resolução do problema:

// /// A partir de uma expressão númerica em notação posfixa, ou seja onde os operadores aparecem
// /// depois dos operandos, e retorna o valor calculado dessa expressão
// pub fn avalia_posfix(expression: List(Symbol)) -> Result(Int, ErroAvalia) {
//   let acc: List(Int) = []
//   case expression {
//     [f, ..r] case f {
//       Operador(num) -> 
//     }
//   }
// }

// pub fn avalia_posfix.examples() {
//   check.eq(avalia_posfix([Operando(5), Operando(6), Operador(Mul), Operando(3), Operador(Add)]), Ok(33))
//   check.eq(avalia_posfix([Operando(9), Operando(4), Operador(Div), Operando(2), Operador(Sub)]), Ok(0))
//   check.eq(avalia_posfix([Operando(3), Operando(0), Operador(Div)]), Error(ErroDivPorZero))
// }

// pub fn a(expression: List(Symbol), acc: List(Int)) -> List(Int) {
//   case expression {
//     [f, ..r] case f {
//       Operador(x) -> -> case acc {
//         [a, b, ..resto] -> use a(r, [opera(a, b, x), ..resto])
//         [] || [_] -> Error(ErroFaltaOperandos)
//       }
//       Operando(num) -> [num, ..acc]
//     }
//   }
// }

// pub fn opera(a: Int, b: Int, op: Operador) -> Int {
//   case Operador {
//   Add -> a + b
//   Sub -> a - b
//   Mul -> a * b
//   Div -> a / b
//   }
// }
// Rascunho da função que converte String para Result(List(Symbol), Erro). Ainda sem lógica.

// /// Caso a string represente uma operação válida, ou seja, sem letras, com parênteses corretos e
// /// operadores e operantos em quantidade e posições válidas, converte-a para uma lista de símbolos.
// /// Caso contrário, retorna o primeiro erro encontrado na expressão.
// pub fn str_to_symbols(string: String) -> Result(List(Symbol), Erro) {
//   string
//   |> string.split("")
//   |> list
// }

// pub fn processa_string(str_lst: List(String)) -> Result(List(Symbol), Erro) {
//   todo
// }

// pub fn processa_char(
//   char: String,
//   acc: #(List(Symbol), Last),
// ) -> Result(#(List(Symbol), Last), Erro) {
//   todo
// }
