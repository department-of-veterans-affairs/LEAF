package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
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


public class userAccessGroupsPart_BACKUP extends setupFramework {

	
	public String sRand;
	public String groupNum;
	public String nexusURL = "https://localhost/LEAF_Nexus/?a=view_group&groupID=";
	public String portalURL = "https://localhost/LEAF_Request_Portal/admin/?a=mod_groups";
	public String id;		
	public WebDriver driverNexus;

	
	
	
	
	private static WebDriver chromeLoginNexus(String env) {	
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
	
	
	public WebDriver getDriverNexus() {						
        return driverNexus;					//Establish ChromeDriver for Nexus
	}							

	
	
	 
	public void createNexusDriver() {
		String NexusURL = nexusURL + id;
		System.out.println("NexusURL: " + NexusURL);
	
		driverNexus = chromeLoginNexus(NexusURL);
		//driverNexus = chromeLoginNexus("https://localhost/LEAF_Nexus/?a=view_group&groupID=" + id);
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
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver();   //   from Framework.setupFramework
		}
		if(driverNexus!= null) {
			driverNexus=getDriverNexus();   //   from Framework.setupFramework
		}		
	}
	

	
	
	
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
 
	
	
	@Test(priority = 2000)
	private void scrollDown() {
		waitMethods.waiter(waitMethods.w2k);
		JavascriptExecutor js = (JavascriptExecutor) driver;
		js.executeScript("window.scrollBy(0,300)", "");
		System.out.println("Scroll Down");
		
	}
	
	

	
	@Test(priority = 2010) //
	private void syncServices() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.xpath("//span[contains(text(),'Sync Services')]"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/a[16]/span[1]"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
	    System.out.println("Clicked SYNC SERVICES");
	} 

	
	
	@Test(priority = 2020) //
	private void gotoAdminPanel() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Admin"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/a[16]/span[1]"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
	    waitMethods.waiter(waitMethods.w2k);
	    System.out.println("Clicked SYNC SERVICES");
	} 
	
	
	@Test(priority = 2030)
	public void navigateAdminBack() {
		driver.navigate().back();
	}
	
	
	
	@Test(priority = 2040) //
	private void openUserAccessGroups() {
		waitMethods.waiter(waitMethods.w1500);
		WebElement ele = driver.findElement(By.xpath("//span[contains(text(),'User Access Groups')]"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/a[16]/span[1]"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
	    System.out.println("Opened User Group");
	} 
	
	
	@Test(priority = 2050)
	private void scrollUp() {
		waitMethods.waiter(waitMethods.w1k);
		JavascriptExecutor js = (JavascriptExecutor) driver;
		js.executeScript("window.scrollBy(0,-300)", "");
		System.out.println("Scroll UP");
		
	}
	
	
	
	
	@Test(priority = 2070) //
	private void openAccessGroup() {
		openUserAccessGroups();
	} 
	
	
	@Test(priority = 2080) //
	private void getElementID() {				
		waitMethods.waiter(waitMethods.w3k);  
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
		highlightElement.highLightElement(driver, ele);
		id = ele.getAttribute("id").toString();
		System.out.println("Element ID = " + id);
	    System.out.println("Got User Access Group ID");  
	    waitMethods.waiter(waitMethods.w500);
	} 
	
	
	@Test(priority = 2085)
	public void closeDownMainPortal1() {
		closeDownMainPortal();
	}
	
	

	@Test(priority = 2090) 
	public void createNexusDriver1() {
		createNexusDriver();
	}
	
	
	
	@Test(priority = 2100)
	public void deleteNexusUser6() {		// 6th position - Weber, Kurt
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[6]/a[2]")); 
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Remove User - Weber, Kurt");
	}
	
	
	
	@Test(priority = 2120) 
	private void confirmYes() {			
		waitMethods.waiter(waitMethods.w200);
		WebElement ele = driverNexus.findElement(By.id("confirm_button_save"));
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Confirmed action");
	} 
	

	
	@Test(priority = 2130)
	public void deleteNexusUser5() {		// 5th position - Walker, Taina
		waitMethods.waiter(waitMethods.w1k);	
		WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[5]/a[2]")); 
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Remove User - Walker, Taina");
	}
	
	
	
	@Test(priority = 2140) 
	private void confirmYes5() {			
		confirmYes();
	} 

	
	
	
	@Test(priority = 2150)
	public void deleteNexusUser4() {		// 4th position - Terry, Rodney
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[4]/a[2]")); 
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Remove User - Terry Rodney");
	}
	
	
	
	@Test(priority = 2160) 
	private void confirmYes4() {			
		confirmYes();
	} 
	
	
	
	// *********** Comment from here down to leave last 3 users and DELTE GROUP ************
	
	
	
	@Test(priority = 2170)
	public void deleteNexusUser3() {		// 3th position - Sauer, Valentin
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[3]/a[2]")); 
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Remove User - Sauer, Valentin");
	}
	
	
	
	@Test(priority = 2180) 
	private void confirmYes3() {			
		confirmYes();
	} 
	
	
	
	@Test(priority = 2190)
	public void deleteNexusUser2() {		// 2nd position - Considine, Warren
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[2]/a[2]")); 
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Remove User - Considine, Warren");
	}
	
	
	
	@Test(priority = 2200) 
	private void confirmYes2() {			
		confirmYes();
	} 


	
	@Test(priority = 2210)
	public void deleteNexusUser1() {		// 1st position - Abbott, Roman
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[1]/a[2]")); 
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Remove User - Abbott, Roman");
	}
	
	
	
	@Test(priority = 2220) 
	private void confirmYes1() {			
		confirmYes();
	} 

	
	@Test(priority = 2230) //
	private void DELETE_GROUP() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(),' Delete Group')]"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
	    System.out.println("Clicked DELETE GROUP");
	} 
	
	
	// *********** END Note to Comment out - will leave last 3 users and Not DELTE GROUP ************
	
	
//	@Test(priority = 4000)
//	public void closeDownNexus1() {
//		closeDownNexus();
//	}
	

	
	@Test(priority = 5000) 
	public void createPortalDriver1() {
		//getDriver();
		driver.navigate().to("https://localhost/LEAF_Request_Portal/admin/?a=mod_groups");
	}
	

	
	@Test(priority = 6000) //
	private void openAccessGroup2() {
		openUserAccessGroups();
	} 
	
	
	// getDriver();
	//  or
	// driver=getDriver();
	
	
	
}  //class userAccessGroupsPart2
