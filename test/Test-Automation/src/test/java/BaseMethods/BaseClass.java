package test.java.BaseMethods;

import test.java.Framework.AppVariables;
import test.java.Framework.highlightElement;
import test.java.Framework.waitMethods;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.Random;

public class BaseClass {

    WebDriver driver;
    public void clickElement(WebElement element) {
        try {
            WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(20));
            wait.until(ExpectedConditions.elementToBeClickable(element)).click();
        } catch (NoSuchElementException e) {
            e.printStackTrace();
        }
    }

    public void SelectElement(String value, WebElement element){
        Select select = new Select(driver.findElement(By.id(String.valueOf(element))));
        highlightElement.highLightElement(driver, element);
        select.selectByValue(value);
        waitMethods.waiter(waitMethods.w200);	//Closes the DDL
        WebElement ele2 = driver.findElement(By.id(String.valueOf(element)));
        ele2.click();
    }

    public void Sendkeys(String value, WebElement element){
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(20));
        wait.until(ExpectedConditions.elementToBeClickable(element)).sendKeys(value);;

    }

    public void Entervalue(String value, WebElement element ){

    }

    public String getText(WebElement element){
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(20));
        return  wait.until(ExpectedConditions.elementToBeClickable(element)).getText();
     //  return element.getText();

    }

    public void clear( WebElement element){
        element.clear();
    }

    public void waiter(int waitTimeInMillis) {
        try {
            Thread.sleep(waitTimeInMillis);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }


    public static void highLightElement(WebDriver driver, WebElement ele) {
        int i = 0;
        int j = 50;
        if (AppVariables.demoMode) {   //Set T/F in test.java.Framework.AppVariables.demoMode
            JavascriptExecutor js = (JavascriptExecutor) driver;

            for(i = 0; i <3; i++) {
                //if(i == 3) {j =200;}
                js.executeScript("arguments[0].setAttribute('style', 'background: yellow; border: 2px solid red;');", ele);
                waitMethods.waiter(j);

                js.executeScript("arguments[0].setAttribute('style','border: solid 2px white');", ele);
                waitMethods.waiter(j);
                //}

            }
        }
    }

    public String generateRand() {
        String sRand;
        Random random = new Random();
        Integer rand = random.nextInt(999999);
        sRand = rand.toString();

        System.out.println("sRand = " + sRand);

        return sRand;

    }

    public WebElement waitForElementToBeVisible(WebElement element){
        WebDriverWait Wait = new WebDriverWait(driver,Duration.ofSeconds(20));
        return(WebElement) Wait.until(ExpectedConditions.visibilityOf(element));
    }
}
