package main.java.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class HomePageActions extends BasePage {

    public HomePageActions(WebDriver driver){
        super(driver);
    }

    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[1]/span")
    WebElement selectNewrequest;

    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[2]/span")
    WebElement selectInbox;

    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[3]/span")
    WebElement selectBookMarks;

    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[4]/span")
    WebElement selectReportBuilder;

    @FindBy(id = "searchContainer_getMoreResults")
    WebElement shoMoreRecords;

    @FindBy(css = "[title^='Enter your search text']")
    WebElement EnterBasicSearchNumber;

    @FindBy(id = "[title^='Enter your search text']")
    WebElement searchText;

    @FindBy(partialLinkText = "Admin Panel")
    WebElement adminPanel;

    @FindBy(id = "button_showHelp")
    WebElement helpDropDown;

    @FindBy(id = "button_showLinks")
    WebElement linkDropdown;



}
