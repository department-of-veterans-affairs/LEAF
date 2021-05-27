package Execution;

import org.openqa.selenium.WebDriver;

import Framework.TestBaseSetup;
import static org.junit.Assert.*;
import static org.junit.Assert.assertTrue;
import org.junit.BeforeClass;
import org.junit.Test;

import Framework.BasePage;

public class BasePageTest extends TestBaseSetup{

	private WebDriver driver;

	@BeforeClass
	public void setUp() {
		driver=getDriver();
	}
	
	@Test
	public void verifyHomePage() {
		System.out.println("Home page test...");
		BasePage basePage = new BasePage(driver);
		Assert.assertTrue(basePage.verifyBasePageTitle(), "Home page title doesn't match");
	}


	
	
}  //class
