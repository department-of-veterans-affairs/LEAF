package main.java.pages;

import org.apache.log4j.Logger;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.testng.Assert;
import test.java.BaseTest;

import java.util.List;

public class WorkflowEditorPageActions extends BasePage {

    private static final Logger log = Logger.getLogger(WorkflowEditorPageActions.class);

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

    @FindBy(id="workflows")
    WebElement workflowSelect;

    @FindBy(xpath="//a[@class='chosen-single']//span[1]")
    WebElement workflowDropdownName;

    @FindBy(id="confirm_xhr")
    WebElement deleteConfirmMsg;

    @FindBy(xpath="//button[@id='confirm_button_save']")
    WebElement deleteConfirmBtn;

    @FindBy(xpath = "//ul[@id='actionType-chosen-search-results']")
    List<WebElement> actionTypeList;

    @FindBy(xpath="//ul[@class='chosen-results']//li")
    List<WebElement> workFlowList;

    @FindBy(id = "workflow_rename")
    WebElement workflowRenameInput;

    @FindBy(xpath = "//div[id='actionType_chosen']")
    WebElement actionType;

    @FindBy(xpath = "//div[contains(text(),'Approval')]")
    WebElement approveButton;

    @FindBy(id = "button_cancelchange")
    WebElement cancelRenameButton;

    @FindBy(id = "actionText")
    WebElement actionInput;

    @FindBy(xpath = "//button[@aria-label='workflow step: Service Chief']")
    WebElement newStepAdded;

    @FindBy(xpath = "//div[@class='workflowStepInfo']")
    WebElement workflowStepInfo;

    @FindBy(xpath = "//input[@id='toggleManageActions']")
    WebElement stepActionsChkBx;

    @FindBy(xpath = "//select[@id = 'create_route']")
    WebElement createRouteSelect;

    @FindBy(id = "actionTextPasttense")
    WebElement actionTextPasttenseInput;

    @FindBy(xpath = "//button[contains(text(),'Requestor')]")
    WebElement requesterBtn;

    @FindBy(xpath = "//button[contains(text(),'End')]")
    WebElement endBtn;

    @FindBy(xpath = "//button[contains(text(),'Approval')]")
    WebElement approvalBtn;

    @FindBy(linkText = "Home")
    WebElement homeLink;

    @FindBy(id = "stepTitle")
    WebElement stepTitleInput;
    public void createWorkflow(String workflowName){
        setExplicitWaitForElementToBeVisible(newWorkflowBtn, 10);
        newWorkflowBtn.click();
        setExplicitWaitForElementToBeClickable(workflowTitle, 10);
        workflowTitle.sendKeys(workflowName);
        saveBtn.click();
        setExplicitWaitForElementToBeClickable(workflowDropdown, 10);

        Boolean isWorkflowCreated = workflowDropdownName.getText().contains(workflowName);
        Assert.assertEquals(isWorkflowCreated, true);
    }

    public void renameWorkflow(String workflowName) throws InterruptedException {
        setExplicitWaitForElementToBeVisible(newWorkflowBtn, 10);
        renameWorkflowBtn.click();

        setExplicitWaitForElementToBeClickable(saveBtn, 30);
        clickElement(workflowRenameInput);
        workflowRenameInput.clear();
        workflowRenameInput.sendKeys(workflowName);
        saveBtn.click();
        Thread.sleep(10000);
        setExplicitWaitForElementToBeClickable(workflowDropdownName, 30);
        Boolean isWorkflowCreated = workflowDropdownName.getText().contains(workflowName);
        Assert.assertEquals(isWorkflowCreated, true);
    }

    public void copyWorkflow(String workflowName) throws InterruptedException {
        setExplicitWaitForElementToBeVisible(newWorkflowBtn, 10);
        duplicateWorkflowBtn.click();

        setExplicitWaitForElementToBeClickable(saveBtn, 30);
        clickElement(workflowTitle);
        workflowTitle.clear();
        workflowTitle.sendKeys(workflowName);
        saveBtn.click();
        Thread.sleep(10000);
        setExplicitWaitForElementToBeClickable(workflowDropdown, 10);
        Boolean isWorkflowCreated = workflowDropdownName.getText().contains(workflowName);
        Assert.assertEquals(isWorkflowCreated, true);
    }

    public void deleteWorkflow(String WorkflowName){
          if (deleteWorkflowBtn != null){
              scrollToView(deleteWorkflowBtn);
          }

        setExplicitWaitForElementToBeVisible(deleteWorkflowBtn, 10);
        deleteWorkflowBtn.click();
        setExplicitWaitForElementToBeVisible(deleteConfirmMsg, 10);
        Assert.assertEquals(deleteConfirmMsg.getText(), "Are you sure you want to delete this workflow?");
        deleteConfirmBtn.click();
        setExplicitWaitForElementToBeVisible(deleteWorkflowBtn, 20);
        driver.navigate().refresh();
        setExplicitWaitForElementToBeVisible(workflowDropdown, 20);
        scrollToView(workflowDropdown);
        setExplicitWaitForElementToBeVisible(workflowDropdown, 20);
        workflowDropdown.click();

        for (WebElement workFlow :workFlowList)
        {
            String actWorkFlowName = workFlow.getText();
            Assert.assertFalse(actWorkFlowName.equals(WorkflowName));
        }
        workflowDropdown.click();
        setExplicitWaitForElementToBeClickable(newWorkflowBtn,30);
    }

    public void addStep(){
        newStepBtn.click();
        setExplicitWaitForElementToBeClickable(stepTitleInput,30);
        stepTitleInput.sendKeys("Approval");
        saveBtn.click();
        setExplicitWaitForElementToBeClickable(newWorkflowBtn,40);
        scrollToView(homeLink);
    }

    public void cleanUp(String WorkflowName){

        for (WebElement workFlow :workFlowList){
            if (workFlow.getText().contains(WorkflowName))
                    workFlow.click();
        }
        if (deleteWorkflowBtn != null){
                    scrollToView(deleteWorkflowBtn);
                }

                setExplicitWaitForElementToBeVisible(deleteWorkflowBtn, 10);
                deleteWorkflowBtn.click();
                setExplicitWaitForElementToBeVisible(deleteConfirmMsg, 10);
                Assert.assertEquals(deleteConfirmMsg.getText(), "Are you sure you want to delete this workflow?");
                deleteConfirmBtn.click();
                setExplicitWaitForElementToBeVisible(deleteWorkflowBtn, 20);
                driver.navigate().refresh();
                setExplicitWaitForElementToBeVisible(workflowDropdown, 20);
                scrollToView(workflowDropdown);
                setExplicitWaitForElementToBeVisible(workflowDropdown, 20);
 //               workflowDropdown.click();
            }

    public  void addApprovedWorkflow(String workflowName) throws InterruptedException {
            createWorkflow(workflowName);
            addStep();
        Thread.sleep(10000);
            approvalBtn.click();
            Thread.sleep(10000);
            stepActionsChkBx.click();
            createRouteSelect.click();

                selectByPartialText(createRouteSelect,"Approval");
                approvalBtn.click();
            }

        }
