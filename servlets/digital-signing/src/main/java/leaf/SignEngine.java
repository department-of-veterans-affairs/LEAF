package leaf;

import sun.security.pkcs11.SunPKCS11;

import java.io.ByteArrayInputStream;
import java.security.InvalidKeyException;
import java.security.KeyStore;
import java.security.KeyStoreException;
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

                // Jar
//                String pkcs11Config = "name=OpenSC\nlibrary=" + ResourceManager.extract("opensc-pkcs11.so");

                // Mac
//                String pkcs11Config = "name=OpenSC\nlibrary=/usr/local/lib/opensc-pkcs11.so";

                // Windows
                String pkcs11Config = "name=OpenSC\nlibrary=" + ResourceManager.extract("opensc-pkcs11.dll");

                // Linux
//                String pkcs11Config = "name=OpenSC\nlibrary=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so";

                byte[] providerConfig = pkcs11Config.getBytes("UTF-8");
                ByteArrayInputStream config = new ByteArrayInputStream(providerConfig);
                provider = new SunPKCS11(config);
                Security.addProvider(provider);
            } catch (Exception e) {
                SignUI.showErrorMessage(e.getMessage());
                e.printStackTrace();
            }
        }
        return signEngine;
    }

    public String getSignature(String data) {
        try {
            KeyStore.CallbackHandlerProtection callbackHandlerProtection = new KeyStore.CallbackHandlerProtection(new PinInputHandler());
            KeyStore.Builder builder = KeyStore.Builder.newInstance("PKCS11", provider, callbackHandlerProtection);
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
