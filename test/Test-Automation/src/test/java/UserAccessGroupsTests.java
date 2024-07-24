package test.java;

import main.java.factory.PageinstancesFactory;
import main.java.pages.UserAccessGroupsPageActions;
import main.java.pages.adminPage_Actions;
import main.java.util.CommonUtility;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;


public class UserAccessGroupsTests extends BaseTest {
    private static final Logger log = LogManager.getLogger(FormEditorTests.class);
    adminPage_Actions adminPageActions;
    UserAccessGroupsPageActions userAccessGroupsPageActions;
    String groupName;

    @BeforeClass
    public void TestInitialization(){
        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class);
        adminPageActions.clickUserAccessGroups();
        userAccessGroupsPageActions = PageinstancesFactory.getInstance(UserAccessGroupsPageActions.class);
        groupName = "Tes_Group_" +CommonUtility.generate_AlphaNumeric_RandomString(3);

    }

    @Test()
    public void TC001_validateGroupCreated() throws InterruptedException {
    userAccessGroupsPageActions.createGroup(groupName);
    Assert.assertTrue(userAccessGroupsPageActions.verifyGroupCreate(groupName));
    }



    @Test
    public void TC002_validateViewHistory(){
    String actGroupName = userAccessGroupsPageActions.verifyViewHistory(groupName);
    if(actGroupName.contains(groupName)) {
        Assert.assertTrue (true);
    }
    else
        Assert.assertTrue(false, "\"On view History Group name should be same\" ");
    }

    @Test()
    public void TC003_validateSearchEmployee() {
        Assert.assertTrue(userAccessGroupsPageActions.addEmployee("Tester,Tester",groupName));

    }

    @Test()
    public void TC004_validateEmployeeResultTable() {
        Assert.assertTrue(userAccessGroupsPageActions.selectEmployee("Tester, Tester",groupName));

    }

    @Test()
    public void TC005_validateEmployeeDetails() {
        Assert.assertTrue(userAccessGroupsPageActions.verifySelectedEmployee("Tester, Tester",groupName));

    }

    @Test()
    public void TC006_validateEmployeeAdded() throws InterruptedException {
        Assert.assertTrue(userAccessGroupsPageActions.verifyEmployeeAdded("Tester Tester",groupName));

    }

    @Test
    public void TC007_validateGroupDeleted() throws InterruptedException {
        userAccessGroupsPageActions.deleteGroup(groupName);
         Assert.assertFalse(userAccessGroupsPageActions.verifyGroupDeleted(groupName));
    }


    @Test
    public void TC008_validateNoGroupsFoundMessage() {
        Assert.assertTrue(userAccessGroupsPageActions.messageNotFound());

    }

}
