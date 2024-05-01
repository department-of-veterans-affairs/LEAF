//package test.java.OrganizationChart;
//
//import test.java.PageObjectClass.*;
//import org.testng.annotations.Test;
//import org.testng.annotations.BeforeMethod;
//
//import java.util.Date;
//
//import org.openqa.selenium.By;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.NoSuchElementException;
//import org.testng.Assert;
//import org.testng.annotations.BeforeClass;
//
//import test.java.Framework.setupFramework;
//import test.java.Framework.highlightElement;
//
//public class orgChartWorkflow extends setupFramework {
//
//	//private static final DateFormat Calendar = null;
//	Date date = new Date();
//
//	test.java.PageObjectClass.AdminTestPageObjects objAdminUtils = new test.java.PageObjectClass.AdminTestPageObjects(getDriver());
//	adminUserAccess_PageObjects userAccess = new adminUserAccess_PageObjects(getDriver());
//	main.java.pageActions.formsWorkFlow_PageObjects formworkflow = new main.java.pageActions.formsWorkFlow_PageObjects(driver);
//	currentMethods_PageObjects currentMethods = new currentMethods_PageObjects(driver);
//	HomePage_PageObjects homePage = new HomePage_PageObjects(driver);
//
//	@BeforeMethod
//	@BeforeClass
//	public void setUp()  {
//		if(driver!= null) {
//			driver=getDriver();   //   Also have a valid ChromeDriver here
//			//System.out.println("Driver established for: " + driver.getClass());
//			//driver.manage().timeouts().wait(test.java.Framework.waitMethods.w100);
//		}
//	}
//
//
//	//Cert test in the event this is starting page for tests
//	@Test(priority = 1) //MUST REMAIN #1 ( or zero)
//	private void testForCertPage() /*throws InterruptedException */ {
//	    try {
//	    	//waitMethods.implicitWait(waitMethods.w300);
//	    	/*waitMethods.waiter(waitMethods.w300);
//	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
//	    	highlightElement.highLightElement(driver, ele);
//	    	ele.click();
//
//	    	waitMethods.waiter(waitMethods.w300);
//
//	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost"));
//	        highlightElement.highLightElement(driver, ele2);
//	    	ele2.click();
//	        System.out.println("Certificate not found, proceeding to unsecure site");*/
//
//			objAdminUtils.clickDetail();
//			currentMethods.clickOnLocalHost();
//			System.out.println("Certificate not found, proceeding to unsecure site");
//
//		} catch (NoSuchElementException e) {
//	        System.out.println("Certificate present, proceeding ");
//	    }
//	}
//
////create New Request Workflow
//
//	@Test(priority = 102) //
//	private void searchByEmployee() {
//		/*waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("search"));
//    	highlightElement.highLightElement(driver, ele);*/
//
//    	String name = "Scott Wagner";
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		//ele.sendKeys(s);
//			homePage.SearchText(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//
//    	//driver.findElement(By.id("search")).clear();
//    	///System.out.println("Search By Employee");
//
//		homePage.clearSearch();
//	}
//
//
//	// How is this test a valid or Dynamic Test
//	@Test(priority = 104) //
//	public void verifySearchByEmployee() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.partialLinkText("Wagner"));
//		highlightElement.highLightElement(driver, ele);
//		String verify = ele.toString();
//		System.out.println(verify);
//		Assert.assertTrue(ele.toString().contains("Wagner"));
//		waitMethods.waiter(waitMethods.w300);
//		System.out.println("Search for employee name on page");
//	}
//
//
//	@Test(priority = 106) //
//	private void searchByPosition() {
//		waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("search"));
//    	highlightElement.highLightElement(driver, ele);
//
//    	String name = "Accountability Officer";
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(Keys.chord(name));
//    		//ele.sendKeys(s);
//
//			homePage.SearchText(s);
//			waitMethods.waiter(waitMethods.w30);
//    	}
//
//    	//driver.findElement(By.id("search")).clear();
//    	//System.out.println("Search By Position");
//
//		homePage.clearSearch();
//		System.out.println("Search By Position");
//
//	}
//
//
//
//	@Test(priority = 108) //STILL FAILING???    TODO:
//	public void verifySearchByPosition() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.partialLinkText("Accountability"));
//		highlightElement.highLightElement(driver, ele);
//		String verify = ele.toString();
//		System.out.println(verify);
//		Assert.assertTrue(ele.toString().contains("Accountability"));
//
//		waitMethods.waiter(waitMethods.w250);
//		System.out.println("Verify search by Position on page");
//	}
//
//
//	@Test(priority = 110) //
//	private void searchByGroup() {
//		/*waitMethods.waiter(waitMethods.w300);
//		WebElement ele = driver.findElement(By.id("search"));
//    	highlightElement.highLightElement(driver, ele);*/
//
//    	String name = "ADPAC";
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(s);
//			homePage.SearchText(s);
//    		waitMethods.waiter(waitMethods.w30);
//    	}
//
//    	//driver.findElement(By.id("search")).clear();
//    	//System.out.println("Search By Group");
//
//		homePage.clearSearch();
//		System.out.println("Search By Group");
//
//	}
//
//
//
//	@Test(priority = 112) //
//	public void verifySearchByGroup() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.partialLinkText("ADPAC"));
//		highlightElement.highLightElement(driver, ele);
//		String verify = ele.toString();
//		System.out.println(verify);
//		Assert.assertTrue(ele.toString().contains("ADPAC"));
//
//		waitMethods.waiter(waitMethods.w250);
//		System.out.println("Verify search by Group on page");
//	}
//
//
//	@Test(priority = 114) //
//	private void searchByServices() {
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.id("search"));
//    	highlightElement.highLightElement(driver, ele);
//
//    	String name = "Office of GEC";
//
//    	for(int i = 0; i < name.length(); i++) {
//    		char c = name.charAt(i);
//    		String s = new StringBuilder().append(c).toString();
//    		//ele.sendKeys(s);
//    		waitMethods.waiter(waitMethods.w30);
//			homePage.SearchText(s);
//    	}
//
//    	driver.findElement(By.id("search")).clear();
//    	System.out.println("Search By Service");
//
//		homePage.clearSearch();
//	}
//
//
//
//	@Test(priority = 116) //
//	public void verifySearchByService() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.partialLinkText("Office of GEC"));
//		highlightElement.highLightElement(driver, ele);
//		String verify = ele.toString();
//		System.out.println(verify);
//		Assert.assertTrue(ele.toString().contains("Office of GEC"));
//
//		waitMethods.waiter(waitMethods.w250);
//		System.out.println("Verify search by Services on page");
//	}
//
//
//
//
//}  //class
//