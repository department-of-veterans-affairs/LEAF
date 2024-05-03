package main.Utility;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

public class Utility extends Constants{

    protected static WebDriver driver= null;
    private static final Logger log = LogManager.getLogger(Utility.class);

    public Utility(){
        super();
        PageFactory.initElements(driver,this);
    }

    //Add explicit wait
    public void setExplicitWait(int seconds){
        Constants.explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
        log.info("Waiting for Element to appear for "+seconds+" seconds");
    }

    //ExplicitWait for element to be clickable
    public void setExplicitWaitForElementToBeClickable(WebElement element, int seconds){
        log.info("Waiting for Element to be clickable for "+seconds+" seconds");
        new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.elementToBeClickable(element));
    }


}
