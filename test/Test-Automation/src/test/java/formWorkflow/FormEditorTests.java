package test.java.formWorkflow;

import main.Base.BasePage;
import main.pageActions.FormEditorPageActions;
import main.pageActions.adminPage_Actions;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.ITestContext;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

public class FormEditorTests extends BasePage {

    private static final Logger log = LogManager.getLogger(FormEditorTests.class);

    adminPage_Actions adminPageActions;
    FormEditorPageActions formEditorPageActions;


    @BeforeTest()
    public void TestInitialization(ITestContext context) {
        System.out.println("FormEditorTests");
        extentTest = extentReports.createTest(context.getName());
        adminPageActions = new adminPage_Actions();
        adminPageActions.clickFormEditor();
        extentTest.info("Form Editor Page is opened successfully");
        formEditorPageActions = new FormEditorPageActions();
    }

    @Test()
    public void validateCreateForm() {
        formEditorPageActions.createForm("TestForm-1", "TestFormDescription-1");
        extentTest.info("Verify that the form is created successfully");
    }

    @Test(dependsOnMethods = {"validateCreateForm"})
    public void validateStapleForm() {
        formEditorPageActions.stapleForm("AS - Vacation Reservations");
        extentTest.info("Verify that the form is stapled successfully");
    }

    @Test()
    public void validateDeleteForm() {
        formEditorPageActions.deleteForm("TestForm-1");
        extentTest.info("Verify that the form is deleted successfully");
    }


}
