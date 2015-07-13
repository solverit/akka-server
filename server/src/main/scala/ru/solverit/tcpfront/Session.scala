package ru.solverit.tcpfront

import java.net.InetSocketAddress
import java.nio.ByteBuffer

import akka.actor._
import akka.io.Tcp
import akka.io.Tcp.Write
import akka.io.TcpPipelineHandler.{Init, WithinActorContext}
import akka.util.ByteString
import ru.solverit.core.{Cmd, Msg, TaskService}
import ru.solverit.net.packet.Packet.PacketMSG

import scala.concurrent.duration._


// -----
class Session(
               val id: Long,
               connect: ActorRef,
               init: Init[WithinActorContext, ByteString, ByteString],
               remote: InetSocketAddress,
               local: InetSocketAddress
               ) extends Actor with ActorLogging {

  import Session._
  import context._

  // -----
  val taskService = context.actorSelection("akka://server/user/task")

  // ----- heartbeat -----
  private var scheduler: Cancellable = _

  // ----- actor -----
  override def preStart() {
    // initialization code
    scheduler = context.system.scheduler.schedule(period, period, self, Heartbeat)

    log.info("Session start: {}", toString)
  }

  override def receive = {
    case init.Event(data) ⇒ receiveData(data)

    case Send(cmd, data) ⇒ sendData(cmd, data)

    case Heartbeat ⇒ sendHeartbeat()

    case _: Tcp.ConnectionClosed ⇒ Closed()

    case _ => log.info("unknown message")
  }

  override def postStop() {
    // clean up resources
    scheduler.cancel()

    log.info("Session stop: {}", toString)
  }

  // ----- actions -----
  def receiveData(data: ByteString) {
    val comm: PacketMSG = PacketMSG.parseFrom( data.toArray )

    taskService ! TaskService.CommandTask( self, comm )
  }

  def sendData(cmd: Msg, data: Array[Byte]) {
    val trp: PacketMSG.Builder = PacketMSG.newBuilder()
    trp.setCmd(cmd.code)
    trp.setData(com.google.protobuf.ByteString.copyFrom(data))

    val packet = trp.build().toByteArray
    val bb: ByteBuffer = ByteBuffer.allocate(4 + packet.length)
    bb.putInt(packet.length)
    bb.put(packet)

    val msg: ByteString = ByteString(bb.array())

    connect ! Write(msg)

    log.info("Cmd send: {}", cmd)
  }

  def sendHeartbeat(): Unit = {
    sendData(Cmd.Ping, Array[Byte]())
  }

  def Closed() {
    context stop self
  }

  // ----- override -----
  override def toString = "{ Id: %d }".format(id)
}

object Session {

  // ----- heartbeat -----
  val period = 10.seconds

  // safe constructor
  def props(id: Long, connect: ActorRef, init: Init[WithinActorContext, ByteString, ByteString],
            remote: InetSocketAddress, local: InetSocketAddress) = Props(
                new Session(id, connect, init, remote, local)
              )

  // ----- API -----
  // Sending message to client
  case class Send(cmd: Msg, data: Array[Byte])
  // Checking client connection for life
  case object Heartbeat
}
