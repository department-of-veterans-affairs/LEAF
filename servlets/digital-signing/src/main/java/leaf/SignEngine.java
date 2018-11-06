package leaf;

import sun.security.pkcs11.SunPKCS11;
import sun.security.pkcs11.wrapper.PKCS11;

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
import java.util.Formatter;

public class SignEngine {

    private static SunPKCS11 provider;

    public static SunPKCS11 getProvider() {
        if (provider == null) {
            try {
                String extractedPath = ResourceManager.extractZip("opensc-pkcs11.dll.zip");
                System.out.println("Getting provider");
                PKCS11 pkcs11 = PKCS11.getInstance(extractedPath, "C_GetFunctionList", null, false);
                long[] slots = pkcs11.C_GetSlotList(true);
                String pkcs11Config = "name=OpenSC\nlibrary=" + extractedPath + "\nslot=" + slots[0];
                System.out.println("pkcs11Config");
                byte[] providerConfig = pkcs11Config.getBytes("UTF-8");
                ByteArrayInputStream config = new ByteArrayInputStream(providerConfig);
                provider = new SunPKCS11(config);
                Security.addProvider(provider);
                System.out.println("\n\nProvider added\n\n");
            } catch (Exception e) {
                StringWriter errors = new StringWriter();
                e.printStackTrace(new PrintWriter(errors));
                SignUI.showErrorMessage(errors.toString());
                e.printStackTrace();
            }
        }
        return provider;
    }

    public static String getSignature(String data) {
        provider = getProvider();
        try {
            CallbackHandler pinInputHandler = new PinInputHandler();
            KeyStore.CallbackHandlerProtection callbackHandlerProtection = new KeyStore.CallbackHandlerProtection(pinInputHandler);
            KeyStore.Builder builder = KeyStore.Builder.newInstance("PKCS11", provider, callbackHandlerProtection);
            KeyStore keyStore = builder.getKeyStore();
            String alias = "Certificate for Digital Signature";
            KeyStore.PrivateKeyEntry privateKeyEntry = (KeyStore.PrivateKeyEntry) keyStore.getEntry(alias, callbackHandlerProtection);
            PrivateKey privateKey = privateKeyEntry.getPrivateKey();
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initSign(privateKey);
            byte[] dataBytes = data.getBytes();
            signature.update(dataBytes);
            byte[] signedBytes = signature.sign();
            Formatter formatter = new Formatter();
            for (byte b : signedBytes) formatter.format("%02x", b);
            return formatter.toString();
        } catch (KeyStoreException e) {
            e.printStackTrace();
            return "ERROR: " + e.getMessage();
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
