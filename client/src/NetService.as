
package
{
import com.awar.ags.api.ConnectionResponse;
import com.awar.ags.api.MessageType;
import com.awar.ags.api.Packet;
import com.awar.ags.connection.AvailableConnection;
import com.awar.ags.connection.TransportType;
import com.awar.ags.engine.AgsEngine;
import com.awar.ags.engine.Server;

import ru.solverit.net.packet.Login;
import ru.solverit.net.packet.LoginResp;

public class NetService
{
    private var ags: AgsEngine;

    private var _name: String;
    private var _pass: String;

    public function NetService()
    {
        ags = new AgsEngine();
        ags.addEventListener( MessageType.ConnectionAttemptResponse.name, onConnectionResponse );
        ags.addEventListener( MessageType.ConnectionResponse.name, onConnectionResponse );
        ags.addEventListener( MessageType.Packet.name, onDataReceived );
    }

    public function connect( name: String, pass: String ): void
    {
        _name = name;
        _pass = pass;

        var server: Server = new Server( "server1" );
        var availConn: AvailableConnection = new AvailableConnection( "127.0.0.1", 8888, TransportType.TCP );
        server.addAvailableConnection( availConn );
        ags.addServer( server );

        ags.connect();
    }

    private function onConnectionResponse( e: ConnectionResponse ): void
    {
        if( e.successful )
        {
            login( _name, _pass );
        }
    }

    private function onDataReceived( e: Packet ): void
    {
        if( e.Cmd == CmdType.Ping )
        {

        }

        // ----- MAIN -----
        if( e.Cmd == CmdType.AuthResp )
        {
            var lr: LoginResp = new LoginResp();
            lr.mergeFrom( e.Data );
        }
    }

    public function login( login: String, pass: String ): void
    {
        var packet: Packet = new Packet();
        packet.Cmd = CmdType.Auth;

        var lr: Login = new Login();
        lr.name = login;
        lr.pass = pass;

        lr.writeTo( packet.Data );

        ags.send( packet );
    }
}
}
