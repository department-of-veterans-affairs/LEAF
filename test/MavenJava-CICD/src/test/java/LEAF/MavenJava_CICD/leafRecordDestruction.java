package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;
import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.JavascriptExecutor;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

import java.util.Random;

import Framework.AppVariables;
import Framework.TestData;
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;


public class leafRecordDestruction extends setupFramework {

	
	public String sRand;
	public String groupNum;
	public String nexusURL = "https://localhost/LEAF_Nexus/?a=view_group&groupID=";
	public String portalURL = "https://localhost/LEAF_Request_Portal/admin/?a=form_vue#/";
	public String id;		
	public WebDriver driverNexus, driverPortal;

	
	
	
	
	private static WebDriver chromeLoginNexus(String env) {	  //Step 3 - call from createNexusDriver()
		System.out.println("Launching Chrome");  //Step Over until - return driver;
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		
		
			if (AppVariables.headless) {
				ChromeOptions options = new ChromeOptions();
				options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
						"--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
						"--disable-dev-shm-usage");
				WebDriver driverNexus = new ChromeDriver(options);
				driverNexus.navigate().to(env);
				System.out.println("Driver established for: " + driverNexus.getClass());
				return driverNexus;  //HEADLESS driver

			} else {
				WebDriver driverNexus = new ChromeDriver();
				driverNexus.manage().window().maximize();
				driverNexus.navigate().to(env);  
				System.out.println("Driver established using: " + driverNexus.getClass());
				
				return driverNexus;  

			}
	}	

	
	private void testForNexusCertPage() /*throws InterruptedException */ {
	    try {
	    	waitMethods.waiter(waitMethods.w300);
	    	WebElement ele = driverNexus.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driverNexus, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w300);
	    	
	        WebElement ele2 = driverNexus.findElement(By.partialLinkText("Proceed to localhost")); 
	        highlightElement.highLightElement(driverNexus, ele2);
	    	ele2.click();
	        System.out.println("Nexus Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Nexus Certificate present, proceeding ");
	    } 
	} 
	
	
	public WebDriver getDriverNexus() {		// Called from setUp() in @BeforeClass				
        return driverNexus;					//Establish ChromeDriver for Nexus
	}							

	
	
	 
	public void createNexusDriver() {		// Step 2 - called by createNexusDriver1()
		String NexusURL = nexusURL + id;
		System.out.println("NexusURL: " + NexusURL);
	
		driverNexus = chromeLoginNexus(NexusURL);
		//driverNexus = chromeLoginNexus("https://localhost/LEAF_Nexus/?a=view_group&groupID=" + id);
		waitMethods.waiter(waitMethods.w2k);
		testForNexusCertPage();
		System.out.println("Chromedriver for Nexus created");
	}
	

					// TODO:  parameterize method to accept String URL
	public void createPortalDriver() {		// Step 2 - called by  a new method to be created like createNexusDriver1()
		String NexusURL = portalURL;
		System.out.println("NexusURL: " + NexusURL);
	
		driverNexus = chromeLoginNexus(NexusURL);
		waitMethods.waiter(waitMethods.w2k);
		testForNexusCertPage();
		System.out.println("Chromedriver for Nexus created");
	}
	
	
	public void closeDownMainPortal() {
		
		driver.quit();
		System.out.println("setupFramework reached @AfterClass, driver.quit()");
		//System.out.println("Method closeDownMainPortal() Disabled - browser remains open");
	}
	
	
	public void closeDownNexus() {
		
		driverNexus.quit();
		System.out.println("setupFramework reached @AfterClass, driverNexus.quit()");
		//System.out.println("Method closeDownNexus() Disabled - browser remains open");
	}
	
	
	public String generateRand() {
    	Random random = new Random();
    	Integer rand = random.nextInt(999999);
    	sRand = rand.toString();
    	
    	System.out.println("sRand = " + sRand);

    	return sRand;
    	
	}
	
	
	@BeforeMethod
	@BeforeClass
	public void setUp()  {			//Starts Here
		if(driver!= null) {
			driver=getDriver();   //   from Framework.setupFramework
		}
		if(driverNexus!= null) {
			driverNexus=getDriverNexus();   
		}		
	}
	

	
	
	//***************** Tests Begin *******************************************************
	
	@Test(priority = 1) //MUST REMAIN #1 ( or zero) -test for certificate - if no, click Advanced -> Proceed
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
 
	
	
	@Test(priority = 4000) //  Destruction of LEAF Record Test
	private void openForm() {
		waitMethods.waiter(waitMethods.w2k);    //  "Test User Access Group " + groupNum
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Destruction of LEAF Record Test')]"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
		highlightElement.highLightElement(driver, ele); 
	    ele.click();
	    System.out.println("Opened Form ");
	} 
	

	
	
	
	@Test(priority = 4025) //			
	private void updateRecordDestructionYears() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.id("destructionAgeYears"));	
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
	    System.out.println("Opened Record Destruction Years DDL");
	
	
	    waitMethods.waiter(waitMethods.w200);
		Select select = new Select(driver.findElement(By.id("destructionAgeYears")));
		highlightElement.highLightElement(driver, ele);
		select.selectByValue("5"); 
		waitMethods.waiter(waitMethods.w100);
		WebElement ele2 = driver.findElement(By.id("destructionAgeYears"));
		ele2.click();
		System.out.println("Selected 5 years - should be 1825 days");
	
	
	} 
	
	
	
	/* ASSERTION Method to determine whether the value of an element is present (or not - Fail test) 
	 * 
	 * 	@Test(priority = 4100) //
		public void verifyDatabaseRecord() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w300);	
			WebElement ele = driver.findElement(By.partialLinkText("Destruction of LEAF Record Test")); 
			highlightElement.highLightElement(driver, ele);
			String verify = ele.toString();
			System.out.println(verify);
			Assert.assertTrue(ele.toString().contains("Destruction of LEAF Record Test"));	
			System.out.println("Verify value in Database");
		}
	 * 
	 */
	
	
	
	
//	@Test(priority = 4080) //			
//	private void confirmYes() {			
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.id("confirm_button_save"));
//        highlightElement.highLightElement(driver, ele);  
//        ele.click();		
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Confirmed action");
//	} 
//	
//	
//	
////	@Test(priority = 4100)
////	public void closeDownMainPortal2() {
////		closeDownMainPortal();
////	}
	


	


	
	
}  //class leafRecordDestruction
