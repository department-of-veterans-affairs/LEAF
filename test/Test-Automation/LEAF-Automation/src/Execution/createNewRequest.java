package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

import Framework.TestData;
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;

public class createNewRequest extends setupFramework {

	
	
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
	    	waitMethods.waiter(waitMethods.w500);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w500);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); //.click();
	    	ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 
 
//create New Request Workflow
	
	@Test(priority = 203) //
	public void selectNewRequest() {         
		//waitMethods.implicitWait(waitMethods.w300);
		//waitMethods.waiter(waitMethods.w1k);	
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[1]/span")); 
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w500);
		System.out.println("New Request Button clicked");
	}


	
	@Test(priority = 206) //
	private void selectService() {
		waitMethods.waiter(waitMethods.w1k);       
		WebElement ele = driver.findElement(By.cssSelector("#service_chosen > a > span"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w1k);
	    System.out.println("Clicked Service Drop down menu");
	} 


	
	
	@Test(priority = 209) // 
	private void selectServiceAcuteCare() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.cssSelector("#service-chosen-search-result-1")); //.click(); 
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w500);
        System.out.println("Selected Service 'Acute Care'");
} 

	//#priority_chosen > a > span	
	
	@Test(priority = 212) //
	private void selectRequestPriority() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.cssSelector("#priority_chosen > a > span")); 
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w500);
		//driver.navigate().back();    //navigate back
	    System.out.println("Selected priority DDL");
	} 


	@Test(priority = 212) 
	private void selectRequestNormalPriority() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.cssSelector("#priority_chosen > a > span")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w500);
		//driver.navigate().back();    //navigate back
	    System.out.println("Select Request Normal Priority");
	} 

	
	
	
	@Test(priority = 215) //
	private void inputRequestTitle() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.name("title")); //.click();  
	    highlightElement.highLightElement(driver, ele);
	    ele.sendKeys("Test Automation");
		waitMethods.waiter(waitMethods.w1k);
	    System.out.println("Input Request Title: 'Test Automation");
	} 


			
	@Test(priority = 218) //
	private void selectMultiRequirementChkBox() {
	    WebElement ele = driver.findElement(By.xpath("//*[@id=\"record\"]/div[2]/div[2]/div/div[2]/span/div[22]"));
	    highlightElement.highLightElement(driver, ele);
	    waitMethods.waiter(waitMethods.w500);
	    ele.click();   
	    waitMethods.waiter(waitMethods.w1k);
	    System.out.println("Selected Multi Requirement Checkbox");
	} 



	@Test(priority = 221) 
	private void selectClickToProceedButton() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"record\"]/div[2]/div[2]/div/div[3]/button")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w500);
	    System.out.println("Clicked Click to Proceed button");
	} 

	
	
//	@Test(priority = 224)
//	public void filterByGroupClear()  {   //
//		//waitMethods.implicitWait(waitMethods.w300);
//    	//waitMethods.waiter(waitMethods.w200);
//    	WebElement ele = driver.findElement(By.id("userGroupSearch"));
//    	highlightElement.highLightElement(driver, ele);
//    	driver.findElement(By.id("userGroupSearch")).clear();
//    	waitMethods.waiter(waitMethods.w200);							//REMOVE **DEBUGGING**
//		System.out.println("Filter cleared");			
//	}


	

}  //class
