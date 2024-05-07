package main.Utility;

import java.util.Random;

public class Constants {

    public static int pageLoadTimeOut= 60;

    public static int implicitWaitTime = 30;


    private static String env_URL = "https://host.docker.internal/LEAF_Request_Portal/admin/";

    private static String remote_url = "https://www.google.com";
    public static String browser = "Chrome";

    private static String environment = "";

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
    public static String getEnvironment(){
        return environment;
    }

}
