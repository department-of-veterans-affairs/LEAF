package leaf;

import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;

import javax.swing.*;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.cert.X509Certificate;
import java.util.Enumeration;
import java.util.Formatter;

public class SignEngine {

    private static Logger logger = LoggerFactory.getLogger(SignEngine.class);

    public static String getSignature(String data) {
        try {
            KeyStore keyStore = KeyStore.getInstance("Windows-MY", "SunMSCAPI");
            keyStore.load(null, null);
            Enumeration<String> aliases = keyStore.aliases();
            String alias = "";
            String aliasString = "Aliases: ";
            while (aliases.hasMoreElements()) {
                String element = aliases.nextElement();
                logger.info(element);
                X509Certificate x509Certificate = (X509Certificate) keyStore.getCertificate(element);
                boolean[] keyUsage = x509Certificate.getKeyUsage();
                if (keyUsage != null) {
                    for (int i = 0; i < keyUsage.length; i++) {
                        aliasString += "\n\t" + keyUsage[i];
                    }
                    if ((keyUsage[0] && keyUsage[1]) || element.contains("Digital Signature")) alias = element;
                }
            }
            logger.info(aliasString);
            logger.info("Using alias \"" + alias + "\"");
            PrivateKey privateKey = (PrivateKey) keyStore.getKey(alias, null);
            Signature signature = Signature.getInstance("SHA256withRSA", "SunMSCAPI");
            signature.initSign(privateKey);
            byte[] dataBytes = data.getBytes();
            signature.update(dataBytes);
            byte[] signedBytes = signature.sign();
            Formatter formatter = new Formatter();
            for (byte b : signedBytes) formatter.format("%02x", b);
            return formatter.toString();
        } catch (Exception e) {
            logger.error(e.getLocalizedMessage());
            return "ERROR: " + e.getMessage();
        }
    }

    public static void showErrorMessage(String message) {
        JOptionPane.showMessageDialog(null, message, "ERROR", JOptionPane.ERROR_MESSAGE);
    }

}
