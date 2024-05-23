package main.pageActions;

import main.Base.BasePage;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;


public class FormWorkflow_PageObjects extends BasePage {


    public FormWorkflow_PageObjects(WebDriver driver){
        super();
        PageFactory.initElements(driver,this);
    }

    @FindBy(xpath="//span[contains(.,'Form Editor')]")
    WebElement form;

    @FindBy(id="createFormButton")
    WebElement CreateForm;

    @FindBy(id="name")
    WebElement EnterName;

    @FindBy(id="description")
    WebElement EnterDescription;

    @FindBy(id="button_save")
    WebElement clickSave;

    @FindBy(xpath = "//*[contains(text(),' Delete this form')]")
    WebElement verifyText;

    @FindBy(xpath = "//*[contains(text(),' Delete this form')]")
    WebElement deleteForm;

    @FindBy(id = "confirm_button_save")
    WebElement clickOnSave;

    @FindBy(xpath ="//*[@id=\"editFormData\"]")
    WebElement EditProperties;

    @FindBy(id="workflowID")
    WebElement workFlowID;

    @FindBy(xpath = "/html/body/div[5]/div[1]/button")
    WebElement close;

    @FindBy(id="button_save")
    WebElement saveButton;

    @FindBy(id="needToKnow")
    WebElement needToKnow;

    @FindBy(id="visible")
    WebElement visible;

    @FindBy(id = "editFormPermissions")
    WebElement editCollaborators;

    @FindBy(xpath = "//*[text()='Add Group']")
    WebElement addGroup;

    @FindBy(id="groupID")
    WebElement groupID;

    @FindBy(id = "button_save")
    WebElement saveCollaborators;

    @FindBy(css = "#formEditor_form > div > div.buttonNorm")
    WebElement sectionHeadings;

    @FindBy(id = "name")
    WebElement sectionName;

    @FindBy(id="description")
    WebElement sectiondescription;

    @FindBy(id = "indicatorType")
    WebElement inputFormatType;

    @FindBy(xpath = "/html/body/div[5]/div[1]/button")
    WebElement closeCollabators;

    @FindBy(id = "button_cancelchange")
    WebElement Cancel_Change;

    @FindBy(xpath = "//*[contains(text(),'Test Q1 Single line text')]")
    WebElement EditFieldIcon;


}
