package ru.solverit.game

import akka.actor._
import ru.solverit.core.Cmd
import ru.solverit.domain.Player
import ru.solverit.net.packet.Packet.{Move, PacketMSG, Point}
import ru.solverit.tcpfront.Session

import scala.collection.mutable
import scala.concurrent.duration._

class Room(val id: Long) extends Actor with ActorLogging {
  import Room._
  import context._

  val players: mutable.HashMap[Player, ActorRef] = mutable.HashMap.empty[Player, ActorRef]

  // ----- game tick -----
  private var scheduler: Cancellable = _

  // ----- actor -----
  override def preStart() {
    log.info("Starting room: "+id)
    scheduler = context.system.scheduler.schedule(period, period, self, Tick)
  }

  override def receive = {
    case Tick => calcTick()
    case task: JoinRoom => handleJoin(task)
    case task: PlayerMove => handleMove(task)

    case _ => log.info("unknown message")
  }

  override def postStop() {
    // clean up resources
    scheduler.cancel()
    log.info("Stoping room: "+id)
  }


  def getPoint(move: Move.Builder, p: Player) = {
    val point: Point.Builder = Point.newBuilder()
    point.setId(p.id)
    point.setX(p.point.x)
    point.setY(p.point.y)
    move.addPoint(point)
  }

  // ----- handles -----
  def calcTick() = {
    val move = Move.newBuilder()
    players.keySet.map(p => getPoint(move, p))
    players.values.map(s => s ! Session.Send(Cmd.Move, move.build().toByteArray))
  }

  def handleJoin(task: JoinRoom) = {
    log.info("Player join room: "+task.player.id)
    players.put(task.player, task.session)
  }

  def handleMove(task: PlayerMove) = {
    val move = Move.parseFrom(task.comm.getData).getPointList.get(0)

    players.keySet.foreach(p => if(p.id == move.getId){
      p.point.x = move.getX
      p.point.y = move.getY
    } )
  }
}

object Room {

  // ----- game tick -----
  private val period = 100.millisecond

  // ----- API -----
  case object Tick

  case class JoinRoom(session: ActorRef, player: Player)
  case class PlayerMove(session: ActorRef, comm: PacketMSG)

  // safe constructor
  def props(id: Long) = Props(new Room(id))
}
