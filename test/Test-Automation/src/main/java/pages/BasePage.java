package main.java.pages;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.remote.DesiredCapabilities;
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
 * @author Nikesh
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
				.withTimeout(Duration.ofSeconds(10)).pollingEvery(Duration.ofSeconds(2));
	}

	public static RemoteWebDriver createDriver(String HUB_URL) throws MalformedURLException {
		DesiredCapabilities caps = new DesiredCapabilities();
		caps.setCapability("browserName", "chrome");
		caps.setCapability("version", "latest");
		return new RemoteWebDriver(new URL(HUB_URL), caps);
	}


	//Add explicit wait
	public static void setExplicitWait(int seconds){
		explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
		log.info("Waiting for Element to appear for "+seconds+" seconds");
	}

	//ExplicitWait for element to be clickable
	public void setExplicitWaitForElementToBeClickable(WebElement element, int seconds){
		log.info("Waiting for Element to be clickable for "+seconds+" seconds");
		explicitWait =  new WebDriverWait(driver, Duration.ofSeconds(seconds));
		explicitWait.until(ExpectedConditions.elementToBeClickable(element));
	}

	//ExplicitWait for element to be visible
	public static void setExplicitWaitForElementToBeVisible(WebElement element, int seconds){
		log.info("Waiting for Element to be visible for "+seconds+" seconds");
		new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.visibilityOf(element));
	}

	//ExplicitWait for element to be invisible
	public void setExplicitWaitForElementToBeInvisible(WebElement element, int seconds){
		log.info("Waiting for Element to be invisible for "+seconds+" seconds");
		new WebDriverWait(driver, Duration.ofSeconds(seconds)).until(ExpectedConditions.invisibilityOf(element));
	}



}
