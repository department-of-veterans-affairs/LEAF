//package main.java.pageActions;
//
//import main.java.Utils.BaseClass;
////import test.java.BaseMethods.BaseClass;
//import org.openqa.selenium.By;
//import org.openqa.selenium.WebDriver;
//import org.openqa.selenium.WebElement;
//import org.openqa.selenium.support.FindBy;
//import org.openqa.selenium.support.PageFactory;
//import org.openqa.selenium.support.ui.ExpectedConditions;
//import org.openqa.selenium.support.ui.WebDriverWait;
//
//import java.time.Duration;
//
//public class adminTest_PageActions extends BaseClass {
//
//   private WebDriver driver;
//
//    public adminTest_PageActions(WebDriver driver){
//        this.driver=driver;
//        PageFactory.initElements(driver,this);
//    }
//
//    @FindBy(id="details-button")
//    WebElement detailBtn;
//
//    @FindBy(linkText="Home")
//    WebElement homeLink;
//
//    public By homePage = By.linkText("Home");
//
//    @FindBy(linkText="Report Builder")
//    WebElement reportBuilder1;
//
//    public By reportBuilder = By.linkText("Report Builder");
//
//
//    @FindBy(linkText="Site Links")
//    WebElement siteLinks;
//
//    @FindBy(linkText="Admin")
//    WebElement admin;
//
//    @FindBy(linkText="Admin Home")
//    WebElement adminHome;
//
//    @FindBy(xpath="//*[@id=\"bodyarea\"]/div/a[1]/span[1]")
//    WebElement adminUserAccessGroup;
//
//    @FindBy(partialLinkText="User Access Groups")
//    WebElement userAccessGroups;
//
//    @FindBy(linkText="Service Chiefs")
//    WebElement serviceChiefs;
//
//    @FindBy(linkText="Workflow Editor")
//    WebElement workflowEditor;
//
//    @FindBy(linkText="Form Editor")
//    WebElement formEditor;
//
//    @FindBy(linkText="Use a form made by the LEAF community")
//    WebElement formByLEAFcommunity;
//
//    @FindBy(linkText="Site Settings")
//    WebElement siteSettings;
//
//    @FindBy(linkText="Create custom reports")
//    WebElement createCustomReports;
//
//    @FindBy(linkText="Timeline Explorer")
//    WebElement timelineExplorer;
//
//    @FindBy(linkText="Template Editor")
//    WebElement templateEditor;
//
//    @FindBy(linkText="Email Template Editor")
//    WebElement emailTemplateEditor;
//
//    @FindBy(linkText="LEAF Programmer")
//    WebElement LEAFProgrammer;
//
//    @FindBy(linkText="File Manager")
//    WebElement fileManager;
//
//    @FindBy(linkText="Search Database")
//    WebElement searchDatabase;
//
//    @FindBy(linkText="Sync Services")
//    WebElement syncServices;
//
//    @FindBy(linkText="Update Database")
//    WebElement updateDatabase;
//
//    @FindBy(linkText="Import Spreadsheet")
//    WebElement importSpreadsheet;
//
//    @FindBy(linkText="Mass Actions")
//    WebElement massActions;
//
//    @FindBy(linkText="Initiator New Account")
//    WebElement initiatorNewAccount;
//
//    @FindBy(linkText="Sitemap Editor")
//    WebElement sitemapEditor;
//
//
//
//    public void clickDetail() {
//        WebDriverWait wait = new WebDriverWait(driver, Duration.ofMillis(100));
//        WebElement detailsButton = wait.until(ExpectedConditions.elementToBeClickable(detailBtn));
//        detailsButton.click();
//        //  highLightElement(driver, detailBtn);
//       // clickElement(detailBtn);
//    }
//
//    public void clickHome() {
//
//        WebElement element = driver.findElement(homePage);
//        element.click();
//    }
//
//    public void clickReportBuilder() {
//        WebElement reportBuilderElement = driver.findElement(reportBuilder);
//        highLightElement(driver, reportBuilderElement);
//        clickElement(reportBuilderElement);
//    }
//
//    public void clickSiteLinks() {
//        highLightElement(driver, siteLinks);
//        clickElement(siteLinks);
//    }
//
//    public void clickAdmin() {
//        highLightElement(driver, admin);
//        clickElement(admin);
//    }
//
//    public void clickAdminHome() {
//        highLightElement(driver, adminHome);
//        clickElement(adminHome);
//    }
//
//    public void clickAdminUserAccessGroup() {
//        clickElement(adminUserAccessGroup);
//    }
//
//    public void clickUserAccessGroups() {
//        highLightElement(driver, userAccessGroups);
//        clickElement(userAccessGroups);
//    }
//
//    public void clickServiceChiefs() {
//        highLightElement(driver, serviceChiefs);
//        clickElement(serviceChiefs);
//    }
//
//    public void clickWorkflowEditor() {
//        highLightElement(driver, workflowEditor);
//        clickElement(workflowEditor);
//    }
//
//    public void clickFormEditor() {
//        highLightElement(driver, formEditor);
//        clickElement(formEditor);
//    }
//
//    public void clickFormByLEAFcommunity() {
//        highLightElement(driver, formByLEAFcommunity);
//        clickElement(formByLEAFcommunity);
//    }
//
//    public void clickSiteSettings() {
//        highLightElement(driver, siteSettings);
//        clickElement(siteSettings);
//    }
//
//    public void clickCreateCustomReports() {
//        highLightElement(driver, createCustomReports);
//        clickElement(createCustomReports);
//    }
//
//    public void clickTimelineExplorer() {
//        highLightElement(driver, timelineExplorer);
//        clickElement(timelineExplorer);
//    }
//
//    public void clickTemplateEditor() {
//        highLightElement(driver, templateEditor);
//        clickElement(templateEditor);
//    }
//
//    public void clickEmailTemplateEditor() {
//        highLightElement(driver, emailTemplateEditor);
//        clickElement(emailTemplateEditor);
//    }
//
//    public void clickLEAFProgrammer() {
//        highLightElement(driver, LEAFProgrammer);
//        clickElement(LEAFProgrammer);
//    }
//
//    public void clickFileManager() {
//        highLightElement(driver, fileManager);
//        clickElement(fileManager);
//    }
//
//    public void clickSearchDatabase() {
//        highLightElement(driver, searchDatabase);
//        clickElement(searchDatabase);
//    }
//
//    public void clickSyncServices() {
//        highLightElement(driver, syncServices);
//        clickElement(syncServices);
//    }
//
//    public void clickUpdateDatabase() {
//        highLightElement(driver, updateDatabase);
//        clickElement(updateDatabase);
//    }
//
//    public void clickImportSpreadsheet() {
//        highLightElement(driver, importSpreadsheet);
//        clickElement(importSpreadsheet);
//    }
//
//    public void clickMassActions() {
//        highLightElement(driver, massActions);
//        clickElement(massActions);
//    }
//
//    public void clickInitiatorNewAccount() {
//        highLightElement(driver, initiatorNewAccount);
//        clickElement(initiatorNewAccount);
//    }
//
//    public void clickSitemapEditor() {
//        highLightElement(driver, sitemapEditor);
//        clickElement(sitemapEditor);
//    }
//
//
//}
