//package Execution;
//
//import org.testng.annotations.Test;
//import org.testng.annotations.BeforeMethod;
//
//import java.text.SimpleDateFormat;
//import java.util.Date;
//
//import org.openqa.selenium.By;
//import org.openqa.selenium.JavascriptExecutor;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.NoSuchElementException;
//import org.testng.annotations.BeforeClass;
//
//import Framework.highlightElement;
//
//public class TestHTMLBox extends setupFramework {
//
//	//private static final DateFormat Calendar = null;
//	Date date = new Date();
//
//	@BeforeMethod
//	@BeforeClass
//	public void setUp()  {
//		if(driver!= null) {
//			driver=getDriver();   //   Also have a valid ChromeDriver here
//			//System.out.println("Driver established for: " + driver.getClass());
//			//driver.manage().timeouts().wait(Framework.waitMethods.w100);
//		}
//	}
//
//
//	//Cert test in the event this is starting page for tests
//	@Test(priority = 1) //MUST REMAIN #1 ( or zero)
//	private void testForCertPage() /*throws InterruptedException */ {
//	    try {
//	    	//waitMethods.implicitWait(waitMethods.w300);
//	    	waitMethods.waiter(waitMethods.w300);
//	    	WebElement ele = driver.findElement(By.id("details-button"));  //.click();
//	    	highlightElement.highLightElement(driver, ele);
//	    	ele.click();
//
//	    	waitMethods.waiter(waitMethods.w300);
//
//	        WebElement ele2 = driver.findElement(By.partialLinkText("Proceed to localhost"));
//	        highlightElement.highLightElement(driver, ele2);
//	    	ele2.click();
//	        System.out.println("Certificate not found, proceeding to unsecure site");
//	    } catch (NoSuchElementException e) {
//	        System.out.println("Certificate present, proceeding ");
//	    }
//	}
//
//// Forms Workflow
//
//
//		@Test(priority = 125) //
//		private void Testing() {			//
//			waitMethods.waiter(waitMethods.w250);
//			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'AUT')]"));
//	    	highlightElement.highLightElement(driver, ele);
//	   		ele.click();
//			waitMethods.waiter(waitMethods.w250);
//	    	System.out.println("Opening existing form = AUT");
//		}
//
//
//		@Test(priority = 130) //
//		private void selectEditFieldIcon() {
//			waitMethods.waiter(waitMethods.w250);
//			WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Test Q1')]"));
//	    	highlightElement.highLightElement(driver, ele);
//	   		ele.click();
//			waitMethods.waiter(waitMethods.w250);
//	    	System.out.println("Test Question: Edit Field Icon");
//		}
//
//
//
//		@Test(priority = 135) //						//
//		private void selectAdvancedOptions() {
//			waitMethods.waiter(waitMethods.w250);
//			WebElement ele = driver.findElement(By.id("button_advanced"));
//	    	highlightElement.highLightElement(driver, ele);
//	   		ele.click();
//			waitMethods.waiter(waitMethods.w250);
//	    	System.out.println("Select Advanced Options");
//		}
//
//
//		@Test(priority = 137) //						//
//		private void insertIntoFirstTextarea() {
//			waitMethods.waiter(waitMethods.w250);
//			WebElement ele = driver.findElement(By.id("html"));
//	    	highlightElement.highLightElement(driver, ele);
//	   		ele.click();
//			waitMethods.waiter(waitMethods.w250);
//	    	System.out.println("insert into textarea");
//		}
//
//
//
////		@Test(priority = 140) //						//
////		private void scrollDown() {
////			waitMethods.waiter(waitMethods.w500);
////			WebElement ele = driver.findElement(By.id("btn_codeSave_htmlPrint"));
////	    	highlightElement.highLightElement(driver, ele);
////	   		//ele.click();
////			waitMethods.waiter(waitMethods.w500);
////	    	System.out.println("Scroll down");
////		}
//
//
//
//
//		@Test(priority = 150)
//		private void scroll() {
//			//Perform Scroll down			===> write class to pass js   Update: javascriptExecutor.java
//			JavascriptExecutor js = (JavascriptExecutor) driver;		//THIS WORKS
//			js.executeScript("window.scrollBy(0,800)");		//down 800 pixels
//		}
//
//
//
//		//Also try:  https://stackoverflow.com/questions/8378678/how-can-i-set-the-value-of-a-codemirror-editor-using-javascript
//
//
//							  //    XPath I believe is where to input text, but it is hidden by the div it's in.
//		@Test(priority = 190) //	/html/body/div[3]/div[2]/form/div/main/div/fieldset/div[1]/div[1]/textarea
//		private void inputHTMLEditDataTest() {
//
//
//			//WebElement ele = driver.findElement(By.xpath("/html/body/article/form/div/div[1]/textarea"));
//			//WebElement ele = driver.findElement(By.xpath("/html/body/article/form/div"));
//			//WebElement ele = driver.findElement(By.cssSelector("#advanced > div:nth-child(7) > div:nth-child(1) > textarea"));
//			// textarea next to 'save code' button			//WebElement ele = driver.findElement(By.id("html"));
//			//WebElement ele = driver.findElement(By.xpath("//*[@id='advanced']/div[1]/div[1]/textarea"));
//			WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div/fieldset/div[1]/div[6]/div[1]/div/div/div/div[1]/pre/span"));
//			//WebElement ele = driver.findElement(By.xpath(""));
//
//			//WebElement ele = driver.findElement(By.id("code"));
//			//highlightElement.highLightElement(driver, ele);
//			//ele.sendKeys("abcdefg");
//
//			/*So instead of writing just "editor", I put
//			"editor=CodeMirror.fromTextArea(document.getElementById(\"reasonReferralNeeded\"),{lineWrapping:true})"
//			*/
//
//
//
//			String js_call = "document.evaluate('/html/body/div[3]/div[2]/form/div/main/div/fieldset/div[1]/div[1]/textarea', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.innerHTML;";
//			//String js_call = "window.editor.setValue(\"Hello World\"); ";
//			JavascriptExecutor js = (JavascriptExecutor) driver;
//			js.executeScript(js_call);
//
//			System.out.println("Input DEMO Data");
//		}
//
//
//
//
///////////////////////   DEMO SITE   \\\\\\\\\\\\\\\\
//
//
//		@Test(priority = 197) //		THIS WORKS!!! (or did)  Gets xpath for textarea
//		private void demoEditData() {
//
//			//RAW HTML:
//
//
//			//Demo Site								//
//			driver.get("http://codemirror.net/demo/theme.html");
//			//WebElement ele = driver.findElement(By.xpath("/html/body/article/form/div/div[1]/textarea"));
//			//WebElement ele = driver.findElement(By.xpath("/html/body/article/form/div/div[1]/textarea"));
//			//WebElement ele = driver.findElement(By.xpath("/html/body/article/form/textarea"));
//			//WebElement ele = driver.findElement(By.id("code"));
////			highlightElement.highLightElement(driver, ele);
////			ele.sendKeys("HTML Test Data");
//			String jsScript = "window.editor.setValue(\"Hello World\"); ";
//			JavascriptExecutor js = (JavascriptExecutor) driver;
//			js.executeScript(jsScript);
//
//			System.out.println("Input DEMO Data");
//		}
//
//
//
//////////////////   DDL TEMPLATE \\\\\\\\\\\\\\\\\\
////	@Test(priority = 199) //
////	public void DDL_Template() {
////		//waitMethods.implicitWait(waitMethods.w300);
////		waitMethods.waiter(waitMethods.w200);			//The below opens the DDL
////		WebElement ele = driver.findElement(By.xpath(""));
////		highlightElement.highLightElement(driver, ele);
////		ele.click();
////		waitMethods.waiter(waitMethods.w250);
////		WebElement ele2 = driver.findElement(By.xpath(""));
////		highlightElement.highLightElement(driver, ele2);
////		ele2.click();
////		waitMethods.waiter(waitMethods.w200);
////		System.out.println("");
////	}
////
////
////
////	@Test(priority = 196) //
////	private void searchByPosition() {
////		waitMethods.waiter(waitMethods.w250);
////		WebElement ele = driver.findElement(By.id("search"));
////    	//highlightElement.highLightElement(driver, ele);
////
////    	String name = "Accountability Officer";
////
////    	for(int i = 0; i < name.length(); i++) {
////    		char c = name.charAt(i);
////    		String s = new StringBuilder().append(c).toString();
////    		ele.sendKeys(s);
////    		waitMethods.waiter(waitMethods.w50);
////    	}
////
////    	driver.findElement(By.id("search")).clear();
////    	System.out.println("Search By Position");
////	}
//
//
//
//
//	public String getDate() {
//	      String pattern = "MM/dd HH:mm";
//	      SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
//
//	      String date = simpleDateFormat.format(new Date());
//	      System.out.println(date);
//
//	      return date;
//	}
//
//
//}  //class
//