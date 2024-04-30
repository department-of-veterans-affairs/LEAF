package main.Base;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import main.Utility.Constants;
import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.*;
import test.java.Framework.waitMethods;

import java.io.File;
import java.io.IOException;
import java.time.Duration;
import java.util.Random;

import static main.Utility.Constants.*;

public class BasePage {

    //Created object of Loggers Class
    private static final Logger log = LogManager.getLogger(BasePage.class);
    public static ExtentReports extentReports;
    public static ExtentTest extentTest;
    protected static WebDriver driver;
    static By Advanced_btn = By.id("details-button");
    static By proceed_link = By.id("proceed-link");

    @Parameters({"env", "browser"})
    @BeforeMethod
    public void setUp1(@Optional("") String env, @Optional("CHROME") String browser) {
        browserInitialization(browser, env);
        System.out.println("Title: " + driver.getCurrentUrl() + " -->" + driver.getTitle());
    }

    @BeforeSuite
    public void setUp() {
        ExtentSparkReporter extentSparkReporter = new ExtentSparkReporter("TestResult.html");
        extentReports = new ExtentReports();
        extentReports.attachReporter(extentSparkReporter);
        extentReports.setSystemInfo("OS", System.getProperty("os.name"));
        extentReports.setSystemInfo("Java Version", System.getProperty("java.version"));
    }

    @AfterSuite
    public void generateReport() throws IOException {
        driver.quit();
        //  extentReports.flush();
        // Desktop.getDesktop().browse(new File("TestResult.html").toURI());
    }

    @AfterMethod
    public void quitDriver() {
        driver.close();
    }

    /*
    public void checkStatus(ITestResult result) throws IOException {
        System.out.println("After method steps");
        if (result.getStatus() == ITestResult.SUCCESS) {
            extentTest.createNode(result.getName(), "Passed");
            String path = takeScreenshot((WebDriver) driver);
            extentTest.addScreenCaptureFromPath(path);
        } else if (result.getStatus() == ITestResult.FAILURE) {
            extentTest.createNode(result.getName(), "Failed");
            String path = takeScreenshot((WebDriver) driver);
            extentTest.addScreenCaptureFromPath(path);
        } else if (result.getStatus() == ITestResult.SKIP) {
            extentTest.createNode(result.getName(), "Skipped");
            String path = takeScreenshot((WebDriver) driver);
            extentTest.addScreenCaptureFromPath(path);
        }
        //driver.close();
    }


     */

    //Baseclass is referring to Utils class using Super() keyword
    public BasePage() {
        super();
        PageFactory.initElements(driver, this);
    }

    //Initializing the driver and maximize the window size
    public static void browserInitialization(String browser, String env) {
        getDriver(browser);
        driver.manage().window().maximize();
        log.warn("Maximizing window size");
        driver.manage().deleteAllCookies();
        log.warn("Deleting all cookies");
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(pageLoadTimeOut));
        log.warn("Page load Timeout duration :" + pageLoadTimeOut);
        if (getEnvironment().equalsIgnoreCase("remote")) {
            driver.get(getRemote_url());
            log.info("Fetching Remote URL : " + getRemote_url());
        } else {
            driver.get(getEnvURL());
            handleSSLError();
            log.info("Fetching Remote URL : " + getEnvURL());
        }
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(implicitWaitTime));
    }

    public static WebDriver getDriver(String browserName) {
        if (browserName.toLowerCase().equals("chrome")) {
            initializeChrome();
        } else if (browserName.toLowerCase().equals("firefox")) {
            initializeFirefox();
        }
        return driver;
    }

    private static WebDriver initializeChrome() {
        ChromeOptions options = new ChromeOptions();
        if (Constants.headless) {
            options.addArguments("headless");
            log.info("Test Running in Headless mode.");
        }
        options.setPageLoadStrategy(PageLoadStrategy.EAGER);
        driver = new ChromeDriver(options);
        log.info("Test Running on Chrome Browser");
        return driver;
    }


    private static WebDriver initializeFirefox() {
        driver = new FirefoxDriver();
        FirefoxOptions options = new FirefoxOptions();
        options.setPageLoadStrategy(PageLoadStrategy.EAGER);
        driver = new FirefoxDriver(options);
        log.info("Opening Firefox Browser");
        return driver;

    }

    //Take screenshot
    public static String takeScreenshot(WebDriver driver) throws IOException {
        TakesScreenshot screenshot = ((TakesScreenshot) driver);
        File file = screenshot.getScreenshotAs(OutputType.FILE);
        //Generating random number for screenshot name
        Random rd = new Random();
        int i = rd.nextInt();
        File destination = new File(currentDir + "//Screenshot/screenshot_" + i + ".png");
        log.trace("Saving screenshot to location :" + destination);
        FileUtils.copyFile(file, destination);
        String scr_path = currentDir + "//Screenshot/screenshot_" + i + ".png";
        log.info("Screenshot with name : screenshot_" + i + ".png saved");
        return scr_path;
    }

    //Get the pageTitle of current page
    public String getPageTitle() {
        String pageTitle = driver.getTitle();
        log.info("Page title of current page is :" + pageTitle);
        return pageTitle;
    }

    //Add explicit wait
    public void setExplicitWait(int seconds) {
        explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
        log.info("Waiting for Element to appear for " + seconds + " seconds");
    }

    public void highLightElement(WebDriver driver, WebElement ele) {
        int j = 50;
        JavascriptExecutor js = (JavascriptExecutor) driver;

        for (int k = 0; k < 3; ++k) {
            js.executeScript("arguments[0].setAttribute('style', 'background: yellow; border: 2px solid red;');", ele);
            test.java.Framework.waitMethods.waiter(j);
            js.executeScript("arguments[0].setAttribute('style','border: solid 2px white');", ele);
            waitMethods.waiter(j);
        }
    }


    public void clickElement(WebElement element) {
        try {
            element.click();
            log.info("Clicked on element : " + element);
        } catch (Exception e) {
            log.error("Unable to click on element : " + element);
        }
    }

    public static void waitUntilElementIsVisible(By element, int time) {
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(time));
        wait.until(ExpectedConditions.visibilityOfElementLocated((By) element));
    }

    //create a method that will click on advanced option in chrome browser and click on proceed to website
    public static void handleSSLError() {
        waitUntilElementIsVisible(Advanced_btn, 10);
        driver.findElement(Advanced_btn).click();
        waitUntilElementIsVisible(proceed_link, 10);
        driver.findElement(proceed_link).click();
    }
}

