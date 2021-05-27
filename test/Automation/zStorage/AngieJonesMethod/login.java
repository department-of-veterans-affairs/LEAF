package Execution;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import Framework.AppVariables;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.Dimension;
import Framework.Driver;				


/* Before this takes place, Need to develop functionality that allows for the environment (and browser) to be selected. 
 * Therefore, variable names need to be generic
 */

public class login {
	
	private static WebDriver webDriver;
	protected static Driver login;					//Page
		
	
	@BeforeClass
	public static void launchApplication() {
		setChromeDriverProperty();
		webDriver = new ChromeDriver();
		webDriver.get(AppVariables.LOCALURI);						//for now, change environments
		webDriver.manage().window().maximize();						//by using LOCALURI, QAURI, or PRODURI
		login = new Driver();
		login.setupWebDriver(webDriver);
	}
	
	@AfterClass
	public static void closeBrowser(){
		//webDriver.quit();
		 Dimension d = new Dimension(800,480);		//set size to 800, 400 for now, ultimately will want to .quit
		 webDriver.manage().window().setSize(d);
	}
 
	private static void setChromeDriverProperty(){
		System.setProperty("webdriver.chrome.driver", "resources/chromedriver");
	}
		
//		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHDRIVERPATH);
//		WebDriver chromeDriver = new ChromeDriver();
//		
//		System.out.println("chromeDriver established for: " + AppVariables.LOCALURI);
//																					//for now, change environments
//		chromeDriver.get(Framework.AppVariables.LOCALURI);								//by using LOCALURI, QAURI
//		chromeDriver.manage().window().maximize();										//or PRODURI
	
	

	
}
