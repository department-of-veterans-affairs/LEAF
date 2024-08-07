package main.java.pages;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.Select;
import org.testng.Assert;

import java.util.List;

/**
 * This class contains actions related to the Form Editor page.
 * It extends the BasePage class to utilize common page functionalities.
 */
public class FormEditorPageActions extends BasePage {

    private static final Logger log = LogManager.getLogger(FormEditorPageActions.class);
    private static final String formsPageURL = "https://host.docker.internal/LEAF_Request_Portal/admin/?a=form_vue#/";


    // Web elements on the Form Editor page
    @FindBy(id = "createFormButton")
    WebElement createForm;

    @FindBy(id = "name")
    WebElement formLabel;

    @FindBy(xpath = "//b[contains(text(),'Remove')]")
    WebElement removeButton;

    @FindBy(id = "supplemental_forms")
    List<WebElement> formTable;

    @FindBy(xpath = "//table[@id='supplemental_forms']//tr//th")
    WebElement formTableHeaderfcontains;

    @FindBy(id = "description")
    WebElement formDescription;

    @FindBy(xpath = "//button[@title='delete this form']")
    WebElement deleteButton;

    @FindBy(xpath = "//div[@id='mergedForms']//following::div")
    WebElement mergeFormMessage;

    @FindBy(xpath = "//button[@title='delete this form']")
    WebElement FOR;

    @FindBy(id = "confirm_saveBtnText")
    WebElement confirmDeleteButton;

    @FindBy(id = "button_save")
    WebElement saveButton;

    @FindBy(id = "confirm_button_cancelchange")
    WebElement selectCancel;

    @FindBy(xpath = "//button[contains(text(),'Staple other form ')]")
    WebElement stapleForm;

    @FindBy(id = "mergedForms")
    WebElement mergeForm;

    @FindBy(id = "stapledCategoryID")
    WebElement formOptions;

    @FindBy(id = "button_cancelchange")
    WebElement dialogueCloseBtn;

    @FindBy(id = "select-form-to-staple")
    WebElement selectFormDropDown;

    @FindBy(xpath = "//button[contains(@id,'main_form_form')]//span[2]")
    WebElement Form;

    @FindBy(linkText = "Form Browser")
    WebElement formLink;

    @FindBy(xpath = "//button[text()=' + Add Section ']")
    WebElement AddSection;

    @FindBy(xpath = "//textarea[@id=\"name\"]")
    WebElement sectionDescription;

    @FindBy(xpath = "/html/body/div[1]/div/div/main/section/div[2]/div[2]/div[1]/ul/li/div/ul/li/div/div/div/div[2]")
    WebElement createdQuestionHeading;

    @FindBy(xpath = "//div[contains(@id,'format_label')]")
    WebElement createdSectionHeading;

    @FindBy(xpath = "//button[text()=' + Add Question to Section ']")
    WebElement AddQuestionToHeader;

    @FindBy(xpath = "//table[@id='supplemental_forms']//tr")
    List<WebElement> row;


    @FindBy(xpath = "//div[contains(text(),'Test-Description')]//following-sibling::div")
    WebElement donotDeleteWarning;

    /**
     * Constructor for FormEditorPageActions.
     *
     * @param driver the WebDriver instance
     */
    public FormEditorPageActions(WebDriver driver) {
        super(driver);
    }

    public void clickCloseStaple() {
        setExplicitWaitForElementToBeVisible(dialogueCloseBtn,30);
        dialogueCloseBtn.click();
    }

    /**
     * Clicks the "Create Form" button.
     */
    public void clickCreateForm() {
        clickElement(createForm);
    }

    /**
     * Clicks the "Create Form" link.
     */
    public void clickCreateFormLink() {
        clickElement(formLink);
    }

    /**
     * Enters the form name.
     *
     * @param formName the name of the form
     */
    public void enterFormName(String formName) {
        enterText(formLabel, formName);
    }

    /**
     * Enters the form description.
     *
     * @param description the description of the form
     */
    public void enterDescription(String description) {
        enterText(formDescription, description);
    }

    /**
     * Clicks the "Save" button.
     */
    public void clickSave() {
        saveButton.click();;
    }

    /**
     * Validates if the form is present.
     *
     * @param formName the name of the form to validate
     * @return true if the form is present, false otherwise
     */
    public Boolean validateForm(String formName) {
        setExplicitWaitForElementToBeVisible(Form, 30);
        return Form.getText().trim().contains(formName);
    }

    /**
     * Clicks the "Add Section" button.
     */
    public void clickAddSection() {
        clickElement(AddSection);
    }

    /**
     * Enters the section heading.
     *
     * @param header the heading of the section
     */
    public void enterSectionHeading(String header) {
        enterText(sectionDescription, header);
    }

    /**
     * Checks if the section is created.
     *
     * @param section the section heading to check
     * @return true if the section is present, false otherwise
     */
    public Boolean checkSectionCreated(String section) {
        setExplicitWaitForElementToBeVisible(createdSectionHeading, 30);
        return createdSectionHeading.getText().trim().contains(section);
    }

    /**
     * Clicks the "Add Question to Header" button.
     */
    public void clickAddQuestionToHeader() {
        clickElement(AddQuestionToHeader);
    }

    /**
     * Adds a question to the form.
     *
     * @param question the question to add
     */
    public void AddQuestion(String question) {
        enterText(formLabel, question);
    }

    /**
     * Validates if the question is created.
     *
     * @param question the question to validate
     * @return true if the question is present, false otherwise
     */
    public Boolean validateCreatedQuestion(String question) {
        setExplicitWaitForElementToBeVisible(createdQuestionHeading, 30);
        return createdQuestionHeading.getText().trim().contains(question);
    }

    /**
     * Opens an existing form by its name.
     *
     * @param FormName the name of the form to open
     */
    public void openExistingForm(String FormName) {
        Boolean formOpened = null;
        WebElement form = driver.findElement(By.xpath("//div[@class='formPreviewTitle'][text()='" + FormName + "']"));
        if (checkFormExists(FormName)) {
            form.click();
            log.info("Opening " + FormName + " Existing Form");
            setExplicitWaitForElementToBeVisible(formLabel, 10);
            formOpened = formLabel.isDisplayed();
        }
        Assert.assertEquals(formOpened, true);
    }

    /**
     * Checks if a form exists by its name.
     *
     * @param FormName the name of the form to check
     * @return true if the form exists, false otherwise
     */
    public Boolean checkFormExists(String FormName) {
        WebElement form = driver.findElement(By.xpath("//div[@class='formPreviewTitle'][text()='" + FormName + "']"));
        js.executeScript("arguments[0].scrollIntoView();", form);
        setExplicitWaitForElementToBeVisible(form, 10);
        return form.isDisplayed();
    }

    /**
     * Deletes a form by its name.
     *
     * @param FormName the name of the form to delete
     */
    public void deleteForm(String FormName) {
        Boolean formDeleted = null;
        setExplicitWaitForElementToBeVisible(deleteButton, 30);
        if (deleteButton.isDisplayed()) {
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(saveButton, 20);
            saveButton.click();
        }
    }

    public void openAndDeleteForm(String FormName) {
        openForm(FormName);

        setExplicitWaitForElementToBeVisible(deleteButton, 30);
        if (deleteButton.isDisplayed()) {
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(saveButton, 20);
            saveButton.click();
        }
    }


    public void clickStapleForm(){
        setExplicitWaitForElementToBeVisible(stapleForm,30);
        stapleForm.click();
    }

    public boolean verifyDNDWarning()
    {
        setExplicitWaitForElementToBeVisible(donotDeleteWarning,30);
        String DNDWarning = donotDeleteWarning.getText();
        return DNDWarning.contains("This form still has stapled forms attached");

    }

    public void clickDeleteFormButton(){
        if (deleteButton.isDisplayed()) {
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(saveButton, 20);

        }

    }
    /**
     * Cancels the deletion of a form by its name.
     *
     * @param FormName the name of the form to cancel deletion
     */
    public void cancelDeleteForm(String FormName) {
        Boolean formDeleted = null;
        if (deleteButton.isDisplayed()) {
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(selectCancel, 20);
            selectCancel.click();
        }
        formDeleted = checkFormExists(FormName);
        Assert.assertEquals(formDeleted, true);
        log.info("Validating Form Not Deleted Successfully");
    }

    //div[@id='mergedForms']//following::div


    /**
     * Staples another form by its name.
     *
     * @param StapleOtherFormName the name of the form to staple
     */
    public void stapleForm(String StapleOtherFormName) throws InterruptedException {
        setExplicitWaitForElementToBeVisible(stapleForm, 20);
        stapleForm.click();
        setExplicitWaitForElementToBeVisible(mergeForm, 10);
        selectFormDropDown.click();
        Select dropDown = new Select(selectFormDropDown);
        dropDown.selectByVisibleText(StapleOtherFormName);
        saveButton.click();
        setExplicitWaitForElementToBeVisible(removeButton, 30);
        log.info("Stapling " + StapleOtherFormName);
        Boolean formStapled = mergeForm.getText().contains(StapleOtherFormName);
        dialogueCloseBtn.click();
        Assert.assertEquals(formStapled, true);
    }

    public void createForm(String inputFormName) {
        clickCreateForm(); // Click on the 'Create Form' button
        enterFormName(inputFormName); // Enter the form name
        enterDescription("Test-Description"); // Enter the form description
        clickSave(); // Click the 'Save' button
    }


    public boolean isFormDeleted(String formName) {
        String beforeXpath = "//table[@id='supplemental_forms']//tr[";
        String afterXpath = "]//a";
        boolean formDeleted = true;
        for (int i = 2; i < row.size(); i++) {
            String actFormName = driver.findElement(By.xpath(beforeXpath + i + afterXpath)).getText();
            if (actFormName.equals(formName)) {
                formDeleted = false;
                break;
            }

        }
        return formDeleted;
    }

    public void openForm(String formName) {
        driver.navigate().to(formsPageURL);
        String beforeXpath = "//table[@id='supplemental_forms']//tr[";
        String afterXpath = "]//a";
        for (int i = 2; i < row.size(); i++) {
            WebElement openForm = driver.findElement(By.xpath(beforeXpath + i + afterXpath));
            String actFormName = openForm.getText();
            if (actFormName.equals(formName)) {
                openForm.click();
                break;
            }

        }
    }

    public boolean checkFormDeleted(String expFormName){
        if (formTable.size() < 0){
            Assert.assertEquals(formTable.size() < 0,true);
            return true;
        }
        else{
        return isFormDeleted(expFormName);
                }
    }

    public void removeStapleForm(){
        stapleForm.click();
        setExplicitWaitForElementToBeVisible(removeButton,30);
        removeButton.click();
        setExplicitWaitForElementToBeVisible(mergeForm,10);
        setExplicitWaitForElementToBeVisible(dialogueCloseBtn,30);
        dialogueCloseBtn.click();
        setExplicitWaitForElementToBeVisible(stapleForm,30);
    }

    public boolean verifyStapleFormRemoved(){

        if(removeButton.isDisplayed())
        {
            return  true;
        }
        else
            return false;
    }

    public boolean verifyAlertMessage(){
        setExplicitWaitForAlert(30);
        // Switch to the alert
        Alert alert = driver.switchTo().alert();
        // Get the text of the alert
        String alertText = alert.getText();
        alert.accept();
        return alertText.contains("Please remove all stapled forms before deleting.");

    }


}
