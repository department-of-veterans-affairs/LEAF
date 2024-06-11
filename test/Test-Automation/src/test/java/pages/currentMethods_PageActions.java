package test.java.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;


public class currentMethods_PageActions extends BasePage {

    WebDriver driver;

    public currentMethods_PageActions(WebDriver driver){
      super(driver);
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

}
