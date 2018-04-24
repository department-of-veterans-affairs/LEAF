package leaf;

import sun.security.pkcs11.SunPKCS11;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.security.InvalidKeyException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.ProviderException;
import java.security.Security;
import java.security.Signature;
import java.util.Formatter;

public class SignEngine {

    private static SignEngine signEngine;

    private static SunPKCS11 provider;

    public static SignEngine getInstance() {
        if (signEngine == null) {
            signEngine = new SignEngine();
            try {
//            String pkcs11Config = "name=OpenSC\nlibrary=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so";
                String pkcs11Config = "name=OpenSC\nlibrary=/usr/local/lib/opensc-pkcs11.so";
                byte[] providerConfig = pkcs11Config.getBytes("UTF-8");
                ByteArrayInputStream config = new ByteArrayInputStream(providerConfig);
                provider = new SunPKCS11(config);
                Security.addProvider(provider);
                System.out.println("instance created");
            } catch (Exception e) {
                System.out.println("In the catch");
                e.printStackTrace();
            }
        }
        return signEngine;
    }

    public String getSignature(String data) {
        try {
            KeyStore.CallbackHandlerProtection callbackHandlerProtection = new KeyStore.CallbackHandlerProtection(new PinInputHandler());
            KeyStore.Builder builder = KeyStore.Builder.newInstance("PKCS11", provider, new File("sc.key"),  callbackHandlerProtection);
            KeyStore keyStore = builder.getKeyStore();
            String alias = "Certificate for Digital Signature";
            KeyStore.PrivateKeyEntry privateKeyEntry = (KeyStore.PrivateKeyEntry) keyStore.getEntry(alias, null);
            Signature signature = Signature.getInstance("SHA1withRSA");
            signature.initSign(privateKeyEntry.getPrivateKey());
            byte[] dataBytes = data.getBytes();
            signature.update(dataBytes);
            byte[] signedBytes = signature.sign();
            provider.logout();
            Formatter formatter = new Formatter();
            for (byte b : signedBytes) formatter.format("%02x", b);
            return formatter.toString();
        } catch (KeyStoreException e) {
            return "ERROR: Token not found or invalid PIN input";
        } catch (ProviderException e) {
            return "ERROR: No cryptography library found";
        } catch (NoSuchAlgorithmException e) {
            return "ERROR: No cryptography library found";
        } catch (InvalidKeyException e) {
            return "ERROR: Invalid certificate for digital signatures";
        } catch (Exception e) {
            return "ERROR: " + e.getMessage();
        }
    }

    public static boolean hasInstance() {
        return signEngine == null;
    }
}
