//package main.java.pageActions;
//
//import test.java.BaseMethods.BaseClass;
//import org.openqa.selenium.By;
//import org.openqa.selenium.WebDriver;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.support.FindBy;
//import org.openqa.selenium.support.PageFactory;
//
//class AdminUserAccess_PageObjects extends BaseClass {
//    WebDriver driver;
//
//    public AdminUserAccess_PageObjects(WebDriver driver){
//        this.driver = driver;
//        PageFactory.initElements(driver,this);
//    }
//
//    @FindBy (id = "details-button")
//    WebElement detailsButton;
//
//    @FindBy(partialLinkText = "Proceed to localhost")
//    WebElement proceedToLocalhost;
//
//    @FindBy(linkText = "Home")
//    WebElement home;
//
//    @FindBy(linkText = "Report Builder")
//    WebElement reportBuilder;
//
//    @FindBy(linkText = "Site Links")
//    WebElement siteLinks;
//
//    @FindBy(linkText = "Admin")
//    WebElement admin;
//
//    @FindBy(linkText = "Admin Home")
//    WebElement adminHome;
//
//    @FindBy(id = "userGroupSearch")
//    WebElement userGroupSearch;
//
//    @FindBy(id = "1")
//    WebElement sysAdmin;
//
//    @FindBy(css = "#xhr > button")
//    WebElement history;
//
//    @FindBy(xpath = "/html/body/div[4]/div[1]/button/span[1]n")
//    WebElement closeHistory;
//
//    @FindBy(id = "button_cancelchange")
//    WebElement closePopUp;
//
//
//    public void clickOnCloseHistory() {
//        highLightElement(driver, closeHistory);
//        clickElement(closeHistory);
//    }
//
//    public void clickOnClosePopUP() {
//        highLightElement(driver, closePopUp);
//        clickElement(closePopUp);
//    }
//
//    public void enterValueOnuserGroupSearch(String value) {
//        highLightElement(driver, userGroupSearch);
//        Sendkeys(value,userGroupSearch);
//    }
//
//    public void clearuserGroupSearch(){
//        clear(userGroupSearch);
//    }
//
//    public WebElement userGroupSearch() {
//        WebElement ele = driver.findElement(By.id("userGroupSearch"));
//
//        return ele;
//    }
//
//    public void clickOnuserGroupSearch() {
//        highLightElement(driver, userGroupSearch);
//        clickElement(userGroupSearch);
//    }
//
//    public void clickOnHistory() {
//        highLightElement(driver, history);
//        clickElement(history);
//    }
//
//    public void clicksysAdmin() {
//        highLightElement(driver, sysAdmin);
//        clickElement(sysAdmin);
//    }
//
//    public void clickOnAdmin() {
//        highLightElement(driver, admin);
//        clickElement(admin);
//    }
//
//    public void clickOnadminHome() {
//        highLightElement(driver, adminHome);
//        clickElement(adminHome);
//    }
//    public void clickOnSiteLinks() {
//        highLightElement(driver, siteLinks);
//        clickElement(siteLinks);
//    }
//
//    public void clickOnReportBuilder() {
//        highLightElement(driver, reportBuilder);
//        clickElement(reportBuilder);
//    }
//
//    public void clickOnHome() {
//        highLightElement(driver, home);
//        clickElement(home);
//    }
//
//    public void clickOnDetailsButton() {
//        highLightElement(driver, detailsButton);
//        clickElement(detailsButton);
//    }
//
//    public void  proceedToLocalhost() {
//        highLightElement(driver, proceedToLocalhost);
//        clickElement(proceedToLocalhost);
//    }
//
//
//}
