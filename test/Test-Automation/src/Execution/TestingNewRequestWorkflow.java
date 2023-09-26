package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;

import static org.testng.Assert.assertTrue;

import java.util.Date;

import org.openqa.selenium.By;
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


public class TestingNewRequestWorkflow extends setupFramework {

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
	
//	@Test(priority = 202) //
//	public void selectNewRequest() {         //
//		//waitMethods.implicitWait(waitMethods.w250);
//		//waitMethods.waiter(waitMethods.w1k);	
//		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[1]/span")); 
//		highlightElement.highLightElement(driver, ele);
//		ele.click();
//		waitMethods.waiter(waitMethods.w250);
//		System.out.println("New Request Button clicked");
//	}
//
//
//	
//	@Test(priority = 204) 					//select drop down
//	private void selectService() {
//		waitMethods.waiter(waitMethods.w200);       
//		WebElement ele = driver.findElement(By.cssSelector("#service_chosen > a > span"));
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w200);
//	    System.out.println("Clicked Service Drop down menu");
//	} 
//
//
//	
//	
//	@Test(priority = 206) // 
//	private void selectServiceAcuteCare() {			//Acute Care
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.cssSelector("#service-chosen-search-result-1")); //.click(); 
//		highlightElement.highLightElement(driver, ele);
//        ele.click();
//		waitMethods.waiter(waitMethods.w250);
//        System.out.println("Selected Service 'Acute Care'");
//	} 
//
//	//#priority_chosen > a > span	
//	
//	@Test(priority = 208) 						//select drop down
//	private void selectRequestPriority() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.cssSelector("#priority_chosen > a > span")); 
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w250);
//		//driver.navigate().back();    //navigate back
//	    System.out.println("Checked priority values in DDL");
//	} 
//
//
//	@Test(priority = 210) 					//select Normal Priority
//	private void selectRequestNormalPriority() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.cssSelector("#priority_chosen > a > span")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//		waitMethods.waiter(waitMethods.w250);
//		//driver.navigate().back();    //navigate back
//	    System.out.println("Select Request Normal Priority");
//	} 
//
//	
//	
//    
//	@Test(priority = 212) //
//	private void inputRequestTitle() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//			
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.name("title")); //.click();  
//	    highlightElement.highLightElement(driver, ele);
//
//    	String name = "Test Automation " + dateAndTimeMethods.getDate().toString();
//    	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		ele.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//	   
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Input Request Title: 'Test Automation + current date & time");
//	} 
//
//	
//
//	@Test(priority = 214) //
//	private void selectMRTestChkBox() {					  
//		WebElement ele = driver.findElement (By.xpath ("//*[contains(text(),'MR - Test')]"));
//	    highlightElement.highLightElement(driver, ele);
//	    waitMethods.waiter(waitMethods.w250);
//	    ele.click();   
//	    waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Selected MR - Test Checkbox");
//	} 
//
//	
//
//	@Test(priority = 216) 
//	private void selectClickToProceedButton() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.xpath("//*[@id=\"record\"]/div[2]/div[2]/div/div[3]/button")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Clicked Click to Proceed button");
//	} 
//
//	
////	REQUEST IS CANCELLED
//	
//	
//	@Test(priority = 218)
//	public void cancelRequest()  {   
//		//waitMethods.implicitWait(waitMethods.w250);
//    	//waitMethods.waiter(waitMethods.w200);
//    	WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Cancel Request')]"));
//    	highlightElement.highLightElement(driver, ele);
//    	ele.click();
//    	waitMethods.waiter(waitMethods.w200);			
//		System.out.println("Request cancelled");			
//	}
//
//
//	//Yes = confirm_button_save  <--Reference only   Not used in this test
//	@Test(priority = 220)
//	public void confirmCancelNo()  {   //
//		//waitMethods.implicitWait(waitMethods.w250);
//    	//waitMethods.waiter(waitMethods.w200);
//    	WebElement ele = driver.findElement(By.id("confirm_button_cancelchange"));
//    	highlightElement.highLightElement(driver, ele);
//    	ele.click();
//    	waitMethods.waiter(waitMethods.w200);			
//		System.out.println("Confirm cancel -> No");			
//	}
//
//	@Test(priority = 222)
//	public void cancelRequest2()  {   //
//		//waitMethods.implicitWait(waitMethods.w250);
//    	//waitMethods.waiter(waitMethods.w200);
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Cancel Request')]"));
//    	highlightElement.highLightElement(driver, ele);
//    	ele.click();
//    	waitMethods.waiter(waitMethods.w200);			
//		System.out.println("Request cancelled (2)");			
//	}
//
//	
//	//Yes = 
//	@Test(priority = 224)
//	public void confirmCancelYes()  {   //We're testing the cancel button - will then begin the request again
//		//waitMethods.implicitWait(waitMethods.w250);
//    	//waitMethods.waiter(waitMethods.w200);
//    	WebElement ele = driver.findElement(By.id("confirm_button_save"));
//    	highlightElement.highLightElement(driver, ele);
//    	ele.click();
//    	waitMethods.waiter(waitMethods.w250);			
//		System.out.println("Confirm cancel -> Yes");			
//	}
//
//
//	//Return home and start again
//
//	
//	
//	@Test(priority = 226)
//	public void returnToHomePage()  {   //
//		//waitMethods.implicitWait(waitMethods.w250);
//    	waitMethods.waiter(waitMethods.w400);
//    	WebElement ele = driver.findElement(By.partialLinkText("Main Page"));
//    	highlightElement.highLightElement(driver, ele);
//    	ele.click();
//    	waitMethods.waiter(waitMethods.w200);			
//		System.out.println("Return to home page");			
//	}
//
//	//=============================================================
//	
//	
//	@Test(priority = 228) //
//	public void selectNewRequest02() {         
//		selectNewRequest();
//	}
//
//
//	
//	@Test(priority = 230) //
//	private void selectService02() {
//		selectService();
//	} 
//
//
//	
//	
//	@Test(priority = 232) // 
//	private void selectServiceAcuteCare02() {
//		selectServiceAcuteCare();
//	} 
//
//	
//	@Test(priority = 234) //
//	private void selectRequestPriority02() {
//		selectRequestPriority();
//	} 
//
//
//	@Test(priority = 236) 
//	private void selectRequestNormalPriority02() {
//		selectRequestNormalPriority();
//	} 
//
//	
//	
//	
//	@Test(priority = 238) //
//	private void inputRequestTitle02() {
//		inputRequestTitle();
//	} 
//
//
//	
//	@Test(priority = 240) //
//	private void selectMRTestChkBox02() {
//		selectMRTestChkBox();
//	}
//	
//
//	
//
//	@Test(priority = 242) 
//	private void selectClickToProceedButton02() {
//		selectClickToProceedButton();
//	} 

	
	
//	@Test(priority = 243)
//	public void getReqNumber() {    //  full text is passed to the stringUtilities class to strip off characters not needed
//				
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement (By.id("headerTab"));
//		
//		highlightElement.highLightElement(driver, ele);	
//	
//		String fullText = ele.getText().toString();
//		requestNum = strUtil.getRequestNumber(fullText);						//requestNum created
//				
//		System.out.println("Full Field Text: " + fullText);        
//		System.out.println("Request #: " + requestNum);	
//       
//	}
	
	
	
	
	
//	@Test(priority = 246) 
//	private void showSinglePage() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.id("showSinglePage")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//		waitMethods.waiter(waitMethods.w400);
//	
//	    System.out.println("Clicked Show Single Page");
//	} 
//	
//	
//	@Test(priority = 250) 
//	private void verifySinglePage() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//	
//		String strExpected = "MR - Test";
//		
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.xpath("//span[contains(text(), 'MR - Test')]"));
//		highlightElement.highLightElement(driver, ele);     
//		String strActual = ele.getText().toString();
//
//			System.out.println("     DEBUG: strExpected = " + strExpected);
//			System.out.println("     DEBUG: strActual   = " + strActual);
//
//		Assert.assertEquals(strActual, strExpected);
//		
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Verify Show Single Page");
//	}
//
//	
//	@Test(priority = 254) 
//	private void returnToPreviousPage() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'MR - Test')]")); //Random element before Back 
//	    driver.navigate().back();
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Return to previous page");
//	} 
//	
//	
//	
//	
//
//	@Test(priority = 268) 
//	private void enterFirstAndLastName() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.id("2")); 
//	    highlightElement.highLightElement(driver, ele);     
//
//    	String name = "Test Automation";
//    	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//		
//	    System.out.println("Entered First and Last Name");
//	} 
//	
//	
//
//	@Test(priority = 272) 
//	private void enterMiddleInitial() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.id("3")); 
//	    highlightElement.highLightElement(driver, ele);     
//
//    	String name = "Q";
//    	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//	    
//	    System.out.println("Entered Middle Initial");
//	} 
//	
//	
//	
//	@Test(priority = 276) 
//	private void selectNextQuestion2() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.id("nextQuestion2")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Clicked Next Question");
//	} 
//					
//	
//	@Test(priority = 280) 
//	private void selectThirdQuestion() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);			
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div[1]/div[2]/form/div/div/div/div/div[2]/span/div[1]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Answered Third Question");
//	} 
//
//	
//	@Test(priority = 284) 
//	private void selectNextQuestion() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.id("nextQuestion2")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Selected 'Next Question' (3)");
//	} 
//
//	
//	@Test(priority = 288) 
//	private void selectSubmitRequest() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w2k);	//   
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[1]/div[2]/div[2]/button")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Selected 'Submit Request'");
//	} 
//
//
//	@Test(priority = 292) 
//	private void enterRequestComment() {   //	//a[starts-with(@id,’link-si’)]
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w500);	    //
//		WebElement ele = driver.findElement(By.xpath("//textarea[starts-with(@id, 'comment_')]")); 
//		//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[1]/div[3]/div/form/div[2]/textarea"));
//	    highlightElement.highLightElement(driver, ele);     
//
//    	String name = "Automated Test Comment";
//    	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//	    
//	     System.out.println("Request Comment Added");
//	} 
//	
//
//	@Test(priority = 296) 					//
//	private void selectAcceptJob() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[1]/div[3]/div/form/div[2]/div/button")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("selected 'Accept Job'");
//	} 
//
//
//	
//	@Test(priority = 300) 					//
//	private void selectViewHistory() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'View History')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected View History");
//	} 
//	
//	
//	
//	@Test(priority = 304) 
//	private void verifyHistory() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//	
//		String strExpected = "Action Taken";
//		
//		waitMethods.waiter(waitMethods.w400);
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Action Taken')]"));
//		highlightElement.highLightElement(driver, ele);     
//		String strActual = ele.getText().toString();
//
//			System.out.println("     DEBUG: strExpected = " + strExpected);
//			System.out.println("     DEBUG: strActual   = " + strActual);
//
//		Assert.assertEquals(strActual, strExpected);
//		
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Verify Show History");
//	}
//	
//	
//	
//	@Test(priority = 308) 					//
//	private void selectPrintIcon() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[7]/div[2]/div/div[4]/div[1]/a/img")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Print Icon");
//	} 
//	
//	
//	
//	@Test(priority = 312) 
//	private void verifyRequestPrint2() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//	
//		String strExpected = "Action Taken";
//		
//		waitMethods.waiter(waitMethods.w400);
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Action Taken')]"));
//		highlightElement.highLightElement(driver, ele);     
//		String strActual = ele.getText().toString();
//
//			System.out.println("     DEBUG: strExpected = " + strExpected);
//			System.out.println("     DEBUG: strActual   = " + strActual);
//
//		Assert.assertEquals(strActual, strExpected);
//		
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Verify Print Page Displays");
//	    driver.navigate().back();
//	}
//	
//	
//	@Test(priority = 316) 					//
//	private void selectPrintToPDF() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Print to PDF')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Print To PDF");
//	} 
//	
//	
//	@Test(priority = 320) 	//
//	private void selectAddBookmark() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.id("tool_bookmarkText")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Select Add Bookmark");
//	} 
//	
//	
//	
//	@Test(priority = 324) 
//	private void verifyBookmarkAdded() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//	
//		String strExpected = "Delete Bookmark";
//		
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Delete Bookmark')]"));
//		highlightElement.highLightElement(driver, ele);     
//		String strActual = ele.getText().toString();
//
//			System.out.println("     DEBUG: strExpected = " + strExpected);
//			System.out.println("     DEBUG: strActual   = " + strActual);
//
//		Assert.assertEquals(strActual, strExpected);
//		
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Verify Bookmark was created");
//	}
//	
//	
//	
//	// Goto Bookmark page to validate Request # is present
//	//	URL to Bookmarks page: https://localhost/LEAF_Request_Portal/?a=bookmarks	
//	
//
//	
//	
//	@Test(priority = 328) 						//Main Page
//	private void selectMainPage() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Main Page')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Main Page");
//	} 
//	
//
//	
//	@Test(priority = 332) 
//	private void selectBookmarks() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);		//
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Bookmarks')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Bookmarks from Main Page");
//	} 
//
//
//	@Test(priority = 336) 
//	private void validateBookmark() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.xpath("//*[contains(text()," + requestNum.toString() + ")]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    
//	    String strExpected = requestNum.toString();
//	    String strActual = ele.getText().toString();
//	    
//	    	System.out.println("     DEBUG: strExpected = " + strExpected);
//	    	System.out.println("     DEBUG: strActual   = " + strActual);
//	    
//		Assert.assertEquals(strActual, strExpected);
//		
//	    System.out.println("Validated Request in progress is within Bookmarks");
//	} 
//
//	@Test(priority = 340) 		
//	private void selectMainPage02() {
//		selectMainPage();
//	}
	

	//		https://localhost/LEAF_Request_Portal/index.php?a=printview&recordID=617
	
	
	@Test(priority = 346) 
	private void selectRequestInProgress() {
		//waitMethods.implicitWait(waitMethods.w250);
		driver.navigate().to("https://localhost/LEAF_Request_Portal/index.php?a=printview&recordID=617");
		
	

	} 
	
	
	
//	@Test(priority = 350) 
//	private void selectInternalUseForm() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Internal Use Form')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Internal Use Form from Request");
//	} 
//	
//	
//	
//	@Test(priority = 354) 
//	private void validateInternalUseForm() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.id("requestTitle")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    
//	    String strExpected = "Internal Use Form";   
//	    
//	    if(ele.getText().toString().contains(strExpected)) {
//	    	Assert.assertTrue(true, "Internal Use Form Validated");   //(true, "Internal Use Form Validated");
//	    } else {
//	    	Assert.assertFalse(false, "Internal Use Form not found");
//	    }
//
//	    	System.out.println("     DEBUG: strExpected = " + strExpected);
//	    	
//	} 
//	
//	
//	
//	
//	@Test(priority = 360) 
//	private void selectMainRequest() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Main Request')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Main Request");
//	} 
//	
//																			//Change Initiator
//	
//	@Test(priority = 364) 
//	private void changeInitiator() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Change Initiator')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Selected Change Initiator");
//	} 
//	
//	
//	
//	@Test(priority = 368) 
//	private void selectRequestInitiator() {   //
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w250);	    //
//		WebElement ele = driver.findElement(By.xpath("//input[starts-with(@id, 'empSel')]")); 
//	    highlightElement.highLightElement(driver, ele);     
//
//    	String name = "gao, michael";
//    	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//    	 waitMethods.waiter(waitMethods.w250);
//	     System.out.println("Select Request Initiator");
//	} 
//	
//	//button_cancelchange
//	
//	
//	@Test(priority = 372) 
//	private void cancelChangeInitator() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.id("button_cancelchange")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Cancel Change Initator");
//	} 
//	
//	
//
//	@Test(priority = 376) 
//	private void changeInitiator02() {
//		changeInitiator();
//	}
//	
//
//		
//	@Test(priority = 380) 
//	private void selectRequestInitiator02() {   //
//		selectRequestInitiator();
//	} 
//
//	
//	
//	@Test(priority = 384) 
//	private void saveChangeInitator() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.id("button_save")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Save Change Initator");
//	} 
//	
//	
//	
//	@Test(priority = 388) 
//	private void verifyChangeInitiator() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//	
//		String strExpected = "Initiator changed to Michael Gao";
//		
//		waitMethods.waiter(waitMethods.w250);
//		WebElement ele = driver.findElement(By.xpath("//class[contains(text(), 'Initiator changed to Michael Gao')]"));
//		highlightElement.highLightElement(driver, ele);     
//		String strActual = ele.getText().toString();
//
//			System.out.println("     DEBUG: strExpected = " + strExpected);
//			System.out.println("     DEBUG: strActual   = " + strActual);
//
//		Assert.assertEquals(strActual, strExpected);
//		
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Verify Change Initiator");
//	}


	
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

	
	
	
	
	
	
	
/*     ***************  THIS IS THE METHOD CURRENTLY in newRequestWorkflow - has issues, consider doing like the
 				the first few dropdown boxes (Service, Priority, etc)
 	
	@Test(priority = 396) //   title ID: newService_chosen		Div ID:
	public void selectNewService() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);			//The below opens the DDL
														//  Div ID:
														//XPath	/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b
		WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w300);
		//WebElement ele2 = driver.findElement(By.id("newService-chosen-search-result-5"));
		//highlightElement.highLightElement(driver, ele);
		
		//Select select = new Select(driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b")));
		//highlightElement.highLightElement(driver, ele);
		//select.selectByValue("35");				//Facilities
		//select.selectByIndex(5);																//******  ERR HERE)
		
		
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/div/div/input"));
		highlightElement.highLightElement(driver, ele);
		//ele.click();
		
    	String name = "Facilities";
 	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele2.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
    	
    	waitMethods.waiter(waitMethods.w250);
    	
    	//WebElement ele3 = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/span"));
		//highlightElement.highLightElement(driver, ele);
    	
    	
    	ele2.sendKeys(Keys.ENTER);							//This WORKS
    	waitMethods.waiter(waitMethods.w200);
    	ele2.sendKeys(Keys.TAB);
    	waitMethods.waiter(waitMethods.w200);
    	ele2.sendKeys(Keys.TAB);
    	waitMethods.waiter(waitMethods.w200);
    	ele2.sendKeys(Keys.TAB);
		waitMethods.waiter(waitMethods.w250);

		System.out.println("Forms-Selected New Service");
	}

*/	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	@Test(priority = 396) //   title ID: newService_chosen		Div ID:
	public void openDropdownListForService() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w1k);
		System.out.println("Forms-Selected Dropdown Box");
	}

		
//		//WebElement ele2 = driver.findElement(By.id("newService-chosen-search-result-5"));
//		//highlightElement.highLightElement(driver, ele);
//		
//		//Select select = new Select(driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b")));
//		//highlightElement.highLightElement(driver, ele);
//		//select.selectByValue("35");				//Facilities
//		//select.selectByIndex(5);																//******  ERR HERE)
//		
//		
//		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/div/div/input"));
//		highlightElement.highLightElement(driver, ele);
//		//ele.click();
//		
//		//	TestingNewRequestWorkflow	
//		
//    	String name = "Facilities";
// 	   
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		ele2.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//    	
//    	waitMethods.waiter(waitMethods.w1k);
//    	
//    	//WebElement ele3 = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/span"));
//		//highlightElement.highLightElement(driver, ele);
//    	
//    	
//    	ele2.sendKeys(Keys.ENTER);						//This WORKS, but may be responsible for altering the position of the SAVE btn
//    	waitMethods.waiter(waitMethods.w2k);
//    	ele2.sendKeys(Keys.TAB);
//    	waitMethods.waiter(waitMethods.w200);
//    	ele2.sendKeys(Keys.TAB);
//    	waitMethods.waiter(waitMethods.w200);
//    	ele2.sendKeys(Keys.TAB);
//		waitMethods.waiter(waitMethods.w250);
//
//		System.out.println("Forms-Selected New Service");
//	}

	
/* Might try breaking into two methods					PICKUP HERE
    The first is 			WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b"));
							highlightElement.highLightElement(driver, ele);
							ele.click();
							waitMethods.waiter(waitMethods.w1k);
	Which works...
	
	The second would be similar to the below -> just get the CSS value of 'Facilities'
		perhaps that will not move the save button behind the cancel button???  Find out...
	
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
	
*/	
	
	
	
	
	@Test(priority = 600) // 
	private void selectNewService() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.cssSelector("#newService-chosen-search-result-5"));  
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w250);
        System.out.println("Selected Service 'Facilities'");
	} 
	
	
	
	
	
	
	
	
	
	

/*	THIS IS THE ORIGINAL METHOD selectNewService()
	
		@Test(priority = 396) //   title ID: newService_chosen		Div ID:
	public void selectNewService() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);			//The below opens the DDL
														//  Div ID:
														//XPath	/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b
		WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w1k);
//		Select select = new Select(driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b")));
//		highlightElement.highLightElement(driver, ele);
		WebElement ele2 = driver.findElement(By.id("newService-chosen-search-result-5"));
		highlightElement.highLightElement(driver, ele);
		
		
		
		
//		select.selectByValue("35");				//Facilities
//		select.selectByIndex(5);																//******  ERR HERE)
//		waitMethods.waiter(waitMethods.w1k);
//		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[6]/div[2]/form/div/div[3]/div/div/a/div/b"));
//		ele2.click();
		System.out.println("Forms-Selected New Service");
	}
	
	
*/
	
	
	//  THIS IS FINISHED, BUT MAY NEED TO BE REFACTORED
	@Test(priority = 605) //		DOESN'T WORK, Cancel button is in front of save button  
	private void saveChangeService() {
		//waitMethods.implicitWait(waitMethods.w250);	
		waitMethods.waiter(waitMethods.w250);		//
		WebElement ele = driver.findElement(By.id("button_save")); 
	    //highlightElement.highLightElement(driver, ele);     
	    ele.click();
	    System.out.println("Save Change Service");
	} 
	
	
	
	// PicKUP HERE after addressing the DDL for changing service ==> Should Add an Assert verification
	
	
	
	
//	@Test(priority = 400) 
//	private void cancelChangeInitator() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.id("button_cancelchange")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Cancel Change Initator");
//	} 	
//	
//
//	
//
//	@Test(priority = 404) 
//	private void changeInitiator02() {
//		waitMethods.waiter(waitMethods.w300);
//		changeInitiator();
//	}
//	
//
//		
//	@Test(priority = 408) 
//	private void selectRequestInitiator02() {   //
//		selectRequestInitiator();
//	} 
//
//	
//	
//	@Test(priority = 412) 
//	private void saveChangeInitator() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//		waitMethods.waiter(waitMethods.w300);		//
//		WebElement ele = driver.findElement(By.id("button_save")); 
//	    highlightElement.highLightElement(driver, ele);     
//	    ele.click();
//	    System.out.println("Save Change Initator");
//	} 
//	
//	
//	
//	@Test(priority = 416) 
//	private void verifyChangeInitiator() {
//		//waitMethods.implicitWait(waitMethods.w250);	
//	
//		String strExpected = "Initiator changed to Michael Gao";
//		
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.xpath("//class[contains(text(), 'Initiator changed to Michael Gao')]"));
//		highlightElement.highLightElement(driver, ele);     
//		String strActual = ele.getText().toString();
//
//			System.out.println("     DEBUG: strExpected = " + strExpected);
//			System.out.println("     DEBUG: strActual   = " + strActual);
//
//		Assert.assertEquals(strActual, strExpected);
//		
//		waitMethods.waiter(waitMethods.w250);
//	    System.out.println("Verify Change Initiator");
//	}

	
	
	
	
	
	
	
	/* TODO for Request
	
	Write Email 				 DONE		
	Print to PDF				 DONE
	Add Bookmark				 DONE 
	Internal use				 DONE
	Change Service				
	Change Initiator			 DONE
	Change Current Step			 ID: newStep-chosen-search-result-37
	Change Form(s)				
	Read access					
	Write access				
	Email recipient test		Will have to be manual

	
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
	
	
	
	

	
	
	
	

	
	
	
	
//		DAMM LINTER
//		waitMethods.waiter(waitMethods.w250);				//
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[1]/div[3]/div/form/div[2]/div/button"));
//		//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[1]/div[2]/div[2]/button")); 
//	    highlightElement.highLightElement(driver, ele);     
//   		waitMethods.waiter(waitMethods.w100);
//	    System.out.println("selected 'Accept Job'");
//	} 



}  //class
	