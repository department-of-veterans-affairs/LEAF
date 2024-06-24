package test.java;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
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
import java.net.URL;
import java.time.Duration;
import java.util.Map;

import static main.java.pages.BasePage.setExplicitWaitForElementToBeVisible;

/**
 * Every test class should extend this class.
 *
 */
@Listeners({ReportListener.class, LogListener.class})
public class BaseTest {

	/** The driver. */
	protected WebDriver driver;

	/**
	 * Global setup.
	 */
	@BeforeSuite(alwaysRun = true)
	public void globalSetup() {
		LoggerUtil.log("************************** Test Execution Started ************************************");
		try {
			TestProperties.loadAllProperties();
		} catch (Exception e) {
			LoggerUtil.log("Error loading properties: " + e.getMessage());
			e.printStackTrace();
		}
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
		LoggerUtil.log("Total number of test cases : " + total);
		LoggerUtil.log("Number of test cases Passed : " + passed);
		LoggerUtil.log("Number of test cases Failed : " + failed);
		LoggerUtil.log("Number of test cases Skipped  : " + skipped);
		boolean mailSent = MailUtil.sendMail(total, passed, failed, skipped);
		LoggerUtil.log("Mail sent : " + mailSent);
		LoggerUtil.log("************************** Test Execution Finished ************************************");
	}

	/**
	 * Setup.
	 */
	@Parameters({"environment", "env_URL", "Hub_Url"})
	@BeforeClass
	protected void setup(@Optional("local") String env, @Optional("https://host.docker.internal/LEAF_Request_Portal/admin/") String env_URL, @Optional("") String Hub_Url) throws MalformedURLException {
		ChromeOptions ops = new ChromeOptions();
		ops.addArguments("disable-infobars");

		if (env.equalsIgnoreCase("local")) {
			WebDriverManager.chromedriver().setup();
			driver = new ChromeDriver(ops);
		} else if (env.equalsIgnoreCase("remote")) {
			DesiredCapabilities capabilities = new DesiredCapabilities();
			capabilities.setCapability("timeouts", Map.of(
					"implicit", 5000,
					"pageLoad", 60000,
					"script", 10000
			));
			capabilities.setCapability(ChromeOptions.CAPABILITY, ops);
			driver = new RemoteWebDriver(new URL(Hub_Url), capabilities);
		}

		WebDriverContext.setDriver(driver);
		driver.manage().window().maximize();
		driver.manage().deleteAllCookies();
		driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(60));

		if (env.equalsIgnoreCase("local")) {
			driver.get(env_URL);
			driver.findElement(By.xpath("//button[@id='details-button']")).click();
			WebElement proceed_link = driver.findElement(By.id("proceed-link"));
			setExplicitWaitForElementToBeVisible(proceed_link, 60);
			proceed_link.click();
		}
		else {
			driver.get(env_URL);
			driver.findElement(By.xpath("//button[@id='details-button']")).click();
			WebElement proceed_link = driver.findElement(By.id("proceed-link"));
			setExplicitWaitForElementToBeVisible(proceed_link, 60);
			proceed_link.click();
		}

		driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(60));
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
