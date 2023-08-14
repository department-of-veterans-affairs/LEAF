package Execution;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.testng.annotations.Test;

import Framework.highlightElement;
import Framework.vbsExecutor;
import Framework.waitMethods;


import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;
import Framework.dateAndTimeMethods;
import Framework.vbsExecutor;

public class testVBS extends Framework.setupFramework{

	
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
	    	//waitMethods.implicitWait(waitMethods.w250);
	    	waitMethods.waiter(waitMethods.w250);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w250);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); 
	        highlightElement.highLightElement(driver, ele2);
	    	ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 
	
	
	@Test(priority = 3316) 					//
	private void selectWriteEmail() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Write Email')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Write Email");
	} 
	
	
	@Test(priority = 3320) 					//
		private void closeEmail() {
			vbsExecutor.executeVBS("C:\\DEV\\Tools\\VB-Scripts\\", "CloseOutlookVerifyFailsafeMR.vbs");
	}	
	
	
}  //class
