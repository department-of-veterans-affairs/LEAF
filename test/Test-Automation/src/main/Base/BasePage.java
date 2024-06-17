package main.Base;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.MediaEntityBuilder;
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
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.PageFactory;
import org.testng.ITestResult;
import org.testng.annotations.*;

import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;
import java.util.Random;

public class BasePage extends Utility {

    //Created object of Loggers Class
    private static final Logger log = LogManager.getLogger(BasePage.class);
    public static ExtentReports extentReports;
    public static ExtentTest extentTest;
    public JavascriptExecutor js = (JavascriptExecutor) driver;


    @Parameters({ "env", "browser"})
    @BeforeSuite
    public void setUp(@Optional("qa") String env, @Optional("CHROME") String browser)throws MalformedURLException {
        browserInitialization(browser,env);
        ExtentSparkReporter extentSparkReporter = new ExtentSparkReporter(Constants.currentDir+"//TestResult.html");
        extentReports = new ExtentReports();
        extentReports.attachReporter(extentSparkReporter);
        extentReports.setSystemInfo("OS", System.getProperty("os.name"));
        extentReports.setSystemInfo("Java Version", System.getProperty("java.version"));
        log.info("Setting up the browser");
        System.out.println("Before Suite");
        log.info("Setting up the extent report");
    }


    @BeforeClass()
    public void initializeExtentTest(){
        extentTest = extentReports.createTest(getClass().getSimpleName());
        System.out.println("Class name is : "+getClass().getSimpleName());
        log.info("Initializing extent test");
    }
    @AfterClass
    public void tearDown(){
       // driver.close();
        System.out.println("After class"+ getClass().getSimpleName());
        log.info("Closing the browser");
        driver.quit();
        log.info("Quitting the browser");
    }

    @AfterSuite
    public void generateReport() throws IOException {
        extentReports.flush();
        Desktop.getDesktop().browse(new File(Constants.currentDir+"//TestResult.html").toURI());
        log.info("Generating extent report");
     }

    @AfterMethod
    public void checkStatus(ITestResult result) throws IOException {
        System.out.println("After Method from BasePage");
        takeScreenshot(driver);
        String screenshotPath = getScreenshotPath();
        log.info("Checking status of the test case");
        switch (result.getStatus()) {
            case ITestResult.FAILURE:
                extentTest.addScreenCaptureFromPath(screenshotPath);
                extentTest.createNode(result.getName(), "Failed");
                Throwable throwable = new Throwable("This is the exception :");
                extentTest.fail("Test case Failed", MediaEntityBuilder.createScreenCaptureFromPath(screenshotPath).build())
                        .fail(throwable);
                break;
            case ITestResult.SUCCESS:
                extentTest.addScreenCaptureFromPath(screenshotPath);
                extentTest.createNode(result.getName(), "Passed");
                break;
            case ITestResult.SKIP:
                extentTest.createNode(result.getName(), "Skipped");
                break;
            case ITestResult.STARTED:
                extentTest.createNode(result.getName(), "Started");
                break;
            default:
                result.getThrowable();
                log.info("Print throwable exception");
        }
    }


    //Baseclass is referring to Utils class using Super() keyword
    public BasePage() {
        PageFactory.initElements(driver, this);
       }

    //Initializing the driver and maximize the window size
    public static void browserInitialization(String browser,String env) throws MalformedURLException {
        System.out.println("browse: " + browser);
        getDriver(browser);
        driver.manage().window().maximize();
        log.warn("Maximizing window size");
        driver.manage().deleteAllCookies();
        log.warn("Deleting all          cookies");
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(Constants.pageLoadTimeOut));
        log.warn("Page load Timeout duration :"+ Constants.pageLoadTimeOut);
        if(env.equalsIgnoreCase("remote")){
            System.out.println("remote: " + Constants.getRemote_url());
            driver = createDriver();
            driver.get(Constants.getRemote_url());
            log.info("Fetching Remote URL on docker hub : "+ Constants.getRemote_url());
        }else if (env.equalsIgnoreCase("qa")) {
            driver.get(Constants.getEnvURL());
            redirectURL();
            log.info("Fetching Remote URL : "+ Constants.getEnvURL());
        }
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(Constants.implicitWaitTime));
    }

        public static WebDriver getDriver(String browserName){
        if(browserName.toLowerCase().equals("chrome")){
            initializeChrome();
        } else if (browserName.toLowerCase().equals("firefox")) {
            initializeFirefox();
        } else if(browserName.toLowerCase().equals("remote")){
            try {
                createDriver();
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
        }
        else{
            log.error("Browser not found");
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


    public String getScreenshotPath() throws IOException {
        String path = takeScreenshot(driver);
        return path;
    }

    public static RemoteWebDriver createDriver() throws MalformedURLException {       
        DesiredCapabilities caps = new DesiredCapabilities();
        caps.setBrowserName("chrome");
        driver = new RemoteWebDriver(new URL(Constants.getRemote_url()), caps);
        return (RemoteWebDriver) driver;
    }


}

