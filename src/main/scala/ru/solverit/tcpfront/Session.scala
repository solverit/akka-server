package ru.solverit.tcpfront

import java.net.InetSocketAddress
import java.nio.ByteBuffer

import akka.actor.{ActorLogging, Cancellable, Actor, ActorRef}
import akka.io.Tcp
import akka.io.Tcp.Write
import akka.io.TcpPipelineHandler.{WithinActorContext, Init}
import akka.util.ByteString

import scala.concurrent.duration._

// -----
case class Send(cmd: Int, data: Array[Byte])

case class Heartbeat()

// -----
class Session(
               val id: Long,
               connect: ActorRef,
               init: Init[WithinActorContext, ByteString, ByteString],
               remote: InetSocketAddress,
               local: InetSocketAddress
               ) extends Actor with ActorLogging {

  import context._

  // -----
  val taskServer = context.actorSelection("akka://ags/user/task")

  // -----
  var creationTime: Long = 0L
  var lastReadTime: Long = 0L
  var lastWriteTime: Long = 0L
  var lastActivityTime: Long = 0L

  // -----
  private val period = 10.seconds
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

    case _ =>
      log.info("unknown message")
  }

  override def postStop() {
    // clean up resources
    scheduler.cancel()

    log.info("Session stop: {}", toString)
  }

  // ----- actions -----
  def receiveData(data: ByteString) {
    setLastReadTime(System.currentTimeMillis())

    //    val comm: PacketMSG = PacketMSG.parseFrom( data.toArray )
    //
    //    taskServer ! AgsCommand( comm )
  }

  def sendData(cmd: Int, data: Array[Byte]) {
    setLastWriteTime(System.currentTimeMillis())

//    val trp: PacketMSG.Builder = PacketMSG.newBuilder()
//    trp.setPing(false)
//    trp.setEncrypted(false)
//    trp.setTime(System.currentTimeMillis())
//    trp.setIdsess(0)
//    trp.setMsgnum(msgNum)
//    trp.setCmd(cmd)
//    trp.setData(com.google.protobuf.ByteString.copyFrom(data))
//
//    val packet = trp.build().toByteArray
//
//    val bb: ByteBuffer = ByteBuffer.allocate(4 + packet.length)
//    bb.putInt(packet.length)
//    bb.put(packet)
//
//    val msg: ByteString = ByteString(bb.array())
//
//    connect ! Write(msg)

    log.info("Cmd send: {}", cmd)
  }

  def sendHeartbeat(): Unit = {
    sendData(1, Array[Byte]())
  }

  def Closed() {
    context stop self
  }


  def setLastReadTime(time: Long) {
    lastActivityTime = time
    lastReadTime = time
  }

  def setLastWriteTime(time: Long) {
    lastActivityTime = time
    lastWriteTime = time
  }


  // ----- override -----
  override def toString = "{ Id: %d }".format(id)
}
