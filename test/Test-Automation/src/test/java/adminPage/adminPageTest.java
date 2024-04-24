package test.java.adminPage;

import test.java.Framework.setupFramework_Local;
import test.java.PageObjectClass.AdminTestPageObjects;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import test.java.Framework.waitMethods;


public class adminPageTest extends setupFramework_Local {

	AdminTestPageObjects objAdminUtils;

	@BeforeMethod
	@BeforeClass
	public void setUp() /*throws InterruptedException */ {
		//if(driver.toString().equals(null)) {
		if(driver!= null) {
			driver=getDriver();
			objAdminUtils = new AdminTestPageObjects(driver);

			//	setDriver("chrome","https://localhost/LEAF_Request_Portal/admin");
			//initializeFramework(driver,"https://localhost/LEAF_Request_Portal/admin/");//   Also have a valid ChromeDriver here
			//System.out.println("Driver established for: " + driver.getClass());
			//driver.manage().timeouts().wait(test.java.Framework.waitMethods.w100);
			//chromeLogin("https://localhost/LEAF_Request_Portal/admin");
		}
	}


	@Test(priority = 1) //MUST REMAIN #1 ( or zero) -test for certificate - if no, click Advanced -> Proceed
	private void testForCertPage() /*throws InterruptedException */ {
		try {
			//waitMethods.implicitWait(waitMethods.w300);
	    	waitMethods.waiter(waitMethods.w300);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	//highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w300);

	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost"));
	       // highlightElement.highLightElement(driver, ele2);
	    	ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");


			/*objAdminUtils.waiter(300);
			objAdminUtils.clickDetail();

			objAdminUtils.waiter(300);
			objAdminUtils.clickDetail();*/
			System.out.println("Certificate not found, proceeding to unsecure site");

		} catch (NoSuchElementException e) {
			System.out.println("Certificate present, proceeding ");
		}
	}



	@Test(priority = 30)  //
	public void verifyAdminPageTitle() {
		//waitMethods.implicitWait(waitMethods.w300);
		String pageTitleExpected = "Academy Demo Site(Test site) | Washington DC";
		String pageTitleActual = driver.getTitle();
		Assert.assertEquals(pageTitleActual, pageTitleExpected);
		System.out.println("Page Title Verified");
	}


	@Test(priority = 35) //
	private void adminHeaderHome() {
		//waitMethods.implicitWait(waitMethods.w300);
		//WebElement ele = driver.findElement(By.partialLinkText("Home")); //.click();
		WebElement ele = driver.findElement(By.linkText("Home"));
	  //  highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
	    System.out.println("Clicked Header Home button");

		//waitMethods.implicitWait(waitMethods.w300);
		//objAdminUtils.clickHome();
		//waitMethods.waiter(waitMethods.w1k);
		//driver.navigate().back();    //navigate back
		System.out.println("Clicked Header Home button");

	}


	@Test(priority = 38) //
	private void adminHeaderReportBuilder() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.linkText("Report Builder")); //.click();
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Header ReportBuilder button");*/


		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickReportBuilder();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Header ReportBuilder button");
	}



	@Test(priority = 40) //
	private void adminHeaderSiteLinks() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w500);
		WebElement ele = driver.findElement(By.linkText("Site Links")); //.click();
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w500);
		//driver.navigate().back();    //navigate back
	    System.out.println("Clicked Admin Header Site links button");*/

		waitMethods.waiter(waitMethods.w500);
		objAdminUtils.clickSiteLinks();
		waitMethods.waiter(waitMethods.w500);
		//driver.navigate().back();    //navigate back
		System.out.println("Clicked Admin Header Site links button");
	}



//	///OPENS NEW PAGE ------- FIX NEEDED  ***************************************************
//	@Test(priority = 42) //
//	private void headerNexusLinks() {
//		//waitMethods.implicitWait(waitMethods.w300);
//		waitMethods.waiter(waitMethods.w1k);
//		WebElement ele = driver.findElement(By.linkText("Nexus: Org Charts")); //.click();
//	    //highlightElement.highLightElement(driver, ele);
//	    //ele.click();
//		//waitMethods.waiter(waitMethods.w1k);
//		//driver.navigate().back();    //navigate back
//	    //    System.out.println("Clicked Header Site links button");
//	}



	@Test(priority = 45) //
	private void headerAdminHomeLinks() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.linkText("Admin")); //.click();
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		WebElement ele2 = driver.findElement(By.linkText("Admin Home")); //.click();
	    highlightElement.highLightElement(driver, ele2);
	    ele2.click();   //Should stay on this page
		waitMethods.waiter(waitMethods.w1k);
		//driver.navigate().back();    //navigate back
	         System.out.println("Clicked Header Admin -> Admin Home");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickAdmin();
		objAdminUtils.clickAdminHome();
		waitMethods.waiter(waitMethods.w1k);
		//driver.navigate().back();    //navigate back
		System.out.println("Clicked Header Admin -> Admin Home");
	}


	@Test(priority = 48) //
	private void headerAdminUserAccessGroups() {
		//WebElement ele = driver.findElement(By.linkText("User Access Groups")); //.click();
		/*WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div/a[1]/span[1]")); //.click();
	    //highlightElement.highLightElement(driver, ele);
	    //waitMethods.waiter(waitMethods.w300);
	    ele.click();
	    waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
	         System.out.println("Clicked Header Admin -> User Access -> User Access Groups");*/

		objAdminUtils.clickAdminUserAccessGroup();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Header Admin -> User Access -> User Access Groups");

	}


	////////// Verify Admin Button Links \\\\\\\\\\\\\\\\\


	@Test(priority = 51)
	public void adminUserAccessGroupsLink() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		//WebElement ele = driver.findElement(By.className("leaf-admin-btntitle"));
		WebElement ele = driver.findElement(By.partialLinkText("User Access Groups"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("User Access Groups clicked");*/
		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickUserAccessGroups();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("User Access Groups clicked");
	}



	@Test(priority = 54) //
	private void adminServiceChiefsLabel() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Service Chiefs"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Header Home button");*/
		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickServiceChiefs();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Header Home button");
	}


	@Test(priority = 57) //
	private void adminWorkflowEditorButton() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w300);

		//CORRECT VALUE
		WebElement ele = driver.findElement(By.partialLinkText("Workflow Editor"));

		//INVALID VALUE FOR DEMO (No id for this element)
		//WebElement ele = driver.findElement(By.id("Workflow Editor"));							//******   CORRECT THIS

        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Workflow Editor button");*/


		waitMethods.waiter(waitMethods.w300);
		objAdminUtils.clickWorkflowEditor();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Workflow Editor button");
	}

	@Test(priority = 60) ////////////////////////////////////////
	private void adminFormEditorButton() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Form Editor"));
		highlightElement.highLightElement(driver, ele);
        ele.click();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		driver.navigate().back();    //navigate back         //??????? Not sure why it requires 2?
        System.out.println("Clicked Form Editor button");*/


		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickFormEditor();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		driver.navigate().back();    //navigate back         //??????? Not sure why it requires 2?
		System.out.println("Clicked Form Editor button");
	}


	@Test(priority = 63) //
	private void adminLeafLibraryButton() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Use a form made by the LEAF community"));
		//WebElement ele = driver.findElement(By.partialLinkText("Leaf Library"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Leaf Library button");*/


		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickFormByLEAFcommunity();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Leaf Library button");
	}

	@Test(priority = 66) //
	private void adminSiteSettingsButton() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Site Settings"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Site Settings button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickSiteSettings();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Site Settings button");
	}


	@Test(priority = 67) //
	private void adminReportBuilderButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Create custom reports"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked ReportBuilder button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickCreateCustomReports();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked ReportBuilder button");
	}


	@Test(priority = 70) //
	private void adminTimelineExplorerButtonl() {
		//waitMethods.implicitWait(waitMethods.w300);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Timeline Explorer"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked TimelineExplorer button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickTimelineExplorer();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked TimelineExplorer button");
	}




	@Test(priority = 73) //
	private void adminTemplateEditorButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Template Editor"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Template Editor button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickTemplateEditor();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Template Editor button");
	}


	@Test(priority = 76) //
	private void adminEmailTemplateEditorButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Email Template Editor"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Email Template Editor button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickEmailTemplateEditor();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Email Template Editor button");
	}





	@Test(priority = 79) //
	private void adminLEAFProgrammerButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("LEAF Programmer"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked LEAF Programmer button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickLEAFProgrammer();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked LEAF Programmer button");
	}


	@Test(priority = 82) //
	private void adminFileManagerButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("File Manager"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked File Manager button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickFileManager();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked File Manager button");
	}


	@Test(priority = 85) //
	private void adminSearchDatabaseButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Search Database"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Search Database button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickSearchDatabase();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Search Database button");
	}


	@Test(priority = 88) //
	private void adminSyncServicesButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Sync Services"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Sync Services button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickSyncServices();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Sync Services button");
	}




	@Test(priority = 90) //
	private void adminUpdateDatabaseButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Update Database"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Update Database button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickUpdateDatabase();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Update Database button");
	}


	@Test(priority = 93) //
	private void adminImportSpreadsheetButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Import Spreadsheet"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Import Spreadsheet button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickImportSpreadsheet();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Import Spreadsheet button");
	}




	@Test(priority = 96) //
	private void adminMassActionsButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Mass Actions"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Mass Actions button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickMassActions();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Mass Actions button");
	}


	@Test(priority = 99) //
	private void adminInitiatorNewAccountButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Initiator New Account"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Initiator New Account button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickInitiatorNewAccount();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Initiator New Account button");
	}




	@Test(priority = 102) //
	private void adminSitemapEditorButton() {
		//waitMethods.implicitWait(waitMethods.w3000);
		/*waitMethods.waiter(waitMethods.w1k);
		WebElement ele = driver.findElement(By.partialLinkText("Sitemap Editor"));
        highlightElement.highLightElement(driver, ele);
        ele.click();
        waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
        System.out.println("Clicked Sitemap Editor button");*/

		waitMethods.waiter(waitMethods.w1k);
		objAdminUtils.clickSitemapEditor();
		waitMethods.waiter(waitMethods.w300);
		driver.navigate().back();    //navigate back
		System.out.println("Clicked Sitemap Editor button");
	}




}  //class
