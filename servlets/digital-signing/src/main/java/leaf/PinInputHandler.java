package leaf;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.PasswordCallback;

public class PinInputHandler implements CallbackHandler {

    PinInputHandler(){}

    private char[] pin;

    @Override
    public void handle(Callback[] callbacks) {
        for (Callback cb : callbacks) {
            if (cb instanceof PasswordCallback) {
                PasswordCallback pcb = (PasswordCallback) cb;
                try {
                    pin = SignUI.askForPin();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                pcb.setPassword(pin);
            }
        }
    }
}