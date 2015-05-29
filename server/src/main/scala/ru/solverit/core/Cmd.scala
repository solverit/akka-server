package ru.solverit.core

sealed trait Msg { def code: Int }

case object Cmd {
  case object Ping     extends Msg { val code = 1 }
  case object Auth     extends Msg { val code = 5 }
  case object AuthResp extends Msg { val code = 6 }
  case object AuthErr  extends Msg { val code = 7 }
  case object Move     extends Msg { val code = 8 }
}

