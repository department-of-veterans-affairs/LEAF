package Framework.Controls;

import java.util.logging.FileHandler;
import java.util.logging.Logger;

import org.openqa.selenium.WebDriver;

public class AUTGlobals {
	
	//The new way of defining which browser(s) to run:
//	public final static boolean runChrome = true;
//	public final static boolean runIE = true;
	
	//Just defining the browser name string once..
	public final static String browserChrome = "Chrome";
	public final static String browserIE = "Internet Explorer";
	public final static String browserFF = "Firefox";
	
	//The original way of defining which browser to run:
	public final static String browserType = browserChrome;
	//public static String browserType = browserIE;
	//public static String browserType = browserFF;
	
//	public final static String QATECOSURL = "http://qat.inmotion.motionindustries.com/motion3/jsp/inmotion/inMotion2_0/home.jsp#";
	
	public final static String eCOSTestLog = AUTLocal.LOCALPATHWORKSPACE + "Logs/TestRunLogFile.log";
	public final static String eCOSTestScriptLog = AUTLocal.LOCALPATHWORKSPACE + "Logs/TestScriptLogFile.log";
	public final String eCOSTestLogFolder = AUTLocal.LOCALPATHWORKSPACE + "Logs/";
	public final String eCOSTestResultLogger = AUTLocal.LOCALPATHWORKSPACE + "TestResults/";
	
	public static Logger TestRunlogger = Logger.getLogger("eCOSTestRunLog");
	public static FileHandler fh2;	
	public final static String xDOMBodyDivsContainer = "/html/body/div";
	
	
	//Configure email address to be used for emailing results
	public final static String emailAutomationTesting = "CONFIGURE_THIS_EMAIL_ADDRESS@domain.com";
	public final static int waitloops = 20;
	public final static int waitTime = 500; //in milliseconds
	public final static int globalTimeout = 10; //in seconds
	public static String testName = "";
	public static String testResultFileName = "";	
	public static String buildNumber = null;
	public static String releaseNumber = null;
	public static StringBuffer VE = new StringBuffer();  //Verification Errors
	//This is set programatically for downstream reporting.  Don't write db entries if running a stub for instance.
	public static boolean runStub = false;
	
	//Generic controls
	public static String cssToolTip = "div.x-tip";
	
}
