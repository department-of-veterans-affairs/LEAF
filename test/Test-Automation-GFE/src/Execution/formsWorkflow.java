package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import java.util.Date;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.openqa.selenium.support.ui.Select;			//Select Method

import Framework.AppVariables;
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;
import Framework.dateAndTimeMethods;
//import Framework.utilities;

public class formsWorkflow extends setupFramework {

	//private static final DateFormat Calendar = null;
	Date date = new Date();
	
	
	@BeforeMethod
	@BeforeClass
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver();   //   Also have a valid ChromeDriver here
		}
	}
	

	//Cert test in the event this is starting page for tests
	@Test(priority = 1) //MUST REMAIN #1 ( or zero)
	private void testForCertPage() /*throws InterruptedException */ {

	/*
		TODO:
		Search for text on the 'no cert' page
		Use an if to determine whether to run this
				*/			
		
		try {
	    	//waitMethods.implicitWait(waitMethods.w500);
	    	waitMethods.waiter(waitMethods.w500);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w500);
	    	
	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); 
	        highlightElement.highLightElement(driver, ele2);
	    	ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    } 
	} 
 
/////////////////////////////     Forms Workflow      \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
		public void testURL() {
			String url = driver.getCurrentUrl();
			System.out.println("Current URL: " + url);
		}

		
		
		@Test(priority = 90) //
		private void clickCreateForm() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("createFormButton"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms - clicked Create Form");
	    	System.out.println();
	    	
		}
		
		
		@Test(priority = 92) //
		private void inputFormLabel() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("name"));
	    	//highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Delete Me";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		//ele.sendKeys(Keys.chord(name));
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	//driver.findElement(By.id("search")).clear();
	    	System.out.println("Input Form Label");			
		}
	
	
		@Test(priority = 94) //
		private void inputFormDesc() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("description"));
	    	//highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Delete Me " + dateAndTimeMethods.getDate().toString();
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Populate Form Description");			
		}
		
		
		
		@Test(priority = 96) //  
		private void selectSave() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms - clicked Save");
		}		
				
		
		@Test(priority = 98) //  Delete this form
		private void deleteForm() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),' Delete this form')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms - Delete Form");
		}
	
		
		
		@Test(priority = 100) //  Confirm Delete
		private void confirmDeleteForm() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("confirm_button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms - Confirm Delete Form");
		}
		
		//////   End Delete Form    \\\\\
	
		

		@Test(priority = 102) //
		private void clickCreateForm02() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("createFormButton"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms - clicked Create Form");
		}
		
		
		@Test(priority = 104) //
		private void inputFormLabel02() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("name"));
	    	//highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Automation Test Form";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		//ele.sendKeys(Keys.chord(name));
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	//driver.findElement(By.id("search")).clear();
	    	System.out.println("Input Form Label");			
		}


		@Test(priority = 106) //
		private void inputFormDesc02() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("description"));
	    	//highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Automation Test Description " + dateAndTimeMethods.getDate().toString();
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Populate Form Description");			
		}
		
		
		@Test(priority = 108) //
		private void selectCancel() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_cancelchange"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms - clicked Cancel");
		}


		@Test(priority = 110) //
		private void clickCreateForm03() {
			clickCreateForm();
			System.out.println("Forms - clicked Create Form");
		}
		
		
		@Test(priority = 112) //
		private void inputFormLabel03() {
			inputFormLabel02();
			System.out.println("Input Form Label");			
		}


		@Test(priority = 114) //
		private void inputFormDesc03() {
			inputFormDesc02();
			System.out.println("Populate Form Description");			
		}
		
		
		@Test(priority = 116) //
		private void selectSave01() {
			selectSave();
		}

	////// Form Created w Title: Automation Test Description + dateAndTimeMethods.getDate().toString();
		 
		
		@Test(priority = 118) //  These Properties will be cancelled
		private void selectEditProperties() {
			waitMethods.waiter(waitMethods.w500);       
			//WebElement ele = driver.findElement(By.xpath("//*[text()='Edit Properties']"));
			WebElement ele = driver.findElement(By.id("editFormData"));
 	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms - clicked Edit Properties");
		}

		
		/*
		 * 
		 * 
		 * 		NEED TO RECREATE A WORKFLOW --
		 * 
		 * 
		 * */
		
		
		
		
		
		
		@Test(priority = 120) //	
		public void selectWorkflow() {         
			//waitMethods.implicitWait(waitMethods.w500);
			waitMethods.waiter(waitMethods.w1k);			//The below opens the DDL
			String url = driver.getCurrentUrl();
			WebElement ele = driver.findElement(By.id("workflowID"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
				Select select = new Select(driver.findElement(By.id("workflowID")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("92");			//Was #92 for PROD, #78 for Pre-Prod, but now #92 for both
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
				Select select = new Select(driver.findElement(By.id("workflowID")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("92");			//Was #92 for PROD, #78 for Pre-Prod, but now #92 for both
			}
			
			waitMethods.waiter(waitMethods.w500);
			WebElement ele2 = driver.findElement(By.id("workflowID"));
			ele2.click();
			System.out.println("Forms-Selected Workflow");
		}
		

			
		@Test(priority = 122) //    Test Cancel button
		private void selectCancelChange() {			// Leaving Blank for now
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_cancelchange"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Selected Cancel (Properties)");
		}
		
		
		@Test(priority = 124) //
		private void selectEditProperties2() {
			selectEditProperties();
		}

		
		@Test(priority = 126) //
		public void selectWorkflow2() {         
			selectWorkflow();
		}
		
		
		
		@Test(priority = 128) //
		public void selectNeedToKnow() {         
			//waitMethods.implicitWait(waitMethods.w500);
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("needToKnow"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("needToKnow")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("0");
			waitMethods.waiter(waitMethods.w200);	//Closes the DDL
			WebElement ele2 = driver.findElement(By.id("needToKnow"));
			ele2.click();
			System.out.println("Forms-Selected Need to Know");
		}


		
		@Test(priority = 130) //
		public void selectAvailability() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w500);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("visible"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("visible")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("1");
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("visible"));
			ele2.click();
			System.out.println("Forms-Selected Availability");
		}

		

		
		@Test(priority = 132) //  Accepts pos & neg integers 
		private void selectSortPriority() {			// Leaving Blank for now
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("0");
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms-Selected Sort Priority");
		}
		
		
		@Test(priority = 134) //
		public void selectType() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("formType"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("formType")));
			highlightElement.highLightElement(driver, ele);
			//select.selectByValue("Standard");		
			select.selectByIndex(0);			//0= Standard; 1=Parallel Processing   (I suppose??)
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("formType"));
			ele2.click();
			System.out.println("Forms-Selected Type");
		}

		
		
/*		
 		 		
 		
 		Need to come back and add: 
 		- Pete's test for Parallel Processing
		Index: 1=Parallel Process

			
*/		
		
		
		@Test(priority = 136) //  
		private void selectSaveProperties() {	
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms-Selected Save (Properties)");
		}

		
		@Test(priority = 138) //  
		private void selectEditCollaborators() {	
			waitMethods.waiter(waitMethods.w1k);       
			WebElement ele = driver.findElement(By.id("editFormPermissions"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w100);
	    	System.out.println("Forms-Selected Edit Collaborators)");
		}

		
		
		@Test(priority = 140) //  
		private void selectAddGroup() {	
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.xpath("//*[text()='Add Group']"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w100);
	    	System.out.println("Forms-Selected Add Group)");
		}
		
		
		@Test(priority = 142) //  
		private void selectAddCollaborators() {	
			waitMethods.waiter(waitMethods.w750);       
			WebElement ele = driver.findElement(By.id("groupID"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Forms-Selected Add Collaborators)");
			Select select = new Select(driver.findElement(By.id("groupID")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("54");
			waitMethods.waiter(waitMethods.w500);
			WebElement ele2 = driver.findElement(By.id("groupID"));
			ele2.click();
			System.out.println("Forms-Selected CPAC Exec 1");
		}
		
		
		@Test(priority = 144) //  
		private void selectSaveCollaborators() {	
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms-Selected Save Collaborators)");
		}
		
			
		
		@Test(priority = 146) //  
		private void closeCollaborators() {	
			waitMethods.waiter(waitMethods.w500);     //       
			String url = driver.getCurrentUrl();
			System.out.println("Current URL: " + url.substring(0, 20));
			System.out.println("Prod Domain: " + AppVariables.PROD_DOMAIN); 
			
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   //   
				WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[1]/button/span[1]"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {  //  
				WebElement ele = driver.findElement(By.xpath("/html/body/div[6]/div[1]/button/span[1]"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
			}
			
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Forms-Selected Close Collaborators)");
		}

		
		@Test(priority = 148) // 
		private void selectEditCollaborators2() {	
			waitMethods.waiter(waitMethods.w500);
			selectEditCollaborators();
		}
		

		
		@Test(priority = 150) //  
		private void selectRemoveCollaborators() {	
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.linkText("Remove"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Forms-Selected Remove Collaborators)");
		}
		
		
		@Test(priority = 152) //  
		private void selectAddGroup2() {	
			selectAddGroup();
		}
		
		

		@Test(priority = 154) //  
		private void selectAddCollaborators2() {	
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("groupID"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Forms-Selected Add Collaborators)");
			Select select = new Select(driver.findElement(By.id("groupID")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("16");
			waitMethods.waiter(waitMethods.w500);
			WebElement ele2 = driver.findElement(By.id("groupID"));
			ele2.click();
			System.out.println("Forms-Selected Approval Group (Washington DC)");
		}
	
		
		
		@Test(priority = 156) //  
		private void selectSaveCollaborators02() {	
			selectSaveCollaborators();
		}
			
		
		
		@Test(priority = 158) // 
		private void closeCollaborators02() {	
			closeCollaborators();
		}	
		
	
	//////// Adding New Question  \\\\\\\\     

	
		@Test(priority = 160) //  
		private void selectAddSectionHeading01() {			//Will reuse this to add all field types
			waitMethods.waiter(waitMethods.w500);       	 
			WebElement ele = driver.findElement(By.cssSelector("#formEditor_form > div > div.buttonNorm"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: +Add Section Heading)");
		}
		
		

		
		@Test(priority = 162) //
		private void inputFieldName01() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Test Q1 Single line text";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Question: Single line text)");			
		}
		

		
		@Test(priority = 164) //
		private void inputShortLabel01() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q1";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Question: Short Label)");			
		}

		

		@Test(priority = 168) //
		public void selectSingleLineText01() {         
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("indicatorType"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w500);
			Select select = new Select(driver.findElement(By.id("indicatorType")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("text");
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("indicatorType"));
			ele2.click();
			System.out.println("Test Question: Single Line Text");
		}
		
		
		@Test(priority = 170) //  
		private void selectQuestionCancel() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_cancelchange"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Cancel button");
		}
		
		
		@Test(priority = 172) //  
		private void selectAddSectionHeading01R() {	
			selectAddSectionHeading01();
		}
		
		
		@Test(priority = 174) //
		private void inputFieldName01R() {
			inputFieldName01();
		}
		
		
		@Test(priority = 176) //
		private void inputShortLabel01R() {
			inputShortLabel01();
		}
		
		
		@Test(priority = 178) //
		public void selectSingleLineText01R() {
			selectSingleLineText01();
		}

		

		@Test(priority = 180) //
		private void inputDefaultAnswer01() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "MR Test Default Response Q1";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Question: input Default Answer");			
		}
		
		
		@Test(priority = 182) //  
		private void selectFieldRequired01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("required"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Field Required = Y");
		}
		
		
		@Test(priority = 184) //  
		private void selectFieldSensitiveData01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("sensitive"));
	    	highlightElement.highLightElement(driver, ele);
	   		//ele.click();
	   		//waitMethods.waiter(waitMethods.w500);
	   		//ele.click();
	    	//waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Sensitive Data = N");
		}
		
		
		
		@Test(priority = 186) //  
		private void selectSortValue01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("1");
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Sort Priority");
		}
		
		
		@Test(priority = 188) //  
		private void selectQuestionSave01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Test Question: Save button");
		}

		
		
		@Test(priority = 190) //									
		private void selectEditFieldIcon() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Test Q1 Single line text')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);	
	    	System.out.println("Test Question: Edit Field Icon");
		}
		
		
		@Test(priority = 192) //								
		private void editDefaultAnswer01() {  //			
			waitMethods.waiter(waitMethods.w1k);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	ele.clear();
	    	
	    	String name = "Test Default";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Question: Edit Default Answer");			
		}
		
	
		
		@Test(priority = 194) //						//PERMISSION Issues - Resolved for Pre-Prod, PROD needs to be fixed 			
		private void selectAdvancedOptions01() {			
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_advanced"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Select Advanced Options");
		}
		
		
	/*		
	TODO:		
			Advanced Formatting:		id=  advNameEditor
			
		  	Required:					id=  required
		  	Sensitive:					id=  sensitive
			Sort Priority: 				id=  sort
			Parent Question ID:			id=	 Different for each

			
			Save:						id=  button_save
			Cancel:						id=  button_cancelchange
			Advanced Options			id = button_advanced
		
	*/	
	
	
		

		
		
		
	//		@Test(priority = 196) //						//  In test in class TestHTMLBox
	//		private void inputHTMLEditData() {			
	//			waitMethods.waiter(waitMethods.w500);       
	//			WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div/fieldset/div[1]/div[6]/div[1]/div"));
	//			String strHTML = "HTML Text Here";
	//			//String strHTML = "<button id=\"button_save\" class=\"usa-button leaf-btn-med\" style=\"border: 2px solid white; "
	//			//		+ "visibility: visible;\">\r\n"
	//			//		+ "                        Save\r\n"
	//			//		+ "                    </button>";
	//	    	highlightElement.highLightElement(driver, ele);
	//	   		ele.sendKeys(strHTML);
	//			//waitMethods.waiter(waitMethods.w500);	
	//	    	System.out.println("Input HTML-Edit Data");
	//		}

		
		


		@Test(priority = 198) //						//  			
		private void selectSaveCode01a() {			
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("btn_codeSave_html"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			//waitMethods.waiter(waitMethods.w500);	
	    	System.out.println("Select Save Code (1st HTML box)");
		}




	//		@Test(priority = 200) //						////  In test in class TestHTMLBox  			
	//		private void inputHTMLReadData01() {			
	//			waitMethods.waiter(waitMethods.w500);       
	//			WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div/fieldset/div[2]/div[6]/div[1]"));
	//			String strHTML = "<title>Form Editor&nbsp; - Academy Demo Site (Test site) | Washington DC</title>";
	//	    	highlightElement.highLightElement(driver, ele);
	//	   		ele.sendKeys(strHTML);
	//			//waitMethods.waiter(waitMethods.w500);	
	//	    	System.out.println("Input HTML-Read Data");
	//		}
		
		
		
		@Test(priority = 202) //				
		private void selectSaveCode01b() {			
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("btn_codeSave_htmlPrint"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			//waitMethods.waiter(waitMethods.w500);	
	    	System.out.println("Select Save Code (2nd HTML box)");
		}
		
		
	
		@Test(priority = 204) //  			
		private void selectSaveQuestion01() {			
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Select Save Code (2nd HTML box)");
		}
		
		
	///////////////////     Advanced Formatting    \\\\\\\\\\\\\\\\\\		
		
		
		@Test(priority = 206) //	  			
		private void selectEditFieldIcon02() {		
			selectEditFieldIcon();
		}
		
		
		
		
		@Test(priority = 208) //  Advanced Formatting
		private void selectAdvancedFormatting() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("advNameEditor"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Select Advanced Formatting Button");
		}
		
		
	
		@Test(priority = 210) //  Select textarea element (actually the div above it)
		private void selectTextToFormat() {			//   
			waitMethods.waiter(waitMethods.w500);      //  
			String url = driver.getCurrentUrl();
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
				WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/div[2]"));
				highlightElement.highLightElement(driver, ele);		
		    	waitMethods.waiter(waitMethods.w500);
		   		ele.sendKeys(Keys.chord(Keys.CONTROL, "a"));
		   		highlightElement.highLightElement(driver, ele);
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
				WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[1]/div/div[2]"));
				highlightElement.highLightElement(driver, ele);		
		    	waitMethods.waiter(waitMethods.w500);
		   		ele.sendKeys(Keys.chord(Keys.CONTROL, "a"));
		   		highlightElement.highLightElement(driver, ele);
			}
			
	   		//String str = ele.getAttribute("value");
	    	
	   		waitMethods.waiter(waitMethods.w500);
	   		System.out.println("Select Text to Format");
		}	
		
  
		
		@Test(priority = 212) // 
		private void formatTextBold() {			//            //	  'B' Bold icon 			
												//		  		
			String url = driver.getCurrentUrl();
			
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
				WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/div[1]/div[2]/button"));
		   		highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
				WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[1]/div/div[1]/div[2]/button"));
		   		highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		
			}
	   		waitMethods.waiter(waitMethods.w500);
	   		
	    	System.out.println("Format text - Bold");
		}	
		
		
		
		
		@Test(priority = 214) //  			
		private void selectSaveQuestion02() {			
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);	
	    	System.out.println("Select Save Code");
		}
		
		
		
		@Test(priority = 216) //	  			
		private void selectEditFieldIcon03() {		
			selectEditFieldIcon();
		}
		
		
		
		
		@Test(priority = 218) //  Show Formatted Code				//	advNameEditor = to open advanced editor
		private void showFormatedCode() {			//				//  rawNameEditor = to see HTML
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("rawNameEditor"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Select Show Formated Code Button");
		}	
				

		
		
		@Test(priority = 230) //  
		private void validateFormatBold() {			//
			waitMethods.waiter(waitMethods.w500);      //
			
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    						  
	    	String strExpected = "<p><strong>Test Q1 Single line text</strong></p>";
	    	
	   		String strActual = ele.getText().toString();
	   		
	   		System.out.println("strExpected: " + strExpected);
	   		System.out.println("strActual: " + strActual);
			waitMethods.waiter(waitMethods.w500);

			Assert.assertEquals(strActual, strExpected);

	    	//if(!str.contains("strong")) {
	    	//	Assert.fail();
			//}

			System.out.println("Format text - Bold");
	    	 
		}
		
		
		
		@Test(priority = 232) //  save
		private void selectSave03() {			//
			selectSave();
		}	
	

	
		
		@Test(priority = 234) //	  			// 
		private void selectEditFieldIcon04() {		
			//selectEditFieldIcon();
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Test Q1 Single line text')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);	
	    	System.out.println("Test Question: Edit Field Icon");
		}
		
		
		
		@Test(priority = 236) //  Select textarea element (actually the div above it)   // 
		private void selectTextToFormat01() {			//
			selectTextToFormat();
		}	
		
		
		@Test(priority = 238) //  
		private void formatTextItalics() {			//	   		

				String url = driver.getCurrentUrl();  //          

				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[1]/div/div[1]/div[3]/button"));
			   		ele.click();
			   		waitMethods.waiter(waitMethods.w500);			
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[1]/div/div[1]/div[3]/button"));
			   		ele.click();
			   		waitMethods.waiter(waitMethods.w500);			
				}			
	   		
	    	System.out.println("Format text - Italics");
		}	
		

		
		@Test(priority = 240) //  save
		private void selectSave04() {			//
			selectSave();
		}	
		
		
		@Test(priority = 242) //	  			// 
		private void selectEditFieldIcon05() {		
			//selectEditFieldIcon();
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Test Q1 Single line text')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);	
	    	System.out.println("Test Question: Edit Field Icon");
		}
		
		
		
		@Test(priority = 244) //  Show Formatted Code			//   
		private void showFormatedCode03() {			//
			showFormatedCode();
		}	

		
		
		@Test(priority = 246) //  
		private void validateFormatItalics() {			//   
			waitMethods.waiter(waitMethods.w500);      //
			
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    						  
	    	String strExpected = "<p><strong><em>Test Q1 Single line text</em></strong></p>";
	    	
	   		String strActual = ele.getText().toString();
	   		
	   		System.out.println("strExpected: " + strExpected);
	   		System.out.println("strActual: " + strActual);
			waitMethods.waiter(waitMethods.w500);

			Assert.assertEquals(strActual, strExpected);

	    	//if(!str.contains("strong")) {
	    	//	Assert.fail();
			//}

			System.out.println("Format text - Bold");
		}
		
		
		@Test(priority = 248) //  save				//  
		private void selectSave05() {			//
			selectSave();
		}	

		
		
		///////////////////    Add Sub-question  \\\\\\\\\\\\\\\\\\\\



	@Test(priority = 250)
	private void addSubQuestion01S01() {          
		waitMethods.waiter(waitMethods.w500);       
		WebElement ele = driver.findElement(By.xpath("//*[contains(text(),' Add Sub-question')]"));
    	highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w300);
    	
	}




		@Test(priority = 252) //  
		private void inputFieldName01S01() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Test Q1S01 Sub-question Multi line text";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Sub-question: Multi line text)");			
		}
		

		
		@Test(priority = 254) //   
		private void inputShortLabel01S01() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q1S01";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Sub-question Q1S01: Short Label)");			
		}

		

		@Test(priority = 256) //  
		public void selectMultiLineText01S01() {         
			//waitMethods.implicitWait(waitMethods.w500);
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("indicatorType"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w500);
			Select select = new Select(driver.findElement(By.id("indicatorType")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("textarea");
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("indicatorType"));
			ele2.click();
			System.out.println("Test Question: Multi-Line Text");
		}
		

		
		@Test(priority = 258) //	
		private void inputDefaultAnswer01S01() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "MR Test Default Response Q1S01";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Question: input Default Answer");			
		}
		
		
		@Test(priority = 260) //  
		private void selectFieldRequired01S01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("required"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Test Question: Field Required = Y");
		}
		
		
		@Test(priority = 262) //  
		private void selectFieldSensitiveData01S01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("sensitive"));
	    	highlightElement.highLightElement(driver, ele);
	   		//ele.click();
	   		//waitMethods.waiter(waitMethods.w200);
	   		//ele.click();
	    	//waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Sensitive Data = N");
		}
		
		
		
		@Test(priority = 264) //  
		private void selectSortValue01S01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("2");
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Test Question: Sort Priority");
		}
		
		
		@Test(priority = 268) //  
		private void selectQuestionSave01S01() {			//
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);						//CHANGE TO w500
	    	System.out.println("Test Question: Save button");
		}
		
		
		
			
//		//////==============    Q1 Subquestion 02 =================================================================
	
	
			@Test(priority = 269) //  add sub-question	
			private void addSubQuestion01S02() {
				String url = driver.getCurrentUrl();    
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) { 			
					waitMethods.waiter(waitMethods.w500);       
					WebElement ele = driver.findElement(By.xpath("//*[contains(text(),' Add Sub-question')]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					waitMethods.waiter(waitMethods.w500);       
					WebElement ele = driver.findElement(By.xpath("//*[contains(text(),' Add Sub-question')]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				System.out.println("Subquestion 2 for Q1");
			}
			
			
			
			
//			private void addSubQuestion01S02() {
//				addSubQuestion();
//				System.out.println("Forms-add Sub-Question 2 to Q1");
//			}
	
			@Test(priority = 272) //						
			private void inputFieldName01S02() {
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Test Q1S02 Sub-question Grid";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Test Sub-question: Grid)");			
			}
			
	
			
			@Test(priority = 274) //							
			private void inputShortLabel01S02() {
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q1S02";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Test Sub-question Q1S02: Short Label)");			
			}
	
			
	
			@Test(priority = 276) //01S02   						
			public void selectGrid01S02() {         
				//waitMethods.implicitWait(waitMethods.w500);
				waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w500);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("grid");
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
	
				System.out.println("Test Question: Grid");
			}
			
	
			@Test(priority = 278) //01S02						
			private void inputColumnTitle01() {
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   //  	
					waitMethods.waiter(waitMethods.w500);    // 
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/input"));
			    	highlightElement.highLightElement(driver, ele);
			    	
			    	String name = "Q-Text";
			    	ele.clear();			
			    	
			    	for(int i = 0; i < name.length(); i++) {
			    		char c = name.charAt(i);
			    		String s = new StringBuilder().append(c).toString();
			    		ele.sendKeys(s);
			    		waitMethods.waiter(waitMethods.w20);
			    	}
					
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) { //  
					waitMethods.waiter(waitMethods.w500);    // 
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/input"));
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/input"));
			    											
					highlightElement.highLightElement(driver, ele);
			    	
			    	String name = "Q-Text";
			    	ele.clear();			
					
			    	for(int i = 0; i < name.length(); i++) {
			    		char c = name.charAt(i);
			    		String s = new StringBuilder().append(c).toString();
			    		ele.sendKeys(s);
			    		waitMethods.waiter(waitMethods.w20);
			    	}
				}
				
		    	System.out.println("Column Title: Grid Col #1");			
			}
			
			
			
			@Test(priority = 280) //01S02    		   
			public void selectColumnType01() {         
				//waitMethods.implicitWait(waitMethods.w500);
				     
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					waitMethods.waiter(waitMethods.w500);	// 
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/select"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);
					Select select = new Select(driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/select")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("text");
					waitMethods.waiter(waitMethods.w200);
					WebElement ele2 = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/select"));
					ele2.click();			
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					waitMethods.waiter(waitMethods.w500);	// 
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/select"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);	
					Select select = new Select(driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/select")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("text");
					waitMethods.waiter(waitMethods.w200);		
					WebElement ele2 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div/select"));
					ele2.click();		
				}
			
				System.out.println("Test Question: Grid");
			}
		
	
			
			@Test(priority = 282) //01S02							
			private void inputDefaultAnswer01S02() {
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "MR Test Default Response Q1S02";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Test Question: input Default Answer");			
			}
			
			
			@Test(priority = 284) //  								
			private void selectFieldRequired01S02() {			//
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w500);
		    	System.out.println("Test Question: Field Required = N");
			}
			
			
			@Test(priority = 286) //  							
			private void selectFieldSensitiveData01S02() {			//
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//waitMethods.waiter(waitMethods.w200);
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Test Question: Sensitive Data = N");
			}
			
			
			@Test(priority = 288) //  Go back to 270
			private void selectSortValue01S02() {			//
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("3");
				waitMethods.waiter(waitMethods.w500);
		    	System.out.println("Test Question: Sort Priority");
			}
			
			
			@Test(priority = 290) //  
			private void selectQuestionSave01S02() {			//
				waitMethods.waiter(waitMethods.w1k);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w500);
		    	System.out.println("Test Question: Save button");
			}

			
			@Test(priority = 292) //  					
			private void editQuestion01S02() {			//
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Test Q1S02 Sub-question Grid')]"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w500);
		    	System.out.println("Edit Sub-question #2");
			}
			
			
			//		Add Column 2
		
			@Test(priority = 294) //  				
			private void addNewColumn02() {			
				waitMethods.waiter(waitMethods.w500);  //  findElement(By.xpath("//*[contains(text(), 'Test Q1S02 Sub-question Grid')]"));
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/button"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);	
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Add column')]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);	
				}
					System.out.println("Add Column #2");	         
			}
			
					
		
			@Test(priority = 296) //													
			private void inputColumnTitle02() {
				waitMethods.waiter(waitMethods.w500);    //           
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/input"));
			    	highlightElement.highLightElement(driver, ele);
			    	
			    	String name = "Q-Date";
			    	ele.clear();
			    	
			    	for(int i = 0; i < name.length(); i++) {
			    		char c = name.charAt(i);
			    		String s = new StringBuilder().append(c).toString();
			    		ele.sendKeys(s);
			    		waitMethods.waiter(waitMethods.w20);
			    	}
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {					
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/input"));
			    	highlightElement.highLightElement(driver, ele);
			    	
			    	String name = "Q-Date";
			    	ele.clear();
			    	
			    	for(int i = 0; i < name.length(); i++) {
			    		char c = name.charAt(i);
			    		String s = new StringBuilder().append(c).toString();
			    		ele.sendKeys(s);
			    		waitMethods.waiter(waitMethods.w20);
			    	}
				}
		    	
				System.out.println("Column Title: Grid Col #2");			
			}
			
			
			
			@Test(priority = 298) //							
			public void selectColumnType02() {         
				//waitMethods.implicitWait(waitMethods.w500);
				waitMethods.waiter(waitMethods.w200);	//        
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/select"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);
					Select select = new Select(driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/select")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("date");
					waitMethods.waiter(waitMethods.w200);
					WebElement ele2 = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/select"));
					ele2.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/select"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);
					Select select = new Select(driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/select")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("date");
					waitMethods.waiter(waitMethods.w200);
					WebElement ele2 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/select"));
					ele2.click();
				}
	
				System.out.println("Test Question: Grid");
			}
		
			
			@Test(priority = 300) //  									
			private void addNewColumn03() {	
				waitMethods.waiter(waitMethods.w500);     //    
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Add column')]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);	
				
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Add column')]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);	
				}
				
		    	System.out.println("Add Column #3");
			}
			
					
		
			@Test(priority = 302) //								
			private void inputColumnTitle03() {
				waitMethods.waiter(waitMethods.w500);     //    
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/input"));
			    	highlightElement.highLightElement(driver, ele);
			    	
			    	String name = "Q-Dropdown";
			    	ele.clear();
			    	
			    	for(int i = 0; i < name.length(); i++) {
			    		char c = name.charAt(i);
			    		String s = new StringBuilder().append(c).toString();
			    		ele.sendKeys(s);
			    		waitMethods.waiter(waitMethods.w20);
			    	}
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/input"));
			    	highlightElement.highLightElement(driver, ele);
			    	
			    	String name = "Q-Dropdown";
			    	ele.clear();
			    	
			    	for(int i = 0; i < name.length(); i++) {
			    		char c = name.charAt(i);
			    		String s = new StringBuilder().append(c).toString();
			    		ele.sendKeys(s);
			    		waitMethods.waiter(waitMethods.w20);
			    	}
				}
				
		    	System.out.println("Column Title: Grid Col #3");			
			}
			
			
			
			@Test(priority = 304) //												
			public void selectColumnType03() {         
				waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/select"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);              //   
					Select select = new Select(driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/select")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("dropdown");
					waitMethods.waiter(waitMethods.w200);
					WebElement ele2 = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/select"));
					ele2.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/select"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);              //   
					Select select = new Select(driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/select")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("dropdown");
					waitMethods.waiter(waitMethods.w200);
					WebElement ele2 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/select"));
					ele2.click();
				}
				
				System.out.println("Test Question: Dropdown");
			}
	
	
			@Test(priority = 306) //  								//
			private void populateDDLOptions() {	//
				String url = driver.getCurrentUrl();	
				waitMethods.waiter(waitMethods.w500);
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
		       
					WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/span[2]/textarea"));
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/span[2]/textarea"));
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/span[2]/textarea"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.sendKeys("Opt Value #1");
			   		ele.sendKeys(Keys.ENTER);
			   		ele.sendKeys("Opt Value #2");
			   		ele.sendKeys(Keys.ENTER);
			   		ele.sendKeys("Opt Value #3");
			   		ele.sendKeys(Keys.ENTER);
			   		ele.sendKeys("Opt Value #4");
					waitMethods.waiter(waitMethods.w500);	
					
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/span[2]/textarea"));
					highlightElement.highLightElement(driver, ele);
			   		ele.sendKeys("Opt Value #1");
			   		ele.sendKeys(Keys.ENTER);
			   		ele.sendKeys("Opt Value #2");
			   		ele.sendKeys(Keys.ENTER);
			   		ele.sendKeys("Opt Value #3");
			   		ele.sendKeys(Keys.ENTER);
			   		ele.sendKeys("Opt Value #4");
					waitMethods.waiter(waitMethods.w500);	
				}
				
		    	System.out.println("populateDDLOptions");
			}			
	
				
				
							
				
			@Test(priority = 308) //  								
			private void addNewColumn04() {	//
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.xpath("//button[contains(text(), 'Add column')]"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w500);	
		    	System.out.println("Add Column #4");
			}
				
						
			
				@Test(priority = 310) // 							
				private void inputColumnTitle04() {
					waitMethods.waiter(waitMethods.w500);         
					String url = driver.getCurrentUrl();	
					if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
						WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/input"));
				    	highlightElement.highLightElement(driver, ele);
				    	
				    	String name = "Q-Textarea";
				    	ele.clear();
				    	
				    	for(int i = 0; i < name.length(); i++) {
				    		char c = name.charAt(i);
				    		String s = new StringBuilder().append(c).toString();
				    		ele.sendKeys(s);
				    		waitMethods.waiter(waitMethods.w20);
				    	}
					} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
						WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/input"));
				    	highlightElement.highLightElement(driver, ele);
				    	
				    	String name = "Q-Textarea";
				    	ele.clear();
				    	
				    	for(int i = 0; i < name.length(); i++) {
				    		char c = name.charAt(i);
				    		String s = new StringBuilder().append(c).toString();
				    		ele.sendKeys(s);
				    		waitMethods.waiter(waitMethods.w20);
				    	}
					}
	
			    	System.out.println("Column Title: Grid Col #4");			
				}
				
				
				/*      TODO      
				 * 		A NEW OPTION (DROPDOWN FILE)  WAS Added, which is causing the XPath to be invalid
				 *          
				 */
				@Test(priority = 312) //										// 
				public void selectColumnType04() {         
					//waitMethods.implicitWait(waitMethods.w500);
					String url = driver.getCurrentUrl();	
					if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
						waitMethods.waiter(waitMethods.w300);			//The below opens the DDL
						WebElement ele = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/select"));
						highlightElement.highLightElement(driver, ele);
						ele.click();
						waitMethods.waiter(waitMethods.w300);		// was w300		    
						Select select = new Select(driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/select")));
						highlightElement.highLightElement(driver, ele);
						select.selectByValue("textarea");
						waitMethods.waiter(waitMethods.w300);		// was w300
						WebElement ele2 = driver.findElement(By.xpath("/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/select"));
						ele2.click();
					} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
						waitMethods.waiter(waitMethods.w200);			//The below opens the DDL	
						WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/select"));
						highlightElement.highLightElement(driver, ele);
						ele.click();
						waitMethods.waiter(waitMethods.w300);				    
						Select select = new Select(driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/select")));
						highlightElement.highLightElement(driver, ele);
						select.selectByValue("textarea");			
						waitMethods.waiter(waitMethods.w300);		
						WebElement ele2 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/select"));
						ele2.click();
					}
					
					System.out.println("Test Question: Textarea");
				}
	
				
				
		//********* OK to Here for PROD & Pre-Prod  **********
		/////// HERE: For DEBUGGing, comment here to end \\\\\\\\\\\\\\\\\\\  Grid
				
				
			
				
				@Test(priority = 320) //
				private void selectQuestionSave01S02_02() {			//
					waitMethods.waiter(waitMethods.w500);       
					WebElement ele = driver.findElement(By.id("button_save"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);
			    	System.out.println("Test Question: Save button");
				}
				
				
				
				@Test(priority = 322) //  					
				private void editQuestion01S02_2() {	//
					waitMethods.waiter(waitMethods.w500);  
					WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Test Q1S02 Sub-question Grid')]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);
			    	System.out.println("Edit Sub-question #2");
				}
				
	
			/*	Arrange Columns arrows
			 						
			  Col 1 (1 arrow R):	/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[1]/img[2]
			  Col 2 L:				/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/img[1]
			  Col 2 R:				/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/img[2]
			  Col 3 L:				/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/img[1]
			  Col 3 R:				/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/img[2]
			  Col 4 (1 arrow L):	/html/body/div[4]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[4]/img[1]
				
				
				1 is in Pos 4 R R
				2 is in Pos 3 R
				2 is in Pos 1 L
				
				
			*/
				
				@Test(priority = 324) //  						
				private void moveCol1_3PositionsR() {			
					waitMethods.waiter(waitMethods.w500);       
					String url = driver.getCurrentUrl();	
					if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
						WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[1]/img[2]"));
				    	highlightElement.highLightElement(driver, ele);
				   		ele.click();
						waitMethods.waiter(waitMethods.w300);
						
				   		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/img[2]"));
				    	highlightElement.highLightElement(driver, ele2);
				   		ele2.click();
						waitMethods.waiter(waitMethods.w300);
		
				   		WebElement ele3 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/img[2]"));
				    	highlightElement.highLightElement(driver, ele3);
				   		ele3.click();
						waitMethods.waiter(waitMethods.w300);				
						
				   		waitMethods.waiter(waitMethods.w300);
					} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
						// From left: first arrow click  OK
						WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[1]/img[2]"));
				    	highlightElement.highLightElement(driver, ele);
				   		ele.click();
						waitMethods.waiter(waitMethods.w300);
																	//ok 
				   		WebElement ele2 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/img[2]"));
				    	highlightElement.highLightElement(driver, ele2);
				   		ele2.click();
						waitMethods.waiter(waitMethods.w300);
																	//ok ???
				   		WebElement ele3 = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[3]/img[2]"));
				    	highlightElement.highLightElement(driver, ele3);
				   		ele3.click();
						waitMethods.waiter(waitMethods.w300);				
						
					}
				
			    	System.out.println("Move Col #1 3 places to right");
				}	
				
				
				@Test(priority = 332) //  					
				private void moveCol2_1PositionsR() {			//
					waitMethods.waiter(waitMethods.w500);       
					
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/img[2]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					
			   		waitMethods.waiter(waitMethods.w500);
			   		System.out.println("Move Col #2 1 places to right");
				}	
				
				
				@Test(priority = 334) //  					
				private void moveCol2_1PositionsL() {			//
					waitMethods.waiter(waitMethods.w500);       
					
					WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/form/div/main/fieldset[3]/div[3]/div/div[2]/img[1]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					
			   		waitMethods.waiter(waitMethods.w500);
			   		System.out.println("Move Col #2 1 places to left");
				}	
				
						
				
				@Test(priority = 338) //  							

				private void selectQuestionSave01S02b() {	//
					waitMethods.waiter(waitMethods.w500);       
					WebElement ele = driver.findElement(By.id("button_save"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);
			    	System.out.println("Test Question: Save button");
				}
			
			
			@Test(priority = 340) //  									
			private void selectSubSubQuestion01S01S01() {	//	
				waitMethods.waiter(waitMethods.w500);       
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
				//(By.xpath("//*[contains(text(), ' Add Sub-Question')]"));
					WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div/div/div[3]/div/div[1]/div/div[1]/span/span[2]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div/div[1]/div[2]/div[2]/div/div[1]/div/div/div[3]/div/div[1]/div/div[1]/span/span[2]"));							
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div/div[1]/div/div/div[3]/div/div[1]/div/div[1]/span/span[2]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w500);
				}
				
		    	System.out.println("Select Sub-Sub-question");
			}
	
			//===========================================================
			
			
			
				@Test(priority = 342) //							
				private void inputFieldName01S01S01() {
					waitMethods.waiter(waitMethods.w500);       
					String url = driver.getCurrentUrl();	
					if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
						WebElement ele = driver.findElement(By.id("name"));
				    	highlightElement.highLightElement(driver, ele);
				    	
				    	String name = "Test Q1S01S01 Sub-sub-question Numeric";
				   
				    	for(int i = 0; i < name.length(); i++) {
				    		char c = name.charAt(i);
				    		String s = new StringBuilder().append(c).toString();
				    		ele.sendKeys(s);
				    		waitMethods.waiter(waitMethods.w20);
				    	}
					} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
						WebElement ele = driver.findElement(By.id("name"));
				    	highlightElement.highLightElement(driver, ele);
				    	
				    	String name = "Test Q1S01S01 Sub-sub-question Numeric";
				   
				    	for(int i = 0; i < name.length(); i++) {
				    		char c = name.charAt(i);
				    		String s = new StringBuilder().append(c).toString();
				    		ele.sendKeys(s);
				    		waitMethods.waiter(waitMethods.w20);
				    	}
					}
	
			    	System.out.println("Test Sub-sub-question: Numeric)");			
				}
				
		
				
				@Test(priority = 344) //						
				private void inputShortLabel01S01S01() {
					waitMethods.waiter(waitMethods.w500);       
					String url = driver.getCurrentUrl();	
					if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
						WebElement ele = driver.findElement(By.id("description"));
				    	highlightElement.highLightElement(driver, ele);
				    	
				    	String name = "Q1S01S01";
				   
				    	for(int i = 0; i < name.length(); i++) {
				    		char c = name.charAt(i);
				    		String s = new StringBuilder().append(c).toString();
				    		ele.sendKeys(s);
				    		waitMethods.waiter(waitMethods.w20);
				    	}
					} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
						WebElement ele = driver.findElement(By.id("description"));
				    	highlightElement.highLightElement(driver, ele);
				    	
				    	String name = "Q1S01S01";
				   
				    	for(int i = 0; i < name.length(); i++) {
				    		char c = name.charAt(i);
				    		String s = new StringBuilder().append(c).toString();
				    		ele.sendKeys(s);
				    		waitMethods.waiter(waitMethods.w20);
				    	}
					}
		    	
					System.out.println("Test Sub-sub-question Q1S01S01: Numeric)");			
				}
	
			
	
			@Test(priority = 346) //							
			public void selectNumeric01S01S01() {         
				//waitMethods.implicitWait(waitMethods.w500);
				waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.id("indicatorType"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);
					Select select = new Select(driver.findElement(By.id("indicatorType")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("number");
					waitMethods.waiter(waitMethods.w200);
					WebElement ele2 = driver.findElement(By.id("indicatorType"));
					ele2.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.id("indicatorType"));
					highlightElement.highLightElement(driver, ele);
					ele.click();
					waitMethods.waiter(waitMethods.w500);
					Select select = new Select(driver.findElement(By.id("indicatorType")));
					highlightElement.highLightElement(driver, ele);
					select.selectByValue("number");
					waitMethods.waiter(waitMethods.w200);
					WebElement ele2 = driver.findElement(By.id("indicatorType"));
					ele2.click();
				}
				
				System.out.println("Test Question: Numeric");
			}
			
	
			
			@Test(priority = 348) //					
			private void inputDefaultAnswer01S01S01() {
				waitMethods.waiter(waitMethods.w500);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	//String name = "0";
		   
		    	//for(int i = 0; i < name.length(); i++) {
		    	//	char c = name.charAt(i);
		    	//	String s = new StringBuilder().append(c).toString();
		    	//	ele.sendKeys(s);
		    	//	waitMethods.waiter(waitMethods.w20);
		    	//}
		    	
		    	System.out.println("Test Question: Default Not Input");			
			}
			
			
			@Test(priority = 350) //  								
			private void selectFieldRequired01S01S01() {			//
				waitMethods.waiter(waitMethods.w250);       
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.id("required"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w250);
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.id("required"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w250);
				}
			
		    	System.out.println("Test Question: Field Required = Y");
			}
			
			
			@Test(priority = 352) //  
			private void selectFieldSensitiveData01S01S01() {			
				waitMethods.waiter(waitMethods.w500);       
				
				
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		    	//ele.click();
		   		//waitMethods.waiter(waitMethods.w200);
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Test Question: Sensitive Data = Y");
			}
			
			
			
			@Test(priority = 362) //  								
			private void selectSortValue01S01S01() {			//
				waitMethods.waiter(waitMethods.w250);       
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.id("sort"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.sendKeys("4");
					waitMethods.waiter(waitMethods.w250);
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.id("sort"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.sendKeys("4");
					waitMethods.waiter(waitMethods.w250);
			    	
				}
				
				System.out.println("Test Question: Sort Priority");
			}
			
			
			@Test(priority = 364) //  								
			private void selectQuestionSave01S01S01() {			//
				waitMethods.waiter(waitMethods.w500);       
				String url = driver.getCurrentUrl();	
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.id("button_save"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w250);				
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.id("button_save"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
					waitMethods.waiter(waitMethods.w250);				
				}
				
				System.out.println("Test Question: Save button");
			}
	
			
			
	////////// Go into Properties and a) change title, b) set sort priority to -128, which will (usually) make it the
	////			// first form on the page
			
			
			
			
		@Test(priority = 366) //
		private void selectEditProperties02() {
			waitMethods.waiter(waitMethods.w500);       
			//WebElement ele = driver.findElement(By.xpath("//*[text()='Edit Properties']"));
			WebElement ele = driver.findElement(By.id("editFormData"));
 	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Forms - clicked Edit Properties");
		}
		

		
		
		
		
		@Test(priority = 368) //
		private void changeFormName() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	ele.clear();
	    	
	    	String name = "AUT";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	   	    	System.out.println("Changed Form Name to AUT");			
		}
		

		@Test(priority = 369) //
		private void changeDescription() {
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	ele.clear();
	    	
	    	String name = "Form Description " + dateAndTimeMethods.getDate().toString();
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	   	    	System.out.println("Changed Description to Form Description + getDate()");			
		}

		
		
		@Test(priority = 370) //  Accepts pos & neg integers 
		private void selectSortPriority02() {	
			waitMethods.waiter(waitMethods.w500);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	    	ele.clear();
	   		ele.sendKeys("-128");
			waitMethods.waiter(waitMethods.w500);
	    	System.out.println("Forms-Selected Sort Priority");
		}
		
		
		
		
		@Test(priority = 372) //  
		private void selectSave06() {
			selectSave();
		}		
		




		
//===================   END code to go in the 2nd form   ============================
		
		
		
//		Begin newformscript at URL:  https://localhost/LEAF_Request_Portal/admin/?a=form#		
		
////////////////   Except the getDate() method, all notes from here on \\\\\\\\\\\\\\\\\\\\\\\\\\\\\		
		
/*  /////// FORM EDITOR Main Screen Element Locators \\\\\\
					
			
			//////  + Adding New Question \\\\\\\\\\\\\
			 Field Name:				id=  name
			  	Advanced Formatting:	id=  advNameEditor
		  	Short Label:				id=  description
		  	
		  	Input Format (DDL):			id=  indicatorType
		  	
		  	Import Values (Field Types):
		  			value = None:						//Don't use this
		  			value = text				Single line text									Q01
		  			value = textarea			Multi-line text										Q01S01
		  			value = grid				Grid (Table with rows and columns)					Q01S02
		  			value = number				Numeric												
		  			value = currency			Currency											
		  			value = date				Date												
		  			value = radio				Radio (single select, multiple options)				
		  			value = checkbox			Checkbox (A single checkbox)						
		  			value = checkboxes			Checkboxes (Multiple Checkboxes)					
		  			value = multiselect			Multi-Select Dropdown								
		  			value = dropdown			Dropdown Menu (single select, multiple options)		
		  			value = fileupload			File Attachment										
		  			value = image				Image Attachment									
		  			value = orgchart_group		Orgchart Group										
		  			value = orgchart_position	Orgchart Position									
		  			value = orgchart_employee	Orgchart Employee									
		  			value = raw_data			Raw Data (for programmers)							
		  			
		  			
		  	
		  	Default Answer:				id=  default
		  	
		  	Required:					id=  required
		  	Sensitive:					id=  sensitive
			Sort Priority: 				id=  sort
			Parent Question ID:			id=	 Won't know until I add more questions

			
			Save:						id=  button_save
			Cancel:						id=  button_cancelchange
			Advanced Options			id = button_advanced
			
			1st html textbx				xPath = /html/body/div[3]/div[2]/form/div/main/div/fieldset/div[1]/div[6]/div[1]
			Save Code (1st)				id = btn_codeSave_html
			
			2nd html textbx				xPath = /html/body/div[3]/div[2]/form/div/main/div/fieldset/div[2]/div[6]/div[1]
			Save Code (2nd)				id = btn_codeSave_htmlPrint 
			
			
										
	View all forms:	TODO		
	+ Add Internal=Use		CSS = #menu > div:nth-child(4)
	Staple Other Form:		CSS = #menu > div:nth-child(7)
	View History:			CSS = #menu > div:nth-child(11)
	Delete this form:		CSS = #menu > div:nth-child(18)
	Restore Fields:			CSS = #menu > div:nth-child(21)
		
	Little lock box at top of question - Special access restrictions
	Hidden
	Need to know

	On a question - Sensitive data (obsfuscates PHI/PII)
	Archive & Restore Question
	Delete Question

	Scooch around Grid columns in Sub-question #2



	IF TEMPLATE
	String url = driver.getCurrentUrl();	
	if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
	
	} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
	
	}


*/			


	
}  //class
	