package main.java.pages;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.*;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.function.Function;

/**
 * The Class BasePage is the base class for all page classes.
 * Every page class should extend this class to inherit common functionalities.
 */
public class BasePage {

	/** The WebDriver instance used for interacting with the web browser. */
	protected static WebDriver driver;

	/** The FluentWait instance used for defining custom wait conditions. */
	protected FluentWait<WebDriver> waiter;

	/** The WebDriverWait instance used for explicit waits. */
	public static WebDriverWait explicitWait;

	/** The JavascriptExecutor instance used for executing JavaScript commands. */
	public static JavascriptExecutor js;

	/** The Logger instance for logging information and errors. */
	private static final Logger log = LogManager.getLogger(BasePage.class);

	/**
	 * Constructor for BasePage.
	 * Initializes WebDriver, PageFactory elements, and FluentWait.
	 *
	 * @param driver the WebDriver instance
	 */
	public BasePage(WebDriver driver) {
		super();
		this.driver = driver;
		PageFactory.initElements(driver, this);
		waiter = new FluentWait<WebDriver>(driver)
				.ignoring(NoSuchElementException.class, WebDriverException.class)
				.withTimeout(Duration.ofSeconds(30))
				.pollingEvery(Duration.ofSeconds(5));
	}

	/**
	 * Creates a RemoteWebDriver instance.
	 *
	 * @param HUB_URL the URL of the Selenium Grid Hub
	 * @return the RemoteWebDriver instance
	 * @throws MalformedURLException if the HUB_URL is malformed
	 */
	public static RemoteWebDriver createDriver(String HUB_URL) throws MalformedURLException {
		ChromeOptions options = new ChromeOptions();
		options.addArguments("disable-infobars");
		log.info("Creating remote WebDriver with hub URL: " + HUB_URL);
		return new RemoteWebDriver(new URL(HUB_URL), options);
	}

	/**
	 * Sets the explicit wait time for WebDriver.
	 *
	 * @param seconds the number of seconds to wait
	 */
	public static void setExplicitWait(int seconds) {
		explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
		log.info("Waiting for Element to appear for " + seconds + " seconds");
		System.out.println("Waiting for Element to appear for " + seconds + " seconds");
	}

	/**
	 * Sets the explicit wait time for WebDriver.
	 *
	 * @param seconds the number of seconds to wait
	 */
	public static void setExplicitWaitForAlert(int seconds) {
		explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
		// Wait for the alert to be present
		explicitWait.until(ExpectedConditions.alertIsPresent());

	}

	public static String getAlertText(){
		// Switch to the alert
		Alert alert = driver.switchTo().alert();

		// Get the text of the alert
		String alertText = alert.getText();
		System.out.println("Alert text: " + alertText);

		// Accept the alert
		alert.accept();
		return alertText;
	}
	/**
	 * Waits explicitly for an element to be clickable.
	 *
	 * @param element the WebElement to wait for
	 * @param seconds the number of seconds to wait
	 */
	public void setExplicitWaitForElementToBeClickable(WebElement element, int seconds) {
		log.info("Waiting for Element to be clickable for " + seconds + " seconds");
		explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
		try {
			explicitWait.until(ExpectedConditions.elementToBeClickable(element));
		} catch (TimeoutException e) {
			log.error("Timeout waiting for element to be clickable: " + element, e);
			throw e;
		}
	}

	public boolean performActionWithRetries(WebElement element) {
		int maxRetries = 3;
		long delayInMillis = 2000;
		int attempts = 0;
		boolean success = false;

		while (attempts < maxRetries) {
			try {
				// Use Fluent Wait to wait for the element to be visible
				Wait<WebDriver> wait = new FluentWait<>(driver)
						.withTimeout(Duration.ofSeconds(30)) // Maximum time to wait
						.pollingEvery(Duration.ofSeconds(5)) // Frequency to check the condition
						.ignoring(Exception.class); // Ignore exceptions during polling

				// Wait for the element to be visible
				wait.until(ExpectedConditions.visibilityOf(element));

				// Perform the desired action on the element (e.g., click)
				element.click();
				success = true;
				break; // Action performed successfully, exit the loop
			} catch (TimeoutException e) {
				// Handle exception if the element is not found within the timeout
				attempts++;
				if (attempts == maxRetries) {
					throw new RuntimeException("Failed to perform action on element after " + maxRetries + " retries.", e);
				}
				try {
					TimeUnit.MILLISECONDS.sleep(delayInMillis); // Wait before retrying
				} catch (InterruptedException ie) {
					Thread.currentThread().interrupt(); // Restore interrupted status
					throw new RuntimeException("Interrupted while waiting to retry element action", ie);
				}
			}
		}

		return success;
	}

	public void dragAndDropByOffset(WebElement element) {
		log.info("Drag and Drop");
		int xOffset = 200;
		int yOffset = 100;
		// Create an Actions object
		Actions actions = new Actions(driver);

		// Perform drag and drop by offset
		actions.clickAndHold(element)
				.moveByOffset(xOffset, yOffset)
				.release()
				.perform();

		// Verify if the element was moved correctly (e.g., check position or style)
		System.out.println("Drag and drop by offset performed successfully.");
	}
	public void waitForPageToLoad(String text,int seconds) {
		WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(seconds)); // Timeout set to 30 seconds
		// Wait for the element to be visible
		wait.until(ExpectedConditions.visibilityOfElementLocated(By.xpath("//a[@class='chosen-single']//span[1]")));

		// Wait for the element to contain text
		wait.until(ExpectedConditions.not(ExpectedConditions.textToBe(By.xpath("//a[@class='chosen-single']//span[1]"),
				text)));}

	/**
	 * Waits explicitly for an element to be visible.
	 *
	 * @param element the WebElement to wait for
	 * @param seconds the number of seconds to wait
	 */
	public static void setExplicitWaitForElementToBeVisible(WebElement element, int seconds) {
		log.info("Waiting for Element to be visible for " + seconds + " seconds");
		try {
			new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.visibilityOf(element));
		} catch (TimeoutException e) {
			log.error("Timeout waiting for element to be visible: " + element, e);
			throw e;
		}
	}

	/**
	 * Waits explicitly for an element to be invisible.
	 *
	 * @param element the WebElement to wait for
	 * @param seconds the number of seconds to wait
	 */
	public void setExplicitWaitForElementToBeInvisible(WebElement element, int seconds) {
		log.info("Waiting for Element to be invisible for " + seconds + " seconds");
		try {
			new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.invisibilityOf(element));
		} catch (TimeoutException e) {
			log.error("Timeout waiting for element to be invisible: " + element, e);
			throw e;
		}
	}

	/**
	 * Clicks on a WebElement.
	 * Waits for the element to be clickable before clicking.
	 *
	 * @param element the WebElement to click
	 */
	public void clickElement(WebElement element) {
		try {
			// Wait for the element to be clickable
			WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));
			wait.until(ExpectedConditions.elementToBeClickable(element));
			// Click the element
			element.click();
		} catch (NoSuchElementException | TimeoutException e) {
			log.error("Element not found or not clickable, Exception thrown: " + e.getMessage(), e);
			throw e;
		}
	}

	/**
	 * Enters text into a WebElement.
	 * Waits for the element to be clickable before entering text.
	 *
	 * @param element the WebElement to enter text into
	 * @param text the text to enter
	 */
	public void enterText(WebElement element, String text) {
		try {
			// Wait for the element to be clickable
			WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(30));
			wait.until(ExpectedConditions.elementToBeClickable(element));
			// Enter the text
			element.sendKeys(text);
		} catch (NoSuchElementException | TimeoutException e) {
			log.error("Element not found or not clickable, Exception thrown: " + e.getMessage(), e);
			throw e;
		}
	}

	public void scrollToView(WebElement element){
		js = (JavascriptExecutor) driver;
		js.executeScript("arguments[0].scrollIntoView();", element);
	}

	public void selectByVisibleText(WebElement element, String text){

		Select dropDown = new Select(element);
		dropDown.selectByVisibleText(text);
	}

	public void selectByPartialText(WebElement element, String partialText) {

		Select select = new Select(element);
		List<WebElement> options = select.getOptions();

		for (WebElement option : options) {
			if (option.getText().contains(partialText)) {
				option.click();
				break;
			}
		}
	}
}
