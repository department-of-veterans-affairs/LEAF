package Framework;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import java.util.concurrent.TimeUnit;
import java.util.List;
import java.util.Set;


public class browserHandles {

	   public static void main(String[] args) {		
		      WebDriver driver = new ChromeDriver();
		      driver.get("https://secure.indeed.com/account/login");
		    
		      //implicit wait
		      driver.manage().timeouts().implicitlyWait(5, TimeUnit.SECONDS);
		      
		      //window handle of parent window
		      String m = driver.getWindowHandle();
		     
		      System.out.println("m = " + m);
		      
		      driver.findElement(By.id("login-google-button")).click();
		      
		      // store window handles in Set
		      Set w = driver.getWindowHandles();
		      int i = driver.getWindowHandles().size();
		      System.out.println("w = " + w);
		      System.out.println("number of handles: " + i);
		      
		      // iterate window handles
//		      for (String h: w){
//		         // switching to each window
//		         driver.switchTo().window(h);
//		         String s= driver.getTitle();
//		         // checking specific window title
//		         if(s.equalsIgnoreCase("Sign in - Google Accounts")){
//		            System.out.println("Window title to be closed: "+ driver.getTitle());
//		            driver.close();
//		         }
//		      }
		      // switching parent window
		      driver.switchTo().window(m);
		      driver.quit();
		   }
}	//class