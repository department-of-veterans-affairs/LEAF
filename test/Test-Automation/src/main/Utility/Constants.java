package main.Utility;

import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.Random;

public class Constants {

    public static int pageLoadTimeOut= 1800;

    public static int implicitWaitTime = 30;

    public static WebDriverWait explicitWait;

    private static String env_URL = "https://host.docker.internal/LEAF_Request_Portal/admin/";

    private static String remote_url = "http://host.docker.internal:4445/wd/hub";
    public static String browser = "chrome";
    public static String HUB_URL = "http://localhost:4445/wd/hub";


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
