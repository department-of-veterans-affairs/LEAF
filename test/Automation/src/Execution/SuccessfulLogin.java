package Execution;

import static org.junit.Assert.*;   	//dl from https://sourceforge.net/projects/junit/
										//add external .jar to Java Build Path
import org.junit.Rule;
import org.junit.Test;
import org.openqa.selenium.By;			// have to add to CLASSPATH, not MODULEPATH
import org.openqa.selenium.WebElement;

//import com.smartbear.almcomplete.TestRunResult;		//No reporting through Smartbear

import Framework.*;
import Framework.Controls.CntlsHome;
import Framework.Controls.CntlsLandingPage;
import Framework.Controls.VareCOSSharedMethodsData;

public class SuccessfulLogin extends AUT{
	
	@Rule
	public WriteResultsRule loggError = new WriteResultsRule();
	
	@Test
	public void SuccessfulLogin_Chrome() throws Exception {
		AUT.logger.info("BEGIN SCRIPT ---------------------------------------------------------------------------------");
		String browserName = AUTGlobals.browserChrome;
		
		//Create the results file and db names
		class Local {};
		AUTGlobals.testName = Local.class.getEnclosingMethod().getName();
		AUTGlobals.testResultFileName = createResultsFile();
		
		if (AUTLocal.runChrome) 
			{run_SuccessfulLogin(browserName);}
		else {AUT.run_stub(browserName);}
	}
	
	@Test
	public void SuccessfulLogin_IE() throws Exception {
		AUT.logger.info("BEGIN SCRIPT ---------------------------------------------------------------------------------");
		String browserName = AUTGlobals.browserIE;
		
		//Create the results file and db names
		class Local {};
		AUTGlobals.testName = Local.class.getEnclosingMethod().getName();
		AUTGlobals.testResultFileName = createResultsFile();
		
		if (AUTLocal.runIE) 
			{run_SuccessfulLogin(browserName);}
		else {AUT.run_stub(browserName);}
	}
	
	public void run_SuccessfulLogin(String browserType) throws Exception {

		AUTGlobals.runStub = false;
		
		//Create variables for script
		VareCOSSharedMethodsData expectedeCOSSharedMethodsData = new VareCOSSharedMethodsData();
		
		//Set User Name and Password
		String username = expectedeCOSSharedMethodsData.username;
		String password = expectedeCOSSharedMethodsData.password;
		String branch = expectedeCOSSharedMethodsData.location;
		
		//Open Browser
		//BrowserOpen(AUTConstants.browserType);
		BrowserOpen(browserType);
		logger.info("Open Browser, browserType = " + browserType);
		
		//Navigate to the Login Page
		assertTrue("Unsuccessful navigating to login screen", Login.NavigateToLoginScreen());
		logger.info("Login Screen Displayed");
		
		//Login to eCOS
		Thread.sleep(1000);
		assertTrue("Login was unsuccessful for user" + username + " and password " + password, Login.LoginAs(username, password));
		logger.info("Logged in as user");
		
		//Verify the Home Page Displays
		Thread.sleep(1000);
		assertTrue("Home Page did not open successfully", Home.accessHomePage());
		
//------//Verify Branch location from expectedeCOSSharedMethodsData.location
		assertTrue("Branch Selection failed", Home.selectBranch(branch));
		logger.info("Selected Branch");
		
//------//Verify the Branch one time for all scripts (was in every script before - RCB 10/21/15)
		//Split this out of the method "selectBranch" that was in every script before
		assertTrue("Branch breadcrumb check failed", Home.checkBranchBreadcrumb(branch));
		logger.info("Checked Branch breadcrumb passed");		
		
		//Logout (manual processes here that are done in Home.logOut() without asserts)
		//Assert some element that should be on the main page
		//the branch combo box is common to all screens.
		assertTrue(FrameworkProcedures.isElementPresentID(CntlsHome.iLocationComboBoxID));
		
		//click logout button
		AUT.Browser.findElement(By.id(CntlsHome.iLogoutButton)).click();
		AUT.logger.info("LogOut button clicked.");
		
		//"Are you sure" dialog
		//verify the "Are you sure" text
		FrameworkProcedures.waitForElementPresentXPath(CntlsHome.xlogoutAlertTextLocator, 5);
		//...this works below the passed in locator, so is it even working?, is the //* inclusive?
		try {assertTrue(FrameworkProcedures.isTextPresentX("//form", "Are you sure you would like to Sign Out of inMotion?", true));} catch (Throwable t){AUTGlobals.VE.append(FrameworkProcedures.filterST(t)); }
	    
		WebElement logoutYes = FrameworkProcedures.getDisplayedElement(CntlsHome.xlogoutYES, 1);
		//click the "Yes" button
		logoutYes.click();
		AUT.logger.info("Log Out Alert 'Are you sure, YES'  clicked.");
		
		//right here there is sometimes an alert in IE asking to update controls
		Thread.sleep(500);
		try {
			AUT.Browser.switchTo().alert().accept();
			AUT.logger.info("Needed to Accept the Alert.");
		} catch (Exception e) {}
		
		//assert that we are back to the eCOS main page
		try {FrameworkProcedures.waitForElementID(CntlsLandingPage.iInMotionMainPanelbody, 3);} catch (Throwable t){AUTGlobals.VE.append(FrameworkProcedures.filterST(t)); }
		
		//verify that the "Are you sure" text is gone. Moved to SuccessfulLogin.
		//This is taking too long, hurting demos, removed Dec 3, 2015. jwa
		//try {assertFalse(FrameworkProcedures.isTextPresentX("//form", "Are you sure you would like to Sign Out of inMotion?"));} catch (Throwable t){AUTGlobals.VE.append(FrameworkProcedures.filterST(t)); }
		
		//Log if the element that was found earlier is gone
		if (!FrameworkProcedures.isElementPresentID(CntlsHome.iLocationComboBoxID)){
			AUT.logger.info("Successfully returned to eCOS main page.");
		} else {
			AUT.logger.info("DID NOT return to eCOS main page.");
		}
			
	}

}
