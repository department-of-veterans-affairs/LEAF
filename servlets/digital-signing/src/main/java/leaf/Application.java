package leaf;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Vertx;
import io.vertx.core.VertxOptions;
import io.vertx.core.buffer.Buffer;
import io.vertx.core.http.HttpServer;
import io.vertx.core.http.HttpServerOptions;
import io.vertx.core.json.Json;
import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;
import io.vertx.core.net.JksOptions;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.handler.sockjs.SockJSHandler;
import io.vertx.ext.web.handler.sockjs.SockJSHandlerOptions;

public class Application extends AbstractVerticle {

    private static Logger logger = LoggerFactory.getLogger(Application.class);

    private SignEngine signEngine;

    public static void main(String[] args) {
        Runner.run(Application.class);
        timeout();
    }

    @Override
    public void start() {

        VertxOptions vertxOptions = new VertxOptions().setMaxEventLoopExecuteTime(Long.MAX_VALUE);
        vertx = Vertx.vertx(vertxOptions);
        HttpServer server = vertx.createHttpServer(new HttpServerOptions().setSsl(true).setKeyStoreOptions(
                new JksOptions().setPath(ResourceManager.extractResource("keystore.jks").getAbsolutePath()).setPassword("changeit")
        ));
        Router router = Router.router(Vertx.vertx());
        SockJSHandlerOptions options = new SockJSHandlerOptions();
        options.setHeartbeatInterval(20000);
        SockJSHandler sockJSHandler = SockJSHandler.create(vertx, options);
        sockJSHandler.socketHandler(ws -> {
            logger.info("SockJS Connection");
            ws.handler(request -> {
                Sign sign = JsonSerializer.deserialize(request.toString());
                logger.info("dataToSign: " + sign.getDataToSign());
                SignEngine signEngine = new SignEngine();
                String signature = signEngine.getSignature(sign.getDataToSign());
                String certificateHex = signEngine.getCertificateHex();
                String status = (signature.substring(0, 5).equals("ERROR")) ? "ERROR" : "SUCCESS";
                logger.info("Verified: " + signEngine.verify());
                ws.write(Buffer.buffer(JsonSerializer.serialize(sign.getKey(), signature, status, certificateHex)));
            });
        });
        router.route("/myapp/*").handler(sockJSHandler);
        server.requestHandler(router::accept).listen(8443);
        logger.info("Secure SockJS server started on port 8443");
        vertx.createHttpServer().websocketHandler(ws -> {
            logger.info("Insecure websocket connection opened");
            ws.handler(request -> {
                Sign sign = JsonSerializer.deserialize(request.toString());
                logger.info("dataToSign: " + sign.getDataToSign());
                SignEngine signEngine = new SignEngine();
                String signature = signEngine.getSignature(sign.getDataToSign());
                String certificateHex = signEngine.getCertificateHex();
                String status = (signature.substring(0, 5).equals("ERROR")) ? "ERROR" : "SUCCESS";
                logger.info("Verified: " + signEngine.verify());
                ws.writeFinalTextFrame(JsonSerializer.serialize(sign.getKey(), signature, status, certificateHex));
            });
        }).listen(8080);
        logger.info("Websocket server started on port 8080");

    }

    private static void timeout() {
        Thread thread = new Thread(() -> {
            try {
                Thread.sleep(43200000);
                System.exit(0);
            } catch (InterruptedException e) {
                logger.error(e.getLocalizedMessage());
            }
        });
        thread.start();
    }
}
