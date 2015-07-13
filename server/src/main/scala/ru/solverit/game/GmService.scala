package ru.solverit.game

import akka.actor.{Actor, ActorLogging, ActorRef}
import ru.solverit.core.StorageService.SomePlayer
import ru.solverit.domain.Player
import ru.solverit.game.Room.PlayerMove

import scala.collection.mutable

class GmService extends Actor with ActorLogging {
  import GmService._

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

    rooms.get(1L).get ! Room.JoinRoom(task.session, players.get(task.session).get)
  }

  def handleMove(task: PlayerMove) = {
    rooms.get(1L).get ! task
  }

  def createRoom(): ActorRef = {
    val room = context.actorOf(Room.props(idCounter), "room" + idCounter)
    rooms.put(idCounter, room)
    room
  }
}

object GmService {

  // ----- API -----
  case class JoinGame(session: ActorRef)
}
