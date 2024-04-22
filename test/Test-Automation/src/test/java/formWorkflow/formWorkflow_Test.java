package test.java.formWorkflow;

import main.java.Base.SetUpTest;
import test.java.PageObjectClass.FormWorkflow_PageObjects;
import org.testng.Assert;
import org.testng.annotations.*;


public class formWorkflow_Test extends SetUpTest {

    @Test
    public void CreateAndDeleteForm() {
        FormWorkflow_PageObjects Form = new FormWorkflow_PageObjects(driver);
        Form.createForm();
        Form.clickOnDelete();
        Form.clickOnDeleteSave();
        Assert.assertEquals("Create Form", Form.VerifyDelete());
    }

    @Test(alwaysRun = true)
    public void EditProperties() {
        FormWorkflow_PageObjects Form = new FormWorkflow_PageObjects(driver);
        Form.createForm();
        Form.clickOnEditProperties();
        Form.EnterName("Edited Form");
        Form.clickOnWorkflowID();
        Form.selectWorkFlow();
        Form.ClickonNeedToKnow();
        Form.selectNeedToKnow();
        Form.clickAvailability();
        Form.selectAvailability();
        Form.clickOnEditSaveButton();
        Assert.assertEquals("Delete this form", Form.VerifyName());
        Form.deleteForm();

    }

    @Test(alwaysRun = true)
    public void editCollaborators() {
        FormWorkflow_PageObjects Form = new FormWorkflow_PageObjects(driver);
        Form.createForm();
        Form.clickOnEditCollaborators();
        Form.clickOnAddgroup();
        Form.selectAddCollaborators();
        Form.saveCollaborators();
        Form.closeCollabators();
        Assert.assertEquals("Delete this form", Form.VerifyName());
        Form.deleteForm();

    }

    @Test
    public void addSectionHeadings() {
        FormWorkflow_PageObjects Form = new FormWorkflow_PageObjects(driver);
        Form.createForm();
        Form.clickAddSectionHeadings();
        Form.EnterSectionName("Section Name");
        Form.EnterSectionDescription("Section Description");
        Form.selectInputFormatType("Single line text");
        Form.clickOnChange();
        Assert.assertEquals("Delete this form",Form.VerifyName());

    }

}