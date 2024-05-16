package test.java.PageObjectClass;

import test.java.BaseMethods.BaseClass;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;


public class currentMethods_PageObjects extends BaseClass {

    WebDriver driver;

    public currentMethods_PageObjects(WebDriver driver){
        this.driver=driver;
        PageFactory.initElements(driver,this);
    }

    @FindBy(id="details-button")
    WebElement detailBtn;

    @FindBy(partialLinkText = "Proceed to localhost")
    WebElement proceedToLocalHost;

    @FindBy(xpath="/html/body/div[3]/div[2]/form/div/main/div[1]/div[1]/input")
    WebElement inputAdminCandidate;

    @FindBy(id="button_save")
    WebElement saveButton;

    @FindBy(partialLinkText="Gao, Michael")
    WebElement AddAdministrator;

    @FindBy(xpath="//a[@aria-label='REMOVE Gao, Michael']")
    WebElement removeAddedAdministrator;

    public void clickremoveAddedAdministrator() {
        highLightElement(driver, removeAddedAdministrator);
        clickElement(removeAddedAdministrator);
    }

    public void clickAddAdministrator() {
        highLightElement(driver, AddAdministrator);
        clickElement(AddAdministrator);
    }


    public void clickSaveButton() {
        highLightElement(driver, saveButton);
        clickElement(saveButton);
    }

    public void clickOnLocalHost() {
        highLightElement(driver, proceedToLocalHost);
        clickElement(proceedToLocalHost);
    }
    public void clickDetail() {
        highLightElement(driver, detailBtn);
        clickElement(detailBtn);
    }

    public void enterInputAdminCandidate(String value ){
        highLightElement(driver, inputAdminCandidate);
        Sendkeys(value,inputAdminCandidate);

    }
}
