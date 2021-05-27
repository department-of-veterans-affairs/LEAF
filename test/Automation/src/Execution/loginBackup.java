package Execution;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

import Framework.AppVariables;

import org.junit.Test;

/* Before this takes place, the environment (and browser) must be selected. 
 * Therefore, variable names need to be generic
 */



public class loginBackup {
	//public static WebDriver chromeDriver;

	public static WebDriver siteLogin() {
		
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		//WebDriver chromeDriver = new ChromeDriver();
		WebDriver chromeDriver = new ChromeDriver();
		
		System.out.println("chromeDriver established for: " + AppVariables.LOCALURI);
																					//for now, change environments
		chromeDriver.get(Framework.AppVariables.LOCALURI);								//by using LOCALURI, QAURI
		chromeDriver.manage().window().maximize();										//or PRODURI
		
		return chromeDriver;
	}

	
	
	
	
// *******  ORIGINAL *****************	
//	public void siteLogin() {
//		
//		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHDRIVERPATH);
//		//WebDriver chromeDriver = new ChromeDriver();
//		WebDriver chromeDriver = new ChromeDriver();
//		
//		System.out.println("chromeDriver established for: " + AppVariables.LOCALURI);
//																					//for now, change environments
//		chromeDriver.get(Framework.AppVariables.LOCALURI);								//by using LOCALURI, QAURI
//		chromeDriver.manage().window().maximize();										//or PRODURI
//	}
	
}
