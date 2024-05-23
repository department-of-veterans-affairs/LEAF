package test.java.formWorkflow;

import main.Base.BasePage;
import main.pageActions.WorkflowEditorPageActions;
import main.pageActions.adminPage_Actions;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.ITestContext;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

public class WorkflowEditorTests extends BasePage {

    private static final Logger log = LogManager.getLogger(WorkflowEditorTests.class);

    adminPage_Actions adminPageActions;
    WorkflowEditorPageActions workflowEditorPageActions ;

    public WorkflowEditorTests() {
        super();
    }

    @BeforeTest()
    public void WorkFlowTest(ITestContext context) {
        extentTest = extentReports.createTest(context.getName());
        adminPageActions = new adminPage_Actions();
        adminPageActions.clickWorkflowEditor();
        extentTest.info("WorkFlow Editor Page is opened successfully");
        workflowEditorPageActions = new WorkflowEditorPageActions();
        System.out.println("WorkflowEditorTests");
    }

    @Test
    public void validateCreateWorkflow() {
        workflowEditorPageActions.createWorkflow("TestWorkflow-2");
        extentTest.info("Verify that the workflow is created successfully");
    }

    @Test
    public void validateDeleteWorkflow() {
        workflowEditorPageActions.deleteWorkflow("TestWorkflow-2");
        extentTest.info("Verify that the workflow is deleted successfully");
    }

}
