package zArchive;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.rules.ErrorCollector;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.support.events.EventFiringWebDriver;
import org.openqa.selenium.interactions.Actions;

//import com.smartbear.almcomplete.Bug;					//I disabled this, not sure what the .Bug method does

//import bsh.This;						//See https://stackoverflow.com/questions/50135269/import-bsh-this-statement-in-eclipse

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.TimeUnit;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;
import java.io.BufferedWriter;

import Framework.Controls.*;

public class AUT  {
	
	public static WebDriver Browser;
	//public static EventFiringWebDriver Browser;
	public static Actions Actions;
	public static AUTGlobals AUTGlobals = new AUTGlobals();
	public static AUTLocal AUTLocal = new AUTLocal();
	public static Logger logger = Logger.getLogger("eCOSLog");
	public static FileHandler fh;	
	public static Logger TestRunlogger = Logger.getLogger("eCOSTestRunLog");
	public static FileHandler fh2;	
	public static int testIDNumber;
	public static int testSetIDNumber;
	public static int testRunID;
	public static FileWriter fw;
	public static BufferedWriter writeToFile;
	public static int intCheckpointCounter = 1;

	
	//Create the log file
	@BeforeClass
	public static void eCOSLogger() throws IOException {
		
		fh = new FileHandler(AUTGlobals.eCOSTestLog, true);
		logger.addHandler(fh);
		//logger.setLevel(Level.ALL);
		SimpleFormatter formatter = new SimpleFormatter();
		fh.setFormatter(formatter);
		
		fh2 = new FileHandler(AUTGlobals.eCOSTestScriptLog, true);
		TestRunlogger.addHandler(fh2);
		//logger.setLevel(Level.ALL);
		SimpleFormatter formatter2 = new SimpleFormatter();
		fh2.setFormatter(formatter2);
		
	}

	//Open the Browser
	public static void BrowserOpen(String browser) throws InterruptedException {
		
		if (browser == "Chrome") {
    	  
			//Specify location to ChromeDriver
			System.setProperty("webdriver.chrome.driver", AUTLocal.LOCALPATHDRIVERCHROME);
    	  
			ChromeOptions options = new ChromeOptions();
            options.addArguments("test-type");
			DesiredCapabilities capabilities = DesiredCapabilities.chrome();
			capabilities.setCapability(ChromeOptions.CAPABILITY, options);
			
			//Create a new Chrome Driver
			//pre-event listener
			//Browser = new ChromeDriver(capabilities);
			
			//Set up main webDriver Browser object, with Event Listener
			//set up a WebDriver instance to pass in to the event-firing webdriver
			WebDriver tempDriver = new ChromeDriver(capabilities);
			//set up event-firing webdriver
			Browser = new EventFiringWebDriver(tempDriver);
			//set up instance of the event listener
			EventListener el = new EventListener();
			//Register the Listener with the event-firing webdriver
			((EventFiringWebDriver) Browser).register(el);
			
			//instantiate "Actions" object (used for hovers, dbl-click, etc.)
			Actions = new Actions(Browser);
			
			//set global timeout
			AUT.logger.info("Setting implicit wait time to: " + AUTGlobals.globalTimeout + " seconds.");
			Browser.manage().timeouts().implicitlyWait(AUTGlobals.globalTimeout, TimeUnit.SECONDS);
			
			//Maximize Browser Window
			Browser.manage().window().maximize();

		}
		
		if (browser == "Internet Explorer") {
			
			System.setProperty("webdriver.ie.driver", AUTLocal.LOCALPATHDRIVERIE);
			
			//pre-event listener
//			Browser = new InternetExplorerDriver();
			
			//Set up main webDriver Browser object, with Event Listener
			  //IE was was running 10x+ slower when using the EvFWD.
			  //It almost never gets to the event listener code so IE must be doing some of its own waiting.
			//set up a WebDriver instance to pass in to the event-firing webdriver
			WebDriver tempDriver = new InternetExplorerDriver();
			//set up event-firing webdriver
			Browser = new EventFiringWebDriver(tempDriver);
			//set up instance of the event listener
			EventListener el = new EventListener();
			//Register the Listener with the event-firing webdriver
			((EventFiringWebDriver) Browser).register(el);
			
			
			//set global timeout
			AUT.logger.info("Setting implicit wait time to: " + AUTGlobals.globalTimeout + " seconds.");
			Browser.manage().timeouts().implicitlyWait(AUTGlobals.globalTimeout, TimeUnit.SECONDS);
			
			Browser.manage().window().maximize();

		}
		
		if (browser == "Firefox") {
			
			//pre-event listener
			//Browser = new FirefoxDriver();
			
			//Set up main webDriver Browser object, with Event Listener
			//set up a WebDriver instance to pass in to the event-firing webdriver
			WebDriver tempDriver = new FirefoxDriver();
			//set up event-firing webdriver
			Browser = new EventFiringWebDriver(tempDriver);
			//set up instance of the event listener
			EventListener el = new EventListener();
			//Register the Listener with the event-firing webdriver
			((EventFiringWebDriver) Browser).register(el);
			
			//set global timeout
			AUT.logger.info("Setting implicit wait time to: " + AUTGlobals.globalTimeout + " seconds.");
			Browser.manage().timeouts().implicitlyWait(AUTGlobals.globalTimeout, TimeUnit.SECONDS);
			
			Browser.manage().window().maximize();

		}
		
		logger.info("Opened " + browser);
		
    }
	
	public static void BrowserNavigateToApplicationURL(String url) {

		//Navigate to Application Under Test URL
		Browser.navigate().to(AUTLocal.QATECOSURL);
		try {
			Browser.manage().deleteAllCookies();	
		}
		catch (Exception ex) {
			try {
				Browser.switchTo().alert().accept();
				Browser.navigate().refresh();
			}
			catch (Exception ex1) {
				logger.info("Failed to Navigated to " + url);
			}
		}
		logger.info("Navigated to " + url);
	}

	public static boolean assertTrueAutomation(String message, Boolean condition) {
		
		try { 	
			
			assertTrue(message, condition);
			TestIntegration.updateTestRunInQAComplete(true);
			return true;
			
			
			
		}
		catch (AssertionError e) {
			
			TestIntegration.updateTestRunInQAComplete(false);
			TestIntegration.createBugInQAComplete(TestIntegrationConstants.webServiceTestID);
			
			return false;
		}
		
	}
	
	public static void setTestID(int testID) {
		
		testIDNumber = testID;
		
	}
	
	public static void setTestSetID(int testSetID) {
		
		testSetIDNumber = testSetID;
		
	}
	
	public static String createResultsFile() { 

		String fileName = AUTGlobals.testName;
		
		try {
			
			String timestamp = FrameworkProcedures.MyFileDate();
			
			fileName = AUTLocal.LOCALPATHRESULTS + fileName + "-" + timestamp + ".txt";
			
			File file = new File(fileName);
			
			//If file doesn't exist, then create it
			if (!file.exists()) {
				file.createNewFile();
			}
			 
			fw = new FileWriter(file.getAbsoluteFile());
			writeToFile = new BufferedWriter(fw);
			
			System.out.println("Result File Created : " + fileName);
			
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		return fileName;

    }
	
	public static void createResultsFile(String fileName) { 

		try {
			
			
			String timestamp = FrameworkProcedures.MyFileDate();
			
			fileName = AUTLocal.LOCALPATHRESULTS + fileName + "-" + timestamp + ".txt";
			
			File file = new File(fileName);
			
			//If file doesn't exist, then create it
			if (!file.exists()) {
				file.createNewFile();
			}
			 
			fw = new FileWriter(file.getAbsoluteFile());
			writeToFile = new BufferedWriter(fw);
			
			System.out.println("Result File Created : " + fileName);

		}
		catch (IOException e) {
			e.printStackTrace();
		}

    }

	public static void run_stub(String browserType) throws Exception {

		AUTGlobals.runStub = true;
		logger.info("Running stub only");
		
	}
	

 // 3/31/2015 VMD Removed the following code.  This functionality is now contained within the WriteResultsRule	
	@After
	public void BrowserClose() {
		if (!AUTGlobals.runStub) {
			Browser.close();
			Browser.quit();
		}
		//If the verification process got any entries then write them all out and "fail" the script
		if (!AUTGlobals.runStub) {
			String vErrors = AUTGlobals.VE.toString();
			if (!"".equals(vErrors)){
				fail(vErrors);
			}
		}
		
		//clear the VE string buffer -> this moved to WriteResultsRule jwa
		//AUTConstants.VE.delete(0, AUTConstants.VE.length());
		
	}
	
}
