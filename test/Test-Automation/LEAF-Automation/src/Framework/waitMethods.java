package Framework;

import java.sql.Driver;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

public class waitMethods {

//	boolean longWaits = true;
//	
//	if(longWaits) {
		
	//String var;				//For testing commits only, delete
	
		//Vars for demo
		public final static int w100 = 100;		//100
		public final static int w200 = 200;		//200
		public final static int w250 = 250;		//300
		public final static int w300 = 300;		//300
		public final static int w500 = 500;		//500
		public final static int w750 = 750;		//750
		public final static int w1k = 1000;		//1000
		public final static int w2k = 2000;		//2000
		public final static int w3k = 3000;		//3000
		public final static int w4k = 4000;		//4000
		public final static int w5k = 5000;		//5000

		
	//	} else {
		
	
	
		//Headless values
//		public final static int w100 = 100;		//100
//		public final static int w200 = 200;		//200
//		public final static int w250 = 250;		//250
//		public final static int w300 = 250;		//300
//		public final static int w500 = 250;		//500
//		public final static int w750 = 250;		//750
//		public final static int w1k = 250;		//1000
//		public final static int w2k = 350;		//2000
//		public final static int w3k = 400;		//3000
//		public final static int w4k = 500;		//4000
//		public final static int w5k = 600;		//5000

		
//	}
	
	
	public static void waiter(int milli) {
		try {
			Thread.sleep(milli);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	public static void implicitWait(int milli) {

		ChromeDriver waitDriver = new ChromeDriver();
		waitDriver.manage().timeouts().implicitlyWait(milli, TimeUnit.MILLISECONDS);
	}
	
	
} //class
