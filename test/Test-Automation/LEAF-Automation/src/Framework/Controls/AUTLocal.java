package Framework.Controls;

public class AUTLocal {
	
	//Define which browser(s) to run:
	public final static boolean runChrome = true;
	public final static boolean runIE = false;
	
	//The URL location of the application under test
	
	//Define URL, Username and Password
	//TO DO: REFACTOR VARIABLE NAMES
	public final static String QATECOSURL = "https://www.regions.com/personal-banking"; //URL under test
	
	public static String username = "madmaxrich@gmail.com"; //Me
	public static String password = "Syrinx2112"; //Me
	
	public static String DCusername = "qatdcmgr"; //
	public static String DCpassword = "Motion01"; //QAT
	
	public static String ServiceCenterusername = "TestUserName"; //QAT
	public static String ServiceCenterpassword = "TestPWD"; //QAT
	
	
	/************************************************************** LOCAL **************************************************************/
	
	//The Local Results path
	public final static String LOCALPATHRESULTS = "C:/DEV/EclipseWorkspaces/AutomatedTestingFramework/logs/";
	//C:/DEV/EclipseWorkspaces/AutomatedTestingFramework/logs
	
	//The Local Workspace
	public final static String LOCALPATHWORKSPACE = "C:/DEV/EclipseWorkspaces/AutomatedTestingFramework/";
	//C:/DEV/EclipseWorkspaces/AutomatedTestingFramework/
	
	//The Local Path to Selenium ChromeDriver v2.14 (2015-01-28) Supports Chrome v39-42
	//The Local Path to Selenium ChromeDriver v2.15 (2015-03-26) Supports Chrome v40-43
	//The Local Path to Selenium ChromeDriver v2.16 (2015-06-08) Supports Chrome v42-45
	//public final static String LOCALPATHDRIVERCHROME = "C:/DATA/Installers/chromedriver_win32-2_16/chromedriver.exe";
	public final static String LOCALPATHDRIVERCHROME = "C:/DEV/Tools/Chromedrivers/Chromedriver 88.0.4324.27/chromedriver_win32/chromedriver.exe";
	
	//C:/DEV/Tools/Chromedrivers/Chromedriver 88.0.4324.27/chromedriver_win32/chromedriver.exe
	//The Selenium Internet Explorer Driver
	//public final static String LOCALPATHDRIVERIE = "C:/DATA/Installers/IEDriverServer_x64_2.44.0/IEDriverServer.exe";
	
	//Not Setup for IE yet  1/7/21
	public final static String LOCALPATHDRIVERIE = "C:/DATA/Installers/IEDriverServer_Win32_2.45.0/IEDriverServer.exe"; 
		
	/************************************************************* JENKINS *************************************************************/
		
	//The Jenkins Local Workspace path for the AutomationDEV branch
	//public final static String LOCALPATHRESULTS = "C:/Users/DP014958/.jenkins/jobs/MotionECOSTestExecution-Process-Critical-AutomationDEV/workspace/Results/";
	
	//The Jenkins Local Workspace path for the AutomationDEV branch
	//public final static String LOCALPATHWORKSPACE = "C:/Users/DP014958/.jenkins/jobs/MotionECOSTestExecution-Process-Critical-AutomationDEV/workspace/";
		
	//The Jenkins Local Path to Selenium ChromeDriver v2.18 (2015-08-19) Supports Chrome v43-46
	//public final static String LOCALPATHDRIVERCHROME = "C:/DATA/Installers/chromedriver_win32-2_18/chromedriver.exe";

	//NOTE: The Selenium Firefox driver is built-in to Firefox.
}