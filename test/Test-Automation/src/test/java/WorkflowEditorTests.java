package test.java;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import main.java.factory.PageinstancesFactory;
import main.java.pages.WorkflowEditorPageActions;
import main.java.pages.adminPage_Actions;

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
    public void Test001_validateCreateWorkflow() {
        workflowEditorPageActions.createWorkflow("TestWorkflow-3");
    }

    @Test
    public void Test002_validateRenameWorkflow() throws InterruptedException {
        workflowEditorPageActions.renameWorkflow("Rename_TestWorkflow-3");
    }

    @Test
    public void Test003_validateCopyWorkflow() throws InterruptedException {
        workflowEditorPageActions.copyWorkflow("Copy_TestWorkflow-3");
    }


    @Test
    public void Test004_validateDeleteWorkflow() {
        workflowEditorPageActions.deleteWorkflow("Copy_TestWorkflow-3");
    }

    @AfterClass
    public void deleteAllWorkflows(){
        workflowEditorPageActions.cleanUp("Rename_TestWorkflow-3");
    }

}
