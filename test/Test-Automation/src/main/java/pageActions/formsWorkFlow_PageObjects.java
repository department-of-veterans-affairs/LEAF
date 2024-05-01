package main.java.pageActions;

import test.java.BaseMethods.BaseClass;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;

public class formsWorkFlow_PageObjects extends BaseClass {

    WebDriver driver;

    public formsWorkFlow_PageObjects(WebDriver driver){
        this.driver=driver;
        PageFactory.initElements(driver,this);
    }

    @FindBy(id = "createFormButton")
    WebElement createForm;

    @FindBy(id = "name")
    WebElement name;

    @FindBy(id = "description")
    WebElement description;

    @FindBy(xpath ="//*[contains(text(),' Delete this form')]")
    WebElement deleteButton;

    @FindBy(id ="confirm_button_save")
    WebElement confirmDeleteButton;

    @FindBy(id ="button_cancelchange")
    WebElement selectCancel;

    public void Click_selectButton(){
        highLightElement(driver,selectCancel);
        clickElement(selectCancel);
    }

    public void ClickConfirm_Delete(){
        highLightElement(driver,confirmDeleteButton);
        clickElement(confirmDeleteButton);
    }

    public void clickDeleteButton(){
        highLightElement(driver,deleteButton);
        clickElement(deleteButton);
    }

    public void Enterdescription(String value){
        highLightElement(driver, description);
        Sendkeys(value,description);

    }

    public void clickOnCreateButton() {
        highLightElement(driver, createForm);
        clickElement(createForm);
    }

    public void EnterName(String value){
        highLightElement(driver, name);
        Sendkeys(value,name);

    }
}
