package test.java.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

class AdminUserAccess_PageObjects extends BasePage {

    public AdminUserAccess_PageObjects(WebDriver driver){
       super(driver);
    }

    @FindBy (id = "details-button")
    WebElement detailsButton;

    @FindBy(partialLinkText = "Proceed to localhost")
    WebElement proceedToLocalhost;

    @FindBy(linkText = "Home")
    WebElement home;

    @FindBy(linkText = "Report Builder")
    WebElement reportBuilder;

    @FindBy(linkText = "Site Links")
    WebElement siteLinks;

    @FindBy(linkText = "Admin")
    WebElement admin;

    @FindBy(linkText = "Admin Home")
    WebElement adminHome;

    @FindBy(id = "userGroupSearch")
    WebElement userGroupSearch;

    @FindBy(id = "1")
    WebElement sysAdmin;

    @FindBy(css = "#xhr > button")
    WebElement history;

    @FindBy(xpath = "/html/body/div[4]/div[1]/button/span[1]n")
    WebElement closeHistory;

    @FindBy(id = "button_cancelchange")
    WebElement closePopUp;



}
