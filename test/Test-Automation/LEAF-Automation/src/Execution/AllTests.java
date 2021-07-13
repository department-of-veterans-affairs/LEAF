package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import Framework.TestData;				
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;

public class AllTests extends setupFramework {
	private WebDriver driver;

	@BeforeMethod
	@BeforeClass
	public void setUp() /*throws InterruptedException */ {
		driver=getDriver();   //   Also have a valid ChromeDriver here
		System.out.println("Driver established for: " + driver.getClass());
		//driver.manage().timeouts().wait(Framework.waitMethods.w100);
	}
	


	
	@Test(priority = 1) //MUST REMAIN #1 ( or zero) -test for certificate - if no, click Advanced -> Proceed
	private void testForSiteCertPage() /*throws InterruptedException */ {
	    try {
	    	waitMethods.waiter(1000);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(2000);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); //.click();
	        highlightElement.highLightElement(driver, ele2);
	        ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 


	@Test(priority = 4)
	public void verifyHomePageTitle() /*throws InterruptedException */ {         
		System.out.println("Page Title Verified");	
		String pageTitle = driver.getTitle();
		AssertJUnit.assertEquals(pageTitle, "Academy Demo Site (Test site) | Washington DC");
		//JUnit syntax, which I had to modify anyway because it was of type boolean
	}

	
	
	
	@Test(priority = 8)
	public void basicSearchNumber() /*throws InterruptedException */ {
		System.out.println("Perform basic search using Request Number");
    	waitMethods.waiter(200);
    	WebElement ele = driver.findElement(By.cssSelector("[title^='Enter your search text']"));
    	highlightElement.highLightElement(driver, ele);
    	ele.sendKeys(TestData.SB_REQNUM);
    	waitMethods.waiter(1000);
    	
		//driver.findElement(By.cssSelector("input[name= ‘searchtxt’]")).sendKeys("245"s);
		//WebElement currentElement = driver.switchTo().activeElement();
				//WebElement currentElement = driver.switchTo().activeElement();
				//currentElement.sendKeys("245");
		//String fullXPath = "/html/body/div[2]/div/div/div[2]/div[1]/input";
		//driver.findElement(By.xpath(fullXPath)).sendKeys("245");
    	waitMethods.waiter(2000);
    	driver.findElement(By.name("searchtxt")).clear();
		System.out.println("Basic search found or not?");						// Add search of records retrieved
	}

	
	@Test(priority = 10)
	public void basicSearchText() /*throws InterruptedException */ {
		System.out.println("Perform basic search using Text");
		waitMethods.waiter(200);
		WebElement ele = driver.findElement(By.name("searchtxt"));
		ele.sendKeys("excel");
		highlightElement.highLightElement(driver, ele);
		waitMethods.waiter(2000);
   	 	driver.findElement(By.name("searchtxt")).clear();
   	 	waitMethods.waiter(1000);
	}


	@Test(priority = 15) //Links Dropdown  
	private void linksDropdown() /*throws InterruptedException */ {
	        WebElement ele = driver.findElement(By.id("button_showLinks")); //.click();
	        highlightElement.highLightElement(driver, ele);
	        waitMethods.waiter(1500);
	        ele.click();
	        waitMethods.waiter(1500);
	        System.out.println("Links test executed");
	        
	} 

	@Test(priority = 20) //Help Button Dropdown   
	private void helpDropdown() /*throws InterruptedException */ {
	        WebElement ele = driver.findElement(By.id("button_showHelp")); //.click();
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
	        waitMethods.waiter(1500);
	        System.out.println("Links test executed");
	} 

	

	@Test(priority = 25) //
	private void adminPanelPage() /*throws InterruptedException */ {
	        //WebElement ele = driver.findElement(By.className("buttonNorm")); //.click();
			String xPath = "//*[@id=\"headerMenu\"]/a";
			WebElement ele = driver.findElement(By.xpath(xPath));
	        highlightElement.highLightElement(driver, ele);
	        waitMethods.waiter(1000);
	        ele.click();
			waitMethods.waiter(1500);
	        System.out.println("Admin panel clicked");
	}  //after this it opens a new page for adminPageTest???

	
////////////////////////////////////   Admin Page Tests   ///////////////////	
	
	
	
	
	@Test(priority = 30)  //
	public void verifyAdminPageTitle() /*throws InterruptedException */ {         
		System.out.println("Page Title Verified");	
		String pageTitle = driver.getTitle();
		AssertJUnit.assertEquals(pageTitle, "Academy Demo Site (Test site) | Washington DC");
		//JUnit syntax, which I had to modify anyway because it was of type boolean
	}


	@Test(priority = 35) //
	private void adminHeaderHome() {
	        WebElement ele = driver.findElement(By.partialLinkText("Home")); //.click();    //******** By.partialLinkText
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
			waitMethods.waiter(2000);
			driver.navigate().back();    //navigate back
	        System.out.println("Clicked Header Home button");
	} 

	
	
	
	@Test(priority = 38) // 
	private void adminHeaderReportBuilder() {
			waitMethods.waiter(2000);
			WebElement ele = driver.findElement(By.partialLinkText("Report Builder")); //.click();    //******** By.partialLinkText
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
			waitMethods.waiter(2000);
			driver.navigate().back();    //navigate back
	        System.out.println("Clicked Header ReportBuilder button");
	} 

		
	
	@Test(priority = 40) //
	private void adminHeaderSiteLinks() {
			waitMethods.waiter(2000);
			WebElement ele = driver.findElement(By.linkText("Site Links")); //.click();    //******** By.partialLinkText
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
			waitMethods.waiter(2000);
			//driver.navigate().back();    //navigate back
	        System.out.println("Clicked Admin Header Site links button");
	} 

	//<a href="../../LEAF_Nexus" target="_blank">Nexus: Org Charts</a>

	@Test(priority = 42) //
	private void headerNexusLinks() {
			waitMethods.waiter(2000);
			WebElement ele = driver.findElement(By.linkText("Nexus: Org Charts")); //.click();    //******** By.partialLinkText
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
			waitMethods.waiter(2000);
			driver.navigate().back();    //navigate back
	        System.out.println("Clicked Header Site links button");
	} 

		
	@Test(priority = 45) //
	private void adminUserAccessGroupsLabel() {
			waitMethods.waiter(1000);
			WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div/a[1]/span[1]")); //.click();    //******** By.partialLinkText
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
			waitMethods.waiter(2000);
			driver.navigate().back();    //navigate back
	        System.out.println("Clicked User Access Groups label");
	} 
	
	
	//leaf-admin-btntitle
	@Test(priority = 50) //
	private void adminServiceChiefsLabel() {
		waitMethods.waiter(1000);
		WebElement ele = driver.findElement(By.xpath("<span class=\"leaf-admin-btntitle\">Service Chiefs</span>")); //.click();    //******** By.partialLinkText
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
			waitMethods.waiter(2000);
			driver.navigate().back();    //navigate back
	        System.out.println("Clicked Header Home button");
	} 
	
	
	
	
	//VALID TEST
//	@Test(priority = 99)
//	public void selectNewRequest() {         //menuButtonSmall
//		System.out.println("Validating Click on New Requst");
//		//driver.findElement(By.className("menuButtonSmall")).click();
//		driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[1]/span")).click();
//	}
//


}  //class
