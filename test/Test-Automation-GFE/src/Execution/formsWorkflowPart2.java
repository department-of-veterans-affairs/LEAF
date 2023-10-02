package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import java.util.Date;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.annotations.BeforeClass;
import org.openqa.selenium.support.ui.Select;			//Select Method

import Framework.AppVariables;
import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;

public class formsWorkflowPart2 extends setupFramework {

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
 
/////////////////////////////     Forms Workflow Part 2      \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	/*		Locating elements using text (XPath)
			//div[contains(text(), "{0}") and @class="inner"]'.format(text)
	
			foo= "foo_bar"
			my_element = driver.find_element_by_xpath("//div[.='" + foo + "']")
			
			driver.find_element_by_xpath("//div[contains(text(),'Add User')]")
			driver.find_element_by_xpath("//button[contains(text(),'Add User')]")
			
			wait.until(ExpectedConditions.elementToBeClickable(//
    		driver.findElements(By.tagName("button")).stream().filter(i -> i.getText().equals("Advanced...")).findFirst().get())).click();
    		
    		Use driver.find_elements_by_xpath and matches regex matching function for the case insensitive search of the element by its text.
			driver.find_elements_by_xpath("//*[matches(.,'My Button', 'i')]")
			
			
	
	*/
	
	
		@Test(priority = 360) //  								 
		private void initializePOM() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), ' Import Form')]"));
			//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[1]/div[3]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Clicked Import Form as Test");
	    	
	    	driver.navigate().back();
		}			
	
	
	
		//Select Work-in-progress Form build using formsWorkflow.java
		@Test(priority = 380)  //Select the form that is in first position (top left)
		private void selectCurrentFormByXpath() {	
			waitMethods.waiter(waitMethods.w1k);  //      
			String url = driver.getCurrentUrl();
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) { 
				WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div[1]/div[1]"));
		    	highlightElement.highLightElement(driver, ele);
		    	ele.click();
		   		waitMethods.waiter(waitMethods.w300);
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {	  													   
		   		WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div[1]/div[2]"));
		    	highlightElement.highLightElement(driver, ele);
		    	ele.click();
		   		waitMethods.waiter(waitMethods.w300);
			}	
		    	System.out.println("Select first form, upper left (-127)");
		}	
	
		
		
		@Test(priority = 382) //  
		private void selectAddSectionHeading02() {			
			waitMethods.waiter(waitMethods.w300);   //   "//*[contains(text(), 'Test Q2 Currency')]"));
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Section Heading')]"));
			//WebElement ele = driver.findElement(By.cssSelector("#formEditor_form > div > div.buttonNorm"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: +Add Section Heading)");
		}


		

		@Test(priority = 384) //
		private void inputFieldName02() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Test Q2 Currency";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w10);
	    	}
	    	
	    	System.out.println("Test Question: Currency");			
		}
		

		
		@Test(priority = 386) //
		private void inputShortLabel02() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w10);
	    	}
	    	
	    	System.out.println("Test Question: Short Label)");			
		}

		

		@Test(priority = 388) //
		public void selectNumericTypeField() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("indicatorType"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("indicatorType")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("currency");
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("indicatorType"));
			ele2.click();
			System.out.println("Test Question: Currency");
		}
		
			
				
		
		
		@Test(priority = 390) //
		private void inputDefaultAnswer02() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "";
	    	//String name = "MR Test Default Response Q2";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Question: input Default Answer Q2");			
		}
		
		
		@Test(priority = 392) //  
		private void selectFieldRequired02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("required"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Field Required = Y");
		}
		
		
		@Test(priority = 394) //  
		private void selectFieldSensitiveData02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sensitive"));
	    	highlightElement.highLightElement(driver, ele);
	   		//ele.click();
	   		//ele.click();
			//waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Sensitive Data = N");
		}
		
		
		
		@Test(priority = 396) //  
		private void selectSortValue02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("5");
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Sort Priority");
		}
		
		
		@Test(priority = 398) //  
		private void selectQuestionSave02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Test Question: Save button");
		}		
		

		//Select question
		@Test(priority = 400) //  
		private void editQuestionQ2() {	//
			waitMethods.waiter(waitMethods.w300);  
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Test Q2 Currency')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Edit Question #2");
		}
		
		
		//select delete
		@Test(priority = 402) //  
		private void selectDeleteQuestion() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("deleted"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Delete Question #2");
		}
		
		
		@Test(priority = 404) //  
		private void selectQuestionSave03() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Test Question: Save button");
		}
				
		
		//select Restore Fields
		@Test(priority = 406) //  
		private void selectRestoreFields() {	//
			waitMethods.waiter(waitMethods.w300);  
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Restore Fields')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Select Restore Question");
		}
		
		
		//Restore Field/Question - Choose last element   Btn txt: Restore this field
		//////// Current AUT
		@Test(priority = 408) //  Choose last element
		private void selectDataToRestore() {	//
			waitMethods.waiter(waitMethods.w300);  
			WebElement ele = driver.findElement(By.cssSelector("table tr:last-child td > button"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Restore Deleted Question");
	    	waitMethods.waiter(waitMethods.w300);
	    	driver.switchTo().alert().accept();		//Dismiss js alert
	    	waitMethods.waiter(waitMethods.w300); 
	    	driver.navigate().back();			
		}
		
		

//=================================================================================================================
//=================================================================================================================
	
		
		@Test(priority = 410) // 
		private void selectCurrentFormByXpath02() {	
			selectCurrentFormByXpath();
		}	
	

		@Test(priority = 430) //  
		private void addSubQuestionQ2S01() {	//
			waitMethods.waiter(waitMethods.w300);  
			String url = driver.getCurrentUrl();
			
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
				WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
				highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);			
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
				// Looks as if it is increasing the 1st and 3rd div.   Add     [1]   to 3rd div
				WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
				//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
				highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);

			}

	    	System.out.println("Add Sub-question Q2S01");
		}
		
		

		
		@Test(priority = 431) //
		private void inputFieldNameQ2S01() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2 Sub-question 1: Date";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Q2 Sub-question 1: Input Field Name)");			
		}
		

		
		@Test(priority = 432) //
		private void inputShortLabelQ2S01() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2S01";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Sub-question Q2S01: Date)");			
		}

		

		@Test(priority = 434) //
		public void selectTypeDateQ2S01() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("indicatorType"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("indicatorType")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("date");   	//<<<< Selects Date Type
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("indicatorType"));
			ele2.click();
			System.out.println("Q2 Sub-Question 1: Date");
		}
		

		
		@Test(priority = 436) //
		private void inputDefaultAnswerQ2S01() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "10/20/2022";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Q2 Sub-Question 1: Default Answer");			
		}
		
		
		@Test(priority = 438) //  
		private void selectFieldRequiredQ2S01() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("required"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 1: Field Required = Y");
		}
		
		
		@Test(priority = 440) //  
		private void selectFieldSensitiveDataQ2S01() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sensitive"));
	    	highlightElement.highLightElement(driver, ele);
	   		//ele.click();
	   		//ele.click();
			//waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Test Question: Sensitive Data = Y");
		}
		
		
		
		@Test(priority = 442) //  
		private void selectSortValueQ2S01() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("6");
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 1: Sort Priority");
		}
		
		
		@Test(priority = 444) //  
		private void selectQuestionSaveQ2S01() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 1: Save button");
		}

		
		
	
//Q2S02
																						
		//Select add sub-question					
		@Test(priority = 446) //  
		private void addSubQuestionQ2S02() {	//
			waitMethods.waiter(waitMethods.w300);  
			String url = driver.getCurrentUrl();
			
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
				WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
				//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Sub-question')]"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
				WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
				//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[2]/div/div[3]/div/div/div/div[1]/span/span[2]"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
			}
			
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Create sub-question Q2S02");
		}
		

		@Test(priority = 448) //
		private void inputFieldNameQ2S02() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2 Sub-question 2: Radio";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Q2 Sub-question 2: Input Field Name)");			
		}
		

		
		@Test(priority = 450) //
		private void inputShortLabelQ2S02() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2S02";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Sub-question Q2S02: Radio)");			
		}

		

		@Test(priority = 452) //
		public void selectInputTypeQ2S02() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("indicatorType"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("indicatorType")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("radio");   	//<<<< Selects radio Type
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("indicatorType"));
			ele2.click();
			System.out.println("Q2 Sub-Question 2: Date");
		}
		

		
		
		@Test(priority = 454) //  
		private void populateRadioOptions() {	//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("Opt Value #1");
	   		ele.sendKeys(Keys.ENTER);
	   		ele.sendKeys("Opt Value #2");
	   		ele.sendKeys(Keys.ENTER);
	   		ele.sendKeys("Opt Value #3");
	   		ele.sendKeys(Keys.ENTER);
	   		ele.sendKeys("Opt Value #4");
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Populate Radio Options");
		}			
		
		
		
		
		@Test(priority = 456) //
		private void inputDefaultAnswerQ2S02() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Q2 Sub-Question 2: Default Answer");			
		}
		
		
		@Test(priority = 458) //  
		private void selectFieldRequiredQ2S02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("required"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 2: Field Required = N");
		}
		
		
		@Test(priority = 460) //  
		private void selectFieldSensitiveDataQ2S02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sensitive"));
	    	highlightElement.highLightElement(driver, ele);
	   		//ele.click();
	   		//ele.click();
	    	//waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 2: Sensitive Data = N");
		}
		
		
		
		@Test(priority = 462) //  
		private void selectSortValueQ2S02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("7");
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 2: Sort Priority");
		}
		
		
		@Test(priority = 464) //  
		private void selectQuestionSaveQ2S02() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 2: Save button");
		}
		

		
		
		
		
		
		
//Q2S03		
		//Select add sub-question									// 
		@Test(priority = 468) //  
		private void addSubQuestionQ2S03() {	//
			waitMethods.waiter(waitMethods.w300);  
			String url = driver.getCurrentUrl();
			
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
				WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
				//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Sub-question')]"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
				WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
				//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Sub-question')]"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				
			}
			
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Create sub-question Q2S03");
		}
		

		@Test(priority = 470) //
		private void inputFieldNameQ2S03() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2 Sub-question 3: Checkbox";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Q2 Sub-question 3: Input Field Name)");			
		}
		

		
		@Test(priority = 472) //
		private void inputShortLabelQ2S03() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2S03";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Test Sub-question Q2S03: Checkbox)");			
		}

		

		@Test(priority = 474) //
		public void selectTypeDateQ2S03() {         
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("indicatorType"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("indicatorType")));
			highlightElement.highLightElement(driver, ele);
			select.selectByValue("checkbox");   	//<<<< Selects checkbox Type
			waitMethods.waiter(waitMethods.w200);
			WebElement ele2 = driver.findElement(By.id("indicatorType"));
			ele2.click();
			System.out.println("Q2 Sub-Question 3: Checkbox");
		}
		

		
		@Test(priority = 476) //  
		private void populateCheckboxOptions() {	//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("indicatorSingleAnswer"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("Select Checkbox");
			waitMethods.waiter(waitMethods.w300);	
	    	System.out.println("Populate Checkbox Options");
		}			
		
		
		
		
		@Test(priority = 478) //
		private void inputDefaultAnswerQ2S03() {
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w20);
	    	}
	    	
	    	System.out.println("Q2 Sub-Question 3: Default Answer");			
		}
		
		
		@Test(priority = 480) //  
		private void selectFieldRequiredQ2S03() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("required"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 3: Field Required = N");
		}
		
		
		@Test(priority = 482) //  
		private void selectFieldSensitiveDataQ2S03() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sensitive"));
	    	highlightElement.highLightElement(driver, ele);
	   		//ele.click();
	   		//ele.click();
	    	//waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 3: Sensitive Data = N");
		}
		
		
		
		@Test(priority = 484) //  
		private void selectSortValueQ2S03() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("sort"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("8");
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 3: Sort Priority");
		}
		
		
		@Test(priority = 486) //  
		private void selectQuestionSaveQ2S03() {			//
			waitMethods.waiter(waitMethods.w300);       
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Q2 Sub-Question 3: Save button");
		}

		
		
		
//Q2S04  

		
			//Select add sub-question						
			@Test(priority = 488) //  
			private void addSubQuestionQ2S04() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[2]/div/div[2]/div/span"));
					highlightElement.highLightElement(driver, ele);
			   		ele.click();
					
				}
				waitMethods.waiter(waitMethods.w100);
		    	System.out.println("Create Question Q2S04");
			}

			


			@Test(priority = 490) //
			private void inputFieldNameQ2S04() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q2 Sub-Question 4: Checkboxes";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Q2S04: Input Field Name)");			
			}
			

			
			@Test(priority = 492) //
			private void inputShortLabelQ2S04() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q2S04";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Test Sub-question Q2S04: Checkboxes)");			
			}

			

			@Test(priority = 494) //
			public void selectTypeCheckboxes() {	//Q2S04         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("checkboxes");   	//<<<< Selects checkboxes Type
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q2S04: Select Type Checkboxes");
			}
			

			@Test(priority = 496) //  
			private void populateCheckboxesOptions() {	//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("Opt Value #1");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #2");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #3");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #4");
				waitMethods.waiter(waitMethods.w300);	
		    	System.out.println("Populate Checkboxes Options");
			}			
			
			
			
			@Test(priority = 498) //
			private void inputDefaultAnswerQ2S04() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Q2S04: Default Answer");			
			}
			
			
			@Test(priority = 500) //  
			private void selectFieldRequiredQ2S04() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		//ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q2S04: Field Required = Y");
			}
			
			
			@Test(priority = 502) //  
			private void selectFieldSensitiveDataQ2S04() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q2S04: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 504) //  
			private void selectSortValueQ2S04() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("9");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q2S04: Sort Priority");
			}
			
			
			@Test(priority = 506) //  
			private void selectQuestionSaveQ2S04() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q2 Sub-Question 3: Save button");
			}

		
			

			
			
			
//Q3
     
			//Add Section Heading:  Q3
			@Test(priority = 508) //  
			private void selectAddSectionHeadingQ3() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[2]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("//*[contains(text(), ' Add Section Heading')]"));
					// This is the XPath
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[2]"));
					highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q3");
			}
			

			@Test(priority = 510) //
			private void inputFieldNameQ3() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3: Multiselect";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Q3: Input Field Name)");			
			}
			

			
			@Test(priority = 512) //
			private void inputShortLabelQ3() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Q3: Multiselect)");			
			}

			

			@Test(priority = 514) //
			public void selectTypeMultiselect() {	//Q3         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("multiselect");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q3: Select Type Multiselect");
			}
			

			@Test(priority = 516) //  
			private void populateMultiselectOptions() {	//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("Opt Value #1");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #2");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #3");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #4");
				waitMethods.waiter(waitMethods.w300);	
		    	System.out.println("Populate Checkboxes Options");
			}			
			
			
			
			@Test(priority = 518) //
			private void inputDefaultAnswerQ3() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w20);
		    	}
		    	
		    	System.out.println("Q3: Default Answer");			
			}
			
			
			@Test(priority = 520) //  
			private void selectFieldRequiredQ3() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3: Field Required = N");
			}
			
			
			@Test(priority = 522) //  
			private void selectFieldSensitiveDataQ3() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 524) //  
			private void selectSortValueQ3() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("10");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3: Sort Priority");
			}
			
			
			@Test(priority = 526) //  
			private void selectQuestionSaveQ3() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3: Save button");
			}

			
			
			
			
			
			
					
			
			
//Q3S01

			//Select add sub-question
			@Test(priority = 528) //  
			private void addSubQuestionQ3S01() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[3]/div/div[2]/div/span"));
					//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Sub-question')]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[3]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q3S01");
			}
			

			@Test(priority = 530) //
			private void inputFieldNameQ3S01() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3S01: Dropdown";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q3S01: Input Field Name)");			
			}
			

			
			@Test(priority = 532) //
			private void inputShortLabelQ3S01() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3S01";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Test Sub-question Q3S01: Dropdown)");			
			}

			

			@Test(priority = 534) //
			public void selectTypeDropdown() {	//Q3S01         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("dropdown");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q3S01: Select Type Checkboxes");
			}
			

			@Test(priority = 536) //  
			private void populateDropdownOptions() {	//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("Dropdown Value #1");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Dropdown Value #2");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Dropdown Value #3");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Dropdown Value #4");
				waitMethods.waiter(waitMethods.w300);	
		    	System.out.println("Populate Dropdown Options");
			}			
			
			
			
			@Test(priority = 538) //
			private void inputDefaultAnswerQ3S01() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q3S01: Default Answer");			
			}
			
			
			@Test(priority = 540) //  
			private void selectFieldRequiredQ3S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		//ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S01: Field Required = Y");
			}
			
			
			@Test(priority = 542) //  
			private void selectFieldSensitiveDataQ3S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S01: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 544) //  
			private void selectSortValueQ3S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("11");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S01: Sort Priority");
			}
			
			
			@Test(priority = 546) //  
			private void selectQuestionSaveQ3S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S01: Save button");
			}

						
			

			
//Q3S02   fileupload


			//Select add sub-question
			@Test(priority = 548) //  
			private void addSubQuestionQ3S02() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[3]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[3]/div/div[2]/div/span"));
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[3]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q3S02");
			}
			

			@Test(priority = 550) //
			private void inputFieldNameQ3S02() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3S02: File Attachment";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q3S02: Input Field Name)");			
			}
			

			
			@Test(priority = 552) //
			private void inputShortLabelQ3S02() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3S02";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Test Sub-question Q3S02: File Attachment)");			
			}

			

			@Test(priority = 554) //
			public void selectTypeFileAttachment() {	//Q3S02         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("fileupload");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q3S02: Select Type File Attachment");
			}
			
// Not used for type: File Attachment
//			@Test(priority = 556) //  
//			private void populateDropdownOptions() {	//
//				waitMethods.waiter(waitMethods.w300);       
//				WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
//		    	highlightElement.highLightElement(driver, ele);
//		   		ele.sendKeys("Dropdown Value #1");
//		   		ele.sendKeys(Keys.ENTER);
//		   		ele.sendKeys("Dropdown Value #2");
//		   		ele.sendKeys(Keys.ENTER);
//		   		ele.sendKeys("Dropdown Value #3");
//		   		ele.sendKeys(Keys.ENTER);
//		   		ele.sendKeys("Dropdown Value #4");
//				waitMethods.waiter(waitMethods.w300);	
//		    	System.out.println("Populate Dropdown Options");
//			}			
			
			
			
			@Test(priority = 558) //
			private void inputDefaultAnswerQ3S02() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q3S02: Default Answer");			
			}
			
			
			@Test(priority = 560) //  
			private void selectFieldRequiredQ3S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S02: Field Required = N");
			}
			
			
			@Test(priority = 562) //  
			private void selectFieldSensitiveDataQ3S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S02: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 564) //  
			private void selectSortValueQ3S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("12");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S02: Sort Priority");
			}
			
			
			@Test(priority = 566) //  
			private void selectQuestionSaveQ3S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S02: Save button");
			}
			

			
			
			
					
//Q3S03   image			Text = Image Attachment

			//Select add sub-question
			@Test(priority = 568) //  
			private void addSubQuestionQ3S03() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();
				
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[3]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[3]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q3S03");
			}
			

			
			@Test(priority = 570) //
			private void inputFieldNameQ3S03() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3S03: Image Attachment";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q3S03: Input Field Name)");			
			}
			

			
			@Test(priority = 572) //
			private void inputShortLabelQ3S03() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q3S03";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Test Sub-question Q3S03: Image Attachment)");			
			}

			

			@Test(priority = 574) //
			public void selectTypeImageAttachment() {	//Q3S03         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("image");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q3S03: Select Type Image Attachment");
			}
			
// Not used for type: Image Attachment
//						@Test(priority = 575) //  
//						private void populateDropdownOptions() {	//
//							waitMethods.waiter(waitMethods.w300);       
//							WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
//					    	highlightElement.highLightElement(driver, ele);
//					   		ele.sendKeys("Dropdown Value #1");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #2");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #3");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #4");
//							waitMethods.waiter(waitMethods.w300);	
//					    	System.out.println("Populate Image Options");
//						}			
			
			
			
			@Test(priority = 576) //
			private void inputDefaultAnswerQ3S03() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q3S03: Default Answer");			
			}
			
			
			@Test(priority = 578) //  
			private void selectFieldRequiredQ3S03() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S03: Field Required = N");
			}
			
			
			@Test(priority = 580) //  
			private void selectFieldSensitiveDataQ3S03() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
				//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S03: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 582) //  
			private void selectSortValueQ3S03() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("13");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S03: Sort Priority");
			}
			
			
			@Test(priority = 584) //  
			private void selectQuestionSaveQ3S03() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q3S03: Save button");
			}


				
				
						
//Q4		orgchart_group			Orgchart Group	
			
			//Select add Section Heading
			@Test(priority = 586) //  					*****  Errs Here  *****
			private void addSubQuestionQ4() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[2]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();				
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Section Heading')]"));
					//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[2]"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q4");
			}
			

			@Test(priority = 588) //
			private void inputFieldNameQ4() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q4: Orgchart Group";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q4: Input Field Name)");			
			}
			

			
			@Test(priority = 590) //
			private void inputShortLabelQ4() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q4";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Test Sub-question Q4: Orgchart Group)");			
			}

			

			@Test(priority = 592) //
			public void selectTypeOrgChartGroup() {	//Q4         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("orgchart_group");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q4: Select Type Orgchart Group");
			}
			
// Not used for type: Image Attachment
//						@Test(priority = 593) //  
//						private void populateDropdownOptions() {	//
//							waitMethods.waiter(waitMethods.w300);       
//							WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
//					    	highlightElement.highLightElement(driver, ele);
//					   		ele.sendKeys("Dropdown Value #1");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #2");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #3");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #4");
//							waitMethods.waiter(waitMethods.w300);	
//					    	System.out.println("Populate Image Options");
//						}			
			
			
			
			@Test(priority = 594) //
			private void inputDefaultAnswerQ4() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q4: Default Answer");			
			}
			
			
			@Test(priority = 596) //  
			private void selectFieldRequiredQ4() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4: Field Required = N");
			}
			
			
			@Test(priority = 598) //  
			private void selectFieldSensitiveDataQ4() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
				//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 600) //  
			private void selectSortValueQ4() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("14");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4: Sort Priority");
			}
			
			
			@Test(priority = 602) //  
			private void selectQuestionSaveQ4() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4: Save button");
			}
			
					
			
			
			
			
//Q4S01		orgchart_position			Orgchart Position	
			
			//Select add Section Heading
			@Test(priority = 604) //  
			private void addSubQuestionQ4S01() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();		
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[4]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[4]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q4S01");
			}
			

			@Test(priority = 606) //
			private void inputFieldNameQ4S01() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q4S01: Orgchart Position";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q4S01: Input Field Name)");			
			}
			

			
			@Test(priority = 608) //
			private void inputShortLabelQ4S01() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q4S01";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Test Sub-question Q4S01: Orgchart Position)");			
			}

			

			@Test(priority = 610) //
			public void selectTypeOrgChartPosition() {	//Q4S01         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("orgchart_position");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q4S01: Select Type Orgchart Position");
			}
			
// Not used for type: Image Attachment
//						@Test(priority = 611) //  
//						private void populateDropdownOptions() {	//
//							waitMethods.waiter(waitMethods.w300);       
//							WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
//					    	highlightElement.highLightElement(driver, ele);
//					   		ele.sendKeys("Dropdown Value #1");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #2");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #3");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #4");
//							waitMethods.waiter(waitMethods.w300);	
//					    	System.out.println("Populate Image Options");
//						}			
			
			
			
			@Test(priority = 612) //
			private void inputDefaultAnswerQ4S01() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q4S01: Default Answer");			
			}
			
			
			@Test(priority = 614) //  
			private void selectFieldRequiredQ4S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S01: Field Required = N");
			}
			
			
			@Test(priority = 616) //  
			private void selectFieldSensitiveDataQ4S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S01: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 618) //  
			private void selectSortValueQ4S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("15");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S01: Sort Priority");
			}
			
			
			@Test(priority = 620) //  
			private void selectQuestionSaveQ4S01() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S01: Save button");
			}	
			

			
			
			
			

//Q4S02		orgchart_employee			Orgchart Employee	
			
			//Select add Section Heading
			@Test(priority = 622) //  
			private void addSubQuestionQ4S02() {	//
				waitMethods.waiter(waitMethods.w300);  
				String url = driver.getCurrentUrl();
				if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
					WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[1]/div[4]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();				
				} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
					WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div[1]/div[2]/div[2]/div/div[1]/div[4]/div/div[2]/div/span"));
			    	highlightElement.highLightElement(driver, ele);
			   		ele.click();
				}
				
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q4S02");
			}
			

			@Test(priority = 624) //
			private void inputFieldNameQ4S02() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q4S02: Orgchart Employee";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q4S02: Input Field Name)");			
			}
			

			
			@Test(priority = 626) //
			private void inputShortLabelQ4S02() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q4S02";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Test Sub-question Q4S02: Orgchart Employee)");			
			}

			

			@Test(priority = 628) //
			public void selectTypeOrgChartEmployee() {	//Q4S02         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("orgchart_employee");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q4S02: Select Type Orgchart Employee");
			}
			
// Not used for type: Image Attachment
//						@Test(priority = 629) //  
//						private void populateDropdownOptions() {	//
//							waitMethods.waiter(waitMethods.w300);       
//							WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
//					    	highlightElement.highLightElement(driver, ele);
//					   		ele.sendKeys("Dropdown Value #1");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #2");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #3");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #4");
//							waitMethods.waiter(waitMethods.w300);	
//					    	System.out.println("Populate Image Options");
//						}			
			
			
			
			@Test(priority = 630) //
			private void inputDefaultAnswerQ4S02() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q4S02: Default Answer");			
			}
			
			
			@Test(priority = 632) //  
			private void selectFieldRequiredQ4S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S02: Field Required = N");
			}
			
			
			@Test(priority = 634) //  
			private void selectFieldSensitiveDataQ4S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S02: Sensitive Data = N");
			}
			
			
			
			@Test(priority = 636) //  
			private void selectSortValueQ4S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("16");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S02: Sort Priority");
			}
			
			
			@Test(priority = 638) //  
			private void selectQuestionSaveQ4S02() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q4S02: Save button");
			}	

			
			
	
			

			
//Q5		raw_data					Raw Data (for programmers)			
		
			//Select add Section Heading
			@Test(priority = 640) //  									// ERR PP
			private void selectAddSectionHeadingQ5() {	//
				waitMethods.waiter(waitMethods.w300);  //    
				//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div/div[2]"));
				WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Section Heading')]"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Create Question Q5");
			}
			

			@Test(priority = 642)										 // ERR PP
			private void inputFieldNameQ5() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("name"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q5: Raw Data";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q5: Input Field Name)");			
			}
			

			
			@Test(priority = 644) //										 // ERR PP
			private void inputShortLabelQ5() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("description"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "Q5";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Test Sub-question Q5: Raw Data)");			
			}

			

			@Test(priority = 646) //										 // ERR PP
			public void selectTypeRawData() {	//Q5         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w300);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("raw_data");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q5: Select Type Raw Data");
			}
			
// Not used for type: Image Attachment
//						@Test(priority = 647) //  
//						private void populateDropdownOptions() {	//
//							waitMethods.waiter(waitMethods.w300);       
//							WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
//					    	highlightElement.highLightElement(driver, ele);
//					   		ele.sendKeys("Dropdown Value #1");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #2");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #3");
//					   		ele.sendKeys(Keys.ENTER);
//					   		ele.sendKeys("Dropdown Value #4");
//							waitMethods.waiter(waitMethods.w300);	
//					    	System.out.println("Populate Image Options");
//						}			
			
			
			
			@Test(priority = 648) 												// ERR PP
			private void inputDefaultAnswerQ5() {
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("default"));
		    	highlightElement.highLightElement(driver, ele);
		    	
		    	String name = "";
		   
		    	for(int i = 0; i < name.length(); i++) {
		    		char c = name.charAt(i);
		    		String s = new StringBuilder().append(c).toString();
		    		ele.sendKeys(s);
		    		waitMethods.waiter(waitMethods.w10);
		    	}
		    	
		    	System.out.println("Q5: Default Answer");			
			}
			
			@Test(priority = 650) //  										 // ERR PP
			private void selectFieldRequiredQ5() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("required"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q5: Field Required = N");
			}
			
			@Test(priority = 652) // 										 // ERR PP 
			private void selectFieldSensitiveDataQ5() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sensitive"));
		    	highlightElement.highLightElement(driver, ele);
		   		//ele.click();
		   		//ele.click();
		    	//waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q5: Sensitive Data = N");
			}
			
			
			@Test(priority = 654) //  										 // ERR PP
			private void selectSortValueQ5() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("sort"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("17");
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q5: Sort Priority");
			}
			
			@Test(priority = 656) //  										 // ERR PP
			private void selectQuestionSaveQ5() {			//
				waitMethods.waiter(waitMethods.w300);       
				WebElement ele = driver.findElement(By.id("button_save"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
		    	System.out.println("Q5: Save button");
			}	

			
			
//********************  Form Complete **************************************	
			
		
															 //(By.xpath("//*[contains(text(), 'Add Sub-question')]"));
// View History		XPath:  /html/body/div[1]/div/div/div[1]/div[6]   or "//*[contains(text(), 'Text to search for')}"));

//Next Page			id: next
// Back				id: prev
//close form		XPath:    /html/body/div[5]/div[1]/button/span[1]
//		
			
//Staple form - then remove form			
			
			
			
			
			
/*  /////// FORM EDITOR Main Screen Element Locators \\\\\\
					
		  	
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
		  			
*/	

			//Incorporated into Framework.dateAndTimeMethods
//	public String getDate() {
//	      String pattern = "MM/dd HH:mm";
//	      SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
//
//	      String date = simpleDateFormat.format(new Date());
//	      System.out.println(date);
//	      
//	      return date;
//	}

			/*	IF TEMPLATE	
			String url = driver.getCurrentUrl();
			
			if(url.substring(0, 20).equals(AppVariables.PROD_DOMAIN)) {   
			
			} else if (url.substring(0, 28).equals(AppVariables.PREPROD_DOMAIN)) {
			
			}

		*/		
			
			
			
			
}  //class
	