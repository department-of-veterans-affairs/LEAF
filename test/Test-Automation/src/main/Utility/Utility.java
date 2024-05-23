package main.Utility;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.net.MalformedURLException;
import java.net.URL;

public class Utility extends Constants{


    public static WebDriverWait explicitWait;

    private static final Logger log = LogManager.getLogger(Utility.class);

    public static RemoteWebDriver createDriver() throws MalformedURLException {
        DesiredCapabilities caps = new DesiredCapabilities();
        caps.setCapability("browserName", "chrome");
        caps.setCapability("version", "latest");
        return new RemoteWebDriver(new URL(HUB_URL), caps);
    }



}
