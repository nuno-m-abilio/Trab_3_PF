import gleam/io
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
pub type OperadorInFix {
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
  OperadorSI(OperadorInFix)
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

// Projeto de funções principais e auxiliares para resolução do problema:

/// A partir de uma expressão númerica em notação posfixa expression, ou seja onde os operadores
/// aparecem depois dos operandos, retorna o valor calculado dessa expressão ou o primeiro erro
/// encontrado.
pub fn avalia_posfix(expression: List(SymbolPosFix)) -> Result(Int, Erro) {
  let pilha_final =
    list.fold_until(expression, Ok([]), fn(acc, i) {
      // Nota-se que isso é uma recursão em cauda e em ambos continue e stop retorna-se apenas isso
      let p = processa_posfix(acc, i)
      case p {
        Ok(_) -> list.Continue(p)
        Error(_) -> list.Stop(p)
      }
    })
  use pilha <- result.try(pilha_final)
  case pilha {
    [] -> Error(FaltaOperando)
    [a] -> Ok(a)
    _ -> Error(ExcessoOperando)
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
      OperandoSP(2),
      OperandoSP(3),
      OperandoSP(4),
      OperadorSP(Mul),
      OperadorSP(Add),
    ]),
    Ok(14),
  )
  check.eq(
    avalia_posfix([
      OperandoSP(5),
      OperandoSP(0),
      OperadorSP(Div),
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

// Versão com a pilha não sendo result
/// Isso aqui eu não preciso de recursão dentro
// pub fn processa_posfix(
//   pilha: List(Int),
//   simbolo: SymbolPosFix,
// ) -> Result(List(Int), Erro) {
//   case simbolo {
//     OperandoSP(num) -> Ok([num, ..pilha])
//     OperadorSP(op) ->
//       case pilha {
//         [b, _, ..] if op == Div && b == 0 -> Error(DivPorZero)
//         [b, a, ..resto] -> Ok([opera(a, b, op), ..resto])
//         _ -> Error(FaltaOperando)
//       }
//   }
// }

/// Aplica o efeito de um símbolo de uma expressão em notação posfixa sobre uma pilha pilha_result.
/// Essa pilha inicia-se como um result que pode incluir erros, pois na função avalia_posfix usa-se
/// um fold com essa função. Nesse sentido, o valor do acumulador deve ser igual o da saída.
pub fn processa_posfix(
  pilha_result: Result(List(Int), Erro),
  simbolo: SymbolPosFix,
) -> Result(List(Int), Erro) {
  use pilha <- result.try(pilha_result)
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
  check.eq(processa_posfix(Ok([5, 6]), OperadorSP(Mul)), Ok([30]))
  check.eq(processa_posfix(Ok([30]), OperandoSP(5)), Ok([5, 30]))
  check.eq(processa_posfix(Ok([30]), OperadorSP(Add)), Error(FaltaOperando))
  check.eq(processa_posfix(Ok([0, 6]), OperadorSP(Div)), Error(DivPorZero))
}

/// Realiza uma operação entre dois inteiros "a" e "b" com o operador op  
pub fn opera(a: Int, b: Int, op: OperadorPosFix) -> Int {
  case op {
    Add -> a + b
    Sub -> a - b
    Mul -> a * b
    Div -> a / b
  }
}

/// Faz a tradução de um aexpressão numérica em notação infixa expression em notação posfixa.
pub fn infix_to_posfix(
  expression: List(SymbolInFix),
) -> Result(List(SymbolPosFix), Erro) {
  // Faz todo o passo 1 indicado pelo algoritmo da especificação do trabalho
  let acc_um: #(List(OperadorInFix), List(SymbolPosFix)) = #([], [])
  use passo_um <- result.try(
    list.fold_until(expression, Ok(acc_um), fn(acc, i) {
      case processa_infix(acc, i) {
        Error(e) -> list.Stop(Error(e))
        Ok(tp) -> list.Continue(Ok(tp))
      }
    }),
  )
  // Faz o passo 2 de retirar os operadores que ficaram na pilha e colocar na saída
  use passo_um_pilha <- result.try(
    result.all(list.map(passo_um.0, opif_to_sipf)),
  )
  let passo_dois =
    list.fold(passo_um_pilha, passo_um.1, fn(acc, i) { [i, ..acc] })

  // Inverte a lista de saída final para ela ficar na configuração certa de ser processada
  passo_dois
  |> list.fold([], fn(acc, i) { [i, ..acc] })
  |> Ok()
}

pub fn infix_to_posfix_examples() {
  check.eq(
    infix_to_posfix([
      OperandoSI(2),
      OperadorSI(Operador(Add)),
      OperandoSI(3),
      OperadorSI(Operador(Mul)),
      OperandoSI(4),
    ]),
    Ok([
      OperandoSP(2),
      OperandoSP(3),
      OperandoSP(4),
      OperadorSP(Mul),
      OperadorSP(Add),
    ]),
  )
  check.eq(
    infix_to_posfix([
      OperadorSI(Parenteses(LPa)),
      OperandoSI(7),
      OperadorSI(Operador(Mul)),
      OperadorSI(Parenteses(LPa)),
      OperandoSI(8),
      OperadorSI(Operador(Sub)),
      OperandoSI(2),
      OperadorSI(Parenteses(RPa)),
      OperadorSI(Operador(Div)),
      OperandoSI(5),
      OperadorSI(Parenteses(RPa)),
    ]),
    Ok([
      OperandoSP(7),
      OperandoSP(8),
      OperandoSP(2),
      OperadorSP(Sub),
      OperadorSP(Mul),
      OperandoSP(5),
      OperadorSP(Div),
    ]),
  )
  check.eq(
    infix_to_posfix([
      OperadorSI(Parenteses(LPa)),
      OperadorSI(Parenteses(LPa)),
      OperadorSI(Parenteses(RPa)),
      OperadorSI(Parenteses(RPa)),
    ]),
    Ok([]),
  )
  check.eq(
    infix_to_posfix([
      OperadorSI(Parenteses(LPa)),
      OperadorSI(Parenteses(LPa)),
      OperandoSI(5),
      OperadorSI(Operador(Add)),
      OperandoSI(2),
      OperadorSI(Parenteses(RPa)),
      OperadorSI(Operador(Mul)),
      OperadorSI(Parenteses(LPa)),
      OperandoSI(8),
      OperadorSI(Operador(Sub)),
      OperadorSI(Parenteses(LPa)),
      OperandoSI(3),
      OperadorSI(Operador(Add)),
      OperandoSI(1),
      OperadorSI(Parenteses(RPa)),
      OperadorSI(Operador(Div)),
      OperandoSI(2),
      OperadorSI(Parenteses(RPa)),
      OperadorSI(Parenteses(RPa)),
      OperadorSI(Operador(Add)),
      OperandoSI(4),
      OperadorSI(Parenteses(RPa)),
      OperadorSI(Operador(Mul)),
      OperandoSI(3),
      OperadorSI(Operador(Sub)),
      OperandoSI(6),
      OperadorSI(Operador(Div)),
      OperadorSI(Parenteses(LPa)),
      OperandoSI(2),
      OperadorSI(Operador(Add)),
      OperandoSI(1),
      OperadorSI(Parenteses(RPa)),
    ]),
    Ok([
      OperandoSP(5),
      OperandoSP(2),
      OperadorSP(Add),
      OperandoSP(8),
      OperandoSP(3),
      OperandoSP(1),
      OperadorSP(Add),
      OperandoSP(2),
      OperadorSP(Div),
      OperadorSP(Sub),
      OperadorSP(Mul),
      OperandoSP(4),
      OperadorSP(Add),
      OperandoSP(3),
      OperadorSP(Mul),
      OperandoSP(6),
      OperandoSP(2),
      OperandoSP(1),
      OperadorSP(Add),
      OperadorSP(Div),
      OperadorSP(Sub),
    ]),
  )
}

// Tenta traduzir um operador infixo para um 
pub fn opif_to_sipf(op: OperadorInFix) -> Result(SymbolPosFix, Erro) {
  case op {
    Operador(o) -> Ok(OperadorSP(o))
    Parenteses(p) -> Error(ParentesesErrado)
  }
}

/// A SAIDA SAI DESSA FUNÇÂO INVERTIDA CASO NÂO HAJA ERROS, É NECESSÁRIO INVERTÊ-LA NO FINAL
pub fn processa_infix(
  pilhaesaida: Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro),
  simbolo: SymbolInFix,
) -> Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro) {
  case pilhaesaida {
    Error(e) -> Error(e)
    Ok(#(pilha, saida)) ->
      case simbolo {
        // Operando: adiciona à saída mantendo a pilha
        OperandoSI(numero) -> {
          Ok(#(pilha, [OperandoSP(numero), ..saida]))
        }

        // Operador: processa considerando a pilha atual
        OperadorSI(Operador(op)) -> {
          // Se a pilha estiver vazia, apenas empilha o operador
          case pilha {
            [] -> Ok(#([Operador(op)], saida))
            _ -> {
              // Caso contrário, processa a pilha
              use quase <- result.try(
                list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, i) {
                  processa_op_pilha(acc, i, op)
                }),
              )
              let #(ajuste, igual) = quase
              Ok(#([Operador(op), ..ajuste], igual))
            }
          }
        }

        // Parêntese esquerdo: sempre empilha
        OperadorSI(Parenteses(LPa)) -> {
          Ok(#([Parenteses(LPa), ..pilha], saida))
        }

        // Parêntese direito: desempilha até encontrar o correspondente
        OperadorSI(Parenteses(RPa)) -> {
          case pilha {
            [] -> Error(ParentesesErrado)
            _ ->
              list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, i) {
                processa_rpa(acc, i)
              })
          }
        }
      }
  }
}

pub fn processa_infix_examples() {
  // Caso 1: Expressão com multiplicação e adição
  // Entrada: 2 + 3 * 4
  // Saída esperada: 2 3 4 * +
  check.eq(
    processa_infix(Ok(#([], [])), OperandoSI(2)),
    Ok(#([], [OperandoSP(2)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(Ok(#([], [OperandoSP(2)])), OperadorSI(Operador(Add))),
    Ok(#([Operador(Add)], [OperandoSP(2)])),
    // Pilha vazia, operador vai para pilha
  )
  check.eq(
    processa_infix(Ok(#([Operador(Add)], [OperandoSP(2)])), OperandoSI(3)),
    Ok(#([Operador(Add)], [OperandoSP(3), OperandoSP(2)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(
      Ok(#([Operador(Add)], [OperandoSP(3), OperandoSP(2)])),
      OperadorSI(Operador(Mul)),
    ),
    Ok(#([Operador(Mul), Operador(Add)], [OperandoSP(3), OperandoSP(2)])),
    // Mul tem maior precedência que Add, vai para pilha
  )
  check.eq(
    processa_infix(
      Ok(#([Operador(Mul), Operador(Add)], [OperandoSP(3), OperandoSP(2)])),
      OperandoSI(4),
    ),
    Ok(
      #([Operador(Mul), Operador(Add)], [
        OperandoSP(4),
        OperandoSP(3),
        OperandoSP(2),
      ]),
    ),
    // Operando vai direto para saída
  )
  // Caso 3: Expressão com parênteses
  // Entrada: (2 + 3) * 4
  // Saída esperada: 2 3 + 4 *
  check.eq(
    processa_infix(Ok(#([], [])), OperadorSI(Parenteses(LPa))),
    Ok(#([Parenteses(LPa)], [])),
    // Abre parênteses vai para pilha
  )
  check.eq(
    processa_infix(Ok(#([Parenteses(LPa)], [])), OperandoSI(2)),
    Ok(#([Parenteses(LPa)], [OperandoSP(2)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(
      Ok(#([Parenteses(LPa)], [OperandoSP(2)])),
      OperadorSI(Operador(Add)),
    ),
    Ok(#([Operador(Add), Parenteses(LPa)], [OperandoSP(2)])),
    // Add vai para pilha
  )
  check.eq(
    processa_infix(
      Ok(#([Operador(Add), Parenteses(LPa)], [OperandoSP(2)])),
      OperandoSI(3),
    ),
    Ok(#([Operador(Add), Parenteses(LPa)], [OperandoSP(3), OperandoSP(2)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(
      Ok(#([Operador(Add), Parenteses(LPa)], [OperandoSP(3), OperandoSP(2)])),
      OperadorSI(Parenteses(RPa)),
    ),
    Ok(#([], [OperadorSP(Add), OperandoSP(3), OperandoSP(2)])),
    // Fecha parênteses: desempilha até achar LPa
  )
  check.eq(
    processa_infix(
      Ok(#([], [OperadorSP(Add), OperandoSP(3), OperandoSP(2)])),
      OperadorSI(Operador(Mul)),
    ),
    Ok(#([Operador(Mul)], [OperadorSP(Add), OperandoSP(3), OperandoSP(2)])),
    // Mul vai para pilha
  )
  check.eq(
    processa_infix(
      Ok(#([Operador(Mul)], [OperadorSP(Add), OperandoSP(3), OperandoSP(2)])),
      OperandoSI(4),
    ),
    Ok(
      #([Operador(Mul)], [
        OperandoSP(4),
        OperadorSP(Add),
        OperandoSP(3),
        OperandoSP(2),
      ]),
    ),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(Ok(#([], [])), OperadorSI(Parenteses(RPa))),
    Error(ParentesesErrado),
  )
}

pub fn processa_op_pilha(
  acc: Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro),
  i: OperadorInFix,
  op: OperadorPosFix,
) -> list.ContinueOrStop(
  Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro),
) {
  case acc {
    Error(e) -> list.Stop(Error(e))
    Ok(#(pilha_atual, saida_atual)) -> {
      case pilha_atual {
        [] -> list.Stop(Ok(#([], saida_atual)))
        [Operador(op_topo), ..resto] -> {
          // Aqui é a parte importante, onde a gente empilha os operadores de maior precedência. Aí
          // só lá pra da função que vamos finalmente colocar o op no lugar certo
          case tem_precedencia(op_topo, op) {
            True -> {
              let nova_saida = [OperadorSP(op_topo), ..saida_atual]
              list.Continue(Ok(#(resto, nova_saida)))
            }
            False -> list.Stop(Ok(#(pilha_atual, saida_atual)))
          }
        }
        [Parenteses(LPa), ..] -> list.Stop(Ok(#(pilha_atual, saida_atual)))
        _ -> list.Stop(Error(ParentesesErrado))
      }
    }
  }
}

pub fn processa_rpa(
  acc: Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro),
  i: OperadorInFix,
) -> list.ContinueOrStop(
  Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro),
) {
  case acc {
    Error(e) -> list.Stop(Error(e))
    Ok(#(pilha_atual, saida_atual)) -> {
      case pilha_atual {
        [] -> list.Stop(Error(ParentesesErrado))
        [Operador(op), ..resto] -> {
          let nova_saida = [OperadorSP(op), ..saida_atual]
          list.Continue(Ok(#(resto, nova_saida)))
        }
        [Parenteses(LPa), ..resto] -> list.Stop(Ok(#(resto, saida_atual)))
        [Parenteses(RPa), ..] -> list.Stop(Error(ParentesesErrado))
      }
    }
  }
}

/// Descarta um elemento da pilha caso ele exista
pub fn desempilhada_infix(pilha: List(OperadorInFix)) -> List(OperadorInFix) {
  case pilha {
    [] -> []
    [_, ..r] -> r
  }
}

/// Verifica se um operador tem maior ou igual precedência que outro. Mul e Div têm maior
/// precedência que Add e Sub. Operadores de mesma classe têm a mesma precedência
pub fn tem_precedencia(oppilha: OperadorPosFix, op: OperadorPosFix) -> Bool {
  case oppilha == Mul || oppilha == Div {
    True -> True
    _ if op == Add || op == Sub -> True
    _ -> False
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
