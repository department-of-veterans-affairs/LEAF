package test.java;

import io.github.bonigarcia.wdm.WebDriverManager;
import main.java.report.ExtentReportManager;
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

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;
import java.util.Map;

import static main.java.pages.BasePage.setExplicitWaitForElementToBeVisible;

/**
 * BaseTest class to be extended by all test classes.
 * It contains setup and teardown methods for WebDriver and test reporting.
 */
@Listeners({ReportListener.class, LogListener.class})
public class BaseTest {

	/** The WebDriver instance. */
	protected WebDriver driver;

	/**
	 * Global setup method that runs once before any test in the suite.
	 * This method initializes logging and loads test properties.
	 */
	@BeforeSuite(alwaysRun = true)
	public void globalSetup() {
		LoggerUtil.log("************************** Test Execution Started ************************************");
		try {
			TestProperties.loadAllProperties(); // Load all test properties
		} catch (Exception e) {
			LoggerUtil.log("Error loading properties: " + e.getMessage());
			e.printStackTrace();
		}
	}

	/**
	 * Global teardown method that runs once after all tests in the suite.
	 * This method logs the results and sends an email summary of the test execution.
	 * @param context The test context containing information about the test execution.
	 */

   	@AfterSuite(alwaysRun = true)
	public void wrapAllUp(ITestContext context) {
		int total = context.getAllTestMethods().length;
		int passed = context.getPassedTests().size();
		int failed = context.getFailedTests().size();
		int skipped = context.getSkippedTests().size();

		LoggerUtil.log("Total number of test cases: " + total);
		LoggerUtil.log("Number of test cases Passed: " + passed);
		LoggerUtil.log("Number of test cases Failed: " + failed);
		LoggerUtil.log("Number of test cases Skipped: " + skipped);

	// Ensure Extent Report is flushed
		ExtentReportManager.getExtentReports().flush();
		String reportPath = ExtentReportManager.reportFilePath; // Use the reportFilePath variable

	// Send email with the test results and report path
		boolean mailSent = MailUtil.sendMail(total, passed, failed, skipped, reportPath);

		LoggerUtil.log("Mail sent: " + mailSent);
		LoggerUtil.log("************************** Test Execution Finished ************************************");
}


	/**
	 * Setup method that runs before each test class.
	 * Initializes the WebDriver based on the provided environment.
	 *
	 * @param env The environment (local or remote).
	 * @param env_URL The URL of the environment.
	 * @param Hub_Url The URL of the Selenium Hub.
	 * @throws MalformedURLException If the Hub URL is malformed.
	 */
	@Parameters({"environment", "env_URL", "Hub_Url"})
	@BeforeClass
	protected void setup(@Optional("remote") String env, @Optional("http://host.docker.internal/LEAF_Request_Portal/admin/") String env_URL, @Optional("http://localhost:4444/wd/hub") String Hub_Url) throws MalformedURLException {

		// Use environment variables as fallback if parameters are not provided
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

		// Initialize ChromeOptions
		ChromeOptions ops = new ChromeOptions();
		ops.addArguments("disable-infobars");

		try {
			// Setup WebDriver based on environment
			if (environment.equalsIgnoreCase("local")) {
				setupLocalDriver(ops); // Local setup
			} else if (environment.equalsIgnoreCase("remote")) {
				setupRemoteDriver(hubUrl, ops); // Remote setup
			}

			// Set WebDriver instance in context for accessibility across the test
			WebDriverContext.setDriver(driver);
			LoggerUtil.log("WebDriver set in WebDriverContext.");

			// Configure browser settings
			driver.manage().window().maximize();
			driver.manage().deleteAllCookies();
			driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(60));

			// Navigate to the specified URL
			navigateToUrl(envUrl);
			LoggerUtil.log("Setup completed");

		} catch (Exception e) {
			LoggerUtil.log("Setup failed: " + e.getMessage());
			throw e;
		}
	}

	/**
	 * Sets up a local ChromeDriver instance.
	 *
	 * @param ops ChromeOptions for the ChromeDriver.
	 */
	private void setupLocalDriver(ChromeOptions ops) {
		WebDriverManager.chromedriver().setup(); // Setup ChromeDriver using WebDriverManager
		driver = new ChromeDriver(ops); // Initialize ChromeDriver with options
		LoggerUtil.log("Local ChromeDriver session created successfully.");
	}

	/**
	 * Sets up a remote WebDriver instance.
	 *
	 * @param hubUrl The URL of the Selenium Hub.
	 * @param ops ChromeOptions for the ChromeDriver.
	 * @throws MalformedURLException If the Hub URL is malformed.
	 */
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
			driver = new RemoteWebDriver(new URL(hubUrl), capabilities); // Initialize RemoteWebDriver with capabilities
			LoggerUtil.log("RemoteWebDriver session created successfully.");
		} catch (Exception e) {
			LoggerUtil.log("Failed to create RemoteWebDriver session: " + e.getMessage());
			throw e;
		}
	}

	/**
	 * Navigates to the given URL and handles the security warning.
	 *
	 * @param url The URL to navigate to.
	 */
	private void navigateToUrl(String url) {
		driver.get(url); // Navigate to the URL
		LoggerUtil.log("Navigated to URL: " + url);
		try {
			// Handle potential security warning
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

	/**
	 * Teardown method that runs after each test class.
	 * Cleans up the WebDriver instance.
	 */
	@AfterClass(alwaysRun = true)
	public void wrapUp() {
		if (driver != null) {
			driver.quit(); // Close and quit WebDriver
			LoggerUtil.log("WebDriver session terminated.");
		}
		WebDriverContext.removeDriver(); // Remove WebDriver from context
		LoggerUtil.log("WebDriver removed from WebDriverContext.");
	}
}
