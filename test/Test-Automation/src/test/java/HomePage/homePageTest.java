package test.java.HomePage;

import test.java.Framework.setupFramework_Local;
import test.java.PageObjectClass.*;
import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

import test.java.Framework.waitMethods;

public class homePageTest extends setupFramework_Local {
	private WebDriver driver;

	AdminTestPageObjects objAdminUtils ;
	currentMethods_PageObjects currentMethods ;
	HomePage_PageObjects homePage;

	@BeforeMethod
	@BeforeClass
	public void setUp() /*throws InterruptedException */ {
		driver=getDriver();   //   Also have a valid ChromeDriver here

		objAdminUtils = new AdminTestPageObjects(driver);
		currentMethods = new currentMethods_PageObjects(driver);
		homePage = new HomePage_PageObjects(driver);

	}


	@Test(priority = 1) //MUST REMAIN #1 ( or zero) -test for certificate - if no, click Advanced -> Proceed
	private void testForCertPage() /*throws InterruptedException */ {
	    try {
	    	//waitMethods.implicitWait(waitMethods.w300);
	    	/*waitMethods.waiter(waitMethods.w200);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w200);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); 
	        highlightElement.highLightElement(driver, ele2);
	        ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");*/

			objAdminUtils.clickDetail();
			currentMethods.clickOnLocalHost();
			System.out.println("Certificate not found, proceeding to unsecure site");


		} catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 


//		Academy Demo Site (Test site) | Washington DC | Washington DC]

	@Test(priority = 4)
	public void verifyPageTitle() /*throws InterruptedException */ {         
		System.out.println("Page Title Verified");	
		String pageTitle = driver.getTitle();
		Assert.assertEquals(pageTitle, "Academy Demo Site(Test site) | Washington DC", "Page Title does not match expected value");
		//AssertJUnit.assertEquals(pageTitle, "Academy Demo Site (Test site) | Washington DC");
		//JUnit syntax, which I had to modify anyway because it was of type boolean
	}


	@Test(priority = 6,enabled = false)
	public void selectNewRequest() {
		//waitMethods.implicitWait(waitMethods.w300);
		//waitMethods.waiter(waitMethods.w1k);									//Change to generate an error when demoing
		/*WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[1]/span"));  // For demo:   id("invalidID"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("New Request Button clicked");*/

		homePage.setSelectNewrequest();
		driver.navigate().back();    //navigate back
		System.out.println("New Request Button clicked");

	}
	
	
	@Test(priority = 8)
	public void selectInbox() {         
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[2]/span"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
		System.out.println("Inbox Button clicked");*/

		homePage.selectInbox();
		driver.navigate().back();    //navigate back
		System.out.println("Inbox Button clicked");
	}
	
	
	@Test(priority = 10)
	public void selectBookmarks() {         
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);							//REMOVE
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[3]/span"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
		System.out.println("Bookmarks Button clicked");*/

		homePage.selectBookMarks();
		driver.navigate().back();    //navigate back
		System.out.println("Bookmarks Button clicked");
	}
	
	
	@Test(priority = 12)
	public void selectReportBuilder() {         
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);						//REMOVE
		WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[4]/span"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
		System.out.println("ReportBuilder Button clicked");*/

		homePage.selectReportBuilder();
		driver.navigate().back();    //navigate back
		System.out.println("ReportBuilder Button clicked");
	}

	
	@Test(priority = 13)   
	private void showMoreRecords() /*throws InterruptedException */ {
	        /*WebElement ele = driver.findElement(By.id("searchContainer_getMoreResults")); //.click();
	        highlightElement.highLightElement(driver, ele);
	        //waitMethods.implicitWait(waitMethods.w300);
	        waitMethods.waiter(waitMethods.w1k);
	        ele.click();
	        waitMethods.waiter(waitMethods.w1k);
	        System.out.println("Show more records button click");*/

		homePage.shoMoreRecords();
		System.out.println("Show more records button click");

	} 

	
	@Test(priority = 15)
	public void basicSearchNumber() /*throws InterruptedException */ {
		System.out.println("Perform basic search using Request Number");
		//waitMethods.implicitWait(waitMethods.w300);
    	/*waitMethods.waiter(waitMethods.w1k);    				//REMOVE
    	WebElement ele = driver.findElement(By.cssSelector("[title^='Enter your search text']"));
    	highlightElement.highLightElement(driver, ele);*/

    	String name = "576";
    	//String name = TestData.SB_REQNUM.toString();
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(s);
    		//waitMethods.waiter(waitMethods.w30);

			homePage.EnterBasicSearchNumber(s);
    	}
    	
    	waitMethods.waiter(waitMethods.w500);
    	driver.findElement(By.name("searchtxt")).clear();
		System.out.println("Basic search found or not?");						// Add search of records retrieved
	}

	
	@Test(priority = 20)
	public void basicSearchText() /*throws InterruptedException */ {
		System.out.println("Perform basic search using Text");
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w1k);								//REMOVE
		WebElement ele = driver.findElement(By.name("searchtxt"));

    	String name = "test automation";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		//ele.sendKeys(s);
			homePage.SearchText(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
		
		/*highlightElement.highLightElement(driver, ele);
		waitMethods.waiter(waitMethods.w300);
   	 	driver.findElement(By.name("searchtxt")).clear();
   	 	waitMethods.waiter(waitMethods.w300);*/
			homePage.clearSearch();
	}


	@Test(priority = 25) //Links Dropdown  
	private void linksDropdown() /*throws InterruptedException */ {
	        /*WebElement ele = driver.findElement(By.id("button_showLinks")); //.click();
	        highlightElement.highLightElement(driver, ele);
	        //waitMethods.implicitWait(waitMethods.w300);
	        waitMethods.waiter(waitMethods.w1k);
	        ele.click();
	        waitMethods.waiter(waitMethods.w300);
	        System.out.println("Links test executed");*/

			homePage.linkDropdown();
			System.out.println("Links test executed");

	} 

	@Test(priority = 30) //Help Button Dropdown   
	private void helpDropdown() /*throws InterruptedException */ {
	        /*WebElement ele = driver.findElement(By.id("button_showHelp")); //.click();
	        highlightElement.highLightElement(driver, ele);
	        ele.click();
	        //waitMethods.implicitWait(waitMethods.w300);
	        waitMethods.waiter(waitMethods.w1k);
	        System.out.println("Links test executed");*/

			homePage.helpDropDown();
			System.out.println("Links test executed");

	} 

	

	@Test(priority = 35) //
	private void adminPanelPage() /*throws InterruptedException */ {
			/*WebElement ele = driver.findElement(By.partialLinkText("Admin Panel"));
	        highlightElement.highLightElement(driver, ele);
	        //waitMethods.implicitWait(waitMethods.w300);
	        waitMethods.waiter(waitMethods.w1k);
	        ele.click();
			waitMethods.waiter(waitMethods.w1k);
	        System.out.println("Admin panel clicked");
	        driver.navigate().back();*/

			homePage.adminPanel();
			System.out.println("Admin panel clicked");
			driver.navigate().back();
	}  
	



}  //class
