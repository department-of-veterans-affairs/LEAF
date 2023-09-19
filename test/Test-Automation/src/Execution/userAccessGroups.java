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


public class userAccessGroups extends setupFramework {

	
	public String sRand;
	public String groupNum;
	public String nexusURL = "https://localhost/LEAF_Nexus/?a=view_group&groupID=";
	public String id ="";		
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
	
	
//	private void gotoTab2() {
//		driver.findElement(By.cssSelector("body")).sendKeys(Keys.CONTROL + "2");
//	}
//
//	private void gotoTab1() {
//		driver.findElement(By.cssSelector("body")).sendKeys(Keys.CONTROL + "2");
//	}

	
	
	
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
 
	
	// Comment down to line 731 for 'Testing' Version

	//    https://localhost/LEAF_Request_Portal/admin/?a=mod_groups
	
	@Test(priority = 100) //
	private void createUserAccessGroup() {
		waitMethods.waiter(waitMethods.w200);
		WebElement ele = driver.findElement(By.xpath("//button[contains(text(),' Create group')]"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w100);
	    System.out.println("Clicked on + New Group");
	} 

	
//  groupNameInput
	@Test(priority = 110)
	public void inputGroupName() {   
    	waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.id("groupNameInput"));
    	highlightElement.highLightElement(driver, ele);

    	groupNum = generateRand().toString();
    	String name = ".Test Access Group " + groupNum;
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w10);
    	}
    	
    	waitMethods.waiter(waitMethods.w100);
    	System.out.println("Input Group Name");			
	}
  


	@Test(priority = 120) 
	private void cancelCreateUserGroup() {			//Click Cancel button
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("button_cancelchange"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Cancel Add User Group");
	} 


	@Test(priority = 130) //
	private void createUserAccessGroup2() {
		createUserAccessGroup();
	} 

	
	@Test(priority = 140) //
	private void inputGroupName2() {
		inputGroupName();
	} 

	
	@Test(priority = 150) 
	private void saveUserGroup() {									//Click Save button
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.id("button_save"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        System.out.println("Clicked Save");
	} 

	
	//															ERR HERE - This fails occasionally ???
	@Test(priority = 160) //
	private void openAccessGroup() {
		//System.out.println("Before opening Group\ngroupNum = " + groupNum);
		waitMethods.waiter(waitMethods.w1k);    //  "Test User Access Group " + groupNum
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
		highlightElement.highLightElement(driver, ele); 
	    ele.click();
	    System.out.println("Opened Test User Group ");
	} 
	

	
	
//  Input User = employeeSelectorInput		Considine, Warren Bayer		
	@Test(priority = 170)
	public void inputEmployee() {   
    	waitMethods.waiter(waitMethods.w1500);     			//Input Box
    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Considine, Warren Bayer";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
     		waitMethods.waiter(waitMethods.w10);
    	}
    	
    	waitMethods.waiter(waitMethods.w100);				//Results Grid
 	    System.out.println("Input User and Select");		
	}
	
	
	//Click Save button
	@Test(priority = 180) 
	private void saveEmployee() {									
		saveUserGroup();
        System.out.println("Saved User Group");
	} 
	
	
	
	@Test(priority = 190) //
	private void openAccessGroup1() {
		openAccessGroup();
	} 
	
	
	
	//Input User 2 = employeeSelectorInput	Sauer, Valentin Will.
	@Test(priority = 200)
	public void inputEmployee2() {   
    	waitMethods.waiter(waitMethods.w1500);     			//Input Box
    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Sauer, Valentin Will";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
     		waitMethods.waiter(waitMethods.w10);
    	}
    	
 	    System.out.println("Input User 2 and Select");		
	}
	
	

	//Click Save button
	@Test(priority = 210) 
	private void saveEmployee2() {									
		saveUserGroup();
        System.out.println("Saved User Group");
	} 
	
	
	
	@Test(priority = 220) //
	private void openAccessGroup2() {
		openAccessGroup();
	} 

	
	
	
	//  Input User 3 = employeeSelectorInput	Abbott, Roman Spencer
	@Test(priority = 230)
	public void inputEmployee3() {   
    	waitMethods.waiter(waitMethods.w1500);     			//Input Box
    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Abbott, Roman Spencer";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
     		waitMethods.waiter(waitMethods.w10);
    	}
    	
 	    System.out.println("Input User 3 and Select");		
	}
	
	

	//Click Save button
	@Test(priority = 233) 
	private void saveEmployee3() {									
		saveUserGroup();
        System.out.println("Saved User Group");
	} 
	
	
	
	@Test(priority = 236) //
	private void openAccessGroup3() {
		openAccessGroup();
	} 

	
	
	//  Input User 4 for PRUNING = employeeSelectorInput	Thiel, Darwin Ullrich
	@Test(priority = 239)
	public void inputEmployee4() {   
    	waitMethods.waiter(waitMethods.w1k);     			//Input Box
    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Thiel, Darwin Ullrich";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
     		waitMethods.waiter(waitMethods.w10);
    	}
    	
 	    System.out.println("Input User 3 and Select");		
	}
	
	

	//Click Save button
	@Test(priority = 242) 
	private void saveEmployee99() {									
		saveUserGroup();
        System.out.println("Saved User Group");
	} 
	
	
	
	@Test(priority = 250) //
	private void openAccessGroup99() {
		openAccessGroup();
	} 
	

	
	
	/******* ADD to NEXUS ****************************************************/
	
	@Test(priority = 260) 
	private void addNexusUser_0() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("addNexusMember_0"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("User 0 Added to Nexus");
	} 

	
	@Test(priority = 280) 
	private void confirmNo() {	
		waitMethods.waiter(waitMethods.w200);
		WebElement ele = driver.findElement(By.id("confirm_button_cancelchange"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Canceled action");
	} 

	

	@Test(priority = 300) 
	private void addNexusUser_0_2() {	
		addNexusUser_0();
	} 

	
	
	
	@Test(priority = 305) 
	private void confirmYes() {			
		waitMethods.waiter(waitMethods.w200);
		WebElement ele = driver.findElement(By.id("confirm_button_save"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Confirmed action");
	} 
	
	
	
	@Test(priority = 307) //
	private void openAccessGroup4() {
		openAccessGroup();
	} 
	
	
	
	@Test(priority = 310) 
	private void addNexusUser_1() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("addNexusMember_1"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("User 1 Added to Nexus");
	} 
	
	
	
	
	@Test(priority = 320) 
	private void confirmYes2() {			
		confirmYes();
	} 
	
	

	@Test(priority = 325) //
	private void openAccessGroup5() {
		openAccessGroup();
	} 
	
	
	
	
	@Test(priority = 330) 
	private void addNexusUser_2() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("addNexusMember_2"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("User 2 Added to Nexus");
	} 


	
	@Test(priority = 340) 
	private void confirmYes3() {			
		waitMethods.waiter(waitMethods.w200);
		WebElement ele = driver.findElement(By.id("confirm_button_save"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w200);
        System.out.println("Confirmed action");
	} 

	
	
	@Test(priority = 345) //
	private void openAccessGroup6() {
		openAccessGroup();
	} 

	
	
	/***********    Deleting Users from Leaf Portal  Last one is Pruned (bc not added to Nexus)  ***************/
	
	@Test(priority = 350) 
	private void deleteUser_0() {		// Should be Abbott, Roman
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("removeMember_0"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Removed User 0");
	} 

	
	
	
	@Test(priority = 360) 
	private void confirmNo2() {	
		confirmNo();
	} 

	
	
	@Test(priority = 370) // Should be Abbott, Roman
	private void deleteUser_0_1() {		
		deleteUser_0(); 
	} 

	
	
	@Test(priority = 380) 
	private void confirmYes4() {	
		confirmYes();
	} 
	
	
	@Test(priority = 390) //
	private void openAccessGroup7() {
		openAccessGroup();
	} 

	
	
	
	@Test(priority = 400) 
	private void deleteUser_1() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("removeMember_1"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Removed User 1");
	} 
	
	
	
	
	@Test(priority = 410) 
	private void confirmYes5() {	
		confirmYes();
	} 

	
	
	@Test(priority = 420) //
	private void openAccessGroup8() {
		openAccessGroup();
	} 
	

	
	@Test(priority = 425) 
	private void deleteUser_3() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("removeMember_3"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Removed User 3");
	} 
	
	
	
	
	@Test(priority = 430) 
	private void confirmYes6() {	
		confirmYes();
	} 

	
	
	@Test(priority = 435) //
	private void openAccessGroup12() {
		openAccessGroup();
	} 
	

	
	@Test(priority = 440) 
	private void ShowHideInactive() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("showInactive"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Show/Hide Inactive Users");
	} 

	
	
	@Test(priority = 445) 
	private void reactivateMember_0() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("reActivateMember_0"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Reactivate Member 0");
	} 
	
	
	
	@Test(priority = 500) 
	private void confirmReactivateMember_0() {	
		confirmYes();
        System.out.println("Confirm Reactivate Member 0");
	} 
	
	
	
	@Test(priority = 510) //
	private void openAccessGroup9() {
		openAccessGroup();
	} 
	
	
	@Test(priority = 520) 
	private void ShowHideInactive2() {	
		ShowHideInactive();
	} 
	
	
	@Test(priority = 530)   
	private void reactivateMember_1() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("reActivateMember_1"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Reactivate Member 1");
	} 
	
	
	@Test(priority = 540) 
	private void confirmReactivate() {	
		confirmYes();
        System.out.println("Confirm Reactivate Member 1");
	} 
	
	
	@Test(priority = 550) //
	private void openAccessGroup10() {
		openAccessGroup();
	} 
	
	
	
	@Test(priority = 555) 
	private void ShowHideInactive3() {	
		ShowHideInactive();
	} 
	
	
	@Test(priority = 560)   
	private void pruneMember_3() {	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("pruneMember_3"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Prune Member 3");
	} 
	
	
	@Test(priority = 565) 
	private void confirmReactivate1() {	
		confirmYes();
        System.out.println("Confirm Prune Member 3");
	} 
	
	
	@Test(priority = 570) //
	private void openAccessGroup11() {
		openAccessGroup();
	} 
	
	

	
	
	// Comment all above for the 'Testing' version

	
	
	
	@Test(priority = 990) //
	private void getElementID() {				
		waitMethods.waiter(waitMethods.w2k);  
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
		highlightElement.highLightElement(driver, ele);
		id = ele.getAttribute("id").toString();
		System.out.println("Element ID = " + id);
	    //ele.click();
	    System.out.println("Got User Access Group ID");  
	    waitMethods.waiter(waitMethods.w500);
	} 
	
	
	
	@Test(priority = 993)
	public void closeDownMainPortal1() {
		closeDownMainPortal();
	}
	
	
	@Test(priority = 995) 
	public void createNexusDriver1() {
		createNexusDriver();
	}

	
	
	
	@Test(priority = 1000) //		
	private void clickAddUserInNexus() {	
		System.out.println("Entered addUseInNexus Method"); 
			//Debugging
			String sURL = driverNexus.getCurrentUrl();
				System.out.println("URL in method addUserInNexus(): " + sURL); 
		waitMethods.waiter(waitMethods.w2k);  
		//WebElement ele = driverNexus.findElement(By.xpath("//button[contains(text(), ' Add Employee/Position')]"));
		WebElement ele = driverNexus.findElement(By.id("button_addEmployeePosition"));
		highlightElement.highLightElement(driverNexus, ele);
		ele.click();
	    System.out.println("Open Add Employee Dialogue");  
	} 
	

	
	
	@Test(priority = 1010) //
	private void selectSearchEmployeesOnly() {				
		waitMethods.waiter(waitMethods.w500);  
		WebElement ele = driverNexus.findElement(By.id("ignorePositions"));		
		highlightElement.highLightElement(driverNexus, ele);
		ele.click();
	    System.out.println("Select Search Employees Only");  
	} 


	
	
	
	
	//Input NEXUS User 		Terry, Rodney Jacobi	
	@Test(priority = 1020)
	public void inputNexusEmployee() {   
	  	waitMethods.waiter(waitMethods.w300);     			//Input Box
	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div[3]/div[1]/input"));
	  	highlightElement.highLightElement(driverNexus, ele);
	  	
	  	String name = "Terry, Rodney Jacobi";
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);
		    System.out.println("Input Nexus User and Select");		
	}
	
	
	
	@Test(priority = 1030)
	public void saveNexusEmployee() {
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driverNexus.findElement(By.id("button_save"));
        //highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Save");
	}
	
	
	
	
	@Test(priority = 1040) //		
	private void clickAddUserInNexus2() {	
		clickAddUserInNexus();
	} 
	

	
	
	@Test(priority = 1050) //
	private void selectSearchEmployeesOnly2() {				
		selectSearchEmployeesOnly();
	} 
	
	
	
	
	//Input NEXUS User 			Walker, Taina Moen
	@Test(priority = 1060)
	public void inputNexusEmployee2() {   
	  	waitMethods.waiter(waitMethods.w300);     			//Input Box
	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div[3]/div[1]/input"));
	  	highlightElement.highLightElement(driverNexus, ele);
	  	
	  	String name = "Walker, Taina Moen";
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);
		    System.out.println("Input Nexus User and Select");		
	}
	
	
	
	@Test(priority = 1070)
	public void saveNexusEmployee2() {
		saveNexusEmployee();
	}
	
	
	
	@Test(priority = 1080) //		
	private void clickAddUserInNexus3() {	
		clickAddUserInNexus();
	} 
	

	
	
	@Test(priority = 1090) //
	private void selectSearchEmployeesOnly3() {				
		selectSearchEmployeesOnly();
	} 
	
	
	
	
	//Input NEXUS User 			Weber, Kurt Bradtke
	@Test(priority = 1100)
	public void inputNexusEmployee3() {   
	  	waitMethods.waiter(waitMethods.w300);     			//Input Box
	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div[3]/div[1]/input"));
	  	highlightElement.highLightElement(driverNexus, ele);
	  	
	  	String name = "Weber, Kurt Bradtke";
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);
		    System.out.println("Input Nexus User and Select");		
	}
	
	
	
	@Test(priority = 1110)
	public void saveNexusEmployee3() {
		saveNexusEmployee();
	}
	
	
	
	//===== ADD Backup for Position 1 ====================================================	
	
	@Test(priority = 1200)
	public void selectMemberPosition1() {
		waitMethods.waiter(waitMethods.w2k);
		WebElement ele = driverNexus.findElement(By.xpath("//a[contains(text(),'Abbott, Roman')]"));
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Selected Member in Position 1");
	}
	
	

	
	@Test(priority = 1210)
	public void clickAssignBackup() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("//*[contains(text(), ' Assign Backup')]"));
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Assign Backup");
	}
	
	
	
	
	@Test(priority = 1220)
	public void addBackupPosition1() {  
	  	waitMethods.waiter(waitMethods.w300);     			//  
	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div/div[1]/input"));
	  	highlightElement.highLightElement(driverNexus, ele);
	  	ele.click();
	  	
	  	String name = "Kub, Brandon Schmidt.";
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);
		    System.out.println("Backup Added for Position 1");		
	}	
	
	
	
	@Test(priority = 1230)
	public void saveBackup() {
		saveNexusEmployee();
	}
	

	
	@Test(priority = 1240)
	public void navigateNexusBack() {
		driverNexus.navigate().back();
	}

	
	//===== ADD Backup for Position 2 ====================================================
	
	@Test(priority = 1250)
	public void selectMemberPosition2() {
		waitMethods.waiter(waitMethods.w2500);
		WebElement ele = driverNexus.findElement(By.xpath("//a[contains(text(),'Considine, Warren')]"));
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Selected Member in Position 2");
	}
	
	

	
	@Test(priority = 1260)
	public void clickAssignBackup2() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("//*[contains(text(), ' Assign Backup')]"));
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Assign Backup");
	}
	
	
	
	
	@Test(priority = 1270)
	public void addBackupPosition2() {  
	  	waitMethods.waiter(waitMethods.w300);     			//  
	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/div[3]/div/div[1]/input"));
	  	highlightElement.highLightElement(driverNexus, ele);
	  	ele.click();
	  	
	  	String name = "Carroll, Zoila Lind";
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);
	  		System.out.println("Backup Added for Position 2");		
	}	
	
	
	
	@Test(priority = 1280)
	public void saveBackup2() {
		saveNexusEmployee();
	}
	
	
	
	@Test(priority = 1290)
	public void navigateNexusBack0() {
		navigateNexusBack();
	}
	

	
	
	

	//===== REMOVE Backup for Position 1 ====================================================	
	
	@Test(priority = 1300)
	public void selectMemberPosition1_2() {
		selectMemberPosition1();
	}
	
	

	
	@Test(priority = 1310)
	public void clickRemoveBackup() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.partialLinkText("Remove")); 
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Remove Backup");
	}
	
		
	@Test(priority = 1320)	
	public void saveRemoveBackup() {
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driverNexus.findElement(By.id("confirm_saveBtnText"));
        highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w100);
        System.out.println("Clicked Save");
	}
	
	
	
	
	@Test(priority = 1330)
	public void navigateNexusBackTwice() {
		navigateNexusBack();
		waitMethods.waiter(waitMethods.w300);
		navigateNexusBack();
	}

	
	
	@Test(priority = 1340)
	public void selectMemberPosition1_3() {
		selectMemberPosition1();
		waitMethods.waiter(waitMethods.w1k);
	}
	
	
	
	
	@Test(priority = 1350)
	public void navigateNexusBack1() {
		navigateNexusBack();
	}
	
	
	
	
	
	//===== REMOVE Backup for Position 2 ====================================================
	
	@Test(priority = 1360)
	public void selectMemberPosition2_2() {
		selectMemberPosition2();
	}
	
	
	
	@Test(priority = 1370)
	public void clickRemoveBackup2() {
		clickRemoveBackup();
	}
	
		
	
	@Test(priority = 1380)
	public void saveRemoveBackup2() {
		saveRemoveBackup();
	}
	
	
	
	@Test(priority = 1390)
	public void navigateNexusBackTwice2() {
		navigateNexusBackTwice();
	}
	

	
	@Test(priority = 1400)
	public void selectMemberPosition2_3() {
		selectMemberPosition2();
		waitMethods.waiter(waitMethods.w1k);
	}
	
	
	
	
	@Test(priority = 1410)
	public void navigateNexusBack2() {
		navigateNexusBack();
	}
	
	
	
	
	@Test(priority = 9999)
	public void closeDownNexus1() {
		closeDownNexus();
	}
	
	

	
	
	/*
	 *  Go ahead and write methods to check xactions in Main Portal
	 *  Add additional assertions
	 * 
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
