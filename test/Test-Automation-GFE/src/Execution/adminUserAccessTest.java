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


public class adminUserAccessTest extends setupFramework {

		
	@BeforeMethod
	@BeforeClass
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver();   //   Also have a valid ChromeDriver here
			//driver.manage().timeouts().wait(Framework.waitMethods.w100);
		}
	}
	

	//Cert test if this is starting page for tests
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

	
	public String sRand;
	
	public String generateRand() {
    	Random random = new Random();
    	Integer rand = random.nextInt(999999);
    	sRand = rand.toString();
    	
    	System.out.println("sRand = " + sRand);

    	return sRand;
    	
	}
	
	
	
//User Access Groups  - Academy Demo Site (Test site) | Washington DC
	
	//NEVER WORKS - Strings appear to be equal, but test fails...
	//Perhaps use .toString to ensure no non-Ascii values??
//	@Test(priority = 100)  //
//	public void verifyUserAccessPageTitle() {         
//		//waitMethods.implicitWait(waitMethods.w300);
//		String pageTitle = driver.getTitle();
//		Assert.assertEquals(pageTitle, "User Access Groups  - Academy Demo Site (Test site) | Washington DC");
//		System.out.println("Page Title - User Access Groups");
//	}


	////////  HEADER TESTS  \\\\\\\\\\\\\\\\
	
	@Test(priority = 102) //
	private void userAccessHeaderHome() {
		//waitMethods.implicitWait(waitMethods.w300);    
		//WebElement ele = driver.findElement(By.partialLinkText("Home")); //.click();   
		WebElement ele = driver.findElement(By.linkText("Home"));
	    highlightElement.highLightElement(driver, ele);
	    //ele.click();
	    ele.click();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
	    System.out.println("Clicked User Access Header Home button");
	} 


	
	
	@Test(priority = 103) // 
	private void userAccessHeaderReportBuilder() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.linkText("Report Builder")); //.click(); 
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked User Access Header ReportBuilder button");
} 

		
	
	@Test(priority = 104) //
	private void userAccessHeaderSiteLinks() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.linkText("Site Links")); //.click(); 
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
		//driver.navigate().back();    //navigate back
	    System.out.println("Clicked Admin User Access Header Site links button");
	} 


	
	@Test(priority = 105) //
	private void userAccessHeaderHomeLinks() {
		//waitMethods.implicitWait(waitMethods.w300);	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.linkText("Admin")); //.click();  
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		WebElement ele2 = driver.findElement(By.linkText("Admin Home")); //.click(); 
	    highlightElement.highLightElement(driver, ele2);
	    ele2.click();   //Should stay on this page
		//waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
	         System.out.println("Clicked Header Admin -> Admin Home");
	} 

	
//	@Test(priority = 106) //
//	private void userAccessHeaderUserAccessGroupsLink() {
//	    //WebElement ele = driver.findElement(By.linkText("User Access Groups")); //.click();
//		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div/a[1]/span[1]")); //.click();
//	    //highlightElement.highLightElement(driver, ele);
//	    //waitMethods.waiter(waitMethods.w300);
//	    ele.click();   
//	    waitMethods.waiter(waitMethods.w300);
//		driver.navigate().back();    //navigate back
//	         System.out.println("Clicked Header Admin -> User Access -> User Access Groups");
//	} 

	
		////////// Filter \\\\\\\\\\\\\\\\\
	
	
	@Test(priority = 107)
	public void filterByGroup() {   
		//waitMethods.implicitWait(waitMethods.w300);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.id("userGroupSearch"));
    	highlightElement.highLightElement(driver, ele);

    	//String name = "Baristas";
    	String name = "Max User Access Group";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
    	
    	waitMethods.waiter(waitMethods.w200);
    	System.out.println("Filtered by group");			
	}


//TODO: Add Assertion	
	
	
	@Test(priority = 108)
	public void filterByGroupClear()  {   //
		//waitMethods.implicitWait(waitMethods.w300);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.id("userGroupSearch"));
    	highlightElement.highLightElement(driver, ele);
    	driver.findElement(By.id("userGroupSearch")).clear();
    	waitMethods.waiter(waitMethods.w250);							//REMOVE **DEBUGGING**  System.out.println("Filter cleared");
    	driver.findElement(By.id("userGroupSearch")).sendKeys(Keys.ENTER);
    	System.out.println("Group Search Box Cleared");
	}


	
	@Test(priority = 109)	 
	public void filterByName1() {
		//waitMethods.implicitWait(waitMethods.w300);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.id("userGroupSearch"));
    	highlightElement.highLightElement(driver, ele);
    	
    	//String name = "vittoria";
    	String name = "tester tester";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
    	
    	driver.findElement(By.id("userGroupSearch")).clear();
    	System.out.println("Filtered by user name (1)");			
	}


//TODO: Add Assertion BEFORE clearing userGroupSearch inputbox	
	
	
	@Test(priority = 110) //
	private void selectedSysAdmin() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w200);
		WebElement ele = driver.findElement(By.id("1"));
		//WebElement ele = driver.findElement(By.id("groupTitle1"));    //userGroupSearch
        highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w200);
		//driver.navigate().back();    //navigate back
        System.out.println("Clicked Header Home button");
	} 


	
//TODO: Add Assertion
	
	

	@Test(priority = 112) //
	private void clickHistory() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		//WebElement ele = driver.findElement(By.xpath("//*[@id=\"xhr\"]/button"));
		WebElement ele = driver.findElement(By.cssSelector("#xhr > button"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w300);
        System.out.println("Clicked History button");
	} 

//TODO: Loop to show next 2-3-4 pages of history
	
	@Test(priority = 114) //////
	private void closeHistory() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[1]/button/span[1]"));   
		WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[1]/button/span[1]"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w300);
        System.out.println("Close History button");
	} 

	

	

	@Test(priority = 116) //////
	private void cancelPopUpMenu() {									//Click Cancel button
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("button_cancelchange"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[1]/button/span[1]"));
        highlightElement.highLightElement(driver, ele);  
        ele.click();	
        waitMethods.waiter(waitMethods.w250);
        System.out.println("Cancel Add Administrator Dialogue ");
	} 


	@Test(priority = 118)	 
	public void filterByName2() {
		//waitMethods.implicitWait(waitMethods.w300);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.id("userGroupSearch"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Tester Tester";
    	//String name = "Max User Access Group";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
    	
    	driver.findElement(By.id("userGroupSearch")).clear();
    	System.out.println("Filtered by user name (2)");			
	}


//TODO: Add Assertion
	
	
	
	@Test(priority = 120) ////////
	public void selectedSysAdmin2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("1"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w300);
        System.out.println("Clicked SysAdmin button");
	} 



	@Test(priority = 122)	 
	public void inputAdminCandidate() {
		//waitMethods.implicitWait(waitMethods.w300);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[1]/div[1]/input"));
    	highlightElement.highLightElement(driver, ele);
    	System.out.println("Input text to 'Add Administor input");
    	
    	String name = "Michael Gao";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
	}


	
	@Test(priority = 126) //
	private void clickSave() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("button_save"));
    	highlightElement.highLightElement(driver, ele);
    	ele.click();
		waitMethods.waiter(waitMethods.w250);
		//driver.navigate().back();    //navigate back
        System.out.println("Save (Administrator) clicked");
	} 

	@Test(priority = 128)
	private void recallSysAdminDialogue() {
		selectedSysAdmin2();		
	}
	

	
	@Test(priority = 130) //
	private void verifyAddAdministrator() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.partialLinkText("Gao, Michael"));						//("Mason, Minerva"));
		highlightElement.highLightElement(driver, ele);
		//ele.click();													//If Click enabled, it opens employee info in a new tab
		waitMethods.waiter(waitMethods.w250);
		//driver.navigate().back();    //navigate back
        System.out.println("Newly added Administrator found");
	} 


//TODO:  Add case to select employee link
//TODO:  Add assertion for the above

	
	@Test(priority = 132) //
	private void removeAddedAdministrator() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		
		
		
		//WebElement ele = driver.findElement(By.xpath("//span[contains(text(), 'Gao, Michael')]")); //Correct, now goto REMOVE
		WebElement ele = driver.findElement(By.xpath("//a[@aria-label='REMOVE Gao, Michael']"));

		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w300);
		//driver.navigate().back();    //navigate back
        System.out.println("Added Administrator Removed");
	} 

	/*
		Debug in Console of Dev Tools:   x$("//span[contains(text(), 'Gao, Michael')]")
	*/												
	
	//////////////////   Left Menu     \\\\\\\\\\\\\\\\\\	
		

	
	@Test(priority = 134) //
	private void clickLeftMenuSysAdmins() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.partialLinkText("System administrators"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Left Menu - System Admins");
	} 


	@Test(priority = 136) //
	private void clickLeftUserGroups() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("userGroupsLink"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Left Menu - User Groups");
	} 

	
	

	@Test(priority = 138) //
	private void clickLeftMenuAllGroups() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.partialLinkText("All groups"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Left Menu - All Groups");
	} 

	
	@Test(priority = 140) //
	private void clickLeftMenuCreateGroup() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("#bodyarea > div.leaf-center-content > div > aside:nth-child(3) > button.usa-button.leaf-btn-green.leaf-btn-med.leaf-side-btn"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Left Menu - + Create Group");
	} 
	

	@Test(priority = 142) //
	private void inputGroupTitle() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("groupNameInput"));
		highlightElement.highLightElement(driver, ele);
    	System.out.println("Input text to 'Create Group' input");
    	
    	String name = "AAA Automation Test " + generateRand();				
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
	} 
	

	
	
	//CANCEL BUTTON FOR + Create Group
	
	
	@Test(priority = 144) //
	private void clickSaveButton() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("button_save"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Create Group - Input Group Title");
	} 
	
	
	
	
	@Test(priority = 146) //	//GET group just created                   
	private void getNewlyCreatedUserGroup() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);
		//WebElement ele = driver.findElement(By.xpath("//[contains(text(), 'AAA Automation Test ' + sRand)]"));
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]/h2"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Selected Group - Group Title");
	} 

	
	//GO BACK AND CLICK ON GROUP CREATED ---> or is that another workflow??
	
	
	
	
	@Test(priority = 148) //
	private void findMemberInputBox() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.cssSelector("*[id^='empSel'][id$='input']"));
		highlightElement.highLightElement(driver, ele);
		System.out.println("Input User Group Member 1");
    	
    	String name = "Frank";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
	} 
	
	
	@Test(priority = 150) //						
	private void selectGroupMember() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.className("employeeSelectorName"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Create Group - Input Group Member 1");
	} 

	
	@Test(priority = 152) //		
	private void saveNameToGroup1() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("button_save"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Member 1 added to Group");
	} 

	
	
	@Test(priority = 154) //	//GET group just created
	private void getNewlyCreatedUserGroup2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]/h2"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Selected Group - Input Group Title");
	} 

		
	
	@Test(priority = 156) //
	private void findMemberInputBox2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("*[id^='empSel'][id$='input']"));
		highlightElement.highLightElement(driver, ele);
		System.out.println("Input User Group Member 2");
    	
    	String name = "Bobby";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
	} 
	
	
	@Test(priority = 158) //		
	private void selectGroupMember2() {	
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.className("employeeSelectorName"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Create Group - Input Group Member 2");
	} 

	
	@Test(priority = 160) //		
	private void saveNameToGroup2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("button_save"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Member 2 added to Group");
	} 
	
	
	
	@Test(priority = 162) //	//GET group just created to remove member
	private void getNewlyCreatedUserGroup3() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]/h2"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Selected Group - Input Group Title");
	} 
	

	
	@Test(priority = 164) //   Grab Frank
	private void getGroupMember1() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.partialLinkText("Frank"));		
		highlightElement.highLightElement(driver, ele);
		//ele.click();
		waitMethods.waiter(waitMethods.w300);
        System.out.println("Located group member 1");
	} 


	

	@Test(priority = 166) //
	private void removeGroupMember1() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		//Need to find better element descriptor. If someone is added above
		WebElement ele = driver.findElement(By.cssSelector("#removeMember_0"));
		
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w300);
		//driver.navigate().back();    //navigate back
        System.out.println("Deleted group member 1");
	} 
	
	@Test(priority = 168) //	//GET group to delete it
	private void getNewlyCreatedUserGroup4() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]/h2"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Selected Group to Delete");
	} 

	
	
	@Test(priority = 170) //	//Hit delete button
	private void deleteUserGroup() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[1]/div[2]/button"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Delete User Group ");
	} 
	
	
	
	@Test(priority = 172) //	//Confirm Delete - NO
	private void cancelDeleteUserGroup() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("confirm_button_cancelchange"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Cancel Delete User Group");
	} 


	@Test(priority = 174) //	//Hit delete button again
	private void deleteUserGroup2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[1]/div[2]/button"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Delete User Group again");
	} 

	
	
	@Test(priority = 176) //	//Confirm Delete - YES
	private void confirmDeleteUserGroup() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("confirm_button_save"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Confirm Delete User Group");
	} 

	
	@Test(priority = 177) //	
	private void selectImportGroup() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("#bodyarea > div.leaf-center-content > div > aside:nth-child(3) > button:nth-child(3)"));			//*[id^='grp'][id$='input']"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Select Import Group");
	} 
	
    
	@Test(priority = 178) //	//Cancel
	private void cancelDialogueBox() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("button_cancelchange"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Select Group based on search");
	} 
	
	
	@Test(priority = 179) //	
	private void selectImportGroup2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("#bodyarea > div.leaf-center-content > div > aside:nth-child(3) > button:nth-child(3)"));			//*[id^='grp'][id$='input']"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Select Import Group");
	} 
	
	
    
	@Test(priority = 180) //
	private void inputImportGroupTitle() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.className("groupSelectorInput"));
		highlightElement.highLightElement(driver, ele);
    	System.out.println("Input text to Import Group");
    	
    	String name = "Admin officers"; //+ generateRand();				
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
	} 
    
	
	@Test(priority = 182) //	
	private void selectGroupBasedOnSearch() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("button_save"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Select Group based on search");
	} 
	
	
	@Test(priority = 184) //	
	private void selectImportedGroupOnPage() {				
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Select Group based on search");
	} 
	
	
	@Test(priority = 186) //
	private void inputImportGroupMember1() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
		highlightElement.highLightElement(driver, ele);
    	System.out.println("Input Import Group Member 1");
    	
    	String name = "Castle"; 				
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
	} 

	
	@Test(priority = 187)
	private void saveGroup() {
		selectGroupBasedOnSearch();
	}
	
	@Test(priority = 188) //	
	private void selectImportedGroupOnPage2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Select Group based on search");
	} 
	
	
	@Test(priority = 189) //
	private void inputImportGroupMember2() {
		//waitMethods.im`plicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[2]/div[1]/input"));
		highlightElement.highLightElement(driver, ele);
    	System.out.println("Input Import Group Member 2");
    	
    	String name = "David Porter"; 				
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w20);
    	}
	} 

	
	@Test(priority = 190)
	private void saveGroup2() {
		selectGroupBasedOnSearch();
	}
	
	
	
	@Test(priority = 191) //	
	private void selectImportedGroup() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div[1]/main/div[4]/div/div/div[1]"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Located imported group on page");
	} 

	@Test(priority = 192) //	
	private void viewHistory() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("#xhr > div.leaf-float-right > div:nth-child(1) > button"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked View History");
	} 
	

	@Test(priority = 193) //	
	private void closeViewHistory() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("body > div:nth-child(6) > div.ui-dialog-titlebar.ui-corner-all.ui-widget-header.ui-helper-clearfix.ui-draggable-handle > button > span.ui-button-icon.ui-icon.ui-icon-closethick"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Close View History Dialogue Box");
	} 

	
	
	@Test(priority = 194) //	//Hit delete button
	private void deleteUserGroup3() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("button[id^=deleteGroup]"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Delete User Group again");
	} 


	@Test(priority = 195) //	//Confirm Delete - NO
	private void confirmDeleteUserGroup4() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("confirm_button_cancelchange"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Confirm Delete User Group");
	} 

	@Test(priority = 196) //	//Delete group
	private void runDeleteUserGroup() {
			deleteUserGroup3();
	}
	
	
	@Test(priority = 197) //	//Confirm Delete - YES
	private void confirmDeleteUserGroup2() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.id("confirm_button_save"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Confirm Delete User Group");
	} 


	@Test(priority = 198) //
	private void clickedLeftMenuShowHistory() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/div/aside[2]/button[3]"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Clicked Left Menu Show History");
	} 


	
	@Test(priority = 199) //
	private void closeShowHistory() {
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("body > div:nth-child(6) > div.ui-dialog-titlebar.ui-corner-all.ui-widget-header.ui-helper-clearfix.ui-draggable-handle > button"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
        System.out.println("Close Show History");
	} 


	
	
	
	


/*
 * 
 * 
 * Lower priority - delete individual members
 * 
 * 
 * */	
	


}  //class
