package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertFalse;
import static org.testng.Assert.fail;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.openqa.selenium.support.ui.Select;			//Select Method

import Framework.TestData;
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;

public class TestAdvancedFormatting extends setupFramework {

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
 

	
		@Test(priority = 125) //										//GET AUT	  			
		private void Testing() {			// Get existing Request - AUT
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'AUT')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w250);	
	    	System.out.println("Opening existing form = AUT");
		}		
		
		
		@Test(priority = 130) //	  			
		private void selectEditFieldIcon() {		
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Test Q1')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w250);	
	    	System.out.println("Test Question: Edit Field Icon");
		}
		
		
		
		@Test(priority = 164) //  Advanced Formatting
		private void selectAdvancedFormatting() {			//
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.id("advNameEditor"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Select Advanced Formatting Button");
		}
		
		
	
		@Test(priority = 166) //  Select textarea element (actually the div above it)
		private void selectTextToFormat() {			//
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/div[2]"));
			//WebElement ele = driver.findElement(By.id("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/textarea"));
	    	highlightElement.highLightElement(driver, ele);
	   		waitMethods.waiter(waitMethods.w250);
	   		
	   		
	   		//String str = ele.getAttribute("value");
	   		ele.sendKeys(Keys.chord(Keys.CONTROL, "a"));
	    	highlightElement.highLightElement(driver, ele);
	   		waitMethods.waiter(waitMethods.w250);
	   		System.out.println("Select Text to Format");
		}	
		
		
		
		@Test(priority = 168) //  
		private void formatTextBold() {			//	  'B' Bold icon 			
	   		WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/div[1]/div[2]/button"));
	   		ele.click();
	   		waitMethods.waiter(waitMethods.w250);
	   		
	    	System.out.println("Format text - Bold");
		}	
		
		

		
		
		@Test(priority = 172) //
		private void validateFormatedCodeBold() {			//   
			waitMethods.waiter(waitMethods.w250);       
			
			String strExpected = "<p><strong>Test Q1 Single line text</strong></p>";
			
			//WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/div[2]"));
			WebElement ele = driver.findElement(By.id("name"));
			highlightElement.highLightElement(driver, ele);
			String str = ele.getText();
			//String fontWeight = driver.findElement(By.className("classname")).getCssValue("font-weight").getCssValue("font-weight");
			
	    	//assertEquals(strActual, strExpected);
			waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Validate Formated Code Button");
		}	

		
		@Test(priority = 174) //  save
		private void selectSave() {			//
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Save edits to question");
		}	
		
		
		@Test(priority = 176) //	  			
		private void selectEditFieldIcon02() {		
			selectEditFieldIcon();
		}
		
		
		
		@Test(priority = 178) //  Show Formatted Code
		private void showFormatedCode() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("rawNameEditor"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Select Show Formated Code Button");
		}	
	
		
		
		
		@Test(priority = 180) //  
		private void validateFormatBold() {			//
			waitMethods.waiter(waitMethods.w250);      // 
			WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/textarea"));
	    	highlightElement.highLightElement(driver, ele);
	   		String str = ele.getText();
	   		System.out.println("Field Name: " + str);
			waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Select Field Name Text Box");

	    	if(!str.contains("strong")) {
	    		Assert.fail();
	    	} 
		}
		
		
		
		@Test(priority = 182) //  save
		private void selectSave01() {			//
			selectSave();
		}	
		
		
		@Test(priority = 184) //	  			
		private void selectEditFieldIcon03() {		
			selectEditFieldIcon();
		}
		
		
		
		@Test(priority = 186) //  Select textarea element (actually the div above it)
		private void selectTextToFormat01() {			//
			selectTextToFormat();
		}	
		
		
		@Test(priority = 188) //  
		private void formatTextItalics() {			//	   			
	   		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/div[1]/div[3]/button"));
	   		ele2.click();
	   		waitMethods.waiter(waitMethods.w250);
	   		
	    	System.out.println("Format text - Italics");
		}	
		

		
		@Test(priority = 190) //  save
		private void selectSave02() {			//
			selectSave();
		}	
		
		
		@Test(priority = 192) //	  			
		private void selectEditFieldIcon04() {		
			selectEditFieldIcon();
		}
		
		
		
		@Test(priority = 194) //  Show Formatted Code
		private void showFormatedCode02() {			//
			showFormatedCode();
		}	

		
		
		@Test(priority = 196) //  
		private void validateFormatItalics() {			//
			waitMethods.waiter(waitMethods.w250);      // 
			WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/textarea"));
	    	highlightElement.highLightElement(driver, ele);
	   		String str = ele.getText();
	   		System.out.println("Field Name: " + str);
			waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Select Field Name Text Box");

	    	if(!str.contains("<em>")) {
	    		Assert.fail();
	    	} 
		}
		
	
}  //class
	