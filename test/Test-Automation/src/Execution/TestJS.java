package Execution;

import org.openqa.selenium.chrome.ChromeDriver;
import org.testng.annotations.Test;
import org.testng.annotations.BeforeClass;
import java.util.concurrent.TimeUnit;
import java.util.List;
import java.util.Set;

import Framework.highlightElement;
import Framework.setupFramework;
import Framework.waitMethods;

import org.openqa.selenium.*;



public class TestJS extends setupFramework {

	public void testSetup() {
		
	
	
		//System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		WebDriver driver = new ChromeDriver();
	
		driver.get("https://localhost/LEAF_Request_Portal/");
		driver.manage().window().maximize();
	
		System.out.println("Chrome should be maximized and GETURL loaded");
	
		
		
		//Cert test if this is starting page for tests
		//@Test(priority = 1) //MUST REMAIN #1 ( or zero)

	
	
		System.out.println("Perform basic search using Text");
		//homeSetup pageAUT = new homeSetup(driver);
		driver.findElement(By.name("searchtxt")).sendKeys("excel");
	
	}
	
	//@BeforeClass
	private void testForCertPage() /*throws InterruptedException */ {
	    try {
	    	//waitMethods.implicitWait(waitMethods.w300);
	    	waitMethods.waiter(waitMethods.w300);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w300);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); 
	        highlightElement.highLightElement(driver, ele2);
	    	ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 
	
	
	//@Test(priority = 150)
	public void scroll() {
		//Perform Scroll down			===> write class to pass js   Update: javascriptExecutor.java
		JavascriptExecutor js = (JavascriptExecutor) driver;		//THIS WORKS
		js.executeScript("window.scrollBy(0,800)");		//down 800 pixels (vertical axis)
	}

	
}  //Class
