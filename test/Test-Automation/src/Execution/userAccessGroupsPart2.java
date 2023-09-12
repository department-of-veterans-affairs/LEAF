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


public class userAccessGroupsPart2 extends setupFramework {

	
	public String sRand;
	public String groupNum;
	public String nexusURL = "https://localhost/LEAF_Nexus/?a=view_group&groupID=";
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
		//closeDownMainPortal();
	
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
		driver.navigate().back();;
	}
	
	
	
	@Test(priority = 2040) //
	private void openUserAccessGroups() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.xpath("//span[contains(text(),'User Access Groups')]"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/a[16]/span[1]"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
	    System.out.println("Clicked SYNC SERVICES");
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
		waitMethods.waiter(waitMethods.w1k); 
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
		highlightElement.highLightElement(driver, ele); 
	    ele.click();
	    System.out.println("Opened Test User Group ");
	} 
	
	
	
//	@Test(priority = 160) //
//	private void openAccessGroup() {
//		//System.out.println("Before opening Group\ngroupNum = " + groupNum);
//		waitMethods.waiter(waitMethods.w1k);    //  "Test User Access Group " + groupNum
//		//String s = "Test User Access Group " + groupNum;
//		//String s = ".Test User Access Group ";
//		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), '.Test User Access Group')]"));
//		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), '" + s + "')]"));
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
//		highlightElement.highLightElement(driver, ele); 
//	    ele.click();
//	    System.out.println("Opened Test User Group ");
//	} 
//	
//
//	
//	
//	//Click Save button
//	@Test(priority = 180) 
//	private void saveEmployee() {									
//		saveUserGroup();
//        System.out.println("Saved User Group");
//	} 
//	
//	
//	@Test(priority = 305) 
//	private void confirmYes() {			
//		waitMethods.waiter(waitMethods.w200);
//		WebElement ele = driver.findElement(By.id("confirm_button_save"));
//        highlightElement.highLightElement(driver, ele);  
//        ele.click();	
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Confirmed action");
//	} 
//	
//	@Test(priority = 990) //
//	private void getElementID() {				
//		waitMethods.waiter(waitMethods.w2k);  
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
//		highlightElement.highLightElement(driver, ele);
//		id = ele.getAttribute("id").toString();
//		System.out.println("Element ID = " + id);
//	    //ele.click();
//	    System.out.println("Got User Access Group ID");  
//	    waitMethods.waiter(waitMethods.w500);
//	} 
//	
//
//	
//	@Test(priority = 993)
//	public void closeDownMainPortal1() {
//		closeDownMainPortal();
//	}
//	
//	
//	@Test(priority = 995) 
//	public void createNexusDriver1() {
//		createNexusDriver();
//	}
//	
//
//	
//	
//	@Test(priority = 1000) //		
//	private void clickAddUserInNexus() {	
//		System.out.println("Entered addUseInNexus Method"); 
//			//Debugging
//			String sURL = driverNexus.getCurrentUrl();
//				System.out.println("URL in method addUserInNexus(): " + sURL); 
//		waitMethods.waiter(waitMethods.w3k);  
//		//WebElement ele = driverNexus.findElement(By.xpath("//button[contains(text(), ' Add Employee/Position')]"));
//		WebElement ele = driverNexus.findElement(By.id("button_addEmployeePosition"));
//		highlightElement.highLightElement(driverNexus, ele);
//		ele.click();
//	    System.out.println("Open Add Employee Dialogue");  
//	} 
//	
//
//	
//	
//	@Test(priority = 1010) //
//	private void selectSearchEmployeesOnly() {				
//		waitMethods.waiter(waitMethods.w1k);  
//		WebElement ele = driverNexus.findElement(By.id("ignorePositions"));		
//		highlightElement.highLightElement(driverNexus, ele);
//		ele.click();
//	    System.out.println("Select Search Employees Only");  
//	} 
//
//	
//	
//	
//
//	
//	//Input NEXUS User 		Terry, Rodney Jacobi	
//	@Test(priority = 1020)
//	public void inputNexusEmployee() {   
//	  	waitMethods.waiter(waitMethods.w300);     			//Input Box
//	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div[3]/div[1]/input"));
//	  	highlightElement.highLightElement(driverNexus, ele);
//	  	
//	  	String name = "Terry, Rodney Jacobi";
//	  	   
//	  	for(int i = 0; i < name.length(); i++) {
//	  		char c = name.charAt(i);
//	  		String s = new StringBuilder().append(c).toString();
//	  		ele.sendKeys(s);
//	   		waitMethods.waiter(waitMethods.w10);
//	  	}
//	  	
//	  		waitMethods.waiter(waitMethods.w100);
//		    System.out.println("Input Nexus User and Select");		
//	}
//	
//	
//	
//	@Test(priority = 1030)
//	public void saveNexusEmployee() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driverNexus.findElement(By.id("button_save"));
//        //highlightElement.highLightElement(driverNexus, ele);  
//        ele.click();	
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Clicked Save");
//	}
//	
//	
//	
//	
//	@Test(priority = 1040) //		
//	private void clickAddUserInNexus2() {	
//		clickAddUserInNexus();
//	} 
//	
//
//	
//	
//	@Test(priority = 1050) //
//	private void selectSearchEmployeesOnly2() {				
//		selectSearchEmployeesOnly();
//	} 
//	
//	
//	
//	
//	//Input NEXUS User 			Walker, Taina Moen
//	@Test(priority = 1060)
//	public void inputNexusEmployee2() {   
//	  	waitMethods.waiter(waitMethods.w300);     			//Input Box
//	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div[3]/div[1]/input"));
//	  	highlightElement.highLightElement(driverNexus, ele);
//	  	
//	  	String name = "Walker, Taina Moen";
//	  	   
//	  	for(int i = 0; i < name.length(); i++) {
//	  		char c = name.charAt(i);
//	  		String s = new StringBuilder().append(c).toString();
//	  		ele.sendKeys(s);
//	   		waitMethods.waiter(waitMethods.w10);
//	  	}
//	  	
//	  		waitMethods.waiter(waitMethods.w100);
//		    System.out.println("Input Nexus User and Select");		
//	}
//	
//	
//	
//	@Test(priority = 1070)
//	public void saveNexusEmployee2() {
//		saveNexusEmployee();
//	}
//	
//	
//	
//	@Test(priority = 1080) //		
//	private void clickAddUserInNexus3() {	
//		clickAddUserInNexus();
//	} 
//	
//
//	
//	
//	@Test(priority = 1090) //
//	private void selectSearchEmployeesOnly3() {				
//		selectSearchEmployeesOnly();
//	} 
//	
//	
//	
//	
//	//Input NEXUS User 			Weber, Kurt Bradtke
//	@Test(priority = 1100)
//	public void inputNexusEmployee3() {   
//	  	waitMethods.waiter(waitMethods.w300);     			//Input Box
//	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div[3]/div[1]/input"));
//	  	highlightElement.highLightElement(driverNexus, ele);
//	  	
//	  	String name = "Weber, Kurt Bradtke";
//	  	   
//	  	for(int i = 0; i < name.length(); i++) {
//	  		char c = name.charAt(i);
//	  		String s = new StringBuilder().append(c).toString();
//	  		ele.sendKeys(s);
//	   		waitMethods.waiter(waitMethods.w10);
//	  	}
//	  	
//	  		waitMethods.waiter(waitMethods.w100);
//		    System.out.println("Input Nexus User and Select");		
//	}
//	
//	
//	
//	@Test(priority = 1110)
//	public void saveNexusEmployee3() {
//		saveNexusEmployee();
//	}
//	
//	
//	
//	
//	
//	@Test(priority = 1200)
//	public void selectMemberPosition1() {
//		waitMethods.waiter(waitMethods.w3k);
//		WebElement ele = driverNexus.findElement(By.xpath("//a[contains(text(),'Abbott, Roman')]"));
//        highlightElement.highLightElement(driverNexus, ele);  
//        ele.click();	
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Selected Member in Position 1");
//	}
//	
//	
//
//	//===== ADD Backup for Position 1 ====================================================
//	
//	@Test(priority = 1210)
//	public void clickAssignBackup() {
//		waitMethods.waiter(waitMethods.w1k);
//		WebElement ele = driverNexus.findElement(By.xpath("//*[contains(text(), ' Assign Backup')]"));
//        highlightElement.highLightElement(driverNexus, ele);  
//        ele.click();	
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Clicked Assign Backup");
//	}
//	
//	
//	
//	
//	@Test(priority = 1220)
//	public void addBackupPosition1() {  
//	  	waitMethods.waiter(waitMethods.w300);     			//  
//	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div/div[1]/input"));
//	  	highlightElement.highLightElement(driverNexus, ele);
//	  	ele.click();
//	  	
//	  	String name = "Kub, Brandon Schmidt.";
//	  	   
//	  	for(int i = 0; i < name.length(); i++) {
//	  		char c = name.charAt(i);
//	  		String s = new StringBuilder().append(c).toString();
//	  		ele.sendKeys(s);
//	   		waitMethods.waiter(waitMethods.w10);
//	  	}
//	  	
//	  		waitMethods.waiter(waitMethods.w100);
//		    System.out.println("Backup Added for Position 1");		
//	}	
//	
//	
//	
//	@Test(priority = 1230)
//	public void saveBackup() {
//		saveNexusEmployee();
//	}
//	
//
//	
//	@Test(priority = 1240)
//	public void navigateNexusBack() {
//		driverNexus.navigate().back();;
//	}
//
//	
//	//===== ADD Backup for Position 2 ====================================================
//	
//	@Test(priority = 1250)
//	public void selectMemberPosition2() {
//		waitMethods.waiter(waitMethods.w3k);
//		WebElement ele = driverNexus.findElement(By.xpath("//a[contains(text(),'Considine, Warren')]"));
//        highlightElement.highLightElement(driverNexus, ele);  
//        ele.click();	
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Selected Member in Position 1");
//	}
//	
//	
//
//	
//	@Test(priority = 1260)
//	public void clickAssignBackup2() {
//		waitMethods.waiter(waitMethods.w1k);
//		WebElement ele = driverNexus.findElement(By.xpath("//*[contains(text(), ' Assign Backup')]"));
//        highlightElement.highLightElement(driverNexus, ele);  
//        ele.click();	
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Clicked Assign Backup");
//	}
//	
//	
//	
//	
//	@Test(priority = 1270)
//	public void addBackupPosition2() {  
//	  	waitMethods.waiter(waitMethods.w300);     			//  
//	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div/div[1]/input"));
//	  	highlightElement.highLightElement(driverNexus, ele);
//	  	ele.click();
//	  	
//	  	String name = "Carroll, Zoila Lind";
//	  	   
//	  	for(int i = 0; i < name.length(); i++) {
//	  		char c = name.charAt(i);
//	  		String s = new StringBuilder().append(c).toString();
//	  		ele.sendKeys(s);
//	   		waitMethods.waiter(waitMethods.w10);
//	  	}
//	  	
//	  		waitMethods.waiter(waitMethods.w100);
//	  		System.out.println("Backup Added for Position 2");		
//	}	
//	
//	
//	
//	@Test(priority = 1280)
//	public void saveBackup2() {
//		saveNexusEmployee();
//	}
//	
//	
//	
//	@Test(priority = 1290)
//	public void navigateNexusBack2() {
//		driverNexus.navigate().back();;
//	}
	
	
	
	
	/*
	 *  Go ahead and write methods to check xactions in Main Portal
	 *  Delete users
	 *  Remove backups
	 *  Add additional assertions
	 * 
	 */
	
	
	
	/*
	 * END ADD tests 
	 */
	
	
	
	
	/*
	
		Removing users in Nexus
			Position 1: /html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[1]/a[2]
			Position 2: /html/body/div[2]/div/div/div[1]/div/div[4]/div[2]/div[2]/a[2]

	*/
	
	// Delete a couple - probably by xpath. Check on backups
	// Assert.assertEquals(pageTitle, "Academy Demo Site (Test site) | Washington DC | Washington DC", "Page Title does not match expected value");
	
	
	
	//  https://localhost/LEAF_Request_Portal/admin/
	//  contains 'Sync Services'
	
	
	
	
	/* ASSERTION Method to determine whether the value of an element is present (or not - Fail test) 
	 * 
	 * 	@Test(priority = 104) //
		public void verifySearchByEmployee() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w300);	
			WebElement ele = driver.findElement(By.partialLinkText("Wagner")); 
			highlightElement.highLightElement(driver, ele);
			String verify = ele.toString();
			System.out.println(verify);
			Assert.assertTrue(ele.toString().contains("Wagner"));	
			System.out.println("Search for employee name on page");
		}
	 * 
	 */
	
	
	
	/*
	 * Add Assertions (Main Portal?)
	 * 
	 * 
	 * Show Inactive Users							showInactive
	 * Assert that Abbott, Roman is displayed
	 * Reactive										reActivateMember_0   // like users 0, 1, 2
	 * Hide Inactive						same	showInactive
	 * 
	 * Prune										pruneMember_0		// like users, pruneMember_0, 1, 2
	 * 
	 */	
	
	
		
	/*************  Ending Procedures  *********/	
	
//	@Test(priority = 9000) //
//	private void editGroupName() {
//		waitMethods.waiter(waitMethods.w1k);
//
//		//WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[1]/button[1]"));
//		     //WebElement ele = driverNexus.findElement(By.xpath("//*[contains(text(), 'Abbott, Roman'"));
//		WebElement ele = driverNexus.findElement(By.xpath("//button[contains(text(), ' Edit Group Name')]"));
//	    highlightElement.highLightElement(driverNexus, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w300);
//	    System.out.println("Clicked on Edit Group Name");
//	} 
//	
//	
//	
//	//  Change Group Name		inputtitle
//	@Test(priority = 9020)
//	public void inputNewGroupTitle() {   
//    	waitMethods.waiter(waitMethods.w500);     			//Input Box
//    	WebElement ele = driverNexus.findElement(By.id("inputtitle"));
//    	//highlightElement.highLightElement(driverNexus, ele);
//    	ele.clear();
//    	String name = "Completed Access Group Test " + groupNum;
//    	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//     		waitMethods.waiter(waitMethods.w10);
//    	}
//    	
// 	    System.out.println("Changed Access Group Title");  // Changes sort order so that it will not be
// 	    												   // the first group in the upper left
//	}
//	
//	
//	
//	@Test(priority = 9030)  
//	private void saveUserGroupNexus() {									//Click Save button
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driverNexus.findElement(By.id("button_save"));
//        //highlightElement.highLightElement(driverNexus, ele);  
//        ele.click();	
//        waitMethods.waiter(waitMethods.w300);
//        System.out.println("Clicked Save");
//	} 
//			
//			
//	
//	@Test(priority = 1300)
//	public void closeDownNexus1() {
//		closeDownNexus();
//	}
	
	

	

/*
 * IDs
 * userGroupSearch
 * 		//String s = ".Test User Access Group ";    // don't forget prefacing dot (.)
		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), '" + s + "')]"));
 *  
 * */	


}  //class userAccessGroups
