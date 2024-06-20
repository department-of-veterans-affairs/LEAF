package test.java.tests;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.testng.ITestContext;
import org.testng.annotations.*;
import main.java.context.WebDriverContext;
import main.java.listeners.LogListener;
import main.java.listeners.ReportListener;
import main.java.pages.BasePage;
import main.java.util.LoggerUtil;
import main.java.util.MailUtil;
import main.java.util.TestProperties;

import java.net.MalformedURLException;
import java.time.Duration;

import static main.java.pages.BasePage.setExplicitWaitForElementToBeVisible;

/**
 * Every test class should extend this calss.
 *
 * @author Nikesh
 */
@Listeners({ ReportListener.class, LogListener.class })
public class BaseTest {

	/** The driver. */
	protected WebDriver driver;


	/**
	 * Global setup.
	 */
	@BeforeSuite(alwaysRun = true)
	public void globalSetup() {
		LoggerUtil.log("************************** Test Execution Started ************************************");
		TestProperties.loadAllPropertie();
	}

	/**
	 * Wrap all up.
	 *
	 * @param context the context
	 */
	@AfterSuite(alwaysRun = true)
	public void wrapAllUp(ITestContext context) {
		int total = context.getAllTestMethods().length;
		int passed = context.getPassedTests().size();
		int failed = context.getFailedTests().size();
		int skipped = context.getSkippedTests().size();
		LoggerUtil.log("Total number of testcases : " + total);
		LoggerUtil.log("Number of testcases Passed : " + passed);
		LoggerUtil.log("Number of testcases Failed : " + failed);
		LoggerUtil.log("Number of testcases Skipped  : " + skipped);
		boolean mailSent = MailUtil.sendMail(total, passed, failed, skipped);
		LoggerUtil.log("Mail sent : " + mailSent);
		LoggerUtil.log("************************** Test Execution Finished ************************************");
	}

	/**
	 * Setup.
	 */
	@Parameters({ "environment", "env_URL","Hub_Url"})
	@BeforeClass
	protected void setup(@Optional("local") String env, @Optional("https://host.docker.internal/LEAF_Request_Portal/admin/") String env_URL,@Optional("") String Hub_Url) throws MalformedURLException {
      	WebDriverManager.chromedriver().setup();
		ChromeOptions ops = new ChromeOptions();
		ops.addArguments("disable-infobars");
		driver = new ChromeDriver(ops);
		driver.manage().window().maximize();
		driver.manage().deleteAllCookies();
		driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(30));
		if(env.equalsIgnoreCase("local")){
			WebDriverContext.setDriver(driver);
			driver.get(env_URL);
			driver.findElement(By.xpath("//button[@id='details-button']")).click();
			WebElement proceed_link = driver.findElement(By.id("proceed-link"));
			setExplicitWaitForElementToBeVisible(proceed_link,30);
			proceed_link.click();
		}else if(env.equalsIgnoreCase("remote")){
			WebDriverContext.setDriver(driver);
			driver = BasePage.createDriver(Hub_Url);
		}
		driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(30));
	}


	/**
	 * Wrap up.
	 */
	@AfterClass(alwaysRun = true)
	public void wrapUp() {
		if (driver != null) {
			driver.close();
			driver.quit();
		}
	}
}
