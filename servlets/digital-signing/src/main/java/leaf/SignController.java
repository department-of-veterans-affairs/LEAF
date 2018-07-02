package leaf;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class SignController {

    private String content;

    @MessageMapping("/sign")
    @SendTo("/topic/greetings")
    public Sign sign(Sign sign) throws Exception {
        SignUI.showErrorMessage(sign.getContent());
        String signature = SignEngine.getInstance().getSignature(sign.getContent());
        return new Sign(signature);
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    @MessageMapping("/close")
    @SendTo("/wsbroker/controller")
    public void close() {
        System.exit(0);
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

}
