package test.java.formWorkflow;

import main.Base.BasePage;
import main.pageActions.FormEditorPageActions;
import main.pageActions.adminPage_Actions;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.ITestContext;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

public class FormEditorTests extends BasePage {

    private static final Logger log = LogManager.getLogger(FormEditorTests.class);

    adminPage_Actions adminPageActions;
    FormEditorPageActions formEditorPageActions;

    public FormEditorTests() {
        super();
    }

    @BeforeTest(dependsOnMethods = {"setUp"})
    public void TestInitialization(ITestContext context) {
        extentTest = extentReports.createTest(context.getName());
        adminPageActions = new adminPage_Actions();
        adminPageActions.clickFormEditor();
        extentTest.info("Form Editor Page is opened successfully");
        formEditorPageActions = new FormEditorPageActions();
    }

    @Test(priority = 1)
    public void validateCreateForm() {
        formEditorPageActions.createForm("TestForm-2", "TestFormDescription-2");
        extentTest.info("Verify that the form is created successfully");
    }

    @Test(priority = 2)
    public void deleteForm() {
        formEditorPageActions.deleteForm("TestForm-2");
        extentTest.info("Verify that the form is deleted successfully");
    }

    @AfterTest
    public void tearDown() {
        extentTest.info("Form Editor Tests case execution is completed");
        log.info("Form Editor Tests case execution is completed");

    }

}
