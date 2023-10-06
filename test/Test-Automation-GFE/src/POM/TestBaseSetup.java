package POM;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Parameters;

import Framework.AppVariables;

public class TestBaseSetup {

	//static String driverPath = "C:/DEV/Tools/Selenium/ChromeDriver_90.0.4430.24/chromedriver_win32/";  //Driver will be set based on Switch
	
	private WebDriver driver;
	
	public WebDriver getDriver() {						
	        return driver;					
	}
	
	private void setDriver(String browserType, String appURL) 	{			//Refactor browserType and appURL
	   switch (browserType) {
	   		case "chrome":
	   			driver = chromeLogin(appURL);
	   			break;
	   		case "IE":
	   			driver = ieLogin(appURL);
	   			break;
	   		default:
	   			System.out.println("browser : " + browserType + " is invalid, Launching Chrome as browser of choice..");

	   		driver = chromeLogin(appURL);
	   }
	}
	
	
	private static WebDriver chromeLogin(String appURL) {						//This is all I need for now
		//Currently version 90.0.4430.93
		System.out.println("Launching Chrome");
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		WebDriver driver = new ChromeDriver();
		driver.manage().window().maximize();
		driver.navigate().to(appURL);

		return driver;

	}	

	//I believe this is the correct driver for the version of IE on Adaptive machine
	private static WebDriver ieLogin(String EnvURI) {
		System.setProperty("webdriver.ie.driver", Framework.AppVariables.IEDRIVER);
		WebDriver driver = new InternetExplorerDriver();							//Change to access IE
		System.out.println("Launching IE");
		driver.manage().window().maximize();
		driver.navigate().to(EnvURI);
	
		return driver;

	}
	
	
//	private static WebDriver ieLogin(String appURL) {
//		System.out.println("Launching Firefox browser..");
//		WebDriver driver = new FirefoxDriver();
//		driver.manage().window().maximize();
//		driver.navigate().to(appURL);
//		return driver;
//
//	}
	
	@Parameters({ "browserType", "appURL" })									//Pass Browser type and URL
	@BeforeClass
	public void initializeTestBaseSetup(String browserType, String appURL) {
		try {
			setDriver(browserType, appURL);
		} catch (Exception e) {
			System.out.println("Error in initializingTestBaseSetup(): " + e.getStackTrace());
		}

	}



	@AfterClass
	public void tearDown() {
		driver.quit();
		System.out.println("TestBaseSetup reached @AfterClass, driver.quit()");
	}


	
} //class
