package Execution;

//import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

public class GoogleLogin {
	public static void main(String[] args) {
		System.setProperties("webdrive.chrome.drive
		System.setProperties("webdriver.chrome.driver")
		WebDriver driverChrome = new ChromeDriver();

		driverChrome.get(Framework.AppVariables.GETURL);
		// driverChrome.manage().window().setSize(arg0);
		driverChrome.manage().window().maximize();

	}
}
