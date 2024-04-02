package test.java.Framework;


import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;


public class highlightElement {

	// Call:  highlightElement.highLightElement(driver, ele);
	public static void highLightElement(WebDriver driver, WebElement ele) {
		int i = 0;	
		int j = 50;
		if (AppVariables.demoMode) {   //Set T/F in test.java.Framework.AppVariables.demoMode
			JavascriptExecutor js = (JavascriptExecutor) driver; 
		 
			for(i = 0; i <3; i++) {
				//if(i == 3) {j =200;}
					js.executeScript("arguments[0].setAttribute('style', 'background: yellow; border: 2px solid red;');", ele);
					waitMethods.waiter(j);
				 
					js.executeScript("arguments[0].setAttribute('style','border: solid 2px white');", ele);
					waitMethods.waiter(j);
				//}
			
			}
		}
	}
	
	/*
	 * This method helps, but I still have to insert:
	 * in front of driver. as I currently have, 
	 * 1. put WebElement ele=  (driver.findElement....
	 * 2. get rid of corresponding action such as .click(), sendKeys() etc.
	 * 3 Then add: Helper.highlightElement(driver, ele); to each @test
	 * 4. write this line afterwards:  ele.action   where action is .sendKeys(), .click(), etc.
	 */
	
} //class
