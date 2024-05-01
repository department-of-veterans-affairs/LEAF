package Framework;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.annotations.BeforeClass;


public class elementLocator extends setupFramework {

	Date date = new Date();
	
	@BeforeMethod
	@BeforeClass
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver();   //   Also have a valid ChromeDriver here
			//System.out.println("Driver established for: " + driver.getClass());
			//driver.manage().timeouts().wait(Framework.waitMethods.w100);
		}
	}
	

	//Cert test in the event this is starting page for tests
	@Test(priority = 1) //MUST REMAIN #1 ( or zero)
	private void testForCertPage() /*throws InterruptedException */ {
	    try {
	    	//waitMethods.implicitWait(waitMethods.w300);
	    	waitMethods.waiter(waitMethods.w200);
	    	WebElement ele = driver.findElement(By.id("details-button")); 
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w200);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); 
	    	ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 
 
	
	
	///// AUT \\\\\\\\
	
//	@Test(priority = 214) //
//	private void selectMRTestChkBox() {
//	    WebElement ele = driver.findElement(By.xpath("//*[@id=\"record\"]/div[2]/div[2]/div/div[2]/span/div[10]"));
//	    highlightElement.highLightElement(driver, ele);
//	    waitMethods.waiter(waitMethods.w500);
//	    ele.click();   
//	    waitMethods.waiter(waitMethods.w1k);
//	    System.out.println("Selected MR - Test Checkbox");
//	} 

	@Test(priority = 212) //
	public void inputRequestTitle() {
		//waitMethods.implicitWait(waitMethods.w300);	
		System.out.println("Test Automation: " + getDate());
		waitMethods.waiter(waitMethods.w500);
	    System.out.println("Input Request Title: 'Test Automation");
	} 
	
	public Date getDate() {
//		SimpleDateFormat dte = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
//		return dte;
		
		SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd 'at' HH:mm:ss");
		Date date = new Date(System.currentTimeMillis());
		System.out.println(formatter.format(date));
		return date;
	}
	
	
	
}  //class
