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
import main.java.util.LoggerUtil;
import main.java.util.MailUtil;
import main.java.util.TestProperties;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;
import java.util.Map;

import static main.java.pages.BasePage.setExplicitWaitForElementToBeVisible;

@Listeners({ReportListener.class, LogListener.class})
public class BaseTest {

	protected WebDriver driver;

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

	@Parameters({"environment", "env_URL", "Hub_Url"})
	@BeforeClass
	protected void setup(@Optional("remote") String env, @Optional("http://host.docker.internal/LEAF_Request_Portal/admin/") String env_URL, @Optional("http://localhost:4444/wd/hub") String Hub_Url) throws MalformedURLException {

		// Use environment variables as fallback
		String environment = System.getenv().getOrDefault("ENVIRONMENT", env);
		String envUrl = System.getenv().getOrDefault("ENV_URL", env_URL);
		String hubUrl = System.getenv().getOrDefault("HUB_URL", Hub_Url);

		// Add this conditional check to differentiate between running inside and outside the container
		if (environment.equalsIgnoreCase("remote") && !System.getenv().containsKey("ENVIRONMENT")) {
			hubUrl = "http://localhost:4445/wd/hub"; // Default to internal container Hub URL
		}

		LoggerUtil.log("Setup started");
		LoggerUtil.log("Environment: " + environment);
		LoggerUtil.log("Environment URL: " + envUrl);
		LoggerUtil.log("Hub URL: " + hubUrl);

		ChromeOptions ops = new ChromeOptions();
		ops.addArguments("disable-infobars");

		try {
			if (environment.equalsIgnoreCase("local")) {
				setupLocalDriver(ops);
			} else if (environment.equalsIgnoreCase("remote")) {
				setupRemoteDriver(hubUrl, ops);
			}

			WebDriverContext.setDriver(driver);
			LoggerUtil.log("WebDriver set in WebDriverContext.");

			driver.manage().window().maximize();
			driver.manage().deleteAllCookies();
			driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(60));

			navigateToUrl(envUrl);
			LoggerUtil.log("Setup completed");

		} catch (Exception e) {
			LoggerUtil.log("Setup failed: " + e.getMessage());
			throw e;
		}
	}


	private void setupLocalDriver(ChromeOptions ops) {
		WebDriverManager.chromedriver().setup();
		driver = new ChromeDriver(ops);
		LoggerUtil.log("Local ChromeDriver session created successfully.");
	}

	private void setupRemoteDriver(String hubUrl, ChromeOptions ops) throws MalformedURLException {
		DesiredCapabilities capabilities = new DesiredCapabilities();
		capabilities.setCapability("timeouts", Map.of(
				"implicit", 5000,
				"pageLoad", 60000,
				"script", 10000
		));
		capabilities.setCapability(ChromeOptions.CAPABILITY, ops);
		LoggerUtil.log("Creating RemoteWebDriver session with URL: " + hubUrl);
		try {
			driver = new RemoteWebDriver(new URL(hubUrl), capabilities);
			LoggerUtil.log("RemoteWebDriver session created successfully.");
		} catch (Exception e) {
			LoggerUtil.log("Failed to create RemoteWebDriver session: " + e.getMessage());
			throw e;
		}
	}

	private void navigateToUrl(String url) {
		driver.get(url);
		LoggerUtil.log("Navigated to URL: " + url);
		try {
			WebElement detailsButton = driver.findElement(By.xpath("//button[@id='details-button']"));
			detailsButton.click();
			WebElement proceedLink = driver.findElement(By.id("proceed-link"));
			setExplicitWaitForElementToBeVisible(proceedLink, 60);
			proceedLink.click();
			LoggerUtil.log("Clicked through security warning");
		} catch (Exception e) {
			LoggerUtil.log("Security warning elements not found or could not be clicked: " + e.getMessage());
		}
	}

	@AfterClass(alwaysRun = true)
	public void wrapUp() {
		if (driver != null) {
			driver.quit();
			LoggerUtil.log("WebDriver session terminated.");
		}
		WebDriverContext.removeDriver();
		LoggerUtil.log("WebDriver removed from WebDriverContext.");
	}
}
