package test.java.Utility;

import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.Random;

public class Constants {

    public static int pageLoadTimeOut= 60;

    public static int implicitWaitTime = 30;

    public static WebDriverWait explicitWait;

    private static String env_URL = "https://host.docker.internal/LEAF_Request_Portal/admin/";

    public static String HUB_URL = "http://localhost:4445/wd/hub";

    private static String remote_url = "https://www.google.com";
    public static String browser = "remote";


    public static String currentDir = System.getProperty("user.dir");

    public static final boolean headless = false;
    Random random = new Random();
    protected int RandomNumber = random.nextInt();

    public static String getEnvURL(){
        return env_URL;
    }
    public static String getRemote_url(){
        return remote_url;
    }

}
