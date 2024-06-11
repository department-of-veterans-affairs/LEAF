package test.java.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.testng.Assert;

public class WorkflowEditorPageActions extends BasePage {

    public WorkflowEditorPageActions(WebDriver driver){
        super(driver);
    }

   @FindBy(id="btn_createStep")
    WebElement newStepBtn;

    @FindBy(xpath = "//span[text()='Choose a step to edit']")
    WebElement chooseStepToEdit;

    @FindBy(id="btn_newWorkflow")
    WebElement newWorkflowBtn;

    @FindBy(id="btn_renameWorkflow")
    WebElement renameWorkflowBtn;

    @FindBy(id="btn_duplicateWorkflow")
    WebElement duplicateWorkflowBtn;

    @FindBy(id="btn_listActionTypes")
    WebElement editActionBtn;

    @FindBy(id="btn_listEvents")
    WebElement editEventBtn;

    @FindBy(id="btn_deleteWorkflow")
    WebElement deleteWorkflowBtn;

    @FindBy(id="description")
    WebElement workflowTitle;

    @FindBy(id="button_save")
    WebElement saveBtn;

    @FindBy(xpath="//div[@class='chosen-search']//following::input[2]")
    WebElement workflowsearchInput;

    @FindBy(xpath="//ul[@class='chosen-results']//following::li[2]")
    WebElement workflowsearchResult;

    @FindBy(id="workflows_chosen")
    WebElement workflowDropdown;

    @FindBy(id="confirm_xhr")
    WebElement deleteConfirmMsg;

    @FindBy(xpath="//button[@id='confirm_button_save']")
    WebElement deleteConfirmBtn;

    public void createWorkflow(String workflowName){
        setExplicitWaitForElementToBeVisible(newWorkflowBtn, 10);
        newWorkflowBtn.click();
        setExplicitWaitForElementToBeClickable(workflowTitle, 10);
        workflowTitle.sendKeys(workflowName);
        saveBtn.click();
        setExplicitWaitForElementToBeClickable(workflowDropdown, 10);
        workflowDropdown.click();
        setExplicitWaitForElementToBeVisible(workflowsearchInput, 10);
        workflowsearchInput.sendKeys(workflowName);
        setExplicitWaitForElementToBeVisible(workflowsearchResult, 10);
        Boolean isWorkflowCreated = workflowsearchResult.getText().contains(workflowName);
        Assert.assertEquals(isWorkflowCreated, true);
    }

    public void deleteWorkflow(String WorkflowName){
        setExplicitWaitForElementToBeVisible(workflowDropdown, 10);
        workflowDropdown.click();
        setExplicitWaitForElementToBeVisible(workflowsearchInput, 10);
        workflowsearchInput.sendKeys(WorkflowName);
        setExplicitWaitForElementToBeVisible(workflowsearchResult, 10);
        workflowsearchResult.click();
        setExplicitWaitForElementToBeVisible(deleteWorkflowBtn, 10);
        deleteWorkflowBtn.click();
        setExplicitWaitForElementToBeVisible(deleteConfirmMsg, 10);
        Assert.assertEquals(deleteConfirmMsg.getText(), "Are you sure you want to delete this workflow?");
        deleteConfirmBtn.click();
        setExplicitWaitForElementToBeVisible(workflowDropdown, 20);
        workflowDropdown.click();
        setExplicitWaitForElementToBeVisible(workflowsearchInput, 10);
        workflowsearchInput.sendKeys(WorkflowName);
        setExplicitWaitForElementToBeVisible(workflowsearchResult, 10);
        Assert.assertEquals(workflowsearchResult.getText(), "No results match "+WorkflowName);
    }



}

