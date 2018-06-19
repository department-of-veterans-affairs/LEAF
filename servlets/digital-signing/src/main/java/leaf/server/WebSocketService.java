package leaf.server;

import leaf.SignEngine;
import leaf.SignUI;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint(value = "/sign")
public class WebSocketService {

    private Session session;

    @OnOpen
    public void open(Session session) {
        this.session = session;
    }

    @OnClose
    public void onClose(Session session) {}

    @OnError
    public void onError(Throwable exception, Session session) { }

    @OnMessage
    public String startSignProcess(String message, Session session) {
        SignUI.showErrorMessage("@OnMessage");
        return SignEngine.getInstance().getSignature(message);
    }

}
