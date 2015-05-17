package ru.solverit

import akka.actor.{Props, ActorSystem}
import ru.solverit.tcpfront.AkkaNetServerTCP

object Starter extends App {

  // create the actor system and actors
  val actorSystem = ActorSystem( "server" )

  val actorNet = actorSystem.actorOf( Props( new AkkaNetServerTCP( "127.0.0.1", 8888 ) ), "front" )

}
