package main.Utility;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;

public class Utility extends Constants{

    public static WebDriver driver=null;

    public static WebDriverWait explicitWait;

    private static final Logger log = LogManager.getLogger(Utility.class);

    public static RemoteWebDriver createDriver(String remote_url) throws MalformedURLException {
        DesiredCapabilities caps = new DesiredCapabilities();
        caps.setCapability("browserName", "chrome");
       // caps.setCapability("version", "latest");
        return new RemoteWebDriver(new URL(remote_url), caps);
    }


    //Add explicit wait
    public static void setExplicitWait(int seconds){
        explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
        log.info("Waiting for Element to appear for "+seconds+" seconds");
    }

    //ExplicitWait for element to be clickable
    public void setExplicitWaitForElementToBeClickable(WebElement element, int seconds){
        log.info("Waiting for Element to be clickable for "+seconds+" seconds");
        explicitWait =  new WebDriverWait(driver, Duration.ofSeconds(seconds));
        explicitWait.until(ExpectedConditions.elementToBeClickable(element));
    }

    //ExplicitWait for element to be visible
    public static void setExplicitWaitForElementToBeVisible(WebElement element, int seconds){
        log.info("Waiting for Element to be visible for "+seconds+" seconds");
        new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.visibilityOf(element));
    }

    //ExplicitWait for element to be invisible
    public void setExplicitWaitForElementToBeInvisible(WebElement element, int seconds){
        log.info("Waiting for Element to be invisible for "+seconds+" seconds");
        new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.invisibilityOf(element));
    }



}
