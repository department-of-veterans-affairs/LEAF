package main.java.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

import java.util.List;

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

    @FindBy(xpath = "//a[@title='nav to homepage']")
    WebElement mainPage;
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

    @FindBy(id = "step1_questions")
    WebElement generalInformationCard;

    @FindBy(xpath = "//input[@id='title']")
    WebElement requestTitleInput;

    @FindBy(xpath = "//span[@class='leaf_check']")
    WebElement formRequestCheckbox;

    @FindBy(xpath = "//label[@class='checkable leaf_check']")
    WebElement formRequestCheckboxText;

    @FindBy(xpath = "//*[@id=\"record\"]/section[2]/div/button/img")
    WebElement proceedButton;

    @FindBy(xpath = "//div//span//input")
    WebElement inputAnswerBox;

    @FindBy(id = "nextQuestion2")
    WebElement nextQuestionButton;

    @FindBy(xpath = "//button[@title=\'Submit Form\']")
    WebElement submitFormButton;

    @FindBy(xpath = "//span[@class='printResponse']")
    WebElement finalAnswer;

    @FindBy(xpath = "//tbody/tr/td[2]/a")
    List<WebElement> formGridTitle;

    @FindBy(xpath = "//tbody/tr/td[4]")
    WebElement formGridStatus;

    @FindBy(xpath = "//span[@class='printResponse']")
    WebElement name;


    public  boolean verifyQuestionAnswered(String requestTitle) throws InterruptedException {
        setExplicitWaitForElementToBeVisible(selectNewrequest,30);
        selectNewrequest.click();
        setExplicitWaitForElementToBeClickable(requestTitleInput, 30);
        requestTitleInput.sendKeys(requestTitle);
        formRequestCheckbox.click();
        proceedButton.click();
        setExplicitWaitForElementToBeVisible(inputAnswerBox,30);
        inputAnswerBox.sendKeys("Tester");
        nextQuestionButton.click();
        Thread.sleep(10000);
        return (name.getText().equals("Tester"));
     //   submitFormButton.click();


    }


    public  boolean verifyRequestCreated(String requestTitle) throws InterruptedException {
        submitFormButton.click();
        boolean isRequestCreated = false;
     mainPage.click();
      Thread.sleep(10000);
       for(WebElement title : formGridTitle) {
           if (title.getText().equals(requestTitle)) {
               isRequestCreated = true;
               break;
           }
       }
           return isRequestCreated;


       }
}
