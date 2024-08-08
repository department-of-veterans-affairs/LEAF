package test.java;

import main.java.factory.PageinstancesFactory;
import main.java.pages.SiteSettingsPageActions;
import main.java.pages.adminPage_Actions;
import main.java.util.CommonUtility;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import test.java.FormEditorTests;

public class SiteSettingTests extends BaseTest {
    private static final Logger log = LogManager.getLogger(FormEditorTests.class);
    adminPage_Actions adminPageActions;
    String leafTitle;
    String facilityName;
    SiteSettingsPageActions siteSettingsPageActions;

    @BeforeClass
    public void TestInitialization(){

        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class);
        adminPageActions.clickSiteSettings();
        siteSettingsPageActions = PageinstancesFactory.getInstance(SiteSettingsPageActions.class);
        leafTitle = "Leaf_Title__" + CommonUtility.generate_AlphaNumeric_RandomString(3);
        facilityName = "Facility_Name__" + CommonUtility.generate_AlphaNumeric_RandomString(3);
    }

    @Test
    public void TC001_validateLeafTitleCreated() {
        siteSettingsPageActions.enterLeafTitle(leafTitle);
        siteSettingsPageActions.enterFacilityName(facilityName);
        siteSettingsPageActions.clickSaveButton();

        Assert.assertTrue(siteSettingsPageActions.verifyLeafTitleAndFacility(facilityName));
    }



}
