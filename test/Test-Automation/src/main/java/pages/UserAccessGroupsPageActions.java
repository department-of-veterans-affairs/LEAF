package main.java.pages;

import org.openqa.selenium.WebDriver;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

import java.util.List;

public class UserAccessGroupsPageActions  extends BasePage {

    /**
     * Instantiates a new base page.
     *
     * @param driver the driver
     */
    public UserAccessGroupsPageActions(WebDriver driver) {
        super(driver);
    }

    @FindBy(xpath ="//button[contains(text(),'Create group')]")
    WebElement createGroupButton;

    @FindBy(xpath ="//button[contains(text(),'Import group')]")
    WebElement importGroupButton;

    @FindBy(xpath = "//input[@aria-label='Search for user to add as ']")
    WebElement importGroupTitle;

    @FindBy(id = "button_import")
    WebElement buttonImport;

    @FindBy(xpath ="//button[contains(text(),'Show group History')]")
    WebElement showGroupHistoryButton;

    @FindBy(id ="allGroupsLink")
    WebElement allGroupsLink;

    @FindBy(id ="sysAdminsLink")
    WebElement systemGroupsLink;

    @FindBy(id ="userGroupsLink")
    WebElement userGroupsLink;

    @FindBy(id ="userGroups")
    WebElement userGroupsHeading;

    @FindBy(id ="userGroupSearch")
    WebElement userGroupsSearch;

    @FindBy(id ="groupNameInput")
    WebElement groupNameInput;

    @FindBy(id ="button_save")
    WebElement saveButton;

    @FindBy(id ="button_cancelchange")
    WebElement cancelButton;

    @FindBy(id ="confirm_button_save")
    WebElement confirmButton;

    @FindBy(id ="confirm_button_cancelchange")
    WebElement cancelConfirmButton;

    @FindBy(xpath ="//button[contains(text(),'Delete Group')]")
    WebElement deleteGroupButton;


    @FindBy(xpath ="//button[contains(text(),'View History')]")
    WebElement viewHistoryButton;

    @FindBy(id = "groupList")
    WebElement userGroupBox;

    @FindBy(id = "groupList")
    WebElement userGroupList;

    @FindBy(xpath ="//span[contains(text(),'Group history')]")
    WebElement groupHistoryWidget;

    @FindBy(id = "historyName")
    WebElement historyName;

    @FindBy(xpath ="//span[contains(text(),'Group history')]/following-sibling::button")
    WebElement widgetCancelButton;

    @FindBy(xpath ="//div[@id='groupList']//h2[@class='groupName']")
    List<WebElement> groupList;

    @FindBy(xpath = "//input[@class='employeeSelectorInput']")
    WebElement searchEmployeeInput;

    @FindBy(id= "empSel908_result")
    WebElement employeeSearchResult;

    @FindBy(xpath = "//div[@id='empSel908_result']//tr[@class='employeeSelector']")
    List<WebElement> employeeSelector;

    @FindBy(xpath = "//div[@aria-label='search results']//tbody//td[@class='employeeSelectorName']")
    List<WebElement> employeeSelectorName;

    @FindBy(xpath = "//div[@aria-label='search results']//tbody//td[@class='employeeSelectorContact']")
    List<WebElement> employeeSelectorContact;

    @FindBy(id = "employee_table")
    WebElement employeeTable;

    @FindBy(xpath = "//div[@id='employee_table']//tr[2]//td[1]//a[1]")
    WebElement employeeName;

    @FindBy(xpath = "//div[@id='employee_table']//tr[2]//td[2]//a[1]")
    WebElement employeeUserName;

    @FindBy(xpath = "//div[@aria-label='search results']")
    WebElement emp_result_table;


    @FindBy(xpath = "//div[@class='groupMemberList']//div[@class='groupUserFirst']")
    WebElement employeeInGroupList;

    @FindBy(xpath = "//i[@class='fas fa-exclamation-circle']//parent::p")
    WebElement notFoundMessage;

    public boolean messageNotFound() throws InterruptedException {
        String expectedMessage = "No matching groups or users found.";
        String actualMessage ;
        userGroupsSearch.sendKeys("invalid test");
        Thread.sleep(5000);
        setExplicitWaitForElementToBeVisible(notFoundMessage,30);

        actualMessage = notFoundMessage.getText();
        return expectedMessage.equals(actualMessage);

    }

    public boolean addEmployee(String employeeName, String groupName) {
        if (getUserGroupList.isDisplayed()) {
            String actGroupName;
            for (int i = 0; i < groupList.size(); i++) {
                actGroupName = groupList.get(i).getText();
                System.out.println("actGroupName: " + actGroupName);
                if (groupName.equals(actGroupName.trim())) {
                    groupList.get(i).click();
                    setExplicitWaitForElementToBeVisible(deleteGroupButton, 30);
                    searchEmployeeInput.sendKeys(employeeName);
                    setExplicitWaitForElementToBeVisible(emp_result_table,30);


                }

            }


        }
        return emp_result_table.isDisplayed();
    }

    public boolean selectEmployee(String employeeName, String groupName) {
        if (emp_result_table.isDisplayed()) {
            for (int i = 0; i < employeeSelectorName.size(); i++) {
                if (employeeSelectorName.get(i).getText().contains(employeeName)) {

                    emp_result_table.click();
                    setExplicitWaitForElementToBeVisible(employeeTable,50);
                }
            }
        }
        return employeeTable.isDisplayed();
    }

    public boolean verifySelectedEmployee(String expEmployeeName, String groupName) {
    setExplicitWaitForElementToBeVisible(employeeName,30);
       String actEmployeeName = employeeName.getText();

        return actEmployeeName.equals(expEmployeeName);
    }

    public boolean verifyEmployeeAdded(String expEmployeeName, String expGroupName) throws InterruptedException {
        saveButton.click();

        String actEmployeeName = "";
        for (int i = 0; i< groupList.size(); i++){
            String actGroupName = groupList.get(i).getText();

            if(expGroupName.equals(actGroupName.trim())) {
               actEmployeeName = groupList.get(i).findElement(By.xpath("//following-sibling::div//div[@class='groupUserFirst']")).getText();
                break;
            }

        }

        return actEmployeeName.equals(expEmployeeName);
    }

    @FindBy(xpath = "//div[@id=\"groupList\"]//*[contains(@class,\"groupName\")]")
    WebElement getUserGroupList;

    public void createGroup(String inputGroupName) throws InterruptedException {
        setExplicitWaitForElementToBeVisible(createGroupButton,30 );
        createGroupButton.click();
        setExplicitWaitForElementToBeVisible(groupNameInput,30 );
        groupNameInput.sendKeys(inputGroupName);
        saveButton.click();
        Thread.sleep(10000);
        setExplicitWaitForElementToBeVisible(createGroupButton,30 );
    }

    public Boolean verifyGroupCreate(String expGroupName) {
        setExplicitWaitForElementToBeVisible(getUserGroupList,30 );
        boolean groupExists = false;

        for(int i = 0; i<groupList.size(); i++){
            String actGroupName = groupList.get(i).getText();
            System.out.println("actGroupName: " +actGroupName);
            if(expGroupName.equals(actGroupName.trim())) {
                groupExists = true;
                break;
            }

        }

        return groupExists;
    }


    public void deleteGroup(String groupName) {
        String actGroupName = "";
        if (getUserGroupList.isDisplayed()) {
            for (int i = 0; i < groupList.size(); i++) {
                actGroupName = groupList.get(i).getText();
                System.out.println("actGroupName: " + actGroupName);
                if (groupName.equals(actGroupName.trim())) {
                    groupList.get(i).click();
                    setExplicitWaitForElementToBeVisible(deleteGroupButton, 30);
                    deleteGroupButton.click();
                    setExplicitWaitForElementToBeVisible(confirmButton, 30);
                    confirmButton.click();
                    break;
                }

            }
        }
    }

    public boolean importGroup(String groupName){
        importGroupButton.click();
        setExplicitWaitForElementToBeVisible(buttonImport,30);
        importGroupTitle.clear();
        importGroupTitle.sendKeys(groupName);
        buttonImport.click();
        boolean groupExists = false;

        for(int i = 0; i<groupList.size(); i++){
            String actGroupName = groupList.get(i).getText();
            System.out.println("actGroupName: " +actGroupName);
            if(groupName.equals(actGroupName.trim())) {
                groupExists = true;
                break;
            }
        }
        return groupExists;



    }

        public boolean verifyGroupDeleted(String groupName) throws InterruptedException {
            setExplicitWaitForElementToBeVisible(userGroupsHeading, 30);
            String actGroupName = "";
            boolean groupDeleted = true;
            setExplicitWaitForElementToBeVisible(getUserGroupList,30);
            Thread.sleep(5000);
            if (getUserGroupList.isDisplayed()) {
                for (int i = 0; i < groupList.size(); i++) {
                    actGroupName = groupList.get(i).getText();
                    System.out.println("actGroupName: " + actGroupName);
                    if (groupName.equals(actGroupName.trim())) {
                        groupDeleted = false;
                        break;
                    }

                }

            }
            return groupDeleted;
        }
    public String verifyViewHistory(String groupName){
        setExplicitWaitForElementToBeVisible(userGroupBox, 30);
        String actGroupName = "";
        String historyGroupName ="";
        if (getUserGroupList.isDisplayed()) {
            for (int i = 0; i < groupList.size(); i++) {
                actGroupName = groupList.get(i).getText();
                System.out.println("actGroupName: " + actGroupName);
                if (groupName.equals(actGroupName.trim())) {
                  groupList.get(i).click();

                    setExplicitWaitForElementToBeVisible(viewHistoryButton, 30);
                    viewHistoryButton.click();
                    setExplicitWaitForElementToBeVisible(historyName, 30);

                    historyGroupName = historyName.getText();
                    widgetCancelButton.click();
                    setExplicitWaitForElementToBeVisible(cancelButton, 30);
                    cancelButton.click();

                }

            }

        }
        return historyGroupName;
    }



}