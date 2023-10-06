package zArchive;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

import Framework.AppVariables;

import org.openqa.selenium.*;
import org.openqa.selenium.WebElement;


public class Authentication {
	public static void main(String[] args) {

		String id = "tester";
		String pass = "tester";

		String vericationQuestionText = "";
		String verificationAnswer = "";
		String idVerificationInputBox = "answer";

		String Filename = "C:/Users/madma_000/Dropbox/DEV/Java/_Output/TestResultsFile.txt";

		
		System.setProperty("webdriver.chrome.driver", Framework.AppVariables.CHROMEDRIVER);
		WebDriver driverChrome = new ChromeDriver();

//		driverChrome.get(Framework.AppVariables.NULLURL);
		driverChrome.manage().window().maximize();

		System.out.println("Chrome should be maximized and GETURL loaded");

		Authentication.wait(200);

		try {
			driverChrome.findElement(By.className("rds-cookie-notice__cookie-button")).click();
		} catch (Exception e) {
			System.out.println("Exception closing cookie policy");
		}

		// send UID
		try {
			driverChrome.findElement(By.id("OnlineID")).sendKeys(id); // Send Pin using id
			// driverChrome.findElement(By.xpath(xpPIN)).sendKeys(id); //Send PIN using
			// xpath
			System.out.println("SendKeys for UID sent");
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Element probably not found: " + e);
		}

		Authentication.wait(200);

		// Click 'Log In' buttom
		try {
			driverChrome.findElement(By.className("regions-login-button")).click();
		} catch (Exception e) {
			System.out.println("Exception pressing Log In button");
		}

		Authentication.wait(350);

		// send pass by text
		try {
			driverChrome.findElement(By.id("input_password")).sendKeys(pass); // send pass by id
			System.out.println("SendKeys for pass sent");
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Element probably not found: " + e);
		}

		Authentication.wait(100);

		// click login button
		try {
			driverChrome.findElement(By.xpath("//*[text()='Log In']")).click();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Failed on clicking Submit button: " + e);
		}

		// IDENTIFY BY TEXT
		// WebElement e = driver.findElement(By.xpath("//*[text()='Get started
		// free']"));

		// LOCATE with contains()
		// WebElement m = driver.findElement (By.xpath ("//*[contains(text(),'Get
		// started ')]"));

		// Challenge Questions
		// Question ID is: spQuestion
		// InputBox ID is: answer

		Authentication.wait(1000);

		vericationQuestionText = driverChrome.findElement(By.id("spQuestion")).getText();
		System.out.println("vericationQuestionText = " + vericationQuestionText);

		switch (vericationQuestionText) {
		case "What is your best friend's middle name?":
			verificationAnswer = "chester";
			System.out.println("verificationAnswer = " + verificationAnswer);
			break;
		case "What is your father's middle name?":
			verificationAnswer = "leonard";
			System.out.println("verificationAnswer = " + verificationAnswer);
			break;
		case "Who is your favorite musical performer/group?":
			verificationAnswer = "rush";
			System.out.println("verificationAnswer = " + verificationAnswer);
			break;
		default:
			throw new IllegalArgumentException("No match for verification question");
		}

		driverChrome.findElement(By.id("answer")).sendKeys(verificationAnswer);

//		try {						
//			vericationQuestionText = driverChrome.findElemdent(By.id(xpVerificationQuestion)).getText();
//				System.out.println("vericationQuestionText = " + vericationQuestionText);
//			if(vericationQuestionText == verificationQuestion1) {
//				driverChrome.findElement(By.id(idVerificationInputBox)).sendKeys(verificationAnswer1);
//			} 
//			else if(vericationQuestionText == verificationQuestion2) {
//				driverChrome.findElement(By.id(idVerificationInputBox)).sendKeys(verificationAnswer2);
//			}
//			else if(vericationQuestionText == verificationQuestion3) {
//				driverChrome.findElement(By.id(idVerificationInputBox)).sendKeys(verificationAnswer3);
//			}
//			else {
//				System.out.println("vericationQuestionText = " + vericationQuestionText);
//			}
//		} catch (Exception e) {
//			e.printStackTrace();
//			System.out.println("Message" + e);
//		}

// try-catch Template
//		try {						//notate function performed
//			
//		} catch (Exception e) {
//			e.printStackTrace();
//			System.out.println("Message" + e);
//		}

		// Xpath for question. One question is "What is your best friend's middle name?"
		// *[@id="contentWrapper"]/div/div[2]/div/div[2]/form/div[2]/fieldset/div[1]/label

		// EXAMPLE I Found
		// WebElement webElement = driverChrome.findElement(By.xpath(""));//You can use
		// xpath, ID or name whatever you like
		// webElement.sendKeys(Keys.TAB);
		// webElement.sendKeys(Keys.ENTER);
		// System.out.println("SendKeys for TAB and ENTER sent");

		/******************** Next (results) page ***********************************/

//		AuthRegions.wait(3000);
//		
//		result = driverChrome.findElement(By.xpath(xpResult)).getAttribute("textContent");
//			System.out.println("Result Msg: " + result);
//		conf = driverChrome.findElement(By.xpath(xpConf)).getAttribute("textContent");
//			System.out.println("Conf: " + conf);
//		dteTime = driverChrome.findElement(By.xpath(xpDteTme)).getAttribute("textContent");
//			System.out.println("DateTime: " + dteTime);
//
//		AuthRegions.wait(1000);
//		driverChrome.close();
//
//			
//		//Write results to Logfile.txt	
//		String logmsg = dteTime + "\t" + result + "\tConf Code: " + conf + "\r\n";
//		FileLogger.log(Filename, logmsg);
//		System.out.println("Results written to: " + Filename);
//	
//		
//		//"Alert" to play sound depending on result
//		if(result.contains(sYes)) {
//			fileToPlay = AppVariables.WavFileY;
//			c=2;
//			System.out.println("Playing: " + fileToPlay);
//		} else if(result.contains(sNo)) {
//			fileToPlay = AppVariables.WavFileN;
//			c=5;
//			System.out.println("Playing: " + fileToPlay);
//		} else if(result.contains(sLate)) {
//			fileToPlay = AppVariables.WavFileX;
//			c=3;
//			System.out.println("Playing: " + fileToPlay);
//		} else {
//			fileToPlay = AppVariables.WavFileX;
//			c=3;
//		}
//			
//		
//		PlayFILE play = new PlayFILE();
//		play.play(fileToPlay, c);
//			
//		AuthRegions.wait(1000);
//		System.exit(0);
	}

	static public void wait(int ms) {
		try {
			Thread.sleep(ms);
		} catch (InterruptedException e) {
			e.printStackTrace();
			System.out.println("Caught: " + e);
		}
	}
}
