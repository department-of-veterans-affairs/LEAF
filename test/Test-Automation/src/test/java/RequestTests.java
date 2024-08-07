package test.java;

import main.java.factory.PageinstancesFactory;
import main.java.pages.HomePageActions;
import main.java.pages.SiteSettingsPageActions;
import main.java.pages.adminPage_Actions;
import main.java.util.CommonUtility;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

public class RequestTests extends BaseTest{
    adminPage_Actions adminPageActions;

    HomePageActions homePageActions;
    String requestTitle;
    @BeforeClass
    public void TestInitialization(){
        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class);
        adminPageActions.clickHome();
        homePageActions = PageinstancesFactory.getInstance(HomePageActions.class);
        requestTitle = "Tes_Group_" + CommonUtility.generate_AlphaNumeric_RandomString(3);
    }


    @Test
    public void TC001_validateQuestionAnsweserd() throws InterruptedException {
       boolean isQuestionAnswered = homePageActions.verifyQuestionAnswered(requestTitle);
       Assert.assertTrue(isQuestionAnswered);
    }

    @Test
    public void TC002_validateLeafRequestCreated() throws InterruptedException {
        boolean isRequestCreated = homePageActions.verifyRequestCreated(requestTitle);
        Assert.assertTrue(isRequestCreated);
    }


}
