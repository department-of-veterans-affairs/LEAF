package main.pageActions;

import main.Base.BasePage;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;

public class HomePageActions extends BasePage {

    public HomePageActions(){
        super();
        PageFactory.initElements(driver,this);
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
