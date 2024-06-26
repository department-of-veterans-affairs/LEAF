package main.java.pages;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.FluentWait;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;

/**
 * The Class BasePage every Page should extend this class.
 *
 */
public class BasePage {

	/** The driver. */
	protected static WebDriver driver;

	/** The waiter. */
	protected FluentWait<WebDriver> waiter;

	public static WebDriverWait explicitWait;

	public static JavascriptExecutor js;

	private static final Logger log = LogManager.getLogger(BasePage.class);

	/**
	 * Instantiates a new base page.
	 *
	 * @param driver the driver
	 */
	public BasePage(WebDriver driver) {
		super();
		this.driver = driver;
		PageFactory.initElements(driver, this);
		waiter = new FluentWait<WebDriver>(driver).ignoring(NoSuchElementException.class, WebDriverException.class)
				.withTimeout(Duration.ofSeconds(30)).pollingEvery(Duration.ofSeconds(5));
	}

	public static RemoteWebDriver createDriver(String HUB_URL) throws MalformedURLException {
		ChromeOptions options = new ChromeOptions();
		options.addArguments("disable-infobars");
		log.info("Creating remote WebDriver with hub URL: " + HUB_URL);
		return new RemoteWebDriver(new URL(HUB_URL), options);
	}


	// Add explicit wait
	public static void setExplicitWait(int seconds){
		explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
		log.info("Waiting for Element to appear for "+seconds+" seconds");
	}

	// ExplicitWait for element to be clickable
	public void setExplicitWaitForElementToBeClickable(WebElement element, int seconds){
		log.info("Waiting for Element to be clickable for "+seconds+" seconds");
		explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
		try {
			explicitWait.until(ExpectedConditions.elementToBeClickable(element));
		} catch (TimeoutException e) {
			log.error("Timeout waiting for element to be clickable: " + element, e);
			throw e;
		}
	}

	// ExplicitWait for element to be visible
	public static void setExplicitWaitForElementToBeVisible(WebElement element, int seconds){
		log.info("Waiting for Element to be visible for "+seconds+" seconds");
		try {
			new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.visibilityOf(element));
		} catch (TimeoutException e) {
			log.error("Timeout waiting for element to be visible: " + element, e);
			throw e;
		}
	}

	// ExplicitWait for element to be invisible
	public void setExplicitWaitForElementToBeInvisible(WebElement element, int seconds){
		log.info("Waiting for Element to be invisible for "+seconds+" seconds");
		try {
			new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.invisibilityOf(element));
		} catch (TimeoutException e) {
			log.error("Timeout waiting for element to be invisible: " + element, e);
			throw e;
		}
	}

	public void clickElement(WebElement element){
		try{
			// Wait for the element to be clickable
			WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));
			wait.until(ExpectedConditions.elementToBeClickable(element));
			// Click the element
			element.click();
		} catch(NoSuchElementException | TimeoutException e){
			log.error("Element not found or not clickable, Exception thrown: " + e.getMessage(), e);
			throw e;
		}
	}

	public void enterText(WebElement element, String text){
		try{
			// Wait for the element to be clickable
			WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));
			wait.until(ExpectedConditions.elementToBeClickable(element));
			// Enter the text
			element.sendKeys(text);
		} catch(NoSuchElementException | TimeoutException e){
			log.error("Element not found or not clickable, Exception thrown: " + e.getMessage(), e);
			throw e;
		}
	}
}
