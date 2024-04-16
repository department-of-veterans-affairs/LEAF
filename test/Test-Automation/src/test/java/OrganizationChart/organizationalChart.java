package test.java.OrganizationChart;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;

import test.java.Framework.setupFramework;
import test.java.Framework.waitMethods;
import test.java.Framework.highlightElement;

public class organizationalChart extends setupFramework {

	
	
	@BeforeMethod
	@BeforeClass
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver();   //   Also have a valid ChromeDriver here
			//System.out.println("Driver established for: " + driver.getClass());
			//driver.manage().timeouts().wait(test.java.Framework.waitMethods.w100);
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
 
//LEAF Demo Organizational Chart  - Academy Demo Site (Test site) | Washington DC
	
	

// TEMPLATE
//	@Test(priority = 3XX) //
//	private void userAccessHeaderHome() {  //change name method here
//		//waitMethods.implicitWait(waitMethods.w300);    
 //		WebElement ele = driver.findElement(By.linkText("Home")); //this is the line I changed
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w1k);
//		driver.navigate().back();    //navigate back
//	    System.out.println("Clicked User Access Header Home button");
//	} 

	
	
// ctrl 7 is delete comments 
	
	@Test(priority = 305) //
	private void clickViewOrgChartButton() {		// method name (can't be two methods with the same name in the same class)
		//waitMethods.implicitWait(waitMethods.w300);  // leave in commented   
		WebElement ele = driver.findElement(By.cssSelector("#bodyarea > div.menu2 > a:nth-child(1) > span"));   //this is the line I changed
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w1k);		
		//driver.navigate().back();
	    System.out.println("Clicked View Organizational Chart button");
	}

		@Test(priority = 307) //
		private void verifyOrgChartButton() {		// method name (can't be two methods with the same name in the same class)
			//waitMethods.implicitWait(waitMethods.w300);  // leave in commented  
			String strExpected = "Network Director";
			waitMethods.waiter(waitMethods.w1k);
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Network Director')]"));   //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    String str = ele.getText().toString();
		    
		    Assert.assertEquals(str, strExpected);
		    
			waitMethods.waiter(waitMethods.w1k);		
			driver.navigate().back();
		    System.out.println("str = " + str);
		}
	
	
	

	@Test(priority = 308) //
	private void clickServiceOrgChartButton() {  
		//waitMethods.implicitWait(waitMethods.w300);    
 		WebElement ele = driver.findElement(By.cssSelector("#bodyarea > div.menu2 > a:nth-child(2) > span")); //this is the line I change
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
	    System.out.println("Clicked Service Org. Chart button");
	} 

	
//	@Test(priority = 311) // *************************************** Fix **********************Ask Max about this**********
//	private void clickExportPDL() {  
//		//waitMethods.implicitWait(waitMethods.w300);    
// 		WebElement ele = driver.findElement(By.cssSelector("#bodyarea > div.menu2 > a:nth-child(3) > span")); //this is the line I change
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//		waitMethods.waiter(waitMethods.w1k);
//		driver.navigate().back();    //navigate back
//	    System.out.println("Clicked Export PDL button"); 
//	} 
	
	@Test(priority = 315) //
	private void clickVacancySummary() {  
		//waitMethods.implicitWait(waitMethods.w300);    
 		WebElement ele = driver.findElement(By.cssSelector("#bodyarea > div.menu2 > a:nth-child(4) > span")); //this is the line I changed
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w1k);
		driver.navigate().back();    //navigate back
	    System.out.println("Clicked Vacancy Summary button");
	}
	
	@Test(priority = 318) // ***********************Ask Max how to enter text in search*******************************************
	private void clickSearch() {  
		//waitMethods.implicitWait(waitMethods.w300);    
 		WebElement ele = driver.findElement(By.cssSelector("#search")); //this is the line change
	    highlightElement.highLightElement(driver, ele);
//	    ele.click();

    	String name = "Steel Beauty";
    	   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
	    
	    waitMethods.waiter(waitMethods.w250);

	    System.out.println("Clicked Search box");
	} 

	// Validate that Steel Beauty is on the page ***********************************
		@Test(priority = 319) //
		private void verifySearchResults() {  //change name method here
			//waitMethods.implicitWait(waitMethods.w300); 
			String searchText="Steel Beauty"; 				
	 		WebElement ele = driver.findElement(By.cssSelector("#grpSel206_grp27 > td > a")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    String foundText="";
		    foundText=ele.getText();
		    System.out.println(">>>>>>>>>>>>> foundText=" +foundText);
		    Assert.assertEquals(foundText, searchText,"Element Found");
			waitMethods.waiter(waitMethods.w3k);
			driver.navigate().back();    //navigate back
		    System.out.println("Verify Search Results");
		} 
	
	
	@Test(priority = 321) //
	private void clickOCAdminPanelButton() {  
		//waitMethods.implicitWait(waitMethods.w300);    
 		WebElement ele = driver.findElement(By.cssSelector("#headerMenu > a")); //this is the line I change
	    highlightElement.highLightElement(driver, ele);
	    ele.click();
		waitMethods.waiter(waitMethods.w1k);
		System.out.println("Clicked OC Admin Panel button");
	}
	
	// ******My test attempts for OC Admin Panel
	@Test(priority = 324) //
	private void clickGroupsButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#maincontent > a:nth-child(1) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			driver.navigate().back();    //navigate back
		    System.out.println("Clicked Groups button");
		}
	
	@Test(priority = 327) //
	private void clickRefreshDirectoryButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#maincontent > a:nth-child(2) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			driver.navigate().back();    //navigate back
		    System.out.println("Clicked Refresh Directory button");
	}
	
	@Test(priority = 330) //
	private void clickSetupWizardButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#maincontent > a:nth-child(3) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			driver.navigate().back();    //navigate back
		    System.out.println("Clicked Setup Wizard button");
	}
	
	// add set up wizard actions here: System admin, Site Preferences, Site director, executive leadership, services
	
	
	@Test(priority = 333) //
	private void clickReportProgrammerButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#maincontent > a:nth-child(4) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			driver.navigate().back();    //navigate back
		    System.out.println("Clicked Report Programmer button");
	}
	
	@Test(priority = 336) //
	private void clickOtherToolsButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#btn_programmerMode")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
		    System.out.println("Clicked Other Tools button");
	}
	
	@Test(priority = 339) //
	private void clickSearchButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#programmerMode > a:nth-child(3) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			driver.navigate().back();
			System.out.println("Clicked Search button");
	}
	
//	Add Search functions here
	
	@Test(priority = 342) //
	private void clickOtherToolsButton111() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#btn_programmerMode")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
		    System.out.println("Clicked Other Tools button");
	}
	
	
	@Test(priority = 345)
	private void clickImportEmployeeButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#programmerMode > a:nth-child(4) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
		    System.out.println("Clicked Import Employee button");
	}
	
	
	@Test(priority = 348) 
	private void clickOrgChartEditorCancelButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#button_cancelchange")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			driver.navigate().back();    //navigate back
		    System.out.println("Clicked Org Chart Editor Cancel button");
	}
	

	@Test(priority = 351) // 
	private void clickSpreadsheetImportButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#programmerMode > a:nth-child(5) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			System.out.println("Clicked Spreadsheet Import button");
	}
	
	@Test(priority = 354) // 
	private void clickOCAdminPanelButton1() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#headerMenu > a:nth-child(2)")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			System.out.println("Clicked OC Admin Panel button");
	}
	
	@Test(priority = 357) 
	private void clickOtherToolsButton2() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#btn_programmerMode")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
		    System.out.println("Clicked Other Tools button");
	}
	
	@Test(priority = 360) 
	private void clickChangeSiteNameButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#programmerMode > a:nth-child(6) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
		    System.out.println("Clicked Change Site Name button");
	}
	
	@Test(priority = 363) // 
	private void clickOCAdminPanelButton11() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#headerMenu > a:nth-child(2)")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			System.out.println("Clicked OC Admin Panel button");
	}
	
//	@Test(priority = 366) // *************** this line was causing the error ********************
//	private void clickUpdateDatabaseButton() throws ElementNotInteractableException {  
//			//waitMethods.implicitWait(waitMethods.w300);    
//	 		WebElement ele = driver.findElement(By.cssSelector("#programmerMode > a:nth-child(7) > span")); //this is the line I changed
//		    highlightElement.highLightElement(driver, ele);
//		    ele.click();
//			waitMethods.waiter(waitMethods.w1k);
//			driver.navigate().back();	
//		    System.out.println("Clicked Update Database button");
//	}
	
	@Test(priority = 369) //
	private void clickOtherToolsButton11() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#btn_programmerMode")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
		    System.out.println("Clicked Other Tools button");
	}
	
	@Test(priority = 372) //
	private void clickUpdateDataBaseButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#programmerMode > a:nth-child(7) > span")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
		    System.out.println("Clicked Update Database button");
	}
	
		
	@Test(priority = 375) //
	private void clickMainPageButton() {  
			//waitMethods.implicitWait(waitMethods.w300);    
	 		WebElement ele = driver.findElement(By.cssSelector("#headerMenu > a:nth-child(1)")); //this is the line I changed
		    highlightElement.highLightElement(driver, ele);
		    ele.click();
			waitMethods.waiter(waitMethods.w1k);
			System.out.println("Clicked Main Page button"); 
	}
	
	// add the tests of the right pink panel here
	// ask Max about how to code the Export PDL section
	
}	
  //class
