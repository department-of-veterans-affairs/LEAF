package main.Base;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import main.Utility.Constants;
import main.Utility.Utility;
import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.support.PageFactory;
import org.testng.ITestResult;
import org.testng.annotations.*;

import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.time.Duration;
import java.util.Random;

public class BasePage extends Utility {

    //Created object of Loggers Class
    private static final Logger log = LogManager.getLogger(BasePage.class);
    public static ExtentReports extentReports;
    public static ExtentTest extentTest;
    public JavascriptExecutor js = (JavascriptExecutor) driver;

    @Parameters({ "env", "browser"})
    @BeforeTest()
    public void setUp(@Optional("") String env, @Optional("CHROME") String browser) {
        browserInitialization(browser,env);
        log.info("Title: "+driver.getCurrentUrl()+" -->"+driver.getTitle());
    }

    @BeforeSuite
    public void setUpReporting(){
        ExtentSparkReporter extentSparkReporter = new ExtentSparkReporter(Constants.currentDir+"//TestResult.html");
        extentReports = new ExtentReports();
        extentReports.attachReporter(extentSparkReporter);
        extentReports.setSystemInfo("OS", System.getProperty("os.name"));
        extentReports.setSystemInfo("Java Version", System.getProperty("java.version"));
    }

    @AfterSuite
    public void generateReport() throws IOException {
        driver.quit();
        extentReports.flush();
        Desktop.getDesktop().browse(new File(Constants.currentDir+"//TestResult.html").toURI());
        log.info("Generating extent report");
    }


    @AfterMethod
    public void checkStatus(ITestResult result) throws IOException {
        log.info("Checking status of the test case");
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
    }



    //Baseclass is referring to Utils class using Super() keyword
    public BasePage() {
        super();
        PageFactory.initElements(driver, this);
    }

    //Initializing the driver and maximize the window size
    public static void browserInitialization(String browser, String env){
        getDriver(browser);
        driver.manage().window().maximize();
        log.warn("Maximizing window size");
        driver.manage().deleteAllCookies();
        log.warn("Deleting all cookies");
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(Constants.pageLoadTimeOut));
        log.warn("Page load Timeout duration :"+ Constants.pageLoadTimeOut);
        if(Constants.getEnvironment().equalsIgnoreCase("remote")){
            driver.get(Constants.getRemote_url());
            log.info("Fetching Remote URL : "+ Constants.getRemote_url());
        }else{
            driver.get(Constants.getEnvURL());
            redirectURL();
            log.info("Fetching Remote URL : "+ Constants.getEnvURL());
        }
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(Constants.implicitWaitTime));
    }


    public static WebDriver getDriver(String browserName){
        if(browserName.toLowerCase().equals("chrome")){
            initializeChrome();
        }
        else if (browserName.toLowerCase().equals("firefox")) {
            initializeFirefox();
        }
        return driver;
    }

    private static WebDriver initializeChrome(){
        if(Constants.headless){
            ChromeOptions options = new ChromeOptions();
            options.addArguments("headless");
            driver = new ChromeDriver(options);
            log.info("Test Running in Headless mode.");
        } else{
            driver = new ChromeDriver();
            ChromeOptions options = new ChromeOptions();
            options.setPageLoadStrategy(PageLoadStrategy.EAGER);
            driver = new ChromeDriver(options);
            log.info("Test Running on Chrome Browser");
        }
        return driver;
    }

    private static WebDriver initializeFirefox(){
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
        File destination = new File(Constants.currentDir+"//Screenshot/screenshot_"+i+".png");
        log.trace("Saving screenshot to location :" +destination);
        FileUtils.copyFile(file,destination);
        String scr_path = Constants.currentDir+"//Screenshot/screenshot_"+i+".png";
        log.info("Screenshot with name : screenshot_"+i+".png saved");
        return scr_path;
    }

    //Get the pageTitle of current page
    public String getPageTitle(){
        String pageTitle = driver.getTitle();
        log.info("Page title of current page is :"+pageTitle);
        return pageTitle;
    }

    public static void redirectURL() {
        WebElement advancedButton = driver.findElement(By.id("details-button"));
        setExplicitWaitForElementToBeVisible(advancedButton, 10);
        advancedButton.click();
        WebElement proceedLink = driver.findElement(By.id("proceed-link"));
        setExplicitWaitForElementToBeVisible(proceedLink, 10);
        proceedLink.click();
        log.info("Redirecting to URL");
    }
}

