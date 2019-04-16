package leaf;

import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;

import javax.swing.*;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.util.Enumeration;
import java.util.Formatter;

public class SignEngine {

    private static Logger logger = LoggerFactory.getLogger(SignEngine.class);
    private byte[] signedBytes;
    private String dataToSign;
    private Certificate publicKey;

    SignEngine() {}

    String getSignature(String data) {
        dataToSign = data;
        try {
            KeyStore keyStore = KeyStore.getInstance("Windows-MY", "SunMSCAPI");
            keyStore.load(null, null);
            Enumeration<String> aliases = keyStore.aliases();
            String alias = "";
            while (aliases.hasMoreElements()) {
                String element = aliases.nextElement();
                X509Certificate x509Certificate = (X509Certificate) keyStore.getCertificate(element);
                boolean[] keyUsage = x509Certificate.getKeyUsage();
                if (keyUsage != null) {
                    if ((keyUsage[0] && keyUsage[1]) || element.contains("Digital Signature")) alias = element;
                }
            }
            logger.info("Using alias \"" + alias + "\"");
            PrivateKey privateKey = (PrivateKey) keyStore.getKey(alias, null);
            publicKey = keyStore.getCertificate(alias);
            Signature signature = Signature.getInstance("SHA256withRSA", "SunMSCAPI");
            signature.initSign(privateKey);
            byte[] dataBytes = dataToSign.getBytes();
            signature.update(dataBytes);
            signedBytes = signature.sign();
            Formatter formatter = new Formatter();
            for (byte b : signedBytes) formatter.format("%02x", b);
            return formatter.toString();
        } catch (Exception e) {
            logger.error(e.getLocalizedMessage());
            return "ERROR: " + e.getMessage();
        }
    }

    boolean verify() {
        try {
            Signature signature = Signature.getInstance("SHA256withRSA", "SunMSCAPI");
            signature.initVerify(publicKey);
            signature.update(dataToSign.getBytes());
            return signature.verify(signedBytes);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    Certificate getPublicKey() {
        return publicKey;
    }

    byte[] getSignedBytes() { return getSignedBytes(); }

    String getDataToSign() { return dataToSign; }

    static void showErrorMessage(String message) {
        JOptionPane.showMessageDialog(null, message, "ERROR", JOptionPane.ERROR_MESSAGE);
    }

}
