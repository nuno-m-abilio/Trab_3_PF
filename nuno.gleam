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
pub fn infix_to_posfix(expression: List(SymbolInFix)) -> List(SymbolPosFix) {
  todo
}

// // Insere um Símbolo em notação infixa no na tupla acumuladora da pilha e saída da tradção de infixa para posfixa
// pub fn processa_infix(
//   pilha_saida: #(List(OperadorInFix), List(SymbolPosFix)),
//   simbolo: SymbolInFix,
// ) -> Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro) {
//   let pilha = pilha_saida.0
//   let saida = pilha_saida.1
//   case simbolo {
//     OperandoSI(num) -> Ok(#(pilha, [OperandoSP(num)]))
//     OperadorSI(Operador(op)) ->
//       list.fold_until(pilha, Ok(#(pilha, saida)), fn(s, p) {
//         case s {
//           Error(a) -> Error(a)
//           #(manipula, _) ->
//             case p {
//               [] -> list.Stop(s)
//               [x, ..r] if x == Operador(opx) ->
//                 case tem_precedencia(opx, op) {
//                   True ->
//                     list.Continue(
//                       Ok(#(desempilhada_infix(tupla.0), [OperadorSP(opx), ..r])),
//                     )
//                   False -> list.Stop(OK(#([Operador(op), ..manipula])))
//                 }
//               [x, ..r] if x == Parenteses(LPa) -> list.Stop(s)
//               [x, ..r] if x == Parenteses(RPa) ->
//                 list.Stop(Error(ParentesesErrado))
//             }
//         }
//       })
//     OperadorSI(Parenteses(LPa)) -> Ok(#([Parenteses(LPa), ..pilha], saida))
//     OperadorSI(Parenteses(RPa)) ->
//       list.fold_until(pilha, Ok(#(pilha, saida)), fn(s, p) {
//         case s {
//           Error(a) -> Error(a)
//           #(manipula, _) ->
//             case p {
//               [] -> list.Stop(Error(ParentesesErrado))
//               [x, ..r] if x == Operador(opx) ->
//                 list.Continue(
//                   Ok(#(desempilhada_infix(tupla.0), [OperadorSP(opx), ..r])),
//                 )
//               [x, ..r] if x == Parenteses(LPa) ->
//                 list.Stop(Ok(#(desempilhada_infix(tupla.0), r)))
//               [x, ..r] if x == Parenteses(RPa) ->
//                 list.Stop(Error(ParentesesErrado))
//             }
//         }
//       })
//   }
// }

// pub fn processa_infix(
//   pilha_saida: #(List(OperadorInFix), List(SymbolPosFix)),
//   simbolo: SymbolInFix,
// ) -> Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro) {
//   let pilha = pilha_saida.0
//   let saida = pilha_saida.1

//   case simbolo {
//     // 1. Correção: Operando deve ser anexado à saída existente
//     OperandoSI(num) -> Ok(#(pilha, list.append(saida, [OperandoSP(num)])))

//     // 2. Correção: Processamento de operadores
//     OperadorSI(Operador(op)) ->
//       list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, _) {
//         case acc {
//           Error(e) -> list.Stop(Error(e))
//           Ok(#(manipula, saida_atual)) ->
//             case manipula {
//               // Pilha vazia: apenas empilha o operador
//               [] -> list.Stop(Ok(#([Operador(op)], saida_atual)))

//               // Encontrou um operador no topo
//               [Operador(op_topo), ..resto] ->
//                 case tem_precedencia(op_topo, op) {
//                   True -> {
//                     // 3. Correção: Desempilha e adiciona à saída
//                     let nova_saida =
//                       list.append(saida_atual, [OperadorSP(op_topo)])
//                     list.Continue(Ok(#(resto, nova_saida)))
//                   }
//                   False ->
//                     list.Stop(Ok(#([Operador(op), ..manipula], saida_atual)))
//                 }

//               // Encontrou parêntese esquerdo
//               [Parenteses(LPa), ..resto] ->
//                 list.Stop(Ok(#([Operador(op), ..manipula], saida_atual)))

//               // 4. Correção: Caso inesperado de parêntese direito
//               [Parenteses(RPa), ..resto] -> list.Stop(Error(ParentesesErrado))
//             }
//         }
//       })

//     // 5. Correção: Parêntese esquerdo é simplesmente empilhado
//     OperadorSI(Parenteses(LPa)) -> Ok(#([Parenteses(LPa), ..pilha], saida))

//     // 6. Correção: Processamento de parêntese direito
//     OperadorSI(Parenteses(RPa)) ->
//       list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, _) {
//         case acc {
//           Error(e) -> list.Stop(Error(e))
//           Ok(#(manipula, saida_atual)) ->
//             case manipula {
//               [] -> list.Stop(Error(ParentesesErrado))

//               // Encontrou um operador
//               [Operador(op), ..resto] -> {
//                 let nova_saida = list.append(saida_atual, [OperadorSP(op)])
//                 list.Continue(Ok(#(resto, nova_saida)))
//               }

//               // Encontrou parêntese esquerdo correspondente
//               [Parenteses(LPa), ..resto] -> list.Stop(Ok(#(resto, saida_atual)))

//               // Encontrou outro parêntese direito (erro)
//               [Parenteses(RPa), ..resto] -> list.Stop(Error(ParentesesErrado))
//             }
//         }
//       })
//   }
// }

// pub fn processa_infix(
//   pilha_saida: #(List(OperadorInFix), List(SymbolPosFix)),
//   simbolo: SymbolInFix,
// ) -> Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro) {
//   let pilha = pilha_saida.0
//   let saida = pilha_saida.1

//   case simbolo {
//     // 1. Operando: anexa à saída e mantém a pilha como está
//     OperandoSI(num) -> Ok(#(pilha, list.append(saida, [OperandoSP(num)])))

//     // 2. Operador: processa considerando precedência
//     OperadorSI(Operador(op)) -> {
//       case pilha {
//         // Se a pilha estiver vazia, simplesmente empilha o operador
//         [] -> Ok(#([Operador(op)], saida))

//         // Se houver elementos na pilha, processa de acordo com a precedência
//         _ ->
//           list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, _) {
//             case acc {
//               Error(e) -> list.Stop(Error(e))
//               Ok(#(manipula, saida_atual)) ->
//                 case manipula {
//                   [] -> list.Stop(Ok(#([Operador(op)], saida_atual)))

//                   [Operador(op_topo), ..resto] ->
//                     case tem_precedencia(op_topo, op) {
//                       True -> {
//                         let nova_saida =
//                           list.append(saida_atual, [OperadorSP(op_topo)])
//                         list.Continue(Ok(#(resto, nova_saida)))
//                       }
//                       False ->
//                         list.Stop(
//                           Ok(#([Operador(op), ..manipula], saida_atual)),
//                         )
//                     }

//                   [Parenteses(LPa), ..resto] ->
//                     list.Stop(Ok(#([Operador(op), ..manipula], saida_atual)))

//                   [Parenteses(RPa), ..resto] ->
//                     list.Stop(Error(ParentesesErrado))
//                 }
//             }
//           })
//       }
//     }

//     // 3. Parêntese esquerdo: empilha diretamente
//     OperadorSI(Parenteses(LPa)) -> Ok(#([Parenteses(LPa), ..pilha], saida))

//     // 4. Parêntese direito: desempilha até encontrar o parêntese esquerdo correspondente
//     OperadorSI(Parenteses(RPa)) ->
//       list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, _) {
//         case acc {
//           Error(e) -> list.Stop(Error(e))
//           Ok(#(manipula, saida_atual)) ->
//             case manipula {
//               [] -> list.Stop(Error(ParentesesErrado))

//               [Operador(op), ..resto] -> {
//                 let nova_saida = list.append(saida_atual, [OperadorSP(op)])
//                 list.Continue(Ok(#(resto, nova_saida)))
//               }

//               [Parenteses(LPa), ..resto] -> list.Stop(Ok(#(resto, saida_atual)))

//               [Parenteses(RPa), ..resto] -> list.Stop(Error(ParentesesErrado))
//             }
//         }
//       })
//   }
// }

pub fn processa_infix(
  pilha_saida: #(List(OperadorInFix), List(SymbolPosFix)),
  simbolo: SymbolInFix,
) -> Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro) {
  let pilha = pilha_saida.0
  let saida = pilha_saida.1

  case simbolo {
    // Operando: adiciona à saída mantendo a pilha
    OperandoSI(numero) -> {
      Ok(#(pilha, list.append(saida, [OperandoSP(numero)])))
    }

    // Operador: processa considerando a pilha atual
    OperadorSI(Operador(op)) -> {
      // Se a pilha estiver vazia, apenas empilha o operador
      case pilha {
        [] -> Ok(#([Operador(op)], saida))
        _ -> {
          // Caso contrário, processa a pilha
          list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, _) {
            case acc {
              Error(e) -> list.Stop(Error(e))
              Ok(#(pilha_atual, saida_atual)) -> {
                case pilha_atual {
                  [] -> list.Stop(Ok(#([Operador(op)], saida_atual)))
                  [Operador(op_topo), ..resto] -> {
                    case tem_precedencia(op_topo, op) {
                      True -> {
                        let nova_saida =
                          list.append(saida_atual, [OperadorSP(op_topo)])
                        list.Continue(Ok(#(resto, nova_saida)))
                      }
                      False ->
                        list.Stop(
                          Ok(#([Operador(op), ..pilha_atual], saida_atual)),
                        )
                    }
                  }
                  [Parenteses(LPa), ..] ->
                    list.Stop(Ok(#([Operador(op), ..pilha_atual], saida_atual)))
                  _ -> list.Stop(Error(ParentesesErrado))
                }
              }
            }
          })
        }
      }
    }

    // Parêntese esquerdo: sempre empilha
    OperadorSI(Parenteses(LPa)) -> {
      Ok(#([Parenteses(LPa), ..pilha], saida))
    }

    // Parêntese direito: desempilha até encontrar o correspondente
    OperadorSI(Parenteses(RPa)) -> {
      list.fold_until(pilha, Ok(#(pilha, saida)), fn(acc, _) {
        case acc {
          Error(e) -> list.Stop(Error(e))
          Ok(#(pilha_atual, saida_atual)) -> {
            case pilha_atual {
              [] -> list.Stop(Error(ParentesesErrado))
              [Operador(op), ..resto] -> {
                let nova_saida = list.append(saida_atual, [OperadorSP(op)])
                list.Continue(Ok(#(resto, nova_saida)))
              }
              [Parenteses(LPa), ..resto] -> list.Stop(Ok(#(resto, saida_atual)))
              [Parenteses(RPa), ..] -> list.Stop(Error(ParentesesErrado))
            }
          }
        }
      })
    }
  }
}

pub fn processa_infix_examples() {
  // Caso 1: Expressão simples com adição
  // Entrada: 2 + 3
  check.eq(
    processa_infix(#([], []), OperandoSI(2)),
    Ok(#([], [OperandoSP(2)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(#([], [OperandoSP(2)]), OperadorSI(Operador(Add))),
    Ok(#([Operador(Add)], [OperandoSP(2)])),
    // Pilha vazia, operador vai para pilha
  )
  check.eq(
    processa_infix(#([Operador(Add)], [OperandoSP(2)]), OperandoSI(3)),
    Ok(#([Operador(Add)], [OperandoSP(2), OperandoSP(3)])),
    // Operando vai direto para saída
  )
  // Caso 2: Expressão com multiplicação e adição
  // Entrada: 2 + 3 * 4
  // Saída esperada: 2 3 4 * +
  check.eq(
    processa_infix(#([], []), OperandoSI(2)),
    Ok(#([], [OperandoSP(2)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(#([], [OperandoSP(2)]), OperadorSI(Operador(Add))),
    Ok(#([Operador(Add)], [OperandoSP(2)])),
    // Pilha vazia, operador vai para pilha
  )
  check.eq(
    processa_infix(#([Operador(Add)], [OperandoSP(2)]), OperandoSI(3)),
    Ok(#([Operador(Add)], [OperandoSP(2), OperandoSP(3)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(
      #([Operador(Add)], [OperandoSP(2), OperandoSP(3)]),
      OperadorSI(Operador(Mul)),
    ),
    Ok(#([Operador(Mul), Operador(Add)], [OperandoSP(2), OperandoSP(3)])),
    // Mul tem maior precedência que Add, vai para pilha
  )
  check.eq(
    processa_infix(
      #([Operador(Mul), Operador(Add)], [OperandoSP(2), OperandoSP(3)]),
      OperandoSI(4),
    ),
    Ok(
      #([Operador(Mul), Operador(Add)], [
        OperandoSP(2),
        OperandoSP(3),
        OperandoSP(4),
      ]),
    ),
    // Operando vai direto para saída
  )

  // Caso 3: Expressão com parênteses
  // Entrada: (2 + 3) * 4
  // Saída esperada: 2 3 + 4 *
  check.eq(
    processa_infix(#([], []), OperadorSI(Parenteses(LPa))),
    Ok(#([Parenteses(LPa)], [])),
    // Abre parênteses vai para pilha
  )
  check.eq(
    processa_infix(#([Parenteses(LPa)], []), OperandoSI(2)),
    Ok(#([Parenteses(LPa)], [OperandoSP(2)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(
      #([Parenteses(LPa)], [OperandoSP(2)]),
      OperadorSI(Operador(Add)),
    ),
    Ok(#([Operador(Add), Parenteses(LPa)], [OperandoSP(2)])),
    // Add vai para pilha
  )
  check.eq(
    processa_infix(
      #([Operador(Add), Parenteses(LPa)], [OperandoSP(2)]),
      OperandoSI(3),
    ),
    Ok(#([Operador(Add), Parenteses(LPa)], [OperandoSP(2), OperandoSP(3)])),
    // Operando vai direto para saída
  )
  check.eq(
    processa_infix(
      #([Operador(Add), Parenteses(LPa)], [OperandoSP(2), OperandoSP(3)]),
      OperadorSI(Parenteses(RPa)),
    ),
    Ok(#([], [OperandoSP(2), OperandoSP(3), OperadorSP(Add)])),
    // Fecha parênteses: desempilha até achar LPa
  )
  check.eq(
    processa_infix(
      #([], [OperandoSP(2), OperandoSP(3), OperadorSP(Add)]),
      OperadorSI(Operador(Mul)),
    ),
    Ok(#([Operador(Mul)], [OperandoSP(2), OperandoSP(3), OperadorSP(Add)])),
    // Mul vai para pilha
  )
  check.eq(
    processa_infix(
      #([Operador(Mul)], [OperandoSP(2), OperandoSP(3), OperadorSP(Add)]),
      OperandoSI(4),
    ),
    Ok(
      #([Operador(Mul)], [
        OperandoSP(2),
        OperandoSP(3),
        OperadorSP(Add),
        OperandoSP(4),
      ]),
    ),
    // Operando vai direto para saída
  )
}

// pub fn processa_rpa(acc: #(List(OperadorInFix), List(SymbolPosFix)), i: List(OperadorInFix)) -> Result(#(List(OperadorInFix), List(SymbolPosFix)), Erro)

/// Descarta um elemento da pilha caso ele exista
pub fn desempilhada_infix(pilha: List(OperadorInFix)) -> List(OperadorInFix) {
  case pilha {
    [] -> []
    [_, ..r] -> r
  }
}

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
