package Execution;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.*;
import org.openqa.selenium.WebElement;
import org.junit.Test;
import org.junit.Rule;
import static org.junit.Assert.*;
import Framework.TestData;
import Execution.login;

public class HomePage {



	//Set up WebDriver for this class
	//WebDriver chromeDriver = new ChromeDriver();
	
	//System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHDRIVERPATH);
	//WebDriver chromeDriver = new ChromeDriver();

	//login Login = new login();
	
	
	
	@Test
	public void loginHomePage() {
	
		//goto Home Page
		try {
			login Login = new login();
			Login.siteLogin();					//run login
		} catch (Exception e) {
			System.out.println("Caught during login: " + e);
			e.printStackTrace();
		}	
	}	
		
	
	@Test	// search inputbox
	public void searchBoxBasic() {
		try {
			login.chromeDriver.findElement(By.name(TestData.S_BASIC_N)).sendKeys(TestData.SEARCHBASIC_VALUE);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Failed on entering data in home.basic.search.inputbox: " + e);
		}
	}
		
// TEMPLATE
//		@Test  //Test Name	
//		try {
//			String str = "string name";
//		} catch (Exception e) {
//			System.out.println("Caught in XXXXXX: " + e);
//			e.printStackTrace();+
//		}	

		
		
		
	
	
	
	
}
