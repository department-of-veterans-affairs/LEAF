package Execution;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.*;
import org.openqa.selenium.WebElement;
import org.junit.Test;
import org.junit.Rule;
import static org.junit.Assert.*;

import Framework.SignInPage;
import Framework.TestData;
import Execution.login;

public class HomePage {

	protected WebDriver driver;
	private By signInButton = By.linkText("Sign in");

	public HomePage(WebDriver driver) {
		this.driver = driver;
	}

	@Test  //Search Basic
	public void searchBasic() {
		driver.findElement(By.name("searchtxt")).sendKeys(TestData.SEARCHBASIC_VALUE);
		//return vari;
	}

	public SignInPage clickSignInBtn() {
		System.out.println("clicking on sign in button");
		WebElement signInBtnElement=driver.findElement(signInButton);
		
		if(signInBtnElement.isDisplayed()||signInBtnElement.isEnabled())
			signInBtnElement.click();
			else System.out.println("Element not found");
			return new SignInPage(driver);
		}

		public void clickImagesLink() {
			//It should have a logic to click on images link
			//And it should navigate to google images page
		}

		public String getPageTitle(){
			String title = driver.getTitle();
			return title;
		}
	
		public boolean verifyBasePageTitle() {
			String expectedPageTitle="Google";
			return getPageTitle().contains(expectedPageTitle);
		}
	
	
	
//	@Test
//	public void loginHomePage() {
//	
//		//goto Home Page
//		try {
//			login Login = new login();
//			Login.siteLogin();					//run login
//			
//		} catch (Exception e) {
//			System.out.println("Caught during login: " + e);
//			e.printStackTrace();
//		}	
//	}	
	
	
//		login driver = new login();
//		WebDriver result = driver.siteLogin();
	
		
	
	
//	@Test	// search inputbox
//	public void searchBoxBasic() {
//		try {
//			
//			
//			//WebDriver chromeDriver = super.chromeDriver;
//			//login chDriver = new login();
//			//chDriver.siteLogin();
//			//login.chromeDriver.findElement(By.name(TestData.S_BASIC_N)).sendKeys(TestData.SEARCHBASIC_VALUE);
//		} catch (Exception e) {
//			e.printStackTrace();
//			System.out.println("Failed on entering data in home.basic.search.inputbox: " + e);
//		}
//	}
		
// TEMPLATE
//		@Test  //Test Name	
//		try {
//			String str = "string name";
//		} catch (Exception e) {
//			System.out.println("Caught in XXXXXX: " + e);
//			e.printStackTrace();+
//		}	

		
		
		
	
	
	
	
}
