package main.pageActions;

import main.Base.BasePage;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;

public class formsWorkFlow_PageObjects extends BasePage {

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

  }
