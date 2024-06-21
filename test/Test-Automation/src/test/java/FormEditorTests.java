package test.java;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import main.java.factory.PageinstancesFactory;
import main.java.pages.FormEditorPageActions;
import main.java.pages.adminPage_Actions;

public class FormEditorTests extends BaseTest {

    private static final Logger log = LogManager.getLogger(FormEditorTests.class);
    adminPage_Actions adminPageActions ;
    FormEditorPageActions formEditorPageActions;


    @BeforeClass
    public void TestInitialization() {
        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class);
        adminPageActions.clickFormEditor();
        formEditorPageActions = PageinstancesFactory.getInstance(FormEditorPageActions.class);
    }


    /*
    Validate a new form is created
     */
    @Test()
    public void TC001_validateCreateForm() {
        formEditorPageActions.clickCreateForm();
        formEditorPageActions.enterFormName("Test-1");
        formEditorPageActions.enterDescription("Test-Decription");
        formEditorPageActions.clickSave();
        Assert.assertTrue(formEditorPageActions.validateForm("Test-1"));
    }

    @Test
    public void TC002_validateSectionCreated(){
        formEditorPageActions.clickAddSection();
        formEditorPageActions.enterSectionHeading("Section Heading");
        formEditorPageActions.clickSave();
        Assert.assertTrue(formEditorPageActions.checkSectionCreated("Section Heading"));
    }

    @Test
    public void TC003_validateQuestionCreated(){
        formEditorPageActions.clickAddQuestionToHeader();
        formEditorPageActions.AddQuestion("Question");
        formEditorPageActions.clickSave();
        Assert.assertTrue(formEditorPageActions.validateCreatedQuestion("Question"));
    }
/*
    @Test(dependsOnMethods = {"validateCreateForm"})
    public void validateStapleForm() {
        formEditorPageActions.stapleForm("AS - Vacation Reservations");
    }

    @Test()
    public void validateDeleteForm() {
        formEditorPageActions.deleteForm("TestForm-1");
    }



 */
}
