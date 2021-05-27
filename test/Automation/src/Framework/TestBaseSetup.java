package Framework;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
//import org.testng.annotations.Parameters;
import org.junit.BeforeClass;
import org.junit.AfterClass;
import org.junit.Test;
import org.junit.Rule;
import static org.junit.Assert.*;

public class TestBaseSetup {

	
	static String driverPath = "C:/DEV/Tools/Selenium/ChromeDriver_90.0.4430.24/chromedriver_win32/";  //Driver will be set based on Switch
	
	private WebDriver driver;
	
	public WebDriver getDriver() {						//********** Not sure what this is used for?? **********
	        return driver;					//Is this the same driver set as private on the line above?
	}
	
	private void setDriver(String browserType, String appURL) 	{			//setBrowser() in login
	   switch (browserType) {
	   		case "chrome":
	   			driver = initChromeDriver(appURL);
	   			break;
	   		case "firefox":
	   			driver = initFirefoxDriver(appURL);
	   			break;
	   		default:
	   			System.out.println("browser : " + browserType + " is invalid, Launching Chrome as browser of choice..");

	   		//driver = initFirefoxDriver(appURL);
	   		driver = initChromeDriver(appURL);
	   }

	}
	
	
	private static WebDriver initChromeDriver(String appURL) {						//This is all I need for now
		System.out.println("Launching google chrome with new profile..");
		System.setProperty("webdriver.chrome.driver", driverPath + "chromedriver.exe");
		WebDriver driver = new ChromeDriver();
		driver.manage().window().maximize();
		driver.navigate().to(appURL);

		return driver;

	}	

	private static WebDriver initFirefoxDriver(String appURL) {
		System.out.println("Launching Firefox browser..");
		WebDriver driver = new FirefoxDriver();
		driver.manage().window().maximize();
		driver.navigate().to(appURL);
		return driver;

	}
	
	//@Parameters({ "browserType", "EnvURI" })									//Pass Browser type and URL
	@BeforeClass
	public void initializeTestBaseSetup(String browserType, String appURL) {
		try {
			setDriver(browserType, appURL);
		} catch (Exception e) {
			System.out.println("Error....." + e.getStackTrace());
		}

	}



	@AfterClass
	public void tearDown() {
		driver.quit();
	}

	
	
} //class
