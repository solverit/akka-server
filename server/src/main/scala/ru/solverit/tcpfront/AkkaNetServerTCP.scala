package ru.solverit.tcpfront

import java.net.InetSocketAddress
import java.nio.ByteOrder
import java.util.concurrent.atomic.AtomicLong

import akka.actor.{ActorLogging, Props, Actor}
import akka.io._
import akka.io.Tcp._


class AkkaNetServerTCP(address: String, port: Int) extends Actor with ActorLogging {
  var idCounter = 0L

  override def preStart() {
    log.info("Starting tcp net server")

    import context.system
    val opts = List(SO.KeepAlive(on = true), SO.TcpNoDelay(on = true))
    IO(Tcp) ! Bind(self, new InetSocketAddress(address, port), options = opts)
  }

  def receive = {
    case b@Bound(localAddress) ⇒
    // do some logging or setup ...

    case CommandFailed(_: Bind) ⇒ context stop self

    case c@Connected(remote, local) ⇒
      log.info("New incoming tcp connection on server")

      val framer = new LengthFieldFrame(8192, ByteOrder.BIG_ENDIAN, 4, false)
      val init = TcpPipelineHandler.withLogger(log, framer >> new TcpReadWriteAdapter)

      idCounter += 1
      val sessact = Props(new Session(idCounter, sender, init, remote, local))
      val sess = context.actorOf(sessact, remote.toString.replace("/", ""))

      val handler = context.actorOf(TcpPipelineHandler.props(init, sender, sess))

      sender ! Register(handler)
  }
}
