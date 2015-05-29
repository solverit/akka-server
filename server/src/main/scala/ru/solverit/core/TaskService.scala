package ru.solverit.core

import akka.actor.{ActorRef, ActorLogging, Actor}
import ru.solverit.net.packet.Packet.PacketMSG


// -----
case class CommandTask(session: ActorRef, comm: PacketMSG)

class TaskService extends Actor with ActorLogging {

  // -----
  val authService = context.actorSelection("akka://server/user/auth")

  // ----- actor -----
  override def preStart() {
    log.info("Starting task service")
  }

  override def receive = {
    case task: CommandTask => handlePacket(task)

    case _ => log.info("unknown message")
  }

  override def postStop() {
    // clean up resources
    log.info("Stoping task service")
  }


  // ----- handles -----
  def handlePacket(task: CommandTask) = {
    task.comm.getCmd match {
      case Cmd.Auth.code => authService ! AuthenticatePlayer(task.session, task.comm)
      case Cmd.Move.code => "move"
      case _ => log.info("Crazy message")
    }
  }



}
