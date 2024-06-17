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


    public FormEditorPageActions(WebDriver driver) {
      super(driver);
    }


    public void createForm(String FormName, String FormDescription) {
        setExplicitWaitForElementToBeVisible(createForm,10);
        createForm.click();
        setExplicitWaitForElementToBeVisible(formLabel,10);
        formLabel.sendKeys(FormName);
        setExplicitWaitForElementToBeVisible(formDescription,10);
        formDescription.sendKeys(FormDescription);
        saveButton.click();
        log.info("Form Created Successfully");
        WebElement form = driver.findElement(By.xpath("//b[text()='"+FormName+"']"));
        setExplicitWaitForElementToBeVisible(form,10 );
        Boolean formCreated = form.isDisplayed();
        Assert.assertEquals(formCreated, true);
        log.info("Validating Form Created Successfully");
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
