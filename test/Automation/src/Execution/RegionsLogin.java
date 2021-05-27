package Execution;

//import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

public class RegionsLogin {
	public static void main(String[] args) {
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		WebDriver driverChrome = new ChromeDriver();

		driverChrome.get(Framework.AppVariables.URI);
		driverChrome.manage().window().maximize();

		System.out.println("Chrome should be maximized and GETURL loaded");

	}
}
