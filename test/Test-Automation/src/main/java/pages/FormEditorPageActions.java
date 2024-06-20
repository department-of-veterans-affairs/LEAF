package main.java.pages;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.Select;
import org.testng.Assert;

public class FormEditorPageActions extends BasePage {

    private static final Logger log = LogManager.getLogger(FormEditorPageActions.class);

    @FindBy(id = "createFormButton")
    WebElement createForm;

    @FindBy(id = "name")
    WebElement formLabel;

    @FindBy(id = "description")
    WebElement formDescription;

    @FindBy(xpath ="//div[contains(text(),' Delete this form')]")
    WebElement deleteButton;

    @FindBy(id="confirm_saveBtnText")
    WebElement confirmDeleteButton;

    @FindBy(id ="button_save")
    WebElement saveButton;

    @FindBy(id ="confirm_button_cancelchange")
    WebElement selectCancel;

    @FindBy(xpath ="//*[text()=' Staple other form']")
    WebElement stapleForm;

    @FindBy(id="mergedForms")
    WebElement mergeForm;

    @FindBy(id="stapledCategoryID")
    WebElement formOptions;

    @FindBy(xpath="//span[@id='ui-id-3']//following::span[1]")
    WebElement dialogueCloseBtn;

    @FindBy(xpath="//button[contains(@id,'main_form_form')]//span[2]")
    WebElement Form;

    @FindBy(xpath="//button[text()=' + Add Section ']")
    WebElement AddSection;

    @FindBy(xpath="//textarea[@id=\"name\"]")
    WebElement sectionDescription;

    @FindBy(xpath="/html/body/div[1]/div/div/main/section/div[2]/div[2]/div[1]/ul/li/div/ul/li/div/div/div/div[2]")
    WebElement createdQuestionHeading;

    @FindBy(xpath="//div[contains(@id,'format_label')]")
    WebElement createdSectionHeading;

    @FindBy(xpath="//button[text()=' + Add Question to Section ']")
    WebElement AddQuestionToHeader;

    public FormEditorPageActions(WebDriver driver) {
      super(driver);
    }

    public void clickCreateForm(){
        clickElement(createForm);
    }

    public void enterFormName(String formName){
        enterText(formLabel,formName);
    }

    public void enterDescription(String description){
        enterText(formDescription,description);
    }

    public void clickSave(){
        clickElement(saveButton);
    }

    public Boolean validateForm(String fornName){
        setExplicitWaitForElementToBeVisible(Form,30 );
        Boolean formPresent = Form.getText().trim().contains(fornName);
        return formPresent;
    }

    public void clickAddSection(){
        clickElement(AddSection);
    }

    public void enterSectionHeading(String header){
        enterText(sectionDescription,header);
    }

    public Boolean checkSectionCreated(String section){
        setExplicitWaitForElementToBeVisible(createdSectionHeading,30 );
        Boolean sectionPresent = createdSectionHeading.getText().trim().contains(section);
        return sectionPresent;
    }

    public void clickAddQuestionToHeader(){
        clickElement(AddQuestionToHeader);
    }

    public void AddQuestion(String question){
        enterText(formLabel,question);
    }

    public Boolean validateCreatedQuestion(String question){
        setExplicitWaitForElementToBeVisible(createdQuestionHeading,30 );
        Boolean questionPresent = createdQuestionHeading.getText().trim().contains(question);
        return questionPresent;
    }
    public void openExistingForm(String FormName) {
        Boolean formOpened = null;
        WebElement form = driver.findElement(By.xpath("//div[@class='formPreviewTitle'][text()='"+FormName+"']"));
        if(checkFormExists(FormName) == true) {
            form.click();
            log.info("Opening " + FormName + " Existing Form");
            setExplicitWaitForElementToBeVisible(formLabel, 10);
            formOpened = formLabel.isDisplayed();
        }
            Assert.assertEquals(formOpened, true);
    }

    public Boolean checkFormExists(String FormName) {
        WebElement form = driver.findElement(By.xpath("//div[@class='formPreviewTitle'][text()='"+FormName+"']"));
        js.executeScript("arguments[0].scrollIntoView();", form);
        setExplicitWaitForElementToBeVisible(form,10 );
        Boolean formExists = form.isDisplayed();
        return formExists;
    }

    public void deleteForm(String FormName) {
        Boolean formDeleted = null;
        if(deleteButton.isDisplayed()){
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(confirmDeleteButton,20 );
            confirmDeleteButton.click();
           }
        formDeleted = checkFormExists(FormName);
        Assert.assertEquals(formDeleted, true);
        log.info("Validating Form Deleted Successfully");
    }

    public void cancelDeleteForm(String FormName) {
        Boolean formDeleted = null;
        if(deleteButton.isDisplayed()){
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(selectCancel,20 );
            selectCancel.click();
        }
        formDeleted = checkFormExists(FormName);
        Assert.assertEquals(formDeleted, true);
        log.info("Validating Form Not Deleted Successfully");
    }

    public void stapleForm(String StapleOtherFormName) {
        setExplicitWaitForElementToBeVisible(stapleForm,20);
        stapleForm.click();
        setExplicitWaitForElementToBeVisible(mergeForm, 10);
        mergeForm.click();
        setExplicitWaitForElementToBeVisible(formOptions, 10);
        Select dropDown = new Select(formOptions);
        dropDown.selectByVisibleText(StapleOtherFormName);
        saveButton.click();
        log.info("Stapling " + StapleOtherFormName);
        Boolean formStapled = mergeForm.getText().contains(StapleOtherFormName);
        dialogueCloseBtn.click();
        Assert.assertEquals(formStapled, true);
    }



}
