package test.java.Framework;

import java.lang.*;


public class browserUtilities {

	public void killChromedriver() {
		try {
			Runtime.getRuntime().exec("taskkill /F /IM ChromeDriver.exe");
		} catch (Exception e) {
			System.out.println("");
		}
	}
	
//	Process[] chromeDriverProcesses = Process.GetProcessesByName("chromedriver");
//	foreach(var chromeDriverProcess in chromeDriverProcesses){
//	 chromeDriverProcess.Kill();
//	}
	



	
	
	
	
} //class
