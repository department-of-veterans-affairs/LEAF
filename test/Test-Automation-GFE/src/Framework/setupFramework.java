package Framework;


import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Parameters;


public class setupFramework {

	public WebDriver driver;
	
	public WebDriver getDriver() {						
	        return driver;					//Establish ONE ChromeDriver
	}										
	
	
	
	//Need to add Firefox (& driver) and Edge
	private void setDriver(String browser, String env) 	{			
	   switch (browser) {     //Step Over
	   		case "chrome":
	   			driver = chromeLogin(env);
	   			break;
	   		case "IE":
	   			driver = ieLogin(env);
	   			break;
	   		default:
	   			System.out.println("browser : " + browser + " is invalid, Launching Chrome as default browser.");

	   		driver = chromeLogin(env);  //
	   }
	}  
	

	//highlightFlash(WebElement element)  //method
	//fp.highlightFlash(returnedElement);  //called using this
	
	
	private static WebDriver chromeLogin(String env) {				//ERR: Here is the DevToolsActivePort error
		//Currently version 98.0.44758.102      2.16.2022  //UPDATED TO v101.something
		System.out.println("Launching Chrome by Automation");  //Step Over until - return driver;
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
			ChromeOptions startOptions = new ChromeOptions();
			startOptions.addArguments("start-maximized");
			
			startOptions.addArguments("--user-data-dir=C:\\Users\\OITBIRRichaM1\\ChromeProfiles\\TestAutomation");
			//startOptions.addArguments("--user-data-dir=C:\\Users\\OITBIRRichaM1\\AppData\\Local\\Chrome\\Cache");
			//startOptions.addArguments("--user-data-dir=C:\\Users\\OITBIRRichaM1\\AppData\\Local\\Chrome\\Cache\\SeLeNiUm");
			
			//startOptions.addArguments("--profile-directory=TestAutomation");
			//startOptions.addArguments("--profile-directory=Person 2");
			//startOptions.addArguments("--profile-directory=SeLeNiUm");
			startOptions.addArguments("--disable-extensions");
			startOptions.addArguments("disable-infobars");
			startOptions.addArguments("--disable-gpu");
			startOptions.addArguments("--disable-dev-shm-usage");
			startOptions.addArguments("--no-sandbox");
			
			
			//startOptions.addArguments("--user-data-dir=C:\\Users\\OITBIRRichaM1\\AppData\\Local\\Chrome\\Cache");
			//startOptions.addArguments("--bwsi");			//ChromeDriver starts, then nothing, no output in Console
			//startOptions.addArguments("");
			//startOptions.addArguments("");
			
			WebDriver driver = new ChromeDriver(startOptions);
			driver.navigate().to(env);
			System.out.println("Driver established for: " + driver.getClass());
			
//			if (AppVariables.headless) {
//				ChromeOptions options = new ChromeOptions();
//				
//				options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
//						"--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
//						"--disable-dev-shm-usage");
//				WebDriver driver = new ChromeDriver(options);
//				driver.navigate().to(env);
//				System.out.println("Driver established for: " + driver.getClass());
//				return driver;  //HEADLESS driver
//
//			} else {
//				WebDriver driver = new ChromeDriver();
//				driver.manage().window().maximize();
//				driver.navigate().to(env);
//				System.out.println("Driver established for: " + driver.getClass());
//				
//				return driver;  
//
//			}

			
		return driver;		//DELETE when headless code is re-enabled
	}	

	
	//I believe this is the correct driver for the version of IE on Adaptive machine
	private static WebDriver ieLogin(String env) {
		System.setProperty("webdriver.ie.driver", Framework.AppVariables.IEDRIVER);
		WebDriver driver = new InternetExplorerDriver();							//Change to access IE
		System.out.println("Launching IE");
		driver.manage().window().maximize();
		driver.navigate().to(env);
	
		return driver;

	}
	
	
	@Parameters({ "browser", "env" })									//Pass Browser type and URL
	@BeforeClass
	//Kill all instances of Chrome and ChromeDriver ******************************************************TODO
	public void initializeFramework(String browser, String env) {
		try {
			setDriver(browser, env);
		} catch (Exception e) {  //Over
			//System.out.println("Error in initializingTestBaseSetup(): " + e.getStackTrace().toString());
			e.printStackTrace();
		}

	} 
	
	
	@AfterClass
	public void closeDown() {
		
		driver.quit();
		System.out.println("setupFramework reached @AfterClass, driver.quit()");
		//System.out.println("@AfterClass disabled - browser remains open");
	}
	
	
	
	
	
} //class

