package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;

import static org.testng.Assert.assertTrue;

import java.util.Date;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;
import Framework.dateAndTimeMethods;
import Framework.vbsExecutor;
import Framework.stringUtilities;


public class newRequestWorkflow extends setupFramework {

	//private static final DateFormat Calendar = null;

	Date date = new Date();
	stringUtilities strUtil = new stringUtilities();
	String requestNum = new String();
	
	
	@BeforeMethod
	@BeforeClass
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver();   //   Also have a valid ChromeDriver here
			//System.out.println("Driver established for: " + driver.getClass());
			//driver.manage().timeouts().wait(Framework.waitMethods.w100);
		}
	}
	

	//Cert test in the event this is starting page for tests
	@Test(priority = 1) //MUST REMAIN #1 ( or zero)
	private void testForCertPage() /*throws InterruptedException */ {
	    try {
	    	//waitMethods.implicitWait(waitMethods.w250);
	    	waitMethods.waiter(waitMethods.w250);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w250);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); 
	        highlightElement.highLightElement(driver, ele2);
	    	ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 
 
//create New Request Workflow   (**First run is cancelled)
	
	@Test(priority = 202) //
	public void selectNewRequest() {         //
		//waitMethods.implicitWait(waitMethods.w250);
		//waitMethods.waiter(waitMethods.w1k);	
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[1]/span")); 
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("New Request Button clicked");
	}


	
	@Test(priority = 204) 					//select drop down
	private void selectService() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.cssSelector("#service_chosen > a > span"));
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w200);
	    System.out.println("Clicked Service Drop down menu");
	} 


	
	
	@Test(priority = 206) // 
	private void selectServiceAcuteCare() {			//Acute Care
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.cssSelector("#service-chosen-search-result-1")); //.click(); 
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w250);
        System.out.println("Selected Service 'Acute Care'");
	} 

	//#priority_chosen > a > span	
	
	@Test(priority = 208) 						//select drop down
	private void selectRequestPriority() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.cssSelector("#priority_chosen > a > span")); 
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
		//driver.navigate().back();    //navigate back
	    System.out.println("Checked priority values in DDL");
	} 


	@Test(priority = 210) 					//select Normal Priority
	private void selectRequestNormalPriority() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.cssSelector("#priority_chosen > a > span")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
		//driver.navigate().back();    //navigate back
	    System.out.println("Select Request Normal Priority");
	} 

	
	
    
	@Test(priority = 212) //
	private void inputRequestTitle() {
		//waitMethods.implicitWait(waitMethods.w250);	
			
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.name("title")); //.click();  
	    highlightElement.highLightElement(driver, ele);

    	String name = "Test Automation " + dateAndTimeMethods.getDate().toString();
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
	   
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Input Request Title: 'Test Automation + current date & time");
	} 

	

	@Test(priority = 214) //
	private void selectMRTestChkBox() {					  
		WebElement ele = driver.findElement (By.xpath ("//*[contains(text(),'MR - Test')]"));
	    highlightElement.highLightElement(driver, ele);
	    waitMethods.waiter(waitMethods.w250);
	    ele.click();   
	    waitMethods.waiter(waitMethods.w250);
	    System.out.println("Selected MR - Test Checkbox");
	} 

	

	@Test(priority = 216) 
	private void selectClickToProceedButton() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"record\"]/div[2]/div[2]/div/div[3]/button")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Clicked Click to Proceed button");
	} 

	
//	REQUEST IS CANCELLED
	
	
	@Test(priority = 218)
	public void cancelRequest()  {   
		//waitMethods.implicitWait(waitMethods.w250);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Cancel Request')]"));
    	highlightElement.highLightElement(driver, ele);
    	ele.click();
    	waitMethods.waiter(waitMethods.w200);			
		System.out.println("Request cancelled");			
	}


	//Yes = confirm_button_save  <--Reference only   Not used in this test
	@Test(priority = 220)
	public void confirmCancelNo()  {   //
		//waitMethods.implicitWait(waitMethods.w250);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.id("confirm_button_cancelchange"));
    	highlightElement.highLightElement(driver, ele);
    	ele.click();
    	waitMethods.waiter(waitMethods.w200);			
		System.out.println("Confirm cancel -> No");			
	}

	@Test(priority = 222)
	public void cancelRequest2()  {   //
		//waitMethods.implicitWait(waitMethods.w250);
    	//waitMethods.waiter(waitMethods.w200);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Cancel Request')]"));
    	highlightElement.highLightElement(driver, ele);
    	ele.click();
    	waitMethods.waiter(waitMethods.w200);			
		System.out.println("Request cancelled (2)");			
	}

	
	//Yes = 
	@Test(priority = 224)
	public void confirmCancelYes()  {   //We're testing the cancel button - will then begin the request again
		//waitMethods.implicitWait(waitMethods.w250);
    	//waitMethods.waiter(waitMethods.w200);
    	WebElement ele = driver.findElement(By.id("confirm_button_save"));
    	highlightElement.highLightElement(driver, ele);
    	ele.click();
    	waitMethods.waiter(waitMethods.w250);			
		System.out.println("Confirm cancel -> Yes");			
	}


	//Return home and start again

	
	
	@Test(priority = 226)
	public void returnToHomePage()  {   //
		//waitMethods.implicitWait(waitMethods.w250);
    	waitMethods.waiter(waitMethods.w400);
    	WebElement ele = driver.findElement(By.partialLinkText("Main Page"));
    	highlightElement.highLightElement(driver, ele);
    	ele.click();
    	waitMethods.waiter(waitMethods.w200);			
		System.out.println("Return to home page");			
	}

	//=============================================================
	
	
	@Test(priority = 228) //
	public void selectNewRequest02() {         
		selectNewRequest();
	}


	
	@Test(priority = 230) //
	private void selectService02() {
		selectService();
	} 


	
	
	@Test(priority = 232) // 
	private void selectServiceAcuteCare02() {
		selectServiceAcuteCare();
	} 

	
	@Test(priority = 234) //
	private void selectRequestPriority02() {
		selectRequestPriority();
	} 


	@Test(priority = 236) 
	private void selectRequestNormalPriority02() {
		selectRequestNormalPriority();
	} 

	
	
	
	@Test(priority = 238) //
	private void inputRequestTitle02() {
		inputRequestTitle();
	} 


	
	@Test(priority = 240) //
	private void selectMRTestChkBox02() {
		selectMRTestChkBox();
	}
	

	

	@Test(priority = 242) 
	private void selectClickToProceedButton02() {
		selectClickToProceedButton();
	} 

	
	
	@Test(priority = 243)
	public void getReqNumber() {    //  full text is passed to the stringUtilities class to strip off characters not needed
				
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement (By.id("headerTab"));
		
		highlightElement.highLightElement(driver, ele);	
	
		String fullText = ele.getText().toString();
		requestNum = strUtil.getRequestNumber(fullText);						//requestNum created
				
		System.out.println("Full Field Text: " + fullText);        
		System.out.println("Request #: " + requestNum);	
       
	}
	
	
	
	
	
	@Test(priority = 246) 
	private void showSinglePage() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("showSinglePage")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w400);
	
	    System.out.println("Clicked Show Single Page");
	} 
	
	
	@Test(priority = 250) 
	private void verifySinglePage() {
		//waitMethods.implicitWait(waitMethods.w250);	
	
		String strExpected = "MR - Test";
		
		waitMethods.waiter(waitMethods.w750);
		WebElement ele = driver.findElement(By.xpath("//span[contains(text(), 'MR - Test')]"));
		highlightElement.highLightElement(driver, ele);     
		String strActual = ele.getText().toString();

			System.out.println("     DEBUG: strExpected = " + strExpected);
			System.out.println("     DEBUG: strActual   = " + strActual);

		Assert.assertEquals(strActual, strExpected);
		
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Verify Show Single Page");
	}

	
	@Test(priority = 254) 
	private void returnToPreviousPage() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'MR - Test')]")); //Random element before Back 
	    driver.navigate().back();
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Return to previous page");
	} 
	
	
	
	

	@Test(priority = 268) 
	private void enterFirstAndLastName() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("2")); 
	    highlightElement.highLightElement(driver, ele);     

    	String name = "Test Automation";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
		
	    System.out.println("Entered First and Last Name");
	} 
	
	

	@Test(priority = 272) 
	private void enterMiddleInitial() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("3")); 
	    highlightElement.highLightElement(driver, ele);     

    	String name = "Q";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
	    
	    System.out.println("Entered Middle Initial");
	} 
	
	
	
	@Test(priority = 276) 
	private void selectNextQuestion2() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("nextQuestion2")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Clicked Next Question");
	} 
					
	
	@Test(priority = 280) 
	private void selectThirdQuestion() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);			
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div[1]/div[2]/form/div/div/div/div/div[2]/span/div[1]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Answered Third Question");
	} 

	
	@Test(priority = 284) 
	private void selectNextQuestion() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("nextQuestion2")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Selected 'Next Question' (3)");
	} 

	
	@Test(priority = 288) 
	private void selectSubmitRequest() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w2k);	//   
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[1]/div[2]/div[2]/button")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Selected 'Submit Request'");
	} 


	@Test(priority = 292) 
	private void enterRequestComment() {   //	//a[starts-with(@id,’link-si’)]
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w500);	    //
		WebElement ele = driver.findElement(By.xpath("//textarea[starts-with(@id, 'comment_')]")); 
		highlightElement.highLightElement(driver, ele);     

    	String name = "Automated Test Comment";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
	    
	     System.out.println("Request Comment Added");
	} 
	

	@Test(priority = 296) 					//
	private void selectAcceptJob() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[1]/div[3]/div/form/div[2]/div/button")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("selected 'Accept Job'");
	} 


	
	@Test(priority = 300) 					//
	private void selectViewHistory() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'View History')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected View History");
	} 
	
	
	
	@Test(priority = 304) 
	private void verifyHistory() {
		//waitMethods.implicitWait(waitMethods.w250);	
	
		String strExpected = "Action Taken";
		
		waitMethods.waiter(waitMethods.w400);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Action Taken')]"));
		highlightElement.highLightElement(driver, ele);     
		String strActual = ele.getText().toString();

			System.out.println("     DEBUG: strExpected = " + strExpected);
			System.out.println("     DEBUG: strActual   = " + strActual);

		Assert.assertEquals(strActual, strExpected);
		
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Verify Show History");
	}
	
	
	
	@Test(priority = 308) 					//
	private void selectPrintIcon() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("/html/body/div[7]/div[2]/div/div[4]/div[1]/a/img")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Print Icon");
	} 
	
	
	
	@Test(priority = 312) 
	private void verifyRequestPrint2() {
		//waitMethods.implicitWait(waitMethods.w250);	
	
		String strExpected = "Action Taken";
		
		waitMethods.waiter(waitMethods.w400);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Action Taken')]"));
		highlightElement.highLightElement(driver, ele);     
		String strActual = ele.getText().toString();

			System.out.println("     DEBUG: strExpected = " + strExpected);
			System.out.println("     DEBUG: strActual   = " + strActual);

		Assert.assertEquals(strActual, strExpected);
		
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Verify Print Page Displays");
	    driver.navigate().back();
	}
	
	
	@Test(priority = 316) 					//
	private void selectPrintToPDF() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Print to PDF')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Print To PDF");
	} 
	
	
	@Test(priority = 320) 	//
	private void selectAddBookmark() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.id("tool_bookmarkText")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Select Add Bookmark");
	} 
	
	
	
	@Test(priority = 324) 
	private void verifyBookmarkAdded() {
		//waitMethods.implicitWait(waitMethods.w250);	
	
		String strExpected = "Delete Bookmark";
		
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Delete Bookmark')]"));
		highlightElement.highLightElement(driver, ele);     
		String strActual = ele.getText().toString();

			System.out.println("     DEBUG: strExpected = " + strExpected);
			System.out.println("     DEBUG: strActual   = " + strActual);

		Assert.assertEquals(strActual, strExpected);
		
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Verify Bookmark was created");
	}
	
	
	
	// Goto Bookmark page to validate Request # is present
	//	URL to Bookmarks page: https://localhost/LEAF_Request_Portal/?a=bookmarks	
	

	
	
	@Test(priority = 328) 						//Main Page
	private void selectMainPage() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Main Page')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Main Page");
	} 
	

	
	@Test(priority = 332) 
	private void selectBookmarks() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Bookmarks')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Bookmarks from Main Page");
	} 


	@Test(priority = 336) 
	private void validateBookmark() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.xpath("//*[contains(text()," + requestNum.toString() + ")]")); 
	    highlightElement.highLightElement(driver, ele);     
	    
	    String strExpected = requestNum.toString();
	    String strActual = ele.getText().toString();
	    
	    	System.out.println("     DEBUG: strExpected = " + strExpected);
	    	System.out.println("     DEBUG: strActual   = " + strActual);
	    
		Assert.assertEquals(strActual, strExpected);
		
	    System.out.println("Validated Request in progress is within Bookmarks");
	} 

	@Test(priority = 340) 		
	private void selectMainPage02() {
		selectMainPage();
	}
	

	@Test(priority = 346) 
	private void selectRequestInProgress() {
		//waitMethods.implicitWait(waitMethods.w250);
		
		waitMethods.waiter(waitMethods.w250);	//  ("//*[contains(text(), 'Bookmarks')]"))
		WebElement ele = driver.findElement(By.xpath("//*[contains(text()," + requestNum.toString() + ")]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Request in Progress");
	} 
	
	
	
	@Test(priority = 350) 
	private void selectInternalUseForm() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Internal Use Form')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Internal Use Form from Request");
	} 
	
	
	
	@Test(priority = 354) 
	private void validateInternalUseForm() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w500);		//
		WebElement ele = driver.findElement(By.id("requestTitle")); 
	    highlightElement.highLightElement(driver, ele);     
	    
	    String strExpected = "Internal Use Form";   
	    
	    if(ele.getText().toString().contains(strExpected)) {
	    	Assert.assertTrue(true, "Internal Use Form Validated");   //(true, "Internal Use Form Validated");
	    } else {
	    	Assert.assertFalse(false, "Internal Use Form not found");
	    }

	    	System.out.println("     DEBUG: strExpected = " + strExpected);
	    	
	} 
	
	
	
	
	@Test(priority = 360) 
	private void selectMainRequest() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Main Request')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Main Request");
	} 
	
																			//Change Initiator
	
	@Test(priority = 364) 
	private void changeInitiator() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Change Initiator')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Change Initiator");
	} 
	
	
	
	@Test(priority = 368) 
	private void selectRequestInitiator() {   //
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);	    //
		WebElement ele = driver.findElement(By.xpath("//input[starts-with(@id, 'empSel')]")); 
	    highlightElement.highLightElement(driver, ele);     

    	String name = "gao, michael";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
    	 waitMethods.waiter(waitMethods.w250);
	     System.out.println("Select Request Initiator");
	} 
	
	//button_cancelchange
	
	
	@Test(priority = 372) 
	private void cancelChangeInitator() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.id("button_cancelchange")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Cancel Change Initator");
	} 
	
	

	@Test(priority = 376) 
	private void changeInitiator02() {
		changeInitiator();
	}
	

		
	@Test(priority = 380) 
	private void selectRequestInitiator02() {   //
		selectRequestInitiator();
	} 

	
	
	@Test(priority = 384) 
	private void saveChangeInitator() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.id("button_save")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Save Change Initator");
	} 
	
	
	
	@Test(priority = 388) 
	private void verifyChangeInitiator() {
		//waitMethods.implicitWait(waitMethods.w250);	
		String strExpected = "Initiator changed to Michael Gao";
					
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Initiator changed')]"));
		highlightElement.highLightElement(driver, ele);     
		String strActual = ele.getText().toString();

			System.out.println("     DEBUG: strExpected = " + strExpected);
			System.out.println("     DEBUG: strActual   = " + strActual);

		Assert.assertEquals(strActual, strExpected);
		
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Verify Change Initiator");
	}


	
																				//Change Service
		
	@Test(priority = 392) 
	private void changeService() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Change Service')]")); 
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Change Service");
	} 
	

	
	
	


	
	@Test(priority = 396) //   
	public void openDropdownListForService() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w500);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w500);
		System.out.println("Forms-Selected Dropdown Box");
	}

	
	@Test(priority = 400) // 
	private void selectNewService() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.cssSelector("#newService-chosen-search-result-5"));  
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w250);
        System.out.println("Selected Service 'Facilities'");
	} 
	

	@Test(priority = 404) //		  
	private void saveChangeService() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.id("button_save")); 
	    //highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Save Change Service");
	} 
	
	
	
		
	@Test(priority = 408) 
	private void verifyChangeService() {
		//waitMethods.implicitWait(waitMethods.w250);	
		String strExpected = "Facilities";
					
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Facilities')]"));
		waitMethods.waiter(waitMethods.w250);
		//highlightElement.highLightElement(driver, ele);     
		String strActual = ele.getText().toString();

			System.out.println("     DEBUG: strExpected = " + strExpected);
			System.out.println("     DEBUG: strActual   = " + strActual);

		Assert.assertEquals(strActual, strExpected);
		
		waitMethods.waiter(waitMethods.w250);
	    System.out.println("Verify Change Service");
	}
	
	
	
	
	@Test(priority = 412) 
	private void selectChangeForms() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		
			//JavascriptExecutor js = (JavascriptExecutor) driver;
			//js.executeScript("window.scrollBy(0,250)", "");
		
		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Change Form')]"));
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    waitMethods.waiter(waitMethods.w300);
	    System.out.println("Selected Change Form(s)");
	} 
	
	
	
	@Test(priority = 416) 
	private void saveChangeForms() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.id("button_save")); 
	    //highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Saved Change Form(s)");
	} 
	
	
	
	@Test(priority = 420) 
	private void selectChangeCurrentStep() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		
		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Change Current Step')]"));
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    waitMethods.waiter(waitMethods.w300);
	    System.out.println("Selected Change Current Step");
	} 
	
	
	
	
	@Test(priority = 424) //   
	public void openDropdownListForStep() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w500);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/span"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w500);
		System.out.println("Open Dropdown For 'Set to this step'");
	}

	
	
	@Test(priority = 428) // 
	private void selectNewStep() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);	//          
		WebElement ele = driver.findElement(By.cssSelector("#newStep-chosen-search-result-1"));  
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w250);
        System.out.println("Selected Step ': Decision'");
	} 
	
	
	
	
	@Test(priority = 432) 
	private void enterStepChangeComment() {   //	//a[starts-with(@id,’link-si’)]
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);	    //
		WebElement ele = driver.findElement(By.id("changeStep_comment")); 
		highlightElement.highLightElement(driver, ele);     

    	String name = "Change Step Automated Comment";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
	    
	     System.out.println("Step Change Comment Added");
	} 
	
	
	
	//Advanced - Steps from all workflows  ID: showAllSteps
	@Test(priority = 436) 
	private void selectShowStepsFromAllWorkflows() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.id("showAllSteps")); 
	    //highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Selected Show Steps From All Workflows");
	} 
	
	
	
	@Test(priority = 440) 
	private void saveStepChange() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		WebElement ele = driver.findElement(By.id("button_save")); 
	    //highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Saved Step Change");
	} 
	
	
		
	
	@Test(priority = 444)     /// Uses css, Ok for now - not sure why contains() doesn't find?     
	private void selectReadAccess() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		
			JavascriptExecutor js = (JavascriptExecutor) driver;
			js.executeScript("window.scrollBy(0,250)", "");
		
		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'You have read')]"));
		WebElement ele = driver.findElement(By.cssSelector("#toolbar > div.toolbar_security > button:nth-child(2) > img"));
		
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    waitMethods.waiter(waitMethods.w300);
	    System.out.println("Selected Read Access");
	} 
	
	
	
	
	@Test(priority = 448)     //   
	private void verifyReadAccess() {
		//waitMethods.implicitWait(waitMethods.w250);	
		String strExpected = "is not need to know";
					
		waitMethods.waiter(waitMethods.w300);
		WebElement ele = driver.findElement(By.xpath("/html/body/div[7]/div[2]/div/div[4]/li"));
		highlightElement.highLightElement(driver, ele);    
		
		//Actual Text is:  Record 669 is not need to know.
		String strActual = ele.getText().toString();
		
		if(strActual.contains(strExpected)) {
			Assert.assertTrue(true, "Read Access Verified");
		} else {
			Assert.assertFalse(false, "Text not found");
		}
			
			System.out.println("     DEBUG: strExpected = " + strExpected);
			System.out.println("     DEBUG: strActual   = " + strActual);
		
		waitMethods.waiter(waitMethods.w100);
	    System.out.println("Verify Read Access");
	}

	
	
	@Test(priority = 452)     //    
	private void closeSecurityMsgbox() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.xpath("/html/body/div[7]/div[1]/button/span[1]"));
		highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    waitMethods.waiter(waitMethods.w250);
	    System.out.println("Security Box Closed");
	} 
	
	
	
	@Test(priority = 456)     //
	private void selectWriteAccess() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w300);		//
		
			JavascriptExecutor js = (JavascriptExecutor) driver;
			js.executeScript("window.scrollBy(0,250)", "");
		
		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'You have write')]"));
		WebElement ele = driver.findElement(By.cssSelector("#toolbar > div.toolbar_security > button:nth-child(3) > img"));
		
		
	    highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    waitMethods.waiter(waitMethods.w300);
	    System.out.println("Selected Write Access");
	} 
	
	
	
	
	@Test(priority = 460)     // 
	private void verifyWriteAccess() {
		//waitMethods.implicitWait(waitMethods.w250);	
		String strExpected1 = "You are not a writable user or initiator";
		String strExpected2 = "You are an admin";			
		
		waitMethods.waiter(waitMethods.w300);    

		WebElement ele = driver.findElement(By.xpath("/html/body/div[7]/div[2]/div/div[4]/li[1]"));
		waitMethods.waiter(waitMethods.w200);
		highlightElement.highLightElement(driver, ele);    
	
		String strActual1 = ele.getText().toString();
		
		
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[7]/div[2]/div/div[4]/li[2]"));
		waitMethods.waiter(waitMethods.w200);
		highlightElement.highLightElement(driver, ele2);    
		
		String strActual2 = ele.getText().toString();
		
		if(strActual1.contains(strExpected1)) {
			Assert.assertTrue(true, "Write Access Verified");
		} else if(strActual2.contains(strExpected2)) {
			Assert.assertTrue(true, "Write Access Verified");
		} else {
			Assert.assertFalse(false, "Text not found");		
		}

			System.out.println("     DEBUG: strExpected1 = " + strExpected1);
			System.out.println("     DEBUG: strExpected2 = " + strExpected2);
			System.out.println("     DEBUG: strActual1   = " + strActual1);
			System.out.println("     DEBUG: strActual2   = " + strActual2);
		
		waitMethods.waiter(waitMethods.w100);
	    System.out.println("Verify Write Access");
	}


	
	
	@Test(priority = 464)     //    
	private void closeSecurityMsgbox2() {
		closeSecurityMsgbox();
	}
	
	
//	@Test(priority = 9998)     //
//	private void displayCompleteAlert() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w100);		//
//		
//			JavascriptExecutor js = (JavascriptExecutor) driver;
//			//js.executeScript("window.scrollBy(0,250)", "");
//			js.executeScript("alert(' newRequestWorkflow Tests Complete\\n See logs for test results')");
//		
//	} 
//	
//
//	@Test(priority = 9999)
//	void dismissJSAlert() {
//		waitMethods.waiter(waitMethods.w4k);
//		driver.switchTo().alert().dismiss();
//		
//	}
	
	

	
	
	
	//PICKUP HERE 
	
/* after this it comes back to the main request - Requires Service Chief approval
 ID:	comment_dep1	
	
	Approve button ID:    button_step1_approve
	Return to Requestor ID:      button_step1_sendback
		When selecting the above, Text displayed is: 'Service Chief: Returned to Requestor'
	
*?	
	
	/* TODO for Request
	
	Write Email 				 DONE		
	Print to PDF				 DONE
	Add Bookmark				 DONE 
	Internal use				 DONE
	Change Service				 DONE
	Change Initiator			 DONE
	Change Current Step			 DONE		 ID:     newStep-chosen-search-result-37
	
					
	
	WebElement ele = driver.findElement(By.xpath("//textarea[starts-with(@id, 'comment_')]"));
	
	
	Change Form(s)				DONE
	Read access					DONE
	Write access				DONE
	Email recipient test		DONE - Commented out below

	
	*/
	
	
//	@Test(priority = 3316) 					//		
//	private void selectWriteEmail() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Write Email')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Write Email");
//	} 
//	
//	
//	@Test(priority = 3320) 					// 
//		private void closeEmail() {
//			vbsExecutor.executeVBS("C:\\Users\\MaxRichard\\Documents\\GitHub\\LEAF\\test\\Test-Automation\\src\\", "CloseOutlookVerifyFailsafeMR.vbs");
//			//vbsExecutor.executeVBS("C:\\DEV\\Tools\\VB Scripts\\", "CloseOutlookVerifyFailsafeMR.vbs");
//						
//	}
	
	


}  //class
	