package test.java.tests;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import test.java.factory.PageinstancesFactory;
import test.java.pages.WorkflowEditorPageActions;
import test.java.pages.adminPage_Actions;

public class WorkflowEditorTests extends BaseTest {

    private static final Logger log = LogManager.getLogger(WorkflowEditorTests.class);
    adminPage_Actions adminPageActions ;
    WorkflowEditorPageActions workflowEditorPageActions;

    @BeforeClass
    public void TestInitialization() {
        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class);
        adminPageActions.clickWorkflowEditor();
        workflowEditorPageActions =  PageinstancesFactory.getInstance(WorkflowEditorPageActions.class);
    }

    @Test
    public void validateCreateWorkflow() {
        workflowEditorPageActions.createWorkflow("TestWorkflow-2");
    }

    @Test
    public void validateDeleteWorkflow() {
        workflowEditorPageActions.deleteWorkflow("TestWorkflow-2");
    }

}
