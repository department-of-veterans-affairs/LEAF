//package main.java.pageActions;
//
//import main.java.Utils.BaseClass;
//import org.openqa.selenium.WebDriver;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.support.FindBy;
//import org.openqa.selenium.support.PageFactory;
//
//public class HomePage_PageObjects extends BaseClass {
//
//    WebDriver driver;
//
//    public HomePage_PageObjects(WebDriver driver){
//        this.driver=driver;
//        PageFactory.initElements(driver,this);
//    }
//
//    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[1]/span")
//    WebElement selectNewrequest;
//
//    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[2]/span")
//    WebElement selectInbox;
//
//    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[3]/span")
//    WebElement selectBookMarks;
//
//    @FindBy(xpath = "//*[@id=\"bodyarea\"]/div[1]/a[4]/span")
//    WebElement selectReportBuilder;
//
//    @FindBy(id = "searchContainer_getMoreResults")
//    WebElement shoMoreRecords;
//
//    @FindBy(css = "[title^='Enter your search text']")
//    WebElement EnterBasicSearchNumber;
//
//    @FindBy(id = "[title^='Enter your search text']")
//    WebElement searchText;
//
//    @FindBy(partialLinkText = "Admin Panel")
//    WebElement adminPanel;
//
//    @FindBy(id = "button_showHelp")
//    WebElement helpDropDown;
//
//    @FindBy(id = "button_showLinks")
//    WebElement linkDropdown;
//
//    public void linkDropdown() {
//        highLightElement(driver, linkDropdown);
//        clickElement(linkDropdown);
//    }
//
//    public void helpDropDown() {
//        highLightElement(driver, helpDropDown);
//        clickElement(helpDropDown);
//    }
//
//    public void adminPanel() {
//        highLightElement(driver, adminPanel);
//        clickElement(adminPanel);
//    }
//
//    public void SearchText(String value) {
//        highLightElement(driver, searchText);
//        Sendkeys(value,searchText);
//    }
//
//    public void clearSearch(){
//        highLightElement(driver,searchText);
//        searchText.clear();
//
//    }
//
//    public void EnterBasicSearchNumber(String Value) {
//        highLightElement(driver, EnterBasicSearchNumber);
//        Sendkeys(Value,EnterBasicSearchNumber);
//    }
//    public void shoMoreRecords() {
//        highLightElement(driver, shoMoreRecords);
//        clickElement(shoMoreRecords);
//    }
//
//    public void selectReportBuilder() {
//        highLightElement(driver, selectReportBuilder);
//        clickElement(selectReportBuilder);
//    }
//
//    public void setSelectNewrequest() {
//        highLightElement(driver, selectNewrequest);
//        clickElement(selectNewrequest);
//    }
//
//    public void selectInbox() {
//        highLightElement(driver, selectInbox);
//        clickElement(selectInbox);
//    }
//
//    public void selectBookMarks() {
//        highLightElement(driver, selectBookMarks);
//        clickElement(selectBookMarks);
//    }
//}
