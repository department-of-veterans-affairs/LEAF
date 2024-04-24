package test.java.Framework;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.testng.annotations.*;

public class setupFramework_Local {

	public WebDriver driver, driver8;
	public int groupID;
	
	public WebDriver getDriver() {						
	        return driver;					//Establish ONE ChromeDriver for main portal
	}										
	
	
//	public WebDriver getDriver8() {											
//        return driver8;						//Driver for Nexus Portal
//	}				
//	
//	public void getURL() {
//		String strUrl = driver8.getCurrentUrl();
//		System.out.println("getURL = " + strUrl );
//	}



	//Need to add Firefox (& driver) and Edge
	public void setDriver(String browser, String env) 	{
	   switch (browser) {     //Step Over
	   		case "chrome":
	   			driver = chromeLogin(env);
	   			//driver8 = chromeLogin("https://localhost/LEAF_Request_Portal/admin/" + groupID);
	   			break;
	   		case "IE":
	   			driver = ieLogin(env);
	   			break;
	   		default:
	   			System.out.println("browser : " + browser + " is invalid, Launching Chrome as default browser.");

	   		driver = chromeLogin(env);
	   }
	}  
	

	//highlightFlash(WebElement element)  //method
	//fp.highlightFlash(returnedElement);  //called using this
	
	
	//public  WebDriver chromeLogin(String env) {						//This is all I need for now
//		//Currently version 98.0.44758.102      2.16.2022
//		System.out.println("Launching Chrome");  //Step Over until - return driver;
//		System.setProperty("webdriver.chrome.driver", test.java.Framework.AppVariables.CHROMEDRIVER);
//
//
//			if (AppVariables.headless) {
//				ChromeOptions options = new ChromeOptions();
//				options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
//						"--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
//						"--disable-dev-shm-usage");
//				WebDriver driver = new ChromeDriver(options);
//				driver.navigate().to(env);
//				System.out.println("Driver established for: " + driver.getClass());
//				return driver;  //HEADLESS driver
//
//			} else {
//				ChromeOptions options = new ChromeOptions();
//
//				options.addArguments("--allow-running-insecure-content");
//				options.addArguments("--ignore-certificate-errors");
//				WebDriver driver = new ChromeDriver(options);
//				driver.manage().window().maximize();
//				driver.navigate().to(env);
//				System.out.println("Driver established for: " + driver.getClass());
//
//				return driver;
		public WebDriver chromeLogin(String env) {
			WebDriver driver;
			System.out.println("Launching Chrome");
			System.setProperty("webdriver.chrome.driver", test.java.Framework.AppVariables.CHROMEDRIVER);

			if (AppVariables.headless) {
				ChromeOptions options = new ChromeOptions();
				options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
						"--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
						"--disable-dev-shm-usage");
				driver = new ChromeDriver(options);
			} else {
				ChromeOptions options = new ChromeOptions();
				options.addArguments("--allow-running-insecure-content");
				options.addArguments("--ignore-certificate-errors");
				driver = new ChromeDriver(options);
				driver = new RemoteWebDriver(options);
				driver.manage().window().maximize();
			}

			driver.navigate().to(env);
			System.out.println("Driver established for: " + driver.getClass());
			return driver;
		}

		
//		System.out.println("driver = " + driver.getClass().toString());
//		
//		return driver;  //driver changed to value null??


	// IE Driver almost certainly needs to be updated
	public  WebDriver ieLogin(String env) {
		System.setProperty("webdriver.ie.driver", test.java.Framework.AppVariables.IEDRIVER);
		WebDriver driver = new InternetExplorerDriver();							//Change to access IE
		System.out.println("Launching IE");
		driver.manage().window().maximize();
		driver.navigate().to(env);
	
		return driver;

	}
	
	
	@BeforeClass
	public void initializeFramework(@Optional("chrome") String browser, @Optional("https://localhost/LEAF_Request_Portal/admin") String env) {
	    try {
	        setDriver(browser, env);
	        // Additional setup logic specific to your framework
	    } catch (Exception e) {
	        e.printStackTrace();
	        // Handle initialization exceptions according to your requirements
	    }
	}

	@AfterClass
	public void closeDown() {
		if (driver != null) {
			driver.quit();
			System.out.println("@AfterMethod - WebDriver quit");
		}
	}

	}
	


