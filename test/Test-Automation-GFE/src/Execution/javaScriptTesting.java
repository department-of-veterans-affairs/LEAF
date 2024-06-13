package Execution;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import java.util.concurrent.TimeUnit;
import java.util.List;
import java.util.Set;
import Framework.setupFramework;

public class javaScriptTesting {
	
	public static void main(String args[]) {  //       C:\DEV\Tools\Selenium\ChromeDriver_95.0.4638.17\chromedriver_win32
	    						WebDriver driver = new ChromeDriver();
	    driver.get("https://secure.indeed.com/account/login");
//	    //implicit wait
	    driver.manage().timeouts().implicitlyWait(5, TimeUnit.SECONDS);
//	    
//	    //window handle of parent window
//	    String m = driver.getWindowHandle();
//	    driver.findElement(By.id("login-google-button")).click();
//	    
//	    // store window handles in Set
//	    Set w = driver.getWindowHandles();
//	    
//	    // iterate window handles
////	    for (String h: w){
////	       // switching to each window
////	       driver.switchTo().window(h);
////	       String s= driver.getTitle();
////	       // checking specific window title
////	       if(s.equalsIgnoreCase("Sign in - Google Accounts")){
////	          System.out.println("Window title to be closed: "+ driver.getTitle());
////	          driver.close();
////	       }
////	    }
//	    // switching parent window
//	    driver.switchTo().window(m);
//	    driver.quit();
		
		
		String baseWin = driver.getWindowHandle();
			System.out.println("Base HWND = " + baseWin);
	    //Some methods to open new window, e.g.
	    //driver.findElementBy("home-button").click();
//	    WebElement ele = driver.findElement(By.id("home-button"));
//	    		ele.click();

	    //loop through all open windows to find out the new window
	    for(String winHandle : driver.getWindowHandles()){
	        if(!winHandle.equals(baseWin)){
	            driver.switchTo().window(winHandle);
	            //your actions with the new window, e.g.
	            String newURL = driver.getCurrentUrl();
	        }
	    }

	    //switch back to the main window after your actions with the new window
	    driver.close();
	    driver.switchTo().window(baseWin);

	    //let the driver focus back on the base window again to continue testing
	    ((JavascriptExecutor) driver).executeScript("window.focus();");
		
		
		
		
	 }
}  //class