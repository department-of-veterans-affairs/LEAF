//package main.java.pageActions;
//
//import test.java.BaseMethods.BaseClass;
//import test.java.Framework.highlightElement;
//import org.openqa.selenium.By;
//import org.openqa.selenium.WebDriver;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.support.FindBy;
//import org.openqa.selenium.support.PageFactory;
//import org.openqa.selenium.support.ui.Select;
//import org.testng.Assert;
//
//
//public class FormWorkflow_PageObjects extends  BaseClass {
//
//    private WebDriver driver;
//
//    public FormWorkflow_PageObjects(WebDriver driver){
//        this.driver=driver;
//        PageFactory.initElements(driver,this);
//    }
//
//    @FindBy(xpath="//span[contains(.,'Form Editor')]")
//    WebElement form;
//
//    @FindBy(id="createFormButton")
//    WebElement CreateForm;
//
//    @FindBy(id="name")
//    WebElement EnterName;
//
//    @FindBy(id="description")
//    WebElement EnterDescription;
//
//    @FindBy(id="button_save")
//    WebElement clickSave;
//
//    @FindBy(xpath = "//*[contains(text(),' Delete this form')]")
//    WebElement verifyText;
//
//    @FindBy(xpath = "//*[contains(text(),' Delete this form')]")
//    WebElement deleteForm;
//
//    @FindBy(id = "confirm_button_save")
//    WebElement clickOnSave;
//
//    @FindBy(xpath ="//*[@id=\"editFormData\"]")
//    WebElement EditProperties;
//
//    @FindBy(id="workflowID")
//    WebElement workFlowID;
//
//    @FindBy(xpath = "/html/body/div[5]/div[1]/button")
//    WebElement close;
//
//    @FindBy(id="button_save")
//    WebElement saveButton;
//
//    @FindBy(id="needToKnow")
//    WebElement needToKnow;
//
//    @FindBy(id="visible")
//    WebElement visible;
//
//    @FindBy(id = "editFormPermissions")
//    WebElement editCollaborators;
//
//    @FindBy(xpath = "//*[text()='Add Group']")
//    WebElement addGroup;
//
//    @FindBy(id="groupID")
//    WebElement groupID;
//
//    @FindBy(id = "button_save")
//    WebElement saveCollaborators;
//
//    @FindBy(css = "#formEditor_form > div > div.buttonNorm")
//    WebElement sectionHeadings;
//
//    @FindBy(id = "name")
//    WebElement sectionName;
//
//    @FindBy(id="description")
//    WebElement sectiondescription;
//
//    @FindBy(id = "indicatorType")
//    WebElement inputFormatType;
//
//    @FindBy(xpath = "/html/body/div[5]/div[1]/button")
//    WebElement closeCollabators;
//
//    @FindBy(id = "button_cancelchange")
//    WebElement Cancel_Change;
//
//    @FindBy(xpath = "//*[contains(text(),'Test Q1 Single line text')]")
//    WebElement EditFieldIcon;
//
//
//    public void clickOnFiledIcon(){
//        highlightElement.highLightElement(driver,EditFieldIcon);
//        waitForElementToBeVisible(EditFieldIcon);
//        clickElement(EditFieldIcon);
//    }
//
//
//
//
//    public void clickOnChange(){
//        highlightElement.highLightElement(driver,Cancel_Change);
//        waitForElementToBeVisible(Cancel_Change);
//        clickElement(Cancel_Change);
//    }
//
//
//    public void selectInputFormatType(String Value){
//        highLightElement(driver,inputFormatType);
//        clickElement(inputFormatType);
//       // SelectElement(Value,inputFormatType);
//        WebElement ele = driver.findElement(By.id("indicatorType"));
//        Select select = new Select(driver.findElement(By.id("indicatorType")));
//        highlightElement.highLightElement(driver, ele);
//        select.selectByValue("text");
//        waitMethods.waiter(waitMethods.w300);
//        WebElement ele2 = driver.findElement(By.id("indicatorType"));
//        ele2.click();
//    }
//
//    public void closeCollabators(){
//        waitForElementToBeVisible(closeCollabators);
//        highLightElement(driver,closeCollabators);
//        clickElement(closeCollabators);
//    }
//
//    public void EnterSectionDescription(String value){
//        highLightElement(driver,sectiondescription);
//        Sendkeys(value,sectiondescription);
//    }
//
//    public void EnterSectionName(String Value){
//        highLightElement(driver,sectionName);
//        Sendkeys(Value,sectionName);
//    }
//
//    public void clickAddSectionHeadings(){
//        waitForElementToBeVisible(sectionHeadings);
//        highLightElement(driver,sectionHeadings);
//        clickElement(sectionHeadings);
//    }
//
//    public void saveCollaborators(){
//        waitForElementToBeVisible(saveCollaborators);
//        highLightElement(driver,saveCollaborators);
//        clickElement(saveCollaborators);
//    }
//
//    public void selectAddCollaborators(){
//        waitForElementToBeVisible(groupID);
//        highLightElement(driver,groupID);
//       // highLightElement(driver, visible);
//        WebElement ele = driver.findElement(By.id("groupID"));
//        Select select = new Select(driver.findElement(By.id("groupID")));
//        highlightElement.highLightElement(driver, ele);
//        select.selectByValue("53");
//        waitMethods.waiter(waitMethods.w300);
//        WebElement ele2 = driver.findElement(By.id("groupID"));
//        ele2.click();
//        //SelectElement("54",groupID);
//    }
//    public void clickOnAddgroup(){
//        waitForElementToBeVisible(addGroup);
//        highLightElement(driver,addGroup);
//        clickElement(addGroup);
//    }
//    public void clickOnEditCollaborators(){
//        highLightElement(driver,editCollaborators);
//        clickElement(editCollaborators);
//    }
//
//    public void clickOnEditSaveButton(){
//        highLightElement(driver, saveButton);
//        clickElement(saveButton);
//    }
//
//    public void selectAvailability(){
//        highLightElement(driver, visible);
//        WebElement ele = driver.findElement(By.id("visible"));
//        Select select = new Select(driver.findElement(By.id("visible")));
//        highlightElement.highLightElement(driver, ele);
//        select.selectByValue("1");
//        waitMethods.waiter(waitMethods.w300);
//        WebElement ele2 = driver.findElement(By.id("visible"));
//        ele2.click();
//        //SelectElement("1",visible);
//    }
//
//    public void clickAvailability(){
//        highLightElement(driver,visible);
//        clickElement(visible);
//    }
//
//    public void selectNeedToKnow(){
//        WebElement ele = driver.findElement(By.id("needToKnow"));
//        Select select = new Select(driver.findElement(By.id("needToKnow")));
//        highlightElement.highLightElement(driver, ele);
//        select.selectByValue("0");
//        waitMethods.waiter(waitMethods.w300);
//        WebElement ele2 = driver.findElement(By.id("needToKnow"));
//        ele2.click();
//    }
//
//    public void ClickonNeedToKnow(){
//        highLightElement(driver, needToKnow);
//        clickElement(needToKnow);
//    }
//
//
//    public void selectWorkFlow(){
//        WebElement ele = driver.findElement(By.id("workflowID"));
//        Select select = new Select(driver.findElement(By.id("workflowID")));
//        highlightElement.highLightElement(driver, ele);
//        select.selectByValue("76");
//        waitMethods.waiter(waitMethods.w300);
//        WebElement ele2 = driver.findElement(By.id("workflowID"));
//        ele2.click();
//    }
//
//    public void clickOnWorkflowID(){
//        waitMethods.waiter(waitMethods.w300);			//The below opens the DDL
//        WebElement ele = driver.findElement(By.id("workflowID"));
//        highlightElement.highLightElement(driver, ele);
//        ele.click();
//    }
//
//    public void clickOnEditProperties(){
//       // waitMethods.waiter(waitMethods.w300);			//The below opens the DDL
//      //  WebElement ele = driver.findElement(By.xpath("//*[@id=\"editFormData\"]"));
//        highlightElement.highLightElement(driver, EditProperties);
//       // ele.click();
//        clickElement(EditProperties);
//    }
//
//
//    public void clickOnDeleteSave(){
//        highLightElement(driver, clickOnSave);
//        clickElement(clickOnSave);
//    }
//    public void clickOnDelete(){
//        highLightElement(driver,deleteForm);
//        waitForElementToBeVisible(deleteForm);
//        clickElement(deleteForm);
//    }
//
//    public void clickOnForm(){
//        highLightElement(driver, form);
//        clickElement(form);
//    }
//
//    public void clickOnCreateForm(){
//        highLightElement(driver, CreateForm);
//        clickElement(CreateForm);
//    }
//
//    public void EnterName(String value){
//        highLightElement(driver, EnterName);
//        Sendkeys(value,EnterName);
//    }
//
//    public void EnterDescription(){
//        highLightElement(driver, EnterDescription);
//        Sendkeys("Test Automation",EnterDescription);
//    }
//
//    public void clickOnSave(){
//        highLightElement(driver, clickSave);
//        clickElement(clickSave);
//    }
//
//    public String VerifyName(){
//        waitMethods.waiter(waitMethods.w300);
//        highLightElement(driver, verifyText);
//       return getText(verifyText);
//    }
//    public String VerifyDelete(){
//        waitMethods.waiter(waitMethods.w300);
//        highLightElement(driver, CreateForm);
//        return getText(CreateForm);
//    }
//    public void createForm(){
//        clickOnForm();
//        clickOnCreateForm();
//        EnterName("Form To be Deleted");
//        EnterDescription();
//        clickOnSave();
//        Assert.assertEquals("Delete this form",VerifyName());
//    }
//    public  void deleteForm() {
//        clickOnDelete();
//        clickOnDeleteSave();
//    }
//}
