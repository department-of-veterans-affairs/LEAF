//package test.java.userAccessGroup;
//
//import org.testng.annotations.Test;
//import org.testng.annotations.BeforeMethod;
//import org.openqa.selenium.By;
//import org.openqa.selenium.WebDriver;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.chrome.ChromeDriver;
//import org.openqa.selenium.chrome.ChromeOptions;
//import org.openqa.selenium.NoSuchElementException;
//import org.testng.annotations.BeforeClass;
//
//import java.util.Random;
//
//import test.java.Framework.AppVariables;
//import test.java.Framework.setupFramework;
//import test.java.Framework.highlightElement;
//
//
//public class z_userAccessGroupsOLD_BACKUP extends setupFramework {
//
//
//	public String sRand;
//	public String groupNum;
//	public String nexusURL = "https://localhost/LEAF_Nexus/?a=view_group&groupID=";
//	public String id;
//	public WebDriver driverNexus;
//
//
//
//
//
//	private static WebDriver chromeLoginNexus(String env) {
//		System.out.println("Launching Chrome");  //Step Over until - return driver;
//		//System.setProperty("webdriver.chrome.driver", test.java.Framework.AppVariables.CHROMEDRIVER);
//
//
//			if (AppVariables.headless) {
//				ChromeOptions options = new ChromeOptions();
//				options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
//						"--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
//						"--disable-dev-shm-usage");
//				WebDriver driverNexus = new ChromeDriver(options);
//				driverNexus.navigate().to(env);
//				System.out.println("Driver established for: " + driverNexus.getClass());
//				return driverNexus;  //HEADLESS driver
//
//			} else {
//				WebDriver driverNexus = new ChromeDriver();
//				driverNexus.manage().window().maximize();
//				driverNexus.navigate().to(env);
//				System.out.println("Driver established using: " + driverNexus.getClass());
//
//				return driverNexus;
//
//			}
//	}
//
//
//	private void testForNexusCertPage() /*throws InterruptedException */ {
//	    try {
//	    	waitMethods.waiter(waitMethods.w300);
//	    	WebElement ele = driverNexus.findElement(By.id("details-button"));  //.click();
//	    	highlightElement.highLightElement(driverNexus, ele);
//	    	ele.click();
//
//	    	waitMethods.waiter(waitMethods.w300);
//
//	        WebElement ele2 = driverNexus.findElement(By.partialLinkText("Proceed to localhost"));
//	        highlightElement.highLightElement(driverNexus, ele2);
//	    	ele2.click();
//	        System.out.println("Nexus Certificate not found, proceeding to unsecure site");
//	    } catch (NoSuchElementException e) {
//	        System.out.println("Nexus Certificate present, proceeding ");
//	    }
//	}
//
//
//	public WebDriver getDriverNexus() {
//        return driverNexus;					//Establish ChromeDriver for Nexus
//	}
//
//
//
//
//	public void createNexusDriver() {
//		String NexusURL = nexusURL + id;
//		System.out.println("NexusURL: " + NexusURL);
//		//closeDownMainPortal();
//
//		driverNexus = chromeLoginNexus(NexusURL);
//		//driverNexus = chromeLoginNexus("https://localhost/LEAF_Nexus/?a=view_group&groupID=" + id);
//		waitMethods.waiter(waitMethods.w2k);
//		testForNexusCertPage();
//		System.out.println("Chromedriver for Nexus created");
//	}
//
//
//	public void closeDownMainPortal() {
//
//		driver.quit();
//		System.out.println("setupFramework reached @AfterClass, driver.quit()");
//		//System.out.println("Method closeDownMainPortal() Disabled - browser remains open");
//	}
//
//
////	public void closeDownNexus() {
////
////		driverNexus.quit();
////		System.out.println("setupFramework reached @AfterClass, driverNexus.quit()");
////		//System.out.println("Method closeDownNexus() Disabled - browser remains open");
////	}
//
//
//	public String generateRand() {
//    	Random random = new Random();
//    	Integer rand = random.nextInt(999999);
//    	sRand = rand.toString();
//
//    	System.out.println("sRand = " + sRand);
//
//    	return sRand;
//
//	}
//
//
//	@BeforeMethod
//	@BeforeClass
//	public void setUp()  {
//		if(driver!= null) {
//			driver=getDriver();   //   from test.java.Framework.setupFramework
//		}
//		if(driverNexus!= null) {
//			driverNexus=getDriverNexus();   //   from test.java.Framework.setupFramework
//		}
//	}
//
//
////	private void gotoTab2() {
////		driver.findElement(By.cssSelector("body")).sendKeys(Keys.CONTROL + "2");
////	}
////
////	private void gotoTab1() {
////		driver.findElement(By.cssSelector("body")).sendKeys(Keys.CONTROL + "2");
////	}
//
//
//
//
//	@Test(priority = 1) //MUST REMAIN #1 ( or zero) -test for certificate - if no, click Advanced -> Proceed
//	private void testForCertPage() /*throws InterruptedException */ {
//	    try {
//	    	//waitMethods.implicitWait(waitMethods.w300);
//	    	waitMethods.waiter(waitMethods.w300);
//	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
//	    	highlightElement.highLightElement(driver, ele);
//	    	ele.click();
//
//	    	waitMethods.waiter(waitMethods.w300);
//
//	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost"));
//	        highlightElement.highLightElement(driver, ele2);
//	    	ele2.click();
//	        System.out.println("Certificate not found, proceeding to unsecure site");
//	    } catch (NoSuchElementException e) {
//	        System.out.println("Certificate present, proceeding ");
//	    }
//	}
//
//
//
//
//	//    https://localhost/LEAF_Request_Portal/admin/?a=mod_groups
//
//	@Test(priority = 100) //
//	private void createUserAccessGroup() {
//		waitMethods.waiter(waitMethods.w200);
//		WebElement ele = driver.findElement(By.xpath("//button[contains(text(),' Create group')]"));
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w100);
//	    System.out.println("Clicked on + New Group");
//	}
//
//
////  groupNameInput
//	@Test(priority = 110)
//	public void inputGroupName() {
//    	waitMethods.waiter(waitMethods.w200);
//    	WebElement ele = driver.findElement(By.id("groupNameInput"));
//    	highlightElement.highLightElement(driver, ele);
//
//    	groupNum = generateRand().toString();
//    	String name = ".Test Access Group " + groupNum;
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w10);
//    	}
//
//    	waitMethods.waiter(waitMethods.w100);
//    	System.out.println("Input Group Name");
//	}
//
//
//
//	@Test(priority = 120)
//	private void cancelCreateUserGroup() {									//Click Cancel button
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.id("button_cancelchange"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Cancel Add User Group");
//	}
//
//
//	@Test(priority = 130) //
//	private void createUserAccessGroup2() {
//		createUserAccessGroup();
//	}
//
//
//	@Test(priority = 140) //
//	private void inputGroupName2() {
//		inputGroupName();
//	}
//
//
//	@Test(priority = 150)
//	private void saveUserGroup() {									//Click Save button
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.id("button_save"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Clicked Save");
//	}
//
//
//	//															ERR HERE - This fails occasionally ???
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
////  Input User = employeeSelectorInput		Considine, Warren Bayer
//	@Test(priority = 170)
//	public void inputEmployee() {
//    	waitMethods.waiter(waitMethods.w600);     			//Input Box
//    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
//    	//WebElement ele = driver.findElement(By.className("employeeSelectorInput"));
//    	//highlightElement.highLightElement(driver, ele);
//    	highlightElement.highLightElement(driver, ele);
//
//    	String name = "Considine, Warren Bayer";
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//     		waitMethods.waiter(waitMethods.w10);
//    	}
//
//    	waitMethods.waiter(waitMethods.w100);				//Results Grid
//    	//WebElement ele2 = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[2]/table/tbody/tr/td[1]"));
//    	//highlightElement.highLightElement(driver, ele2);
//    	//ele2.click();
// 	    System.out.println("Input User and Select");
//	}
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
//
//	@Test(priority = 190) //
//	private void openAccessGroup1() {
//		openAccessGroup();
//	}
//
//
//
//	//Input User 2 = employeeSelectorInput	Smith, Harvey Schiller
//	@Test(priority = 200)
//	public void inputEmployee2() {
//    	waitMethods.waiter(waitMethods.w750);     			//Input Box
//    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
//    	highlightElement.highLightElement(driver, ele);
//
//    	String name = "Smith, Harvey Schiller";
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//     		waitMethods.waiter(waitMethods.w10);
//    	}
//
// 	    System.out.println("Input User 2 and Select");
//	}
//
//
//
//	//Click Save button
//	@Test(priority = 210)
//	private void saveEmployee2() {
//		saveUserGroup();
//        System.out.println("Saved User Group");
//	}
//
//
//
//	@Test(priority = 220) //
//	private void openAccessGroup2() {
//		openAccessGroup();
//	}
//
//
//
//
//	//  Input User 3 = employeeSelectorInput	Abbott, Roman Spencer
//	@Test(priority = 230)
//	public void inputEmployee3() {
//    	waitMethods.waiter(waitMethods.w750);     			//Input Box
//    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
//    	highlightElement.highLightElement(driver, ele);
//
//    	String name = "Abbott, Roman Spencer";
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//     		waitMethods.waiter(waitMethods.w10);
//    	}
//
// 	    System.out.println("Input User 3 and Select");
//	}
//
//
//
//	//Click Save button
//	@Test(priority = 240)
//	private void saveEmployee3() {
//		saveUserGroup();
//        System.out.println("Saved User Group");
//	}
//
//
//
//	@Test(priority = 250) //
//	private void openAccessGroup3() {
//		openAccessGroup();
//	}
//
//
//
//
//
//	/******* ADD to NEXUS ****************************************************/
//
//	@Test(priority = 260)
//	private void addNexusUser_0() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("addNexusMember_0"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("User 0 Added to Nexus");
//	}
//
//
//	@Test(priority = 280)
//	private void confirmNo() {
//		waitMethods.waiter(waitMethods.w200);
//		WebElement ele = driver.findElement(By.id("confirm_button_cancelchange"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Canceled action");
//	}
//
//
//
//	@Test(priority = 300)
//	private void addNexusUser_0_2() {
//		addNexusUser_0();
//	}
//
//
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
//
//
//	@Test(priority = 307) //
//	private void openAccessGroup4() {
//		openAccessGroup();
//	}
//
//
//
//	@Test(priority = 310)
//	private void addNexusUser_1() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("addNexusMember_1"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("User 1 Added to Nexus");
//	}
//
//
//
//
//	@Test(priority = 320)
//	private void confirmYes2() {
//		confirmYes();
//	}
//
//
//
//	@Test(priority = 325) //
//	private void openAccessGroup5() {
//		openAccessGroup();
//	}
//
//
//
//
//	@Test(priority = 330)
//	private void addNexusUser_2() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("addNexusMember_2"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("User 2 Added to Nexus");
//	}
//
//
//
//	@Test(priority = 340)
//	private void confirmYes3() {
//		waitMethods.waiter(waitMethods.w200);
//		WebElement ele = driver.findElement(By.id("confirm_button_save"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w200);
//        System.out.println("Confirmed action");
//	}
//
//
//
//	@Test(priority = 345) //
//	private void openAccessGroup6() {
//		openAccessGroup();
//	}
//
//
//
//	/***********    Deleting Users from Leaf Portal   ***************/
//
//	@Test(priority = 350)
//	private void deleteUser_0() {		// Should be Abbott, Roman
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("removeMember_0"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Removed User 0");
//	}
//
//
//
//
//	@Test(priority = 360)
//	private void confirmNo2() {
//		confirmNo();
//	}
//
//
//
//	@Test(priority = 370) // Should be Abbott, Roman
//	private void deleteUser_0_1() {
//		deleteUser_0();
//	}
//
//
//
//	@Test(priority = 380)
//	private void confirmYes4() {
//		confirmYes();
//	}
//
//
//	@Test(priority = 390) //
//	private void openAccessGroup7() {
//		openAccessGroup();
//	}
//
//
//
//
//	@Test(priority = 450)
//	private void deleteUser_1() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("removeMember_1"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Removed User 1");
//	}
//
//
//
//
//	@Test(priority = 460)
//	private void confirmYes5() {
//		confirmYes();
//	}
//
//
//
//	@Test(priority = 470) //
//	private void openAccessGroup8() {
//		openAccessGroup();
//	}
//
//
//
//
//
//	@Test(priority = 480)
//	private void ShowHideInactive() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("showInactive"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Show/Hide Inactive Users");
//	}
//
//
//
//	@Test(priority = 490)
//	private void reactivateMember_0() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("reActivateMember_0"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Reactivate Member 0");
//	}
//
//
//
//	@Test(priority = 500)
//	private void confirmReactivateMember_0() {
//		confirmYes();
//        System.out.println("Confirm Reactivate Member 0");
//	}
//
//
//
//	@Test(priority = 510) //
//	private void openAccessGroup9() {
//		openAccessGroup();
//	}
//
//
//	@Test(priority = 520)
//	private void ShowHideInactive2() {
//		ShowHideInactive();
//	}
//
//
//	@Test(priority = 530)
//	private void reactivateMember_1() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("reActivateMember_1"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Reactivate Member 1");
//	}
//
//
//	@Test(priority = 540)
//	private void confirmReactivate() {
//		confirmYes();
//        System.out.println("Confirm Reactivate Member 1");
//	}
//
//
//	@Test(priority = 550) //
//	private void openAccessGroup10() {
//		openAccessGroup();
//	}
//
//
//
//	/*
//	 * PICKUP HERE:
//	 * Add Assertions
//	 *
//	 *
//	 * Show Inactive Users							showInactive
//	 * Assert that Abbott, Roman is displayed
//	 * Reactive										reActivateMember_0   // like users 0, 1, 2
//	 * Hide Inactive						same	showInactive
//	 *
//	 * Prune										pruneMember_0		// like users, pruneMember_0, 1, 2
//	 *
//	 */
//
//
//
//
//
//	/*************  Ending Procedures  *********/
//
//
////	@Test(priority = 990) //
////	private void getElementID() {
////		waitMethods.waiter(waitMethods.w1500);
////		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));
////		highlightElement.highLightElement(driver, ele);
////		id = ele.getAttribute("id").toString();
////		System.out.println("Element ID = " + id);
////	    //ele.click();
////	    System.out.println("Got User Access Group ID");
////	    waitMethods.waiter(waitMethods.w500);
////	}
////
////
////	@Test(priority = 995)
////	public void createNexusDriver1() {
////		createNexusDriver();
////	}
////
////
////
////
////	@Test(priority = 1005) //
////	private void editGroupName() {
////		waitMethods.waiter(waitMethods.w1k);
////
////		//WebElement ele = driverNexus.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[1]/button[1]"));
////		WebElement ele = driverNexus.findElement(By.xpath("//button[contains(text(), ' Edit Group Name')]"));
////	    highlightElement.highLightElement(driverNexus, ele);
////	    ele.click();
////		waitMethods.waiter(waitMethods.w300);
////	    System.out.println("Clicked on Edit Group Name");
////	}
////
////
////
////	//  Change Group Name		inputtitle
////	@Test(priority = 1010)
////	public void inputNewGroupTitle() {
////    	waitMethods.waiter(waitMethods.w500);     			//Input Box
////    	WebElement ele = driverNexus.findElement(By.id("inputtitle"));
////    	//highlightElement.highLightElement(driverNexus, ele);
////    	ele.clear();
////    	String name = "Completed Access Group Test " + groupNum;
////
////    	for(int i = 0; i < name.length(); i++) {
////    		char c = name.charAt(i);
////    		String s = new StringBuilder().append(c).toString();
////    		//ele.sendKeys(Keys.chord(name));
////    		ele.sendKeys(s);
////     		waitMethods.waiter(waitMethods.w10);
////    	}
////
//// 	    System.out.println("Changed Access Group Title");  // Changes sort order so that it will not be
//// 	    												   // the first group in the upper left
////	}
////
////
////
////	@Test(priority = 1020)
////	private void saveUserGroupNexus() {									//Click Save button
////		waitMethods.waiter(waitMethods.w500);
////		WebElement ele = driverNexus.findElement(By.id("button_save"));
////        //highlightElement.highLightElement(driverNexus, ele);
////        ele.click();
////        waitMethods.waiter(waitMethods.w300);
////        System.out.println("Clicked Save");
////	}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
///*
// * NEXUS
// * Save					button_save
// * Cancel				button_cancelchange
// * X in upper right		/html/body/div[5]/div[1]/button/span[1]
// * Alt Name				abrinputtitle
// *
// * Add Employee			button_addEmployeePosition
// * Edit Group Name
//
//
//
// * IDs
// * userGroupSearch
// *
// * 		//String s = ".Test User Access Group ";
//		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), '" + s + "')]"));
// *
// * */
//
//
//
//}  //class userAccessGroups
