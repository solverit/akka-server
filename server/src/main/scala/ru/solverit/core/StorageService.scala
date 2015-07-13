package ru.solverit.core

import akka.actor.{ActorLogging, Actor, ActorRef}
import ru.solverit.domain.{Point, Player}
import ru.solverit.net.packet.Packet.{Login, PacketMSG}

class StorageService extends Actor with ActorLogging {
  import StorageService._

  val players = List(
                      new Player(1L, "Tester1", "test", Point(0, 0)),
                      new Player(2L, "Tester2", "test", Point(0, 0)),
                      new Player(3L, "Tester3", "test", Point(0, 0)),
                      new Player(4L, "Tester4", "test", Point(0, 0))
                    )

  // ----- actor -----
  override def preStart() {
    log.info("Starting storage service")
  }

  override def receive = {
    case cmdTask: GetPlayerByName => handleAuth(cmdTask)

    case _ => log.info("unknown message")
  }

  override def postStop() {
    // clean up resources
    log.info("Stoping storage service")
  }


  // ----- handles -----
  def handleAuth(task: GetPlayerByName) = {
    val cmd: Login = Login.parseFrom(task.comm.getData)

    val player = players.filter(p => p.name.equals(cmd.getName) && p.pass.equals(cmd.getPass)).head
    player match {
      case Player(_,_,_,_) => sender ! SomePlayer(task.session, task.comm, player)
      case _ => sender ! AuthService.AuthenticatedFailed(task.session, task.comm)
    }

  }
}

object StorageService {

  // ----- API -----
  case class GetPlayerByName(session: ActorRef, comm: PacketMSG)
  case class SomePlayer(session: ActorRef, comm: PacketMSG, player: Player)
}
