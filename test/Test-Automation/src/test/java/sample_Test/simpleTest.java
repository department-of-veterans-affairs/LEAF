package test.java.sample_Test;

import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.*;

public class simpleTest {

	public static void main(String[] args) {
		
	
	
	System.setProperty("webdriver.chrome.driver", test.java.Framework.AppVariables.CHROMEDRIVER);
	WebDriver driverChrome = new ChromeDriver();

	driverChrome.get("https://localhost/LEAF_Request_Portal/");
	driverChrome.manage().window().maximize();

	System.out.println("Chrome should be maximized and GETURL loaded");

	
	
	    try {
	        driverChrome.findElement(By.id("details-button")).click();
	      //driver.manage().timeouts().implicitlyWait(200, TimeUnit.MILLISECONDS);
	        driverChrome.findElement(By.partialLinkText("Proceed to localhost")).click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    }
	 
	
	
	System.out.println("Perform basic search using Text");
	//homeSetup pageAUT = new homeSetup(driver);
	driverChrome.findElement(By.name("searchtxt")).sendKeys("excel");
	
	}
	
}  //Class
