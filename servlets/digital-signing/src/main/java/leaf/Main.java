package leaf;

import leaf.server.WebSocketServer;

public class Main {

    public static void main(String[] args) {
        try {
//            SignUI.showErrorMessage(System.getProperty("java.version"));
            new WebSocketServer(WebSocketServer.DEFAULT_PORT).serverThreadStart();
        } catch (Exception e) {
            e.printStackTrace();
            SignUI.showErrorMessage(e.getMessage());
        }
    }
}
