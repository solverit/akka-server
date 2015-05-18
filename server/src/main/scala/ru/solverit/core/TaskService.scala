package ru.solverit.core

import akka.actor.{ActorRef, ActorLogging, Actor}
import ru.solverit.net.packet.Packet.PacketMSG

case class CommandTask(session: ActorRef, comm: PacketMSG)

class TaskService extends Actor with ActorLogging {

  // ----- actor -----
  override def preStart() {
    log.info( "Starting task service" )
  }

  override def receive = {
    case cmdTask: CommandTask ? handlePacket( cmdTask )

    case _ => log.info( "unknown message" )
  }

  override def postStop() {
    // clean up resources
    log.info( "Stoping task service" )
  }


  // ----- handles -----
  def handlePacket( task: CommandTask ) = {


  }
}
