package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;

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

public class orgChartWorkflow extends setupFramework {

	//private static final DateFormat Calendar = null;
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
 
//create New Request Workflow
	
	@Test(priority = 102) //									TODO:May have to change name on Pre-prod
	private void searchByEmployee() {
		waitMethods.waiter(waitMethods.w300);       
		WebElement ele = driver.findElement(By.id("search"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Richard, Max";		//  Scott Wagner
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
    	
    	driver.findElement(By.id("search")).clear(); 
    	System.out.println("Search By Employee");			
	}


	@Test(priority = 104) //									TODO:May have to change name on Pre-prod
	public void verifySearchByEmployee() {         			// ERR Data not found in PROD
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);	
		WebElement ele = driver.findElement(By.partialLinkText("Richard, Max"));    //Wagner
		highlightElement.highLightElement(driver, ele);
		String verify = ele.toString();
		System.out.println("Employee = " + verify);
		//highlightElement.highLightElement(driver, ele);		
		
		Assert.assertTrue(ele.toString().contains("Richard, Max"));	
		waitMethods.waiter(waitMethods.w300);
		System.out.println("Search for employee name on page");
	}

//	public void verifySearchByPositionDELETE() {         
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w1k);	
//		WebElement ele = driver.findElement(By.partialLinkText("Accountability")); 
//		highlightElement.highLightElement(driver, ele);
//		String verify = ele.toString();
//		System.out.println(verify);
//		Assert.assertTrue(ele.toString().contains("Accountability"));
//	
//		waitMethods.waiter(waitMethods.w250);
//		System.out.println("Verify search by Position on page");
//	}
	
	
	
	@Test(priority = 106) //
	private void searchByPosition() {
		waitMethods.waiter(waitMethods.w300);       
		WebElement ele = driver.findElement(By.id("search"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Accountability Officer";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
    	
    	driver.findElement(By.id("search")).clear();
    	System.out.println("Search By Position");			
	}

	
	
	@Test(priority = 108) //STILL FAILING???    TODO:
	public void verifySearchByPosition() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);	
		WebElement ele = driver.findElement(By.partialLinkText("Accountability")); 
		highlightElement.highLightElement(driver, ele);
		String verify = ele.toString();
		System.out.println(verify);
		Assert.assertTrue(ele.toString().contains("Accountability"));
	
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Verify search by Position on page");
	}


	@Test(priority = 110) //
	private void searchByGroup() {
		waitMethods.waiter(waitMethods.w300);       
		WebElement ele = driver.findElement(By.id("search"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "ADPAC";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
    	
    	driver.findElement(By.id("search")).clear();
    	System.out.println("Search By Group");			
	}

	
	
	@Test(priority = 112) //
	public void verifySearchByGroup() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);	
		WebElement ele = driver.findElement(By.partialLinkText("ADPAC")); 
		highlightElement.highLightElement(driver, ele);
		String verify = ele.toString();
		System.out.println(verify);
		Assert.assertTrue(ele.toString().contains("ADPAC"));
	
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Verify search by Group on page");
	}

	
	@Test(priority = 114) //
	private void searchByServices() {
		waitMethods.waiter(waitMethods.w500);       
		WebElement ele = driver.findElement(By.id("search"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Office of GEC";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
    	
    	driver.findElement(By.id("search")).clear();
    	System.out.println("Search By Service");			
	}

	
	
	@Test(priority = 116) //
	public void verifySearchByService() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);	
		WebElement ele = driver.findElement(By.partialLinkText("Office of GEC")); 
		highlightElement.highLightElement(driver, ele);
		String verify = ele.toString();
		System.out.println(verify);
		Assert.assertTrue(ele.toString().contains("Office of GEC"));
	
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Verify search by Services on page");
	}
	

	

}  //class
	