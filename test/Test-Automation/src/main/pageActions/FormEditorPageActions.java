package main.pageActions;

import main.Base.BasePage;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;
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

    @FindBy(id ="button_cancelchange")
    WebElement selectCancel;


    public FormEditorPageActions() {
        PageFactory.initElements(driver, this);
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

    public void deleteForm(String FormName) {
        Boolean formDeleted = null;
        if(deleteButton.isDisplayed()==false){
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(confirmDeleteButton,20 );
            confirmDeleteButton.click();
            WebElement form = driver.findElement(By.xpath("//div[@class='formPreviewTitle'][text()='"+FormName+"']"));
            formDeleted = js.executeScript("arguments[0].scrollIntoView();", form).equals(false);
           }
        else if(createForm.isDisplayed() == true){
            WebElement form = driver.findElement(By.xpath("//div[@class='formPreviewTitle'][text()='"+FormName+"']"));
            js.executeScript("arguments[0].scrollIntoView();", form);
            form.click();
            log.info("Selecting form to delete");
            setExplicitWaitForElementToBeVisible(deleteButton,20 );
            deleteButton.click();
            setExplicitWaitForElementToBeVisible(confirmDeleteButton,20 );
            confirmDeleteButton.click();
            js.executeScript("arguments[0].scrollIntoView();", form);
            formDeleted = form.isDisplayed();
            log.info("Form Deleted Successfully");
            js.executeScript("arguments[0].scrollIntoView();", form);
        }
        Assert.assertEquals(formDeleted, false);
        log.info("Validating Form Deleted Successfully");
    }

}
