package test.java.POM;

import org.openqa.selenium.WebDriver;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

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
		String pageTitle = driver.getTitle();
		Assert.assertEquals(basePage.verifyBasePageTitle(), pageTitle);
		//Assert.assertEquals(basePage.verifyBasePageTitle(), "Home page title doesn't match");
		//JUnit syntax, which I had to modify anyway because it was of type boolean
		//assertTrue(basePage.verifyBasePageTitle() == "Home page title doesn't match");
	}


	
	
}  //class
