package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.JavascriptExecutor;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

import java.util.Random;

import Framework.TestData;
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;


public class userAccessGroupsTESTING extends setupFramework {

		
	@BeforeMethod
	@BeforeClass
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver();   //   from Framework.setupFramework
			//driver.manage().timeouts().wait(Framework.waitMethods.w100);
		}
//		if(driver8 != null) {
//			driver8 = getDriver8();
//		}
		
	}

	
	public String sRand;
	public String groupNum;
	
	public String generateRand() {
    	Random random = new Random();
    	Integer rand = random.nextInt(999999);
    	sRand = rand.toString();
    	
    	System.out.println("sRand = " + sRand);

    	return sRand;
    	
	}

	
//	private void gotoTab2() {
//		driver.findElement(By.cssSelector("body")).sendKeys(Keys.CONTROL + "2");
//	}
//
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
 
	
	

	//    https://localhost/LEAF_Request_Portal/admin/?a=mod_groups
	
//	@Test(priority = 100) //
//	private void createUserAccessGroup() {
//		waitMethods.waiter(waitMethods.w200);
//		WebElement ele = driver.findElement(By.xpath("//button[contains(text(),' Create group')]"));
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w300);
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
//    		waitMethods.waiter(waitMethods.w15);
//    	}
//    	
//    	waitMethods.waiter(waitMethods.w200);
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
//        waitMethods.waiter(waitMethods.w250);
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
//        waitMethods.waiter(waitMethods.w300);
//        System.out.println("Clicked Save");
//	} 
//
//	
//	//															ERR HERE - This fails occasionally ???
//	@Test(priority = 160) //
//	private void openAccessGroup() {
//		System.out.println("Before opening Group\ngroupNum = " + groupNum);
//		waitMethods.waiter(waitMethods.w3k);    //  "Test User Access Group " + groupNum
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
//    	waitMethods.waiter(waitMethods.w750);     			//Input Box
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
//     		waitMethods.waiter(waitMethods.w15);
//    	}
//    	
//    	waitMethods.waiter(waitMethods.w300);				//Results Grid
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
//	private void openAccessGroup2() {
//		openAccessGroup();
//	} 
//	
//	
//	
////  Input User 2 = employeeSelectorInput	Smith, Harvey Schiller
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
//     		waitMethods.waiter(waitMethods.w15);
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
//	private void openAccessGroup3() {
//		openAccessGroup();
//	} 
//
//	
//	
//	
////  Input User 3 = employeeSelectorInput	Abbott, Roman Spencer
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
//     		waitMethods.waiter(waitMethods.w15);
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
	
	
	
//	@Test(priority = 250) //
//	private void openAccessGroup4() {
//		openAccessGroup();
//	} 

	
	
	
	
	
	
	
	
	

	

	
	
	/*************  Ending Procedures  *********/
	
	// String id = driver.findElement(By.xpath("//*[contains(text(), 'Your text')]")).getAttribute("id");
	
	@Test(priority = 990) //
	private void getElementID() {							//	TODO: Change Method Name
		waitMethods.waiter(waitMethods.w3k);  
		
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));		
		String id = ele.getAttribute("id").toString();
		System.out.println("Element ID = " + id);
		highlightElement.highLightElement(driver, ele); 
	    //ele.click();
	    System.out.println("Navigate to Nexus");   //click on group H2
	    waitMethods.waiter(waitMethods.w2k);
	} 
	
	
	
//	@Test(priority = 1000) //
//	private void gotoNexus() {							//	TODO: Change Method Name
//		waitMethods.waiter(waitMethods.w300);  
//		WebElement ele = driver.findElement(By.partialLinkText("Test Access Group"));		
//		highlightElement.highLightElement(driver, ele); 
//	    ele.click();
//	    System.out.println("Navigate to Nexus");   //click on group H2
//	    waitMethods.waiter(waitMethods.w2k);
//	} 
	
	
	/* PICKUP HERE  (below method)
	 * 
	 * From:  https://stackoverflow.com/questions/12729265/switch-tabs-using-selenium-webdriver-with-java
	 * Selenium is still on the portal
	 * it needs to act on https://localhost/LEAF_Nexus/?a=view_group&groupID=227
	 * PROBLEM is that it's already on the 2nd tab - 
	 * 
	 * ********** TAKE THIS STEP FIRST *************************
	 * Maybe if I establish a new driver
	 * 
	 * psdbComponent.clickDocumentLink();  // Don't need to use psdbComponent
     * ArrayList<String> tabs = new ArrayList<String> (driver.getWindowHandles());
     * driver.switchTo().window(tabs.get(1));
     * driver.close();
     * driver.switchTo().window(tabs.get(0));
	 * 
	 * ******* THIS ************
	 * driver.findElement(By.cssSelector("body")).sendKeys(Keys.CONTROL + "1");
	 * # goes to 1st tab
	 *
	 * driver.findElement(By.cssSelector("body")).sendKeys(Keys.CONTROL + "4");
	 * # goes to 4th tab if its exists or goes to last tab.
	 * 
	 *    
	 * 
	 */
	
	
//	@Test(priority = 1005) //
//	private void editGroupName() {
//		waitMethods.waiter(waitMethods.w1k);
//		String strUrl = driver.getCurrentUrl();
//		System.out.println("URL: " + strUrl);
//		gotoTab2();
//		strUrl = driver.getCurrentUrl();
//		System.out.println("URL: " + strUrl);
//
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[1]/button[1]"));
//		//WebElement ele = driver.findElement(By.xpath("//button[contains(text(), ' Edit Group Name')]"));
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w300);
//	    System.out.println("Clicked on Edit Group Name");
//	} 
//	
//	
//	//  Change Group Name		inputtitle
//	@Test(priority = 1010)
//	public void inputNewGroupTitle() {   
//    	waitMethods.waiter(waitMethods.w500);     			//Input Box
//    	WebElement ele = driver.findElement(By.id("inputtitle"));
//    	highlightElement.highLightElement(driver, ele);
//    	
//    	String name = "Completed Access Group Test " + groupNum;
//    	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//     		waitMethods.waiter(waitMethods.w15);
//    	}
//    	
// 	    System.out.println("Changed Access Group Title");  // Changes sort order so that it will not be
// 	    												   // the first group in the upper left
//	}
//	
//	
//	@Test(priority = 1020) 
//	private void saveChangeTitle() {									//Click Save button
//		saveUserGroup();
//	} 
	
	
	
/* Remove users
 * removeMember_0   - After saving, users will be sorted by last name and renamed 0, 1, 2 etc
 * addNexusMember_0  - Same as above
 * 
 * 
 * By.partialLink		.Test User Access Group   (Don't forget leading dot (.))
 * By.partialLink		User last name
 * 	
 * 
 * NEXUS
 * Save					button_save
 * Cancel				button_cancelchange
 * X in upper right		/html/body/div[5]/div[1]/button/span[1]
 * Alt Name				abrinputtitle
 * 
 * Add Employee			button_addEmployeePosition
 * Edit Group Name		
 */
	
	
	
	
	


//	@Test(priority = 300) //
//	private void removeGroupMember1() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w300);
//		//Need to find better element descriptor. If someone is added above
//		WebElement ele = driver.findElement(By.cssSelector("#removeMember_0"));
//		
//		highlightElement.highLightElement(driver, ele);
//		ele.click();
//		waitMethods.waiter(waitMethods.w300);
//		//driver.navigate().back();    //navigate back
//        System.out.println("Deleted group member 1");
//	} 
//	
//	
//	
//	@Test(priority = 325) //	//Confirm Delete - NO
//	private void cancelDeleteUserGroup() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("confirm_button_cancelchange"));
//		highlightElement.highLightElement(driver, ele);
//        ele.click();
//        System.out.println("Cancel Delete User Group");
//	} 
//
//	
//	
//	@Test(priority = 400) 
//	public void selectedSysAdmin2() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("1"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//		waitMethods.waiter(waitMethods.w300);
//        System.out.println("Clicked SysAdmin button");
//	} 
//
//

	


/*
 * IDs
 * userGroupSearch
 * 
 * 		//String s = ".Test User Access Group ";
		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), '.Test User Access Group')]"));
		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), '" + s + "')]"));
 * 
 * WebElement ele = driver.findElement(By.partialLinkText("Home")); //.click(); 
 * WebElement ele = driver.findElement(By.cssSelector("*[id^='empSel'][id$='input']"));
 * WebElement ele = driver.findElement(By.xpath("//a[@aria-label='REMOVE Gao, Michael']"));
 * 
 * */	
	


}  //class userAccessGroups
