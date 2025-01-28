import gleam/list
import gleam/result
import gleam/string
import sgleam/check

//   Projeto dos tipos de dados: Para solucionar o problema, é conveniente criar tipos de dados que
// adequem-se aos requisitos que são apresentados. Inicialmente vou criar uma estutura de dados para
// representar os operadores válidos da expressão. Além disso, vou criar um tipo enumerado com 2
// valores opcionais para poder representar um operador e um número em um mesmo tipo de dados. Uma
// estrutura para representar os tipos de erros que podem ser encontrados na entrada também será
// necessária. Por fim, para a operação de conversão da String para uma lista de símbolos, vou
// criar uma estrutura enumerada para indicar o qual foi o último tipo de dado lido.

/// Estrutura enumerada que representa os operadores válidos da expressão posfixa
pub type OperadorPosFix {
  // Representa o operação de adição +
  Add
  // Representa o operador de subtração -
  Sub
  // Representa o operador de multiplicação *
  Mul
  // Representa o operador de divisão inteira /
  Div
}

pub type Parenteses {
  // Representa o parenteses à esquerda/Left (
  LPa
  // Representa o parenteses à direita/Right
  RPa
}

/// Estrutura enumerada que representa os operadores válidos da expressão infixa
pub type OperadorInfFix {
  //
  Operador(OperadorPosFix)
  //
  Parenteses(Parenteses)
}

/// Estrutura que representa um símbolo em uma expressão com notação posfixa, que pode ser tanto operador quanto operando
pub type SymbolPosFix {
  // Representa um Operador
  OperadorSP(OperadorPosFix)
  // Representa um Operando
  OperandoSP(Int)
}

/// Estrutura que representa um símbolo em uma expressão com notação infixa, que pode ser tanto operador quanto operando ou parênteses
pub type SymbolInFix {
  // Representa um Operador
  OperadorSI(OperadorInfFix)
  // Representa um Operando
  OperandoSI(Int)
}

/// Estrutura enumerada que representa o tipo de erro presente na String de entrada
pub type Erro {
  LetraPresente
  ParentesesErrado
  ExcessoOperador
  ExcessoOperando
  FaltaOperando
  DivPorZero
}

// /// Estrutura enumerada que representa os erros na 
// pub type ErroAvalia {
//   ErroDivPorZero
//   ErroFaltaOperandos
//   ErroExcessoOperandos
// }

/// Estrutura enumerada que representa tipo de símbolo lido anteriormente - Operador ou Operando
pub type Last {
  // Representa que o último dado lido compõe uma Operação
  Op
  // Representa que o último dado lido compõe um Número
  Num
}

// // Projeto de funções principais e auxiliares para resolução do problema:

/// A partir de uma expressão númerica em notação posfixa, ou seja onde os operadores aparecem
/// depois dos operandos, retorna o valor calculado dessa expressão
pub fn avalia_posfix(expressions: List(SymbolPosFix)) -> Result(Int, Erro) {
  let pilha_final =
    list.fold_until(expressions, [], fn(acc, i) {
      let p = processa_posfix(acc, i)
      case p {
        Ok(pilha) -> list.Continue(p)
        Error(_) -> list.Stop(acc)
      }
    })
  case pilha_final {
    Error(x) -> Error(x)
    Ok(pilha) ->
      case pilha {
        [] -> Error(FaltaOperando)
        [a] -> Ok(a)
        _ -> Error(ExcessoOperando)
      }
  }
}

pub fn avalia_posfix_examples() {
  check.eq(
    avalia_posfix([
      OperandoSP(5),
      OperandoSP(6),
      OperadorSP(Mul),
      OperandoSP(3),
      OperadorSP(Add),
    ]),
    Ok(33),
  )
  check.eq(
    avalia_posfix([
      OperandoSP(5),
      OperandoSP(0),
      OperadorSP(Mul),
      OperandoSP(3),
      OperadorSP(Add),
    ]),
    Error(DivPorZero),
  )
  check.eq(
    avalia_posfix([OperandoSP(5), OperandoSP(6), OperadorSP(Mul), OperandoSP(3)]),
    Error(ExcessoOperando),
  )
  check.eq(
    avalia_posfix([
      OperandoSP(5),
      OperandoSP(6),
      OperadorSP(Mul),
      OperandoSP(3),
      OperadorSP(Add),
      OperadorSP(Add),
    ]),
    Error(FaltaOperando),
  )
}

/// Isso aqui eu não preciso de recursão dentro
pub fn processa_posfix(
  pilha: List(Int),
  simbolo: SymbolPosFix,
) -> Result(List(Int), Erro) {
  case simbolo {
    OperandoSP(num) -> Ok([num, ..pilha])
    OperadorSP(op) ->
      case pilha {
        [b, _, ..] if op == Div && b == 0 -> Error(DivPorZero)
        [b, a, ..resto] -> Ok([opera(a, b, op), ..resto])
        _ -> Error(FaltaOperando)
      }
  }
}

pub fn processa_posfix_examples() {
  check.eq(processa_posfix([5, 6], OperadorSP(Mul)), Ok([30]))
  check.eq(processa_posfix([30], OperandoSP(5)), Ok([5, 30]))
  check.eq(processa_posfix([30], OperadorSP(Add)), Error(FaltaOperando))
  check.eq(processa_posfix([0, 6], OperadorSP(Div)), Error(DivPorZero))
}

pub fn opera(a: Int, b: Int, op: OperadorPosFix) -> Int {
  case op {
    Add -> a + b
    Sub -> a - b
    Mul -> a * b
    Div -> a / b
  }
}
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
