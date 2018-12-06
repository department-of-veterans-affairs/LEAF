package leaf;

import sun.security.pkcs11.SunPKCS11;

import javax.security.auth.callback.CallbackHandler;
import java.io.ByteArrayInputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.security.InvalidKeyException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.PrivateKey;
import java.security.ProviderException;
import java.security.Security;
import java.security.Signature;
import java.util.Enumeration;
import java.util.Formatter;
import java.util.concurrent.TimeUnit;

public class SignEngine {

    private static SunPKCS11 provider;

    public static String getSignature(String data) {
        try {
            KeyStore keyStore = KeyStore.getInstance("Windows-MY", "SunMSCAPI");
            keyStore.load(null, null);
            Enumeration<String> aliases = keyStore.aliases();
            String alias = "";
            while (aliases.hasMoreElements()) {
                String element = aliases.nextElement();
                System.out.println("Enum element: " + element);
                if (element.contains("Digital Signature")) alias = element;
            }
            PrivateKey privateKey = (PrivateKey) keyStore.getKey(alias, null);
            Signature signature = Signature.getInstance("SHA256withRSA", "SunMSCAPI");
            signature.initSign(privateKey);
            byte[] dataBytes = data.getBytes();
            signature.update(dataBytes);
            byte[] signedBytes = signature.sign();
            Formatter formatter = new Formatter();
            for (byte b : signedBytes) formatter.format("%02x", b);
            return formatter.toString();
        } catch (KeyStoreException e) {
            e.printStackTrace();
            return "ERROR: Token not found or invalid PIN input";
        } catch (ProviderException e) {
            e.printStackTrace();
            return "ERROR: No cryptography library found or user not logged in";
        } catch (InvalidKeyException e) {
            e.printStackTrace();
            return "ERROR: Invalid certificate for digital signatures";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: " + e.getMessage();
        }
    }

}
