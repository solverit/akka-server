package ru.solverit

import akka.actor.{Props, ActorSystem}
import ru.solverit.core.{StorageService, AuthService, TaskService}
import ru.solverit.game.GmService
import ru.solverit.tcpfront.AkkaNetServerTCP

object Starter extends App {

  // create the actor system and actors
  val actorSystem = ActorSystem("server")

  val storageAuth = actorSystem.actorOf(Props[StorageService], "storage")
  val actorAuth   = actorSystem.actorOf(Props[AuthService],    "auth")
  val actorTasks  = actorSystem.actorOf(Props[TaskService],    "task")
  val actorGame   = actorSystem.actorOf(Props[GmService],      "game")
  val actorNet    = actorSystem.actorOf(AkkaNetServerTCP.props("127.0.0.1", 8888), "front")
}
