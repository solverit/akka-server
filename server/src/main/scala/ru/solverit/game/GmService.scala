package ru.solverit.game

import akka.actor.{Props, ActorRef, ActorLogging, Actor}
import ru.solverit.core.{Cmd, SomePlayer}
import ru.solverit.domain.Player

import scala.collection.mutable


case class JoinGame(session: ActorRef)

class GmService extends Actor with ActorLogging {

  val players: mutable.HashMap[ActorRef, Player] = mutable.HashMap.empty[ActorRef, Player]
  val rooms: mutable.HashMap[Long, ActorRef] = mutable.HashMap.empty[Long, ActorRef]

  var idCounter = 1L

  // ----- actor -----
  override def preStart() {
    log.info("Starting game service")
  }

  override def receive = {
    case task: SomePlayer => handleAuthenticated(task)
    case task: JoinGame => handleJoin(task)
    case task: PlayerMove => handleMove(task)

    case _ => log.info("unknown message")
  }

  override def postStop() {
    // clean up resources
    log.info("Stoping game service")
  }


  // ----- handles -----
  def handleAuthenticated(task: SomePlayer) = {
    players.put(task.session, task.player)
  }

  def handleJoin(task: JoinGame) = {
    if(rooms.isEmpty) {
      createRoom()
    }

    rooms.get(1L).get ! JoinRoom(task.session, players.get(task.session).get)
  }

  def handleMove(task: PlayerMove) = {
    rooms.get(1L).get ! task
  }

  def createRoom(): ActorRef = {
    val room = context.actorOf(Props(new Room(idCounter)), "room"+idCounter)
    rooms.put(idCounter, room)
    room
  }
}
