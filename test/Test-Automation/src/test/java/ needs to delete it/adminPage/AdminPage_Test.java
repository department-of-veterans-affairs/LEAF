package test.java.adminPage;

import test.java.PageObjectClass.AdminTestPageObjects;
import org.openqa.selenium.WebDriver;
import org.testng.Assert;
import org.testng.annotations.*;

public class AdminPage_Test {
    WebDriver driver;
    AdminTestPageObjects objAdminUtils = new AdminTestPageObjects(driver);

    @Test
    public void verifyAdminPageTitle(){
        String pageTitleActual = driver.getTitle();
        Assert.assertEquals(pageTitleActual, "Academy Demo Site(Test site) | Washington DC");
        System.out.println("Page Title Verified");
    }
}
