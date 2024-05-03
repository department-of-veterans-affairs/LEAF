package main.pageActions;

import main.Base.BasePage;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;

public class adminPage_Actions extends BasePage {


    public adminPage_Actions(){
        PageFactory.initElements(driver,this);
    }

    @FindBy(linkText="Home")
    WebElement homePageBtn;

    @FindBy(linkText="Report Builder")
    WebElement reportBuilderBtn;

    @FindBy(linkText="Site Links")
    WebElement siteLinksBtn;

    @FindBy(linkText="Admin")
    WebElement adminBtn;

    @FindBy(linkText="Admin Home")
    WebElement adminHomeBtn;

    @FindBy(xpath="//span[text()='User Access Groups']")
    WebElement adminUserAccessGroupIcon;

    @FindBy(xpath="//span[text()='Service Chiefs']")
    WebElement serviceChiefsIcon;

    @FindBy(linkText="Workflow Editor")
    WebElement workflowEditor;

    @FindBy(linkText="Form Editor")
    WebElement formEditor;

    @FindBy(linkText="Use a form made by the LEAF community")
    WebElement formByLEAFcommunity;

    @FindBy(linkText="Site Settings")
    WebElement siteSettings;

    @FindBy(linkText="Create custom reports")
    WebElement createCustomReports;

    @FindBy(linkText="Timeline Explorer")
    WebElement timelineExplorer;

    @FindBy(linkText="Template Editor")
    WebElement templateEditor;

    @FindBy(linkText="Email Template Editor")
    WebElement emailTemplateEditor;

    @FindBy(linkText="LEAF Programmer")
    WebElement LEAFProgrammer;

    @FindBy(linkText="File Manager")
    WebElement fileManager;

    @FindBy(linkText="Search Database")
    WebElement searchDatabase;

    @FindBy(linkText="Sync Services")
    WebElement syncServices;

    @FindBy(linkText="Update Database")
    WebElement updateDatabase;

    @FindBy(linkText="Import Spreadsheet")
    WebElement importSpreadsheet;

    @FindBy(linkText="Mass Actions")
    WebElement massActions;

    @FindBy(linkText="Initiator New Account")
    WebElement initiatorNewAccount;

    @FindBy(linkText="Sitemap Editor")
    WebElement sitemapEditor;


    public HomePageActions clickHome(){
     setExplicitWaitForElementToBeClickable(homePageBtn,30);
     homePageBtn.click();
     return new HomePageActions();
    }

    public ReportBuilderPageActions clickReportBuilder(){
     setExplicitWaitForElementToBeClickable(reportBuilderBtn,30);
     reportBuilderBtn.click();
     return new ReportBuilderPageActions();
    }

    public UserAccessGroupsPageActions clickUserAccessGroups(){
     setExplicitWaitForElementToBeClickable(adminUserAccessGroupIcon,30);
     adminUserAccessGroupIcon.click();
     return new UserAccessGroupsPageActions();
    }

    public ServiceChiefsPageActions clickServiceChiefs(){
     setExplicitWaitForElementToBeClickable(serviceChiefsIcon,30);
     serviceChiefsIcon.click();
     return new ServiceChiefsPageActions();
    }



}


