package leaf;

import sun.security.pkcs11.SunPKCS11;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.security.InvalidKeyException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.ProviderException;
import java.security.Security;
import java.security.Signature;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Formatter;

public class SignEngine {

    private static SignEngine signEngine;

    private static SunPKCS11 provider;

    public static SignEngine getInstance() {
//        SignUI.showErrorMessage("Getting instance 2");
        if (signEngine == null) {
            signEngine = new SignEngine();
            try {
                String pkcs11Config = "name=OpenSC\nlibrary=C:\\Program Files\\OpenSC Project\\OpenSC\\pkcs11\\opensc-pkcs11.dll";
//                String pkcs11Config = "name=OpenSC\nlibrary=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so";

//                InputStream initialStream = SignEngine.class.getClassLoader().getResourceAsStream("opensc-pkcs11.so");
//                byte[] buffer = new byte[initialStream.available()];
//                initialStream.read(buffer);
//
//                File targetFile = new File("temp-opensc-pkcs11.so");
//                OutputStream outStream = new FileOutputStream(targetFile);
//                outStream.write(buffer);
//
//
//                String pkcs11Config = "name=OpenSC\nlibrary=temp-opensc-pkcs11.so";
//                SignUI.showErrorMessage(pkcs11Config);
//                SignUI.showErrorMessage("path2: " + SignEngine.class.getClassLoader().getResource("index.html").getPath());
//                SignUI.showErrorMessage("path3: " + SignEngine.class.getClassLoader().getResource("test.html").getPath());
//                File f = new File("./");
//                SignUI.showErrorMessage("path1: " + SignEngine.class.getClassLoader().getResource("opensc-pkcs11.so").getPath());
//                ArrayList<String> names = new ArrayList<String>(Arrays.asList(f.list()));
//                SignUI.showErrorMessage(names.toString());
//                SignUI.showErrorMessage("OpenSC library exist: " + new File("temp-opensc-pkcs11.so").getAbsolutePath());
//                SignUI.showErrorMessage("file exist: " + new File("index.html").exists());
                byte[] providerConfig = pkcs11Config.getBytes("UTF-8");
                ByteArrayInputStream config = new ByteArrayInputStream(providerConfig);
//                SignUI.showErrorMessage("Creating provider");
                provider = new SunPKCS11(config);
//                SignUI.showErrorMessage("Adding provider");
                Security.addProvider(provider);
//                System.out.println("Sign Engine instance created");
//                SignUI.showErrorMessage("Sign Engine instance created");
            } catch (Exception e) {
                SignUI.showErrorMessage(e.getMessage());
                e.printStackTrace();
            }
        }
        return signEngine;
    }

    public String getSignature(String data) {
        try {
//            SignUI.showErrorMessage("Getting signature; data = " + data);
//            System.out.println("Begin getting signature");
            KeyStore.CallbackHandlerProtection callbackHandlerProtection = new KeyStore.CallbackHandlerProtection(new PinInputHandler());
            KeyStore.Builder builder = KeyStore.Builder.newInstance("PKCS11", provider, callbackHandlerProtection);
//            System.out.println("Begin getting keystore");
//            SignUI.showErrorMessage("Getting keystore");
//            KeyStore.Builder builder = KeyStore.Builder.newInstance("PKCS11", provider, new File("sc.key"),  callbackHandlerProtection);
            KeyStore keyStore = builder.getKeyStore();
            String alias = "Certificate for Digital Signature";
            KeyStore.PrivateKeyEntry privateKeyEntry = (KeyStore.PrivateKeyEntry) keyStore.getEntry(alias, null);
            Signature signature = Signature.getInstance("SHA1withRSA");
//            SignUI.showErrorMessage("init sign");
            signature.initSign(privateKeyEntry.getPrivateKey());
            byte[] dataBytes = data.getBytes();
            signature.update(dataBytes);
            byte[] signedBytes = signature.sign();
            provider.logout();
            Formatter formatter = new Formatter();
            for (byte b : signedBytes) formatter.format("%02x", b);
//            System.out.println("Data signed");
            return formatter.toString();
//        } catch (KeyStoreException e) {
//            return "ERROR: Token not found or invalid PIN input";
//        } catch (ProviderException e) {
//            return "ERROR: No cryptography library found";
//        } catch (NoSuchAlgorithmException e) {
//            return "ERROR: No cryptography library found";
//        } catch (InvalidKeyException e) {
//            return "ERROR: Invalid certificate for digital signatures";
//        } catch (Exception e) {
//            return "ERROR: " + e.getMessage();
//        }
        } catch (Exception e) {
//            SignUI.showErrorMessage(e.getMessage());
            return "ERROR: " + e.getMessage();
        }
    }

    public static boolean hasInstance() {
        return signEngine == null;
    }
}
