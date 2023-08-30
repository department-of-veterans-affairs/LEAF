package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import java.text.SimpleDateFormat;

import java.util.Date;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.NoSuchElementException;
import org.testng.annotations.BeforeClass;

import Framework.setupFramework;
import Framework.waitMethods;
import Framework.highlightElement;


public class _TestNG_FrameworkRefactor extends setupFramework {

	//private static final DateFormat Calendar = null;
	Date date = new Date();
	
	@BeforeMethod
	@BeforeClass
	public void setUp()  {
		if(driver!= null) {
			driver=getDriver(); 
		}
	}
	

	@Test(priority = 1) 
	private void testForCertPage() throws InterruptedException {
		
		try {
	    	//waitMethods.implicitWait(waitMethods.w300);
	    	waitMethods.waiter(waitMethods.w300);
	    	WebElement ele = driver.findElement(By.id("details-button")); 
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

	//Adding a line for the purpose of checking git.
	
	
		@Test(priority = 380)  //Select the form that is in first position (top left)
		private void selectCurrentFormByXpath() {	
			waitMethods.waiter(waitMethods.w250);  //            
			WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div[1]/div[2]"));
			//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div[1]/div[2]"));
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();
	   		waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Select first form top left");
		}	
	

		
		@Test(priority = 382) //  
		private void selectAddSectionHeading02() {			
			waitMethods.waiter(waitMethods.w300);   //   "//*[contains(text(), 'Test Q2 Currency')]"));
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Add Section Heading')]"));
			//WebElement ele = driver.findElement(By.cssSelector("#formEditor_form > div > div.buttonNorm"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w250);
	    	System.out.println("Test Question: +Add Section Heading)");
		}


		

		@Test(priority = 384) //
		private void inputFieldName02() {
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Test Q2 Currency";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w30);
	    	}
	    	
	    	System.out.println("Test Question: Currency");			
		}
		

		
		@Test(priority = 386) //
		private void inputShortLabel02() {
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "Q2";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w30);
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
			waitMethods.waiter(waitMethods.w250);
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
			waitMethods.waiter(waitMethods.w250);       
			WebElement ele = driver.findElement(By.id("default"));
	    	highlightElement.highLightElement(driver, ele);
	    	
	    	String name = "";
	    	//String name = "MR Test Default Response Q2";
	   
	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w30);
	    	}
	    	
	    	System.out.println("Test Question: input Default Answer Q2");			
		}
		
		

			@Test(priority = 514) //
			public void selectTypeMultiselect() {	//Q3         
				//waitMethods.implicitWait(waitMethods.w300);
				waitMethods.waiter(waitMethods.w200);			
				WebElement ele = driver.findElement(By.id("indicatorType"));
				highlightElement.highLightElement(driver, ele);
				ele.click();
				waitMethods.waiter(waitMethods.w250);
				Select select = new Select(driver.findElement(By.id("indicatorType")));
				highlightElement.highLightElement(driver, ele);
				select.selectByValue("multiselect");   	//<<<< Selects Type ID from HTML
				waitMethods.waiter(waitMethods.w200);
				WebElement ele2 = driver.findElement(By.id("indicatorType"));
				ele2.click();
				System.out.println("Q3: Select Type Checkboxes");
			}
			

			@Test(priority = 516) //  
			private void populateMultiselectOptions() {	//
				waitMethods.waiter(waitMethods.w250);       
				WebElement ele = driver.findElement(By.id("indicatorMultiAnswer"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.sendKeys("Opt Value #1");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #2");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #3");
		   		ele.sendKeys(Keys.ENTER);
		   		ele.sendKeys("Opt Value #4");
				waitMethods.waiter(waitMethods.w250);	
		    	System.out.println("Populate Checkboxes Options");
			}			
			
			
					
	//Need if logic in the event there is no 'next' page		
		@Test(priority = 703) //  
		private void viewHistoryNext() {			//
			waitMethods.waiter(waitMethods.w200);       
			List<WebElement> eleVisible = driver.findElements(By.id("next")); 
			if(eleVisible.size()!=0) {
				WebElement ele = driver.findElement(By.id("next"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w200);
				System.out.println("Clicked View History -> Next");
				
			} else if(eleVisible.size()==0) {
				System.out.println("Next button not available");
			}
		}			
			
			
			
		@Test(priority = 706) //  
		private void viewHistoryBack() {			//
			waitMethods.waiter(waitMethods.w200);     //			
			List<WebElement> eleVisible = driver.findElements(By.id("prev")); 
			if(	eleVisible.size()!=0) {
				WebElement ele = driver.findElement(By.id("prev"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w200);
		    	System.out.println("Clicked View History -> Previous");
			} else if(eleVisible.size()==0) {
				System.out.println("Previous button not available");
			}
			
		}			
			
			
		
		
		@Test(priority = 709) //  
		private void viewHistoryClose() {			//
			waitMethods.waiter(waitMethods.w200);       
			WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[1]/button/span[1]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w200);
	    	System.out.println("Clicked View History -> Close");
		}				
		
		
		
		
		
		
		
		
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

	
	public String getDate() {
	      String pattern = "MM/dd HH:mm";
	      SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);

	      String date = simpleDateFormat.format(new Date());
	      System.out.println(date);
	      
	      return date;
	}

	
}  //class
	