package Framework;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Parameters;
import org.testng.annotations.Test;

//import Execution.userAccessGroupsOLD_DoNotUse;

public class setupFramework {

	public WebDriver driver;
	public int groupID;
	
	public WebDriver getDriver() {						
	        return driver;					//Establish ONE ChromeDriver for main portal
	}										
	
		
	
//	public void getURL() {
//		String strUrl = driverNexus.getCurrentUrl();
//		System.out.println("getURL = " + strUrl );
//	}

	
	
	//Need to add Firefox (& driver) and Edge
	private void setDriver(String browser, String env) 	{			// called as: setDriver(browser, env);
	   switch (browser) {     //Step Over
	   		case "chrome":
	   			driver = chromeLogin(env);
	   			
	   			break;
	   		case "IE":
	   			driver = ieLogin(env);
	   			break;
	   		default:
	   			System.out.println("browser : " + browser + " is invalid, Launching Chrome as default browser.");

	   			driver = chromeLogin(env);
	   			//driverNexus = chromeLoginNexus(env);    //Need to call this from userAccessGroups
	   }
	}  
	
	

	
	private static WebDriver chromeLogin(String env) {						//This is all I need for now
		//Currently version 98.0.44758.102      2.16.2022
		System.out.println("Launching Chrome");  //Step Over until - return driver;
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		
		
			if (AppVariables.headless) {
				ChromeOptions options = new ChromeOptions();
				options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
						"--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
						"--disable-dev-shm-usage");
				WebDriver driver = new ChromeDriver(options);
				driver.navigate().to(env);
				System.out.println("Driver established for: " + driver.getClass());
				return driver;  //HEADLESS driver

			} else {
				WebDriver driver = new ChromeDriver();
				driver.manage().window().maximize();
				driver.navigate().to(env);
				System.out.println("Driver established for: " + driver.getClass());
				
				return driver;  

			}

	}		
	
			
//		System.out.println("driver = " + driver.getClass().toString());
//		
//		return driver;  //driver changed to value null??
	
	

	// IE Driver almost certainly needs to be updated
	private static WebDriver ieLogin(String env) {
		System.setProperty("webdriver.ie.driver", Framework.AppVariables.IEDRIVER);
		WebDriver driver = new InternetExplorerDriver();							//Change to access IE
		System.out.println("Launching IE");
		driver.manage().window().maximize();
		driver.navigate().to(env);
	
		return driver;

	}
	
	
	@Parameters({ "browser", "env" })							//Pass Browser type and URL
	@BeforeClass
	//Kill all instances of Chrome and ChromeDriver ****************************************************** TODO
	public void initializeFramework(String browser, String env) {
		try {
			setDriver(browser, env);
			//setDriver(browser, userAccessGroups.nexusTempURL);
		} catch (Exception e) {  //Over
			System.out.println("Error in initializingTestBaseSetup(): " + e.getStackTrace());
		}

	}
	
	
	@AfterClass
	public void closeDown() {
		
		//driver.quit();
		//System.out.println("setupFramework reached @AfterClass, driver.quit()");
		System.out.println("@AfterClass disabled - browser remains open");
	}
	
	
	
	
	
} //class

