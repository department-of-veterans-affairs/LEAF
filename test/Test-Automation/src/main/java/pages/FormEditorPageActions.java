package main.java.pages;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.Select;
import org.testng.Assert;

/**
 * This class contains actions related to the Form Editor page.
 * It extends the BasePage class to utilize common page functionalities.
 */
public class FormEditorPageActions extends BasePage {

    private static final Logger log = LogManager.getLogger(FormEditorPageActions.class);

    // Web elements on the Form Editor page
    @FindBy(id = "createFormButton")
    WebElement createForm;

    @FindBy(id = "name")
    WebElement formLabel;

    @FindBy(id = "description")
    WebElement formDescription;

    @FindBy(xpath = "//div[contains(text(),' Delete this form')]")
    WebElement deleteButton;

    @FindBy(id = "confirm_saveBtnText")
    WebElement confirmDeleteButton;

    @FindBy(id = "button_save")
    WebElement saveButton;

    @FindBy(id = "confirm_button_cancelchange")
    WebElement selectCancel;

    @FindBy(xpath = "//*[text()=' Staple other form']")
    WebElement stapleForm;

    @FindBy(id = "mergedForms")
    WebElement mergeForm;

    @FindBy(id = "stapledCategoryID")
    WebElement formOptions;

    @FindBy(xpath = "//span[@id='ui-id-3']//following::span[1]")
    WebElement dialogueCloseBtn;

    @FindBy(xpath = "//button[contains(@id,'main_form_form')]//span[2]")
    WebElement Form;

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

    /**
     * Constructor for FormEditorPageActions.
     *
     * @param driver the WebDriver instance
     */
    public FormEditorPageActions(WebDriver driver) {
        super(driver);
    }

    /**
     * Clicks the "Create Form" button.
     */
    public void clickCreateForm() {
        clickElement(createForm);
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
        clickElement(saveButton);
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
        if (deleteButton.isDisplayed()) {
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(confirmDeleteButton, 20);
            confirmDeleteButton.click();
        }
        formDeleted = checkFormExists(FormName);
        Assert.assertEquals(formDeleted, true);
        log.info("Validating Form Deleted Successfully");
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

    /**
     * Staples another form by its name.
     *
     * @param StapleOtherFormName the name of the form to staple
     */
    public void stapleForm(String StapleOtherFormName) {
        setExplicitWaitForElementToBeVisible(stapleForm, 20);
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
