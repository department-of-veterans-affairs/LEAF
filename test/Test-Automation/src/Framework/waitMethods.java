package Framework;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.chrome.ChromeDriver;

public class waitMethods {

	//Call would be:  waitMethods.waiter(waitMethods.w300);
	public static void waiter(int milli) {
		try {
			Thread.sleep(milli);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	public static void implicitWait(int milli) {

		try {
			ChromeDriver waitDriver = new ChromeDriver();
			waitDriver.manage().timeouts().implicitlyWait(milli, TimeUnit.MILLISECONDS);
		} catch (Exception e) {
			System.out.println("implicitWait Method fired");
			e.printStackTrace();
		}
	}
	
	
	
	
//	boolean longWaits = true;
//	
//	if(longWaits) {
		
	//String var;				//For testing commits only, delete
	
		//Standard Values
		public final static int w10 = 10;		//10
		public final static int w15 = 15;		//15
		public final static int w20 = 20;		//20
		public final static int w30 = 30;		//30
		public final static int w50 = 50;		//50	
		public final static int w100 = 100;		//100
		public final static int w200 = 200;		//200
		public final static int w250 = 250;		//300
		public final static int w300 = 300;		//300
		public final static int w400 = 400;		//400
		public final static int w500 = 500;		//500
		public final static int w600 = 600;		//600
		public final static int w750 = 750;		//750
		public final static int w1k = 1000;		//1000
		public final static int w1500 = 1500;	//1500
		public final static int w2500 = 2500;	//2500
		public final static int w2k = 2000;		//2000
		public final static int w3k = 3000;		//3000
		public final static int w4k = 4000;		//4000
		public final static int w5k = 5000;		//5000
		public final static int w8k = 8000;		//8000
	
		
		
		
		
		
	//	} else {
		
	
	
		//Headless values - Speed up
//		public final static int w10 = 10;		//10
//		public final static int w15 = 15;		//15
//		public final static int w20 = 20;		//20
//		public final static int w30 = 30;		//30
//		public final static int w50 = 50;		//50
//		public final static int w100 = 100;		//100
//		public final static int w200 = 200;		//200
//		public final static int w250 = 250;		//250
//		public final static int w300 = 250;		//300
//		public final static int w400 = 250;		//400
//		public final static int w500 = 250;		//500
//		public final static int w600 = 250;		//600
//		public final static int w750 = 250;		//750
//		public final static int w1k = 250;		//1000
//		public final static int w2k = 350;		//2000
//		public final static int w1500 = 400;	//1500
//		public final static int w2500 = 700;	//2500
//		public final static int w3k = 2000;		//3000
//		public final static int w4k = 3000;		//4000
//		public final static int w5k = 3500;		//5000
//		public final static int w8k = 5500;		//8000

	
	
	
		//Super slo-mo mode     TODO: Fix Time Values in class waitMethods
//		public final static int w10 = 10;		//10
//		public final static int w15 = 15;		//15
//		public final static int w20 = 20;		//20
//		public final static int w30 = 30;		//30
//		public final static int w50 = 75;		//75	
//		public final static int w100 = 400;		//100
//		public final static int w200 = 450;		//200
//		public final static int w250 = 500;		//250
//		public final static int w300 = 550;		//300
//		public final static int w400 = 525;		//400
//		public final static int w500 = 650;		//500
//		public final static int w600 = 800;		//600
//		public final static int w750 = 1000;	//750
//		public final static int w1k = 2000;		//1000
//		public final static int w2k = 2000;		//2000
//		public final static int w1500 = 2000;	//1500
//		public final static int w2500 = 3000;	//2500
//		public final static int w3k = 3500;		//3000
//		public final static int w4k = 4500;		//4000
//		public final static int w5k = 5500;		//5000
//		public final static int w8k = 8500;		//8000

	
	

	
	
} //class
