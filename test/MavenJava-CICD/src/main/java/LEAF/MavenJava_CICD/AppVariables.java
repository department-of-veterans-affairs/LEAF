package LEAF.MavenJava_CICD;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

public class AppVariables {


	//     C:\Selenium\Current_ChromeDriver
	public final static String CHROMEDRIVER = "C:\\Selenium\\Current_ChromeDriver\\chromedriver.exe";
	//public final static String CHROMEDRIVER = "C:\\DEV\\Tools\\Selenium\\Current_ChromeDriver\\chromedriver.exe";
	//public final static String CHROMEDRIVER = "C:\\DEV\\Tools\\Selenium\\ChromeDriver_98.0.4758.102\\chromedriver_win32\\chromedriver.exe";
										
	public final static String IEDRIVER = "C:/DEV/Tools/Selenium/IEDriver/IEDriverServer_Win32_3.150.1/IEDriverServer.exe";
	
	public final static String PREPROD_DOMAIN = "https://leaf-preprod.va.gov/";  //  len = 28
	public final static String PROD_DOMAIN = "https://leaf.va.gov/";	  		 //  len = 20 
	


	
	//		https://leaf.va.gov/Academy/Demo1/admin/?a=form#
	
	
	//*****************************************************************	
 
 
	//Change this variable to turn highlighting off
	public final static boolean demoMode = true; 

 
	//Change this variable to to true to run in headless mode with correct parameters, resolution,
	public final static boolean headless = false;
	//public final static boolean headless = true;

		//Local environment

	//public final static String LOCALURI ="http://localhost/LEAF_Request_Portal/";
	//	public final static String LOCALUID = "tester";
	//	public final static String LOCALPWD = "tester";


	//***************************************************************** 
	//public final static String LOCALURI = "http://localhost/LEAF_Request_Portal/";

 	 

}  //class
