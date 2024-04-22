//package test.java.userAccessGroup;
//
//import org.testng.annotations.Test;
//import org.testng.annotations.BeforeMethod;
//import org.openqa.selenium.By;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.NoSuchElementException;
//import org.testng.annotations.BeforeClass;
//
//import java.util.Random;
//
//import test.java.Framework.setupFramework;
//import test.java.Framework.highlightElement;
//
//
//public class userAccessGroupsPart3ORIGINAL extends setupFramework {
//
//
//	public String sRand;
//	public String groupNum;
//	public String nexusURL = "https://localhost/LEAF_Nexus/?a=view_group&groupID=";
//	public String portalURL = "https://localhost/LEAF_Request_Portal/admin/?a=mod_groups";
//	public String id;
//
//
//
//
////	public void closeDownMainPortal() {
////
////		driver.quit();
////		System.out.println("setupFramework reached @AfterClass, driver.quit()");
////		//System.out.println("Method closeDownMainPortal() Disabled - browser remains open");
////	}
//
//
//
//
//	public String generateRand() {
//    	Random random = new Random();
//    	Integer rand = random.nextInt(999999);
//    	sRand = rand.toString();
//    	System.out.println("sRand = " + sRand);
//
//    	return sRand;
//	}
//
//
//	@BeforeMethod
//	@BeforeClass
//	public void setUp()  {			//Starts Here
//		if(driver!= null) {
//			driver=getDriver();   //   from test.java.Framework.setupFramework
//		}
//	}
//
//
//
//
//	//***************** Tests Begin *******************************************************
//
//	@Test(priority = 1) //MUST REMAIN #1 ( or zero) -test for certificate - if no, click Advanced -> Proceed
//	private void testForCertPage() /*throws InterruptedException */ {
//	    try {
//	    	waitMethods.implicitWait(waitMethods.w300);
//	    	//waitMethods.waiter(waitMethods.w300);
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
//
//
//
//	@Test(priority = 4040) //
//	private void openAccessGroup() {
//		waitMethods.waiter(waitMethods.w2k);
//		WebElement ele = driver.findElement(By.xpath("//span[contains(text(),'User Access Groups')]"));
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//	    System.out.println("Opened User Group");
//	}
//
//
//
//	@Test(priority = 4060) //						Pickup here: ERR HERE - Local
//	private void deleteUserGroup() {
//		waitMethods.waiter(waitMethods.w1k);
//		//WebElement ele = driver.findElement(By.xpath("//*[contains(text(),'Delete Group')]"));
//		WebElement ele = driver.findElement(By.xpath("/html/body/div[3]/div[2]/form/div/main/div[1]/div[2]/button"));
//	    highlightElement.highLightElement(driver, ele);
//	    ele.click();
//	    System.out.println("Delete User Group");
//	}
//
//
//	@Test(priority = 4080) //						ERR HERE - Local
//	private void confirmYes() {
//		waitMethods.waiter(waitMethods.w500);
//		WebElement ele = driver.findElement(By.id("confirm_button_save"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//        waitMethods.waiter(waitMethods.w100);
//        System.out.println("Confirmed action");
//	}
//
//
//
////	@Test(priority = 4100)
////	public void closeDownMainPortal2() {
////		closeDownMainPortal();
////	}
//
//
//
//
//
//
//
//}  //class userAccessGroupsPart3
