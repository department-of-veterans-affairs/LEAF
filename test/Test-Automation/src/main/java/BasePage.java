package main.java;

/*
import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.ITestResult;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeSuite;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.internal.Utils;

import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.time.Duration;
import java.util.logging.LogManager;
import java.util.logging.Logger;

public class BasePage extends Utils {


    //Created object of Loggers Class
    private static final Logger log = LogManager.getLogger(BasePage.class);
    public static ExtentReports extentReports;
    public static ExtentTest extentTest;

    @BeforeSuite
    public void initializeExtentReport(){
        ExtentSparkReporter extentSparkReporter = new ExtentSparkReporter("TestResult.html");
        extentReports = new ExtentReports();
        extentReports.attachReporter(extentSparkReporter);
        extentReports.setSystemInfo("OS", System.getProperty("os.name"));
        extentReports.setSystemInfo("Java Version", System.getProperty("java.version"));
    }
    @AfterSuite
    public void generateReport() throws IOException {
        driver.quit();
        extentReports.flush();
        Desktop.getDesktop().browse(new File("TestResult.html").toURI());
    }

    @AfterMethod
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


    //Baseclass is referring to Utils class using Super() keyword
    /*public BaseClass(){
        super();
    }




    //Initializing the driver we're using and Reading from env.properties file
    public static void initialization(){
        String browserName = properties.getProperty("browser");
        if(browserName.equals("chrome")){
            driver = new ChromeDriver();
            log.info("Opening chrome browser");
            ChromeOptions options = new ChromeOptions();
            options.addArguments("--remote-allow-origin=*");
        } else if (browserName.equals("firefox")) {
            driver = new FirefoxDriver();
            log.info("Opening FireFox browser");
        } else if (browserName.equals("edge")) {
            driver = new EdgeDriver();
        }
        driver.manage().window().maximize();
        driver.manage().deleteAllCookies();
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(pageLoadTimeOut));
        driver.get(properties.getProperty("url"));
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(implicitWaitTime));
    }

    }

    */