/*
package Execution;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;

import java.util.Date;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.openqa.selenium.support.ui.Select;			//Select Method

import Framework.highlightElement;

//public class formsWorkflowPart3 extends setupFramew{

	//private static final DateFormat Calendar = null;
	Date date = new Date();

//	@BeforeMethod
//	@BeforeClass
//	public void setUp()  {
//		if(driver!= null) {
//			driver=getDriver();   //   Also have a valid ChromeDriver here
//			//System.out.println("Driver established for: " + driver.getClass());
//			//driver.manage().timeouts().wait(Framework.waitMethods.w100);
//		}
//	}


	//Cert test in the event this is starting page for tests
	//Complete: Add if logic in the event the cert page does not appear.   Achieved via Try/Catch
	@Test(priority = 1) //MUST REMAIN #1 ( or zero)
	private void testForCertPage()
throws InterruptedException
 {
	    try {
	    	//waitMethods.implicitWait(waitMethods.w300);
	    	waitMethods.waiter(waitMethods.w300);
	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();

	    	waitMethods.waiter(waitMethods.w300);

	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost")); //.click();
	        highlightElement.highLightElement(driver, ele2);
	        ele2.click();
	        System.out.println("Certificate not found, proceeding to unsecure site");
	    } catch (NoSuchElementException e) {
	        System.out.println("Certificate present, proceeding ");
	    }
	}

/////////////////////////////     Forms Workflow Part THREE      \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\




//		@Test(priority = 310) //
//		private void initializePOM() {			//
//			waitMethods.waiter(waitMethods.w300);
//			WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[1]/div[3]"));
//	    	highlightElement.highLightElement(driver, ele);
//	   		ele.click();
//			waitMethods.waiter(waitMethods.w300);
//	    	System.out.println("Clicked Import Form as Test");
//
//	    	driver.navigate().back();
//		}




		//Select Work-in-progress Form build using formsWorkflow.java
		@Test(priority = 325)  //Select the form that is in first position (top left)
		private void selectCurrentFormByXpath() {
			//
			waitMethods.waiter(waitMethods.w1k);  //    Either should work, the 1st is Xpath for the AUT element, 2nd is for description
			//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div[1]/div[2]]"));
			WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div[1]/div[1]"));
			//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div[1]/div[1]"));
			//WebElement ele = driver.findElement(By.xpath("//div[text() = 'AUT']"));
			//WebElement ele = driver.findElement(By.xpath("//div[contains(text(), 'AUT')]"));
			highlightElement.highLightElement(driver, ele);
	    	ele.click();
	   		waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Select first form top left");


//			waitMethods.waiter(waitMethods.w500);  //     /html/body/div[1]/div/div/div[2]/div[2]/div[1]/div[2]
//			//WebElement ele = driver.findElement(By.xpath("//*[text()='AUT']"));
//
//			WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[2]/div[2]/div[1]/div[2]"));
//			//WebElement ele = driver.findElement(By.xpath("/html/body/div[2]/div/div/div[2]/div[2]/div[1]/div[2]"));
//	    	highlightElement.highLightElement(driver, ele);
//	    	ele.click();
//	   		waitMethods.waiter(waitMethods.w300);
//	    	System.out.println("Select first form top left");
		}


		@Test(priority = 405) //
		private void viewHistory() {			//
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[1]/div[6]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Clicked View History");
		}


		//Need if logic in the event there is no 'next' page - DONE
		@Test(priority = 410) //
		private void viewHistoryNext() {			//
			waitMethods.waiter(waitMethods.w300);
			List<WebElement> eleVisible = driver.findElements(By.id("next"));
			if(eleVisible.size()!=0) {
				WebElement ele = driver.findElement(By.id("next"));
		    	highlightElement.highLightElement(driver, ele);
		   		ele.click();
				waitMethods.waiter(waitMethods.w300);
				System.out.println("Clicked View History -> Next");

			} else if(eleVisible.size()==0) {
				System.out.println("Next button not available");
			}
		}


		@Test(priority = 415) //
		private void viewHistoryBack() {			//
			waitMethods.waiter(waitMethods.w300);     //
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


		@Test(priority = 420) //
		private void viewHistoryClose() {			//
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[1]/button/span[1]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w200);
	    	System.out.println("Clicked View History -> Close");
		}



		////////////////    Staple Form    \\\\\\\\   Has to be a form without a workflow - Use Staple Form

		@Test(priority = 425) //  Staple form question given Sort Priority = 20 - Observe where it appears
		private void selectStapleForm() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Staple other form')]"));
			//WebElement ele = driver.findElement(By.cssSelector("#formEditor_form > div > div.buttonNorm"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Staple: Staple Form");
		}




		@Test(priority = 430) //
		private void selectFormToMergeButton() {
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[2]/div/main/div/span"));
			//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Select a form to merge')]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Select a form to merge/staple");
		}





		@Test(priority = 435) //  Err here - No form (Staple Form 01)????
		public void selectFormToBeStapled() {
			//waitMethods.implicitWait(waitMethods.w300);
			waitMethods.waiter(waitMethods.w300);			//The below opens the DDL
			WebElement ele = driver.findElement(By.id("stapledCategoryID"));
			highlightElement.highLightElement(driver, ele);
			ele.click();
			waitMethods.waiter(waitMethods.w300);
			Select select = new Select(driver.findElement(By.id("stapledCategoryID")));
			highlightElement.highLightElement(driver, ele);
			//select.selectByValue("76");
			select.selectByVisibleText("Staple Form 01");
			waitMethods.waiter(waitMethods.w300);
			WebElement ele2 = driver.findElement(By.id("stapledCategoryID"));
			ele2.click();
			System.out.println("Staple Form Selected");
		}



		@Test(priority = 440) //
		private void saveStapledFormSelection() {			//
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.id("button_save"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Save Stapled Form Selection");
		}


		@Test(priority = 445) //
		private void closeStapleFormDialogue() {	//    /html/body/div[5]/div[1]/button/span[1]
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[1]/button/span[1]"));
	    	highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Close Staple Form Dialogue");
		}


		@Test(priority = 450) //   VIEW ALL FORMS
		private void selectViewAllForms() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'View All Forms')]"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Select View All Form");	//exiting and reentering
		}


		@Test(priority = 455)  //
		private void selectCurrentFormByXpath02() {
			selectCurrentFormByXpath();
		}



//====================================================================================

	@Test(priority = 465) //
		private void verifyStapledForm() {			//

			String strExpected = "Staple Form 01";

			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Staple Form 01')]"));
			//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Staple Form 01')]"));
	    	highlightElement.highLightElement(driver, ele);

	   		String strActual = ele.getText().toString();
	   		Assert.assertEquals(strActual, strExpected);
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Verify form was Stapled");
		}



		@Test(priority = 470) //  Staple form question given Sort Priority = 20 - Observe where it appears
		private void selectStapleForm02() {
			selectStapleForm();
		}

//		@Test(priority = 472) //  Select Staple other form
//		private void stapleForm02() {
//			selectStapleForm();
//		}


		@Test(priority = 475) //  Remove form
		private void removeStapledForm() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.partialLinkText("Remove"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Remove Stapled Form");
		}


		@Test(priority = 480) //
		private void closeStapledFormDialogue() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.xpath("/html/body/div[5]/div[1]/button/span[1]"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Remove Stapled Form");
		}



			////////////////    Add Internal-Use    \\\\\\\

		@Test(priority = 485) //
		private void addInternalUseForm() {
			waitMethods.waiter(waitMethods.w300);   //    /html/body/div[1]/div/div/div[1]/div[3]
			WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/div[1]/div[3]"));
	    	highlightElement.highLightElement(driver, ele);
	    	ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("click on + Add Internal-Use");
		}


		@Test(priority = 490) //
		private void inputFormLabel() {
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.id("name"));
	    	highlightElement.highLightElement(driver, ele);

	    	String name = "Internal Use Form";

	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w30);
	    	}

	    	System.out.println("Input Form Label");
		}



		@Test(priority = 495) //
		private void inputFormDesc() {
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);

	    	String name = "Internal Use Form Description";

	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w30);
	    	}

	    	System.out.println("Input Form Description");
		}



		@Test(priority = 500) //  Cancel form
		private void cancelInternalUseForm() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.id("button_cancelchange"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Cancel Internal Use Form");
		}

		//// Begin creating new Internal Use Form (above case deleted it)

		@Test(priority = 505) //
		private void addInternalUseForm02() {
			addInternalUseForm();
		}


		@Test(priority = 510) //
		private void inputFormLabel02() {
			inputFormLabel();
		}



		@Test(priority = 515) //
		private void inputFormDesc02() {
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.id("description"));
	    	highlightElement.highLightElement(driver, ele);

	    	String name = "Internal Use Form Description";

	    	for(int i = 0; i < name.length(); i++) {
	    		char c = name.charAt(i);
	    		String s = new StringBuilder().append(c).toString();
	    		ele.sendKeys(s);
	    		waitMethods.waiter(waitMethods.w30);
	    	}

	    	System.out.println("Input Form Description");
		}


		@Test(priority = 520) //  Save form
		private void saveInternalUseForm() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.id("button_save"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Save Internal Use Form");
		}


		/////////// Internal Use form created, BUT it is not visible until you exit and come back in

		@Test(priority = 525) //   VIEW ALL FORMS
		private void selectViewAllForms02() {
			waitMethods.waiter(waitMethods.w300);   //
				selectViewAllForms();
			}


		@Test(priority = 530)  //Select the form that is in first position (top left)
		private void selectCurrentFormByXpath03() {
			selectCurrentFormByXpath();
		}



		@Test(priority = 535) //
		private void verifyInternalUseForm() {			//

			String strExpected = "Internal Use Form";
			System.out.println(strExpected);

			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Internal Use Form')]"));
	    	highlightElement.highLightElement(driver, ele);

	   		String strActual = ele.getText().toString();

	   		System.out.println(strActual);

	   		Assert.assertEquals(strActual, strExpected);
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Verify Internal Use form was Created");
		}


		@Test(priority = 540) //
		private void selectInternalUseForm() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Internal Use Form')]"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Select Internal Use Form");	//will delete in next method
		}


		@Test(priority = 545) //
		private void deleteInternalUseForm() {
			waitMethods.waiter(waitMethods.w300);   //
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Delete this form')]"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Select Internal Use Form");	//will delete in next method
		}



		@Test(priority = 550) //
		private void confirmDeleteInternalUseForm() {
			waitMethods.waiter(waitMethods.w300);   // confirm_button_save
			WebElement ele = driver.findElement(By.id("confirm_button_save"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Delete Internal Use Form");	//delete IU Form
		}



		@Test(priority = 555)  //Select the form that is in first position (top left)
		private void selectCurrentFormByXpath04() {
			selectCurrentFormByXpath();
		}



		@Test(priority = 560) //
		private void selectExportForm() {
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Export Form')]"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Export Form");
		}


		@Test(priority = 565) //   VIEW ALL FORMS
		private void selectViewAllForms03() {
			waitMethods.waiter(waitMethods.w300);   //
				selectViewAllForms();
			}



		@Test(priority = 570) //
		private void selectImportForm() {
			waitMethods.waiter(waitMethods.w300);
			WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Import Form')]"));
			highlightElement.highLightElement(driver, ele);
	   		ele.click();
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Select Import Form");
		}


		@Test(priority = 575) //
		private void chooseFileToImport() {
			waitMethods.waiter(waitMethods.w300);
			//WebElement ele = driver.findElement(By.xpath("/html/body/div[1]/div/div/form/div[1]/input"));
			//WebElement ele = driver.findElement(By.xpath("//*[contains(text(), 'Choose File')]"));
			WebElement ele = driver.findElement(By.id("formPacket"));
			highlightElement.highLightElement(driver, ele);
	   		ele.sendKeys("C:\\Users\\MaxRichard\\Documents\\QA\\LEAF-Exports\\LEAF_Form_AUT_2021-11-12.txt");
			waitMethods.waiter(waitMethods.w300);
	    	System.out.println("Choose File To Import");
		}



////////////////////////  Change Form Name and Priority, setting up for next run \\\\\\\\\\\\\\\\\


	@Test(priority = 577)  //Select the form
	private void selectCurrentFormByXpath01() {
		selectCurrentFormByXpath();
	}

	@Test(priority = 580) //
	private void selectEditProperties02() {
		waitMethods.waiter(waitMethods.w250);
		//WebElement ele = driver.findElement(By.xpath("//*[text()='Edit Properties']"));
		WebElement ele = driver.findElement(By.id("editFormData"));
	    	highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w250);
    	System.out.println("Forms - clicked Edit Properties");
	}






	@Test(priority = 585) //
	private void changeFormName() {
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("name"));
    	highlightElement.highLightElement(driver, ele);
    	ele.clear();

    	String name = "Automation Test Run " + dateAndTimeMethods.getDate().toString();

    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}

   	    	System.out.println("Changed Form Name to Automation Test Run");
	}


	@Test(priority = 590) //
	private void changeDescription() {
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("description"));
    	highlightElement.highLightElement(driver, ele);
    	ele.clear();

    	String name = "Test Form Description " + dateAndTimeMethods.getDate().toString();

    	for(int i = 0; i < name.length(); i++) {
    		char c = name.charAt(i);
    		String s = new StringBuilder().append(c).toString();
    		ele.sendKeys(s);
    		waitMethods.waiter(waitMethods.w30);
    	}

   	    	System.out.println("Changed Description to Test Form Description + getDate()");
	}



	@Test(priority = 595) //  Accepts pos & neg integers
	private void selectSortPriority02() {
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("sort"));
    	highlightElement.highLightElement(driver, ele);
    	ele.clear();
   		ele.sendKeys("0");
		waitMethods.waiter(waitMethods.w250);
    	System.out.println("Forms-Selected Sort Priority");
	}




	@Test(priority = 600) //
	private void selectSave() {
		waitMethods.waiter(waitMethods.w250);
		WebElement ele = driver.findElement(By.id("button_save"));
    	highlightElement.highLightElement(driver, ele);
   		ele.click();
		waitMethods.waiter(waitMethods.w250);
    	System.out.println("Forms - clicked Save");
	}



	/// Confirm Method
//	@Test(priority = 9990)     //
//	private void displayCompleteAlert() {
//		//waitMethods.implicitWait(waitMethods.w250);
//		waitMethods.waiter(waitMethods.w100);		//
//
//			JavascriptExecutor js = (JavascriptExecutor) driver;
//			//js.executeScript("window.scrollBy(0,250)", "");
//			js.executeScript("let msg = ' LEAF Automated Test Suite Complete. Complete\\n THANK YOU FOR YOUR PARTICIPATION!!!'");
//			js.executeScript("if (confirm(msg) == true");
//				driver.switchTo().alert().dismiss();
//				driver.quit();
//				System.out.println("setupFramework reached @AfterClass, driver.quit()");
////				System.out.println("@AfterClass disabled - browser remains open");
//
//			//js.executeScript("confirm(' LEAF Automated Test Suite Complete. Complete\\n THANK YOU FOR YOUR PARTICIPATION!!!')");
//
//	}


	@Test(priority = 9990)     //
	private void displayCompleteAlert() {
		//waitMethods.implicitWait(waitMethods.w250);
		waitMethods.waiter(waitMethods.w100);		//

			JavascriptExecutor js = (JavascriptExecutor) driver;
			//js.executeScript("window.scrollBy(0,250)", "");
			js.executeScript("confirm(' LEAF Automated Test Suite Complete. Complete\\n THANK YOU FOR YOUR PARTICIPATION!!!')");

	}







//	@Test(priority = 9993)
//	void dismissJSAlert() {
//		waitMethods.waiter(waitMethods.w8k);
//		driver.switchTo().alert().dismiss();
//
//	}



//	@Test(priority = 9996)
//	public void closeDown() {
//
//		//driver.quit();
//		//System.out.println("setupFramework reached @AfterClass, driver.quit()");
//		System.out.println("@AfterClass disabled - browser remains open");
//	}






		Internal-Use Form
		Form Label:						name
		Form Description				description
		Save							button_save
		Cancel							button_cancelchange
		close (x)						/html/body/div[3]/div[1]/button/span[1]


		Internal Use Form
		Select btn						Use Contains     XPath: /html/body/div[1]/div/div/div[1]/div[10]


		 After Form Created text		 Add Internal-Use





// Documentation can be found in formsWorkflow and formsWorkflowPart2





}  //class
*/
