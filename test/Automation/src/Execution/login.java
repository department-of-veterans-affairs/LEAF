package Execution;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.ie.InternetExplorerDriver;
//import org.openqa.selenium.firefox.FirefoxDriver;
import org.junit.*;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

//import Framework.AppVariables;

import org.junit.Test;


public class login {
	
	private WebDriver driver;

	public WebDriver getDriver() {	
	        return driver;								//Uses the driver created above
	}


	private void setBrowser(String browser, String EnvURI) 	{
		   switch (browser) {
		   		case "chrome":
		   			driver = chromeLogin(EnvURI);		//
		   			break;
		   		case "IE":
		   			//driver = ieLogin(EnvURI);
		   			System.out.println("IE Driver not setup");
		   			break;
		   		default:
		   			System.out.println("Launching default browser Chrome");

		   		driver = chromeLogin(EnvURI);
		   }
	}
	
	//Currently version 90.0.4430.93
	@Test
	public static WebDriver chromeLogin(String EnvURI) {
		
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		WebDriver driver = new ChromeDriver();
		
		System.out.println("chromeDriver established for: " + EnvURI);
																					//for now, change environments
		driver.get(EnvURI);														//by setting EnvURI (Local, QA, PROD)
		driver.manage().window().maximize();										
		
		return driver;
	}

	//I believe this is the correct driver for the version of IE on AS machine
	private static WebDriver ieLogin(String EnvURI) {
		System.setProperty("webdriver.ie.driver", Framework.AppVariables.IEDRIVER);
		WebDriver driver = new InternetExplorerDriver();							//Change to access IE
		System.out.println("Launching IE");
		driver.manage().window().maximize();
		driver.navigate().to(EnvURI);
	
		return driver;

	}
	
	@Parameterized.Parameters
	//@Parameters({ "browserType", "appURL" })				// TestNGPass Browser type and URL
	@BeforeClass
	public void initializeTestBaseSetup(String browserType, String EnvURI) {
		try {
			setBrowser(browserType, EnvURI);
		} catch (Exception e) {
			System.out.println("Error....." + e.getStackTrace());
		}

	}


	@AfterClass
	public void tearDown() {
		driver.quit();
	}

} //class
