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
import org.openqa.selenium.interactions.Actions;
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


public class serviceChiefs extends setupFramework {

	
	public String sRand;
	public String groupNum;
	public String nexusURL = "https://localhost/LEAF_Request_Portal/admin/";
	public String id ="";		
	public WebDriver driverNexus;

	
	
	/* Navigation
	 * 	https://localhost/LEAF_Request_Portal/  (Portal Home)
	 * 		Select Portal 'Links' Nexus -> https://localhost/LEAF_Nexus/ 	
	 * 			Select OC Admin Panel -> https://localhost/LEAF_Nexus/admin/
	 * 				*** Select Groups -> https://localhost/LEAF_Nexus/?a=browse_group
	 * 					Select 'Create New Group' ->  Modal   (contains = ' Create New Group'
	 * 
	 * 	
	 * 
	 * 	//  https://localhost/LEAF_Request_Portal/admin/
	 *	//  contains 'Sync Services'
	 * 
	 */
	
	
	
	
	
	
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
 
	
	
	/*
	 * 
	 * Until I refactor, this class has REVERSED drivers.
	 * 
	 * driverNexus = main portal
	 * driver = Nexus portal
	 */
	
	
	
	
	//===============  Begin Tests  =========================================
	
	@Test(priority = 100) //
	private void clickSetupWizard() {
		waitMethods.waiter(waitMethods.w2k);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/a[3]/span"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w100);
	    System.out.println("Clicked on Setup Wizard");
	} 


	
	
	@Test(priority = 110) //  menu_leadership
	private void clickExecLeadershipTeam() {
		waitMethods.waiter(waitMethods.w2k);
		WebElement ele = driver.findElement(By.id("menu_leadership"));
		//WebElement ele = driver.findElement(By.xpath("//button[contains(text(),' Setup Wizard')]"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w100);
	    System.out.println("Clicked on Executive Leadership Team");
	} 
	
	
	
	@Test(priority = 120) //
	private void clickCreateELT() {
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Create')]"));
		///html/body/div[2]/div/div/div[2]/div[1]/div
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w100);
	    System.out.println("Clicked on Create ELT");
	} 
	
	
	
	@Test(priority = 130) //  serviceName
		public void enterNameOfService() {   
	  	waitMethods.waiter(waitMethods.w2k);     			//Input Box
	  	WebElement ele = driver.findElement(By.id("serviceName"));
	  	highlightElement.highLightElement(driver, ele);
	  	
	  	String name = ".Automated Test Services";
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();
	  		//ele.sendKeys(Keys.chord(name));
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);				
		    System.out.println("Input Service Name");		
	}
	
	
	
	
	@Test(priority = 140) //  positionTitle
	public void enterPositionTitle() {   
	  	waitMethods.waiter(waitMethods.w1k);     			//Input Box
	  	WebElement ele = driver.findElement(By.id("positionTitle"));
	  	highlightElement.highLightElement(driver, ele);
	  	
	  	String name = "Burger King";    //  generateRand().toString();
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();  
	  		//ele.sendKeys(Keys.chord(name));
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);				
		    System.out.println("Input Position Title");		
	}
	
	
	
	
	@Test(priority = 150) //
	public void inputEmployeeName() {   
	  	waitMethods.waiter(waitMethods.w1k);     			//Input Box
	  	WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/div[3]/table/tbody/tr[3]/td[2]/div/div[1]/input"));
	  	highlightElement.highLightElement(driver, ele);
	  	
	  	String name = "Abbott, Roman Spencer";    //  generateRand().toString();
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();  
	  		//ele.sendKeys(Keys.chord(name));
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w100);				
		    System.out.println("Input Employee Name");		
	}
	



	@Test(priority = 160) 
	private void saveSCGroup() {									//Click Save button
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("button_save"));
        //highlightElement.highLightElement(driver, ele);  
        ele.click();	
        System.out.println("Clicked Save");
	} 
	
	
	
//	@Test(priority = 170) 
//	public void closeDownMainPortal1() {
//		closeDownMainPortal();
//	}

	
	
	
	
	@Test(priority = 200) 
	public void createNexusDriver1() {
		createNexusDriver();   // Actual Main Portal Driver
	}
	
	
	

	@Test(priority = 210)
	private void scrollDownNexus() {
		waitMethods.waiter(waitMethods.w2k);
		JavascriptExecutor js = (JavascriptExecutor) driverNexus;
		js.executeScript("window.scrollBy(0,300)", "");
		System.out.println("Scroll Down");
		
	}
	
	

	
	@Test(priority = 220) //
	private void syncServices() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("//span[contains(text(),'Sync Services')]"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/a[16]/span[1]"));
	    highlightElement.highLightElement(driverNexus, ele);
	    ele.click();
	    System.out.println("Clicked SYNC SERVICES");
	} 
	
	
	
	
	@Test(priority = 230)
	public void navigateNexusBack() {
		driverNexus.navigate().back();
	}
	
	
	
	@Test(priority = 240)
	private void scrollUpNexus() {
		waitMethods.waiter(waitMethods.w500);
		Actions a = new Actions(driverNexus);
		a.sendKeys(Keys.PAGE_UP).build().perform();
		waitMethods.waiter(waitMethods.w1k);
		System.out.println("Scroll UP");
		
		//waitMethods.waiter(waitMethods.w1k);
		//JavascriptExecutor js = (JavascriptExecutor) driverNexus;
		//js.executeScript("window.scrollBy(0,-300)", "");
		//System.out.println("Scroll UP");
	}
	
	
	
	@Test(priority = 250) //
	private void clickServiceChiefs() {
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[1]/div/div/a[3]"));
		///html/body/div[2]/div/div/div[2]/div[1]/div
	    highlightElement.highLightElement(driverNexus, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w100);
	    System.out.println("Clicked on Service Chiefs");
	} 
	

	//************** Add Employees ******************************************************
	
	@Test(priority = 260) //  
	private void openSCGroup() {
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driverNexus.findElement(By.xpath("//*[contains(text(),'.Automated Test Services')]"));
	    highlightElement.highLightElement(driverNexus, ele);
	    ele.click();
	    System.out.println("Opened Service Chiefs Test Group");
	} 
	
	

	
	//Input User = employeeSelectorInput		Considine, Warren Bayer		
	@Test(priority = 270)
	public void inputEmployee() {   
  	waitMethods.waiter(waitMethods.w1k);     			//Input Box
  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
  	highlightElement.highLightElement(driverNexus, ele);
  	
  	String name = "Considine, Warren Bayer";
  	   
  	for(int i = 0; i < name.length(); i++) {
  		char c = name.charAt(i);
  		String s = new StringBuilder().append(c).toString();
  		//ele.sendKeys(Keys.chord(name));
  		ele.sendKeys(s);
   		waitMethods.waiter(waitMethods.w10);
  	}
  	
  		waitMethods.waiter(waitMethods.w500);				//Results Grid
	    System.out.println("Input User Considine, Warren Bayer and Select");		
	}
	
	
	
	@Test(priority = 280) 
	private void saveSCGroupNexus() {									//Click Save button
		waitMethods.waiter(waitMethods.w400);
		WebElement ele = driverNexus.findElement(By.id("button_save"));
        //highlightElement.highLightElement(driverNexus, ele);  
        ele.click();	
        System.out.println("Clicked Save");
	} 
	
	
	@Test(priority = 290) //  
	private void openSCGroup1() {
		openSCGroup();
	} 
	
	
	
	
	//Input User = employeeSelectorInput		Sauer, Valentin Will		
		@Test(priority = 300)
		public void inputEmployee_2() {   
	  	waitMethods.waiter(waitMethods.w1k);     			//Input Box
	  	WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
	  	highlightElement.highLightElement(driverNexus, ele);
	  	
	  	String name = "Sauer, Valentin Will";
	  	   
	  	for(int i = 0; i < name.length(); i++) {
	  		char c = name.charAt(i);
	  		String s = new StringBuilder().append(c).toString();
	  		//ele.sendKeys(Keys.chord(name));
	  		ele.sendKeys(s);
	   		waitMethods.waiter(waitMethods.w10);
	  	}
	  	
	  		waitMethods.waiter(waitMethods.w500);				//Results Grid
		    System.out.println("Input User Sauer, Valentin Will and Select");		
		}
		
		
		
		@Test(priority = 310) 
		private void saveSCGroupNexus2() {									//Click Save button
			saveSCGroupNexus();	
		} 
		
		
		@Test(priority = 320) //  
		private void openSCGroup2() {
			openSCGroup();
		} 
	
		
		
	
		//************** REMOVE Employees ******************************************************	
		
		
		// Member 0
		@Test(priority = 350) 
		private void deleteUser_0() {		//  Should be Abbott, Roman Spencer
			waitMethods.waiter(waitMethods.w500);
			WebElement ele = driverNexus.findElement(By.id("removeMember_0"));
	        highlightElement.highLightElement(driverNexus, ele);  
	        ele.click();	
	        waitMethods.waiter(waitMethods.w500);
	        System.out.println("Removed User 0 - Abbott, Roman Spencer");
		} 
		
		
		
		@Test(priority = 360) 
		private void confirmYesNexus() {			
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driverNexus.findElement(By.id("confirm_button_save"));
	        highlightElement.highLightElement(driverNexus, ele);  
	        ele.click();	
	        waitMethods.waiter(waitMethods.w100);
	        System.out.println("Confirmed action");
		} 
		
		
	
		@Test(priority = 370) //  
		private void openSCGroup3() {
			openSCGroup();
		} 
		
		
		
		// Member 1			Sauer, Valentin Will
		@Test(priority = 380) 
		private void deleteUser_1() {		// 
			waitMethods.waiter(waitMethods.w500);
			WebElement ele = driverNexus.findElement(By.id("removeMember_1"));
	        highlightElement.highLightElement(driverNexus, ele);  
	        ele.click();	
	        waitMethods.waiter(waitMethods.w500);
	        System.out.println("Removed User 1 - Sauer, Valentin Will");
		} 
		
		
		
		@Test(priority = 390) 
		private void confirmYesNexus2() {			
			confirmYesNexus();
		} 
		
		
	
		@Test(priority = 400) //  
		private void openSCGroup4() {
			openSCGroup();
		} 
		
		
		
		//******************** Prune Members 0 and 1 ****************************
		
		@Test(priority = 420) 
		private void ShowHideInactive() {	
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driverNexus.findElement(By.id("showInactive"));
	        highlightElement.highLightElement(driverNexus, ele);  
	        ele.click();	
	        waitMethods.waiter(waitMethods.w300);
	        System.out.println("Show/Hide Inactive Users");
		} 

		
		// Prune Member 0			Should be:  Sauer, Valentin Will			
		@Test(priority = 430)   
		private void pruneMember_0() {	
			waitMethods.waiter(waitMethods.w500);
			WebElement ele = driverNexus.findElement(By.id("pruneMember_0"));
	        highlightElement.highLightElement(driverNexus, ele);  
	        ele.click();	
	        waitMethods.waiter(waitMethods.w500);
	        System.out.println("Prune Member 0 - Sauer, Valentin Will");
		} 
		
		
		
		@Test(priority = 440) 
		private void confirmYesNexus3() {			
			confirmYesNexus();
		} 
		
		
	
		@Test(priority = 450) //  
		private void openSCGroup5() {
			openSCGroup();
		} 

		
		
		@Test(priority = 470) 
		private void ShowHideInactive2() {	
			ShowHideInactive();
		} 

		
		// Prune Member 0 again: Abbott Unlike User Access Groups, 
		//Once member_0 is deleted, the next item becomes member_0 
		@Test(priority = 480)   
		private void pruneMember_0_1() {	
			waitMethods.waiter(waitMethods.w500);
			WebElement ele = driverNexus.findElement(By.id("pruneMember_0"));
	        highlightElement.highLightElement(driverNexus, ele);  
	        ele.click();	
	        waitMethods.waiter(waitMethods.w500);
	        System.out.println("Prune Member 0 - Abbot, Valentin Will");
		} 
		
		
		
		@Test(priority = 490) 
		private void confirmYesNexus4() {			
			confirmYesNexus();
		} 
		
		
	
		@Test(priority = 500) //  
		private void openSCGroup6() {
			openSCGroup();
			waitMethods.waiter(waitMethods.w500);
		} 

		
		
		@Test(priority = 510) 
		private void saveSCGroupNexus3() {									//Click Save button
			saveSCGroupNexus();
		} 
		
		
		
		
//		@Test(priority = 520)   
//		private void importFromNexus() {	
//			waitMethods.waiter(waitMethods.w500);
//			WebElement ele = driverNexus.findElement(By.id("btn_uploadFile"));
//	        highlightElement.highLightElement(driverNexus, ele);  
//	        ele.click();	
//	        System.out.println("Clicked 'Import From Nexus'");
//	        waitMethods.waiter(waitMethods.w300);
//		} 
//	
//		
//		
//		@Test(priority = 530)   
//		private void closeImportFromNexus() {	
//			waitMethods.waiter(waitMethods.w1k);
//			WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[4]/div[1]/button/span[1]"));
//	        highlightElement.highLightElement(driverNexus, ele);  
//	        ele.click();	
//	        System.out.println("Dismissed confirmation 'Import From Nexus'");
//	        waitMethods.waiter(waitMethods.w300);
//		} 
//		
//		
//		//CLOSE DOWN NEXUS
//		@Test(priority = 999) 
//		private void closeDownNexus2() {
//			closeDownNexus();
//		}
		
		
		
	/*
	 *  Import from Nexus    id = btn_uploadFile
	 *  
	 *  Close dialog		xpath = /html/body/div[4]/div[1]/button/span[1]
	 *  
	 *  
	 *  Show Inactive		id = showInactive
	 *  
	 *  Prune				id = pruneMember_x  where x = 0, 1, 2 et.
	 */
	
	



}  //class userAccessGroups
