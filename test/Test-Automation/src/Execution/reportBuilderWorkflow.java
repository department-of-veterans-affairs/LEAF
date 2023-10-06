package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.AssertJUnit;
import org.testng.asserts.*;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

import Framework.TestData;
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;

public class reportBuilderWorkflow extends setupFramework {

	//private static final DateFormat Calendar = null;
	Date date = new Date();
	
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
 
// Report Builder Workflow
	
	@Test(priority = 102) //
	private void clickReportBuilder() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("//*[text()='Report Builder']"));
		// Alternatively:  WebElement ele = driver.findElement(By.xpath("//*[@id=\"bodyarea\"]/div[1]/a[4]/span"));
    	highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder clicked from home page");
	}
    	

	

	/*    Filter selections
		104				TITLE		CONTAINS	"test"
		106		AND		
		108				Service		IS			Acute Care (DDL)
		110		OR
		112				Service		
		114							Is			Facilities (DDL)			
		116		AND		
		118				Initiator	Is			
		120										"Tester Tester"
		122		AND
		124				Current Status
		126							Is NOT
											(Default of Submitted
		128		Select Next Step
	*/

	
	


	
	@Test(priority = 104) //
	private void inputTextBox01() {
		waitMethods.waiter(waitMethods.w300);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[1]/td[5]/input"));
    	highlightElement.highLightElement(driver, ele);
    	waitMethods.waiter(waitMethods.w250);
    	
    	String name = "test";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
    	
    	System.out.println("Input text to first textbox");			
	}

	
	@Test(priority = 106) //  1st And
	private void selectAnd01() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[2]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder clicked first 'and' button");
	}


		
	
	@Test(priority = 108) //
	public void clickServiceButton02() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[2]/td[3]/div/a"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w200); //		Service - Acute Care
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[2]/td[3]/div/div/ul/li[2]"));
		highlightElement.highLightElement(driver, ele2);
		ele2.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Clicked on Service Button Row 2");
	}

	
	@Test(priority = 110) //  1st OR
	private void selectOr01() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[3]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder clicked first 'OR' button");
	}

	@Test(priority = 112) //
	public void inputTextBox03() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[3]/td[3]/div/a"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w200);		// Service = Facilities
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[3]/td[3]/div/div/ul/li[2]"));
		highlightElement.highLightElement(driver, ele2);
		ele2.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Clicked on Service Button Row 3");
	}
	
	
	@Test(priority = 114) //
	public void clickServiceButton03() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[3]/td[5]/div/a"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w200);
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[3]/td[5]/div/div/ul/li[6]"));
		highlightElement.highLightElement(driver, ele2);
		ele2.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Selected Facilities Row 3");
	}

	
	@Test(priority = 116) //  2nd And
	private void selectAnd02() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[2]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder clicked second 'and' button");
	}
	
	
	@Test(priority = 118) //
	public void clickTypeButton01() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w300);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[4]/td[3]/div/a"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w200);				//Select Initiator
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[4]/td[3]/div/div/ul/li[5]"));
		//WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[4]/td[3]/div/div/ul/li[4]"));
		highlightElement.highLightElement(driver, ele2);
		ele2.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Selected Initiator");
	}
	
	
	@Test(priority = 120) //
	private void inputTextBox04() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[4]/td[5]/div/div[1]/input"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "tester tester";
    	//String name = "Merry, Vittoria";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
    	
    	System.out.println("Input user name - Tester Testers");			
	}

	
	@Test(priority = 122) //  3rd And
	private void selectAnd03() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[2]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder clicked third 'and' button");
	}

	
	@Test(priority = 124) //
	public void clickTypeButton02() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);			//The below opens the DDL - Current Status
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[5]/td[3]/div/a"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w200);			//Current Status   		
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[5]/td[3]/div/div/ul/li[7]"));
		highlightElement.highLightElement(driver, ele2);
		ele2.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Selected Current Status");
	}

	
	
	@Test(priority = 126) //
	public void clickIsNot() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[5]/td[4]/div/a"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w200);	//     Select - IS NOT		
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[5]/td[4]/div/div/ul/li[2]"));
		highlightElement.highLightElement(driver, ele2);
		ele2.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Selected IS NOT");
	}

	
	@Test(priority = 128) //  
	private void selectNextStep() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[4]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Select Next Step");
	}


	
	@Test(priority = 130) //  
	private void selectCheckboxService() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[2]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Service");
	}

	
	@Test(priority = 132) //  
	private void selectCheckboxRequestType() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[3]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Type of Request");
	}
	

	
	@Test(priority = 134) //  
	private void selectCheckboxCurrentStatus() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[4]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Current Status");
	}


	
	@Test(priority = 136) //  
	private void selectCheckboxInitiator() {
		//driver.manage().timeouts().implicitlyWait(250, TimeUnit.MILLISECONDS);
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[5]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Initiator");
	}


	
	@Test(priority = 138) //  
	private void selectCheckboxActionButton() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[6]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Action Button");
	}


	
	@Test(priority = 140) //  
	private void selectCheckboxCommentHistory() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[7]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Comment History");
	}


	@Test(priority = 142) //  
	private void selectCheckboxApprovalHistory() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[8]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Approval History");
	}


	
	@Test(priority = 144) //  
	private void selectCheckboxLastAction() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[9]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Last Action Days");
	}


	
	@Test(priority = 146) //  
	private void selectCheckboxLastMovement() {
		waitMethods.waiter(waitMethods.w200);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div[10]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		//waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for Last Movement Days");
	}



		
	@Test(priority = 148) 						//     
	private void selectCheckboxMRTest() {
		waitMethods.waiter(waitMethods.w400);       

			JavascriptExecutor js = (JavascriptExecutor) driver;
			js.executeScript("window.scrollBy(0,300)", "");
		
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'MR - Test')]"));
		//WebElement ele = driver.findElement(By.xpath("//*[@id=\"indicatorList\"]/div[2]/div[4]/div[1]"));
		
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder checkbox for MR - Test");
	}


	@Test(priority = 150) // FREQUENCY 
	private void selectMRTestField1() {
		waitMethods.waiter(waitMethods.w250);         
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Frequency')]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Frequency checkbox for MR - Test selected");
	}


	@Test(priority = 152) // Middle Initial 
	private void selectMRTestField2() {
		waitMethods.waiter(waitMethods.w250);         // 
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Middle Initial')]"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[2]/div[4]/div[3]/div"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w250);
    	System.out.println("Middle Initial checkbox for  MR - Test selected");
	}

	
	
	
	@Test(priority = 154) // Name 		TODO: Err here		//Cannot find by text()   //*[contains(text(),'Name')]???
	private void selectMRTestField3() {
		waitMethods.waiter(waitMethods.w750);     //      
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[2]/div[14]/div[4]/div"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[2]/div[4]/div[4]/div"));
		
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w250);
    	System.out.println("Name checkbox for  MR - Test selected");
	}

	
	
	
	
	@Test(priority = 156) //  
	private void selectGenerateReport() {  //Generate Report
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.id("generateReport"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - Generate Report");
	}

	
	
	@Test(priority = 158) //
	private void inputReportName() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.id("reportTitle"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Test Report - Max";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
    	
    	System.out.println("Input Report Name");			
	}
	
	
	@Test(priority = 160) //  
	private void selectModifyReport() {  //Generate Report
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.id("editReport"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w100);
    	System.out.println("Report Builder - Modify Report");
	}
	
	
	@Test(priority = 162) //  
	private void removeInitiator() {  //Delete Initiator - Tester Tester
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[4]/td[1]/button"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - Remove/Delete initiator");
	}
	

	@Test(priority = 164) //  2nd OR
	private void selectOr02() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[3]"));
		//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[3]"));
		
		
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder clicked first 'OR' button");
	}
	
//	@Test(priority = 164) //  4th And
//	private void selectAnd04() {
//		waitMethods.waiter(waitMethods.w250);       
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[2]"));
//		highlightElement.highLightElement(driver, ele);
//   		ele.click();
//		waitMethods.waiter(waitMethods.w200);
//    	System.out.println("Report Builder clicked fourth 'and' button");
//	}

	
	@Test(priority = 166) //
	public void clickTypeButton03() {         
		//waitMethods.implicitWait(waitMethods.w300);
		waitMethods.waiter(waitMethods.w250);			//The below opens the DDL
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[5]/td[3]/div/a"));
		highlightElement.highLightElement(driver, ele);
		ele.click();
		waitMethods.waiter(waitMethods.w200);				//Select Initiator
		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[5]/td[3]/div/div/ul/li[5]"));
		highlightElement.highLightElement(driver, ele2);
		ele2.click();
		waitMethods.waiter(waitMethods.w250);
		System.out.println("Selected Initiator");
	}
	
	
	@Test(priority = 168) //
	private void inputTextBox05() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/table/tr[5]/td[5]/div/div[1]/input"));
    	highlightElement.highLightElement(driver, ele);
    	
    	String name = "Michael Gao";
   
    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		//ele.sendKeys(Keys.chord(name));
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}
    	
    	System.out.println("Input user name - M. Gao");			
	}
	
//======================= Selecting Buttons on Report View Page ==================================	
	
		
	
	@Test(priority = 170) //  
	private void selectNextStep02() {
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[1]/div[2]/div/div[1]/fieldset/button[4]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Select Next Step");
	}
	
	
	@Test(priority = 172) //  
	private void selectGenerateReport02() {  //Generate Report
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.id("generateReport"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - Generate Report");
	}
	
	
	@Test(priority = 174) //  
	private void selectEditLabels() {  
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.id("editLabels"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - Edit Labels");
	}
	
	
	/*
	 *    There were no labels to change... Come back to here
	 */
	
	
		@Test(priority = 176) //
		private void saveEditLabels() {  			
			waitMethods.waiter(waitMethods.w250);     
			WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[1]/button/span[1]"));
			//WebElement ele = driver.findElement(By.id("button_save"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w200);
	    	System.out.println("Report Builder - Save Edit Labels");
		}

	
	
	@Test(priority = 178) //  
	private void selectShareReport() {  
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[4]/div[1]/div[1]/div/button[3]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - Share Report");
	}
	
	
		@Test(priority = 180) //  
		private void clickEmailReport() {  
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.id("prepareEmail"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w200);
	    	System.out.println("Report Builder - Email Report");
		}

		
	
	/* Need to find a way to validate that an Outlook email has opened */
		
		@Test(priority = 182) //  
		private void closeEmailDialogue() {  
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[1]/button/span[1]"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w200);
	    	System.out.println("Report Builder - Close Email Dialogue");
		}
		
		
	@Test(priority = 184) //  
	private void selectExportReport() {  
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[4]/div[1]/div[1]/div/button[4]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - Export Report");
	}
		
		
	/* Need to find a way to validate that file has downloaded as .csv */

	
	@Test(priority = 186) //  
	private void selectJSON() {  
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[4]/div[1]/div[1]/div/button[5]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - JSON");
	}


	
	@Test(priority = 188) //  
	private void jsonShortenLink() {  
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.id("shortenLink"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - JSON Shorten Link");
	}


	@Test(priority = 190) //  
	private void jsonCloseForm() {  
		waitMethods.waiter(waitMethods.w250);       
		WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[1]/button/span[1]"));
		highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w200);
    	System.out.println("Report Builder - JSON Close Formx");
	}



}  //class 
	