package ru.solverit.domain

case class Point(var x:Int, var y:Int)

case class Player (id:Long, name: String, pass: String, point: Point)
