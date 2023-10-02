package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.annotations.BeforeClass;

import Framework.TestData;				
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;

public class _testTemplate extends setupFramework {

	@BeforeMethod
	@BeforeClass
	public void setUp() /*throws InterruptedException */ {
		driver=getDriver();   //   Also have a valid ChromeDriver here
		System.out.println("Driver established for: " + driver.getClass());
		//driver.manage().timeouts().wait(Framework.waitMethods.w100);
	}
	
	
//	@Test(priority = ##) //Description  
//	private void templateById() {
//	        WebElement ele = driver.findElement(By.id("id")); //.click();		//******** By.id
//	        highlightElement.highLightElement(driver, ele);
//	        ele.click();
//	        waitMethods.waiter(1500);
//	        System.out.println("message");
//	} 
	
	
	
//	@Test(priority = ##)  //DESCRIPTION
//	public void templateBycssSelector() {
//    	waitMethods.waiter(200);
//    	WebElement ele = driver.findElement(By.cssSelector("[title^='Enter your search text']"));	//******** By.cssSelector
//    	highlightElement.highLightElement(driver, ele);
//    	ele.sendKeys(TestData.SB_REQNUM);
//    	System.out.println("message");
//    	waitMethods.waiter(1000);
//	}
	
	
//	@Test(priority = ##)  //DESCRIPTION
//	public void templateByName() {  //notes
//    	waitMethods.waiter(200);
//    	WebElement ele = driver.findElement(By.name("searchtxt"));		       					//******** By.name
//    	highlightElement.highLightElement(driver, ele);
//    	ele.sendKeys("");
//    	waitMethods.waiter(1000);
//	}
	
	
//	@Test(priority = ##)
//	public void templateByName() {
//		waitMethods.waiter(200);
//		WebElement ele = driver.findElement(By.name("searchtxt"));		          				//******** By.name    (2+ elements)
//		ele.sendKeys("excel");
//		highlightElement.highLightElement(driver, ele);
//		waitMethods.waiter(500);
//		 	driver.findElement(By.name("")).clear();
//		 	waitMethods.waiter(500);
//		System.out.println("message");
//	}


	
//	@Test(priority = ##) //		
//	private void templateByPartialLinkText() {
//	        WebElement ele = driver.findElement(By.partialLinkText("link text")); //.click();	//******** By.partialLinkText
//	        highlightElement.highLightElement(driver, ele);
//	        ele.click();
//			waitMethods.waiter(500);
//	        System.out.println("message");
//	} 
	

//Add this for Text Box Input
//
//String name = "test";
//		   
//for(int i = 0; i < name.length(); i++) {
//	char c = name.charAt(i);
//	String s = new StringBuilder().append(c).toString();
//	ele.sendKeys(s);
//	waitMethods.waiter(waitMethods.w100);
//}



}  //class
