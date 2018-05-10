package leaf.server;

import org.glassfish.tyrus.server.Server;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class WebSocketServer extends Thread {

    public final static int DEFAULT_PORT = 8765;
    private int port;
    private Server server;
    private ActionListener statusChangeListener;
    private boolean started = false, terminated = false, terminating = false;
    private final Object terminatingLock = new Object();
    private final Object terminatedLock = new Object();
    private final Object startedLock = new Object();

    public WebSocketServer(int port) {
        this.port = port;
        server = new Server("0.0.0.0", this.port, "/websockets", null, WebSocketService.class);
    }

    public void onStatusChanged(ActionListener listener) { statusChangeListener = listener; }

    public boolean getStarted() {
        synchronized (startedLock) {
            return started;
        }
    }

    public boolean getTerminated() {
        synchronized (terminatedLock) {
            return terminated;
        }
    }

    public boolean getTerminating() {
        synchronized (terminatingLock) {
            return terminating;
        }
    }

    public int getPort() { return port; }

    @Override
    public void run() {
        started = false;
        terminated = false;
        terminating = false;
        try {
            server.start();
            if (statusChangeListener != null) statusChangeListener.actionPerformed(new ActionEvent(this, 0, "started"));
        } catch (Exception e) {
            e.printStackTrace();
            terminating = true;
        }
        synchronized (startedLock) {
            started = true;
            startedLock.notifyAll();
        }
        synchronizeLock(terminatingLock, terminating);
        server.stop();
        if (statusChangeListener != null) statusChangeListener.actionPerformed(new ActionEvent(this, 1, "terminated"));
        synchronized (terminatingLock) {
            terminated = true;
            terminatedLock.notifyAll();
        }
    }

    public void waitTermination() {
        synchronizeLock(terminatedLock, terminated);
    }

    public void waitStart() {
        synchronizeLock(startedLock, started);
    }

    private void synchronizeLock(Object lock, boolean state) {
        synchronized (lock) {
            while (!state) {
                try {
                    lock.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                    break;
                }
            }
        }
    }

    public void serverThreadStart() { this.start(); }

    public void terminate() { terminate(0); }

    private void terminate(int seconds) {
        if (seconds != 0) {
            try {
                sleep(seconds * 1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        synchronized (terminatingLock) {
            terminating = true;
            terminatingLock.notifyAll();
        }
    }

}
